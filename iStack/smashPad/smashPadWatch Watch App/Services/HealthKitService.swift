//
//  HealthKitService.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import Foundation
import HealthKit
import CoreMotion
import Combine

class HealthKitService: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private let motionActivityManager = CMMotionActivityManager()
    private var activeHeartRateQuery: HKQuery?
    
    @Published var isAuthorized = false
    @Published var currentHeartRate: Double = 0.0
    @Published var isSessionActive = false
    @Published var restingHeartRate: Double = 75.0 // Default fallback value
    @Published var isPaused = false
    
    @Published var isStationary: Bool = true
    private var thresholdStartTime: Date?
    
    private override init() {
        super.init()
        _ = ConnectivityManager.shared
    }
    
    func requestAuthorization() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        let typesToRead: Set<HKObjectType> = [hrType, rhrType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                self.isAuthorized = success
                
                if success {
                    self.fetchRestingHeartRate()
                }
            }
        }
    }
    
    // MARK: - Fetch Resting Heart Rate
    private func fetchRestingHeartRate() {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: oneWeekAgo,
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: rhrType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, _ in
            
            DispatchQueue.main.async {
                
                if let average = result?.averageQuantity() {
                    
                    let rhr = average.doubleValue(for: HKUnit(from: "count/min"))
                    
                    self.restingHeartRate = rhr
                    
                    ConnectivityManager.shared.sendRestingHeartRate(rhr)
                    
                    print("✅ Resting HR: \(rhr) BPM")
                    
                } else {
                    
                    self.restingHeartRate = 75
                    
                    ConnectivityManager.shared.sendRestingHeartRate(75)
                    
                    print("⚠️ No Resting HR found. Using 75 BPM.")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Session Control (FIXED: Separated into Start and Stop for iPhone Control)
    func startSession() {
        guard !isSessionActive else { return }
        guard workoutSession == nil else { return }
        
        isPaused = false
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .mindAndBody
        configuration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: Date())
            
            startHeartRateQuery()
            startMotionTracking()
            
            isSessionActive = true
            
            ConnectivityManager.shared.sendSessionSync(isActive: true)
            
            print("⌚️ Session Started")
            
        } catch {
            
            print("❌ \(error.localizedDescription)")
        }
    }
    
    func stopSession() {
        
        guard isSessionActive else { return }
        
        workoutSession?.end()
        workoutSession = nil
        
        motionActivityManager.stopActivityUpdates()
        
        if let query = activeHeartRateQuery {
            healthStore.stop(query)
            activeHeartRateQuery = nil
        }
        
        currentHeartRate = 0
        isPaused = false
        isSessionActive = false
        
        ConnectivityManager.shared.sendSessionSync(isActive: false)
        
        print("🛑 Session Stopped")
    }
    
    func pauseSession() {
        
        guard isSessionActive else { return }
        guard !isPaused else { return }
        
        isPaused = true
        
        if let query = activeHeartRateQuery {
            healthStore.stop(query)
            activeHeartRateQuery = nil
        }
        
        motionActivityManager.stopActivityUpdates()
        
        print("⏸ Session Paused")
    }
    
    func resumeSession() {
        guard isSessionActive else { return }
        guard isPaused else { return }

        isPaused = false

        startHeartRateQuery()
        startMotionTracking()

        print("▶️ Session Resumed")
    }

// MARK: - Sensor CoreMotion
private func startMotionTracking() {
    if CMMotionActivityManager.isActivityAvailable() {
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            
            // Considered Stationary if not walking, running, cycling
            let isMoving = activity.walking || activity.running || activity.cycling
            self?.isStationary = !isMoving
            
            print(isMoving ? "Moving" : "Stationary")
        }
    }
}

// MARK: - Sensor Real-Time
private func startHeartRateQuery() {
    guard activeHeartRateQuery == nil else { return }
    guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
    let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
    
    let query = HKAnchoredObjectQuery(type: hrType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
        self?.process(samples)
    }
    query.updateHandler = { [weak self] _, samples, _, _, _ in
        self?.process(samples)
    }
    self.activeHeartRateQuery = query
    healthStore.execute(query)
}

// MARK: - Stress Logic + DEBOUNCE + COREMOTION
private func process(_ samples: [HKSample]?) {
    guard !isPaused else { return }
    guard let sample = samples?.last as? HKQuantitySample else { return }
    let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
    
    DispatchQueue.main.async {
        self.currentHeartRate = bpm
        ConnectivityManager.shared.sendHeartRate(bpm)
        // Formula: Considered Stress if BPM is more than 30% from RHR
        let stressThreshold = self.restingHeartRate * 1.30
        // Formula: Considered Back to relaxed if BPM falls near RHR
        let relaxedThreshold = self.restingHeartRate * 1.10
        
        if bpm >= stressThreshold {

            if self.isStationary {

                if self.thresholdStartTime == nil {
                    self.thresholdStartTime = Date()
                }

                if let start = self.thresholdStartTime,
                   Date().timeIntervalSince(start) >= 30 {

                    ConnectivityManager.shared.sendStressAlert()

                    self.thresholdStartTime = nil
                }

            } else {

                self.thresholdStartTime = nil
            }

            print("🔥 STRESS DETECTED")
        } else if bpm <= relaxedThreshold {
            self.thresholdStartTime = nil
            ConnectivityManager.shared.sendRelaxedAlert()
            print("🍏 RELAXED. (BPM: \(bpm) is safe below \(relaxedThreshold))")
        } else {
            self.thresholdStartTime = nil
        }
    }
}

func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
    print("Workout Session State Changed to: \(toState.rawValue)")
}

func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    print("Workout Session Failed: \(error.localizedDescription)")
}
}
