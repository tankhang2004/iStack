//
//  TrackingPage.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI
import SwiftData

struct TrackingPage: View {
    
    @Bindable var session: Session
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showConnectivity = false
    
    @State private var isPaused = false
    @State private var isExpanded = false
    
    // MARK: Session
    
    private func cancelSession() {
        
        ConnectivityManager.shared.sendStopCommandToWatch()
        
        modelContext.delete(session)
        
        try? modelContext.save()
        
        dismiss()
    }
    
    private func endSession() {
        
        ConnectivityManager.shared.sendStopCommandToWatch()
        
        session.endTime = .now
        
        try? modelContext.save()
        
        dismiss()
    }
    
    // MARK: UI
    
    var body: some View {
        
        ZStack {
            
            Image("GradientOval1")
                .resizable()
                .scaledToFill()
            
            VStack(spacing: 0) {
                
                TrackingTopBar(
                    showConnectivity: $showConnectivity,
                    onBack: cancelSession
                )
                .padding(.bottom, 36)
                
                TrackingInfo(session: session)
                    .padding(.bottom, 100)
                
                
                PunchCounter(
                    punchCount: session.punchCount
                )
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            VStack(spacing: 0){
                
                Spacer()
                
                TrackingControlPanel(
                    isPaused: $isPaused,
                    isExpanded: $isExpanded,
                    onEndSession: endSession
                )
            }
            .ignoresSafeArea(edges: .bottom)
            
            if showConnectivity {
                
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showConnectivity = false
                        }
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        ConnectivityMenu(isPresented: $showConnectivity)
                    }
                    
                    Spacer()
                }
                .padding(.top, 66)
                .padding(.trailing, 24)
                .transition(
                    .scale(scale: 0.95, anchor: .topTrailing)
                    .combined(with: .opacity)
                )
                .zIndex(999)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.dark)
    }
    
}

#Preview {
    
    do {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(
            for: Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self,
            configurations: config
        )
        
        let category = Category(name: "Studying")
        
        container.mainContext.insert(category)
        
        let session = Session(
            category: category,
            startTime: .now,
            averageRestingHR: 75
        )
        
        container.mainContext.insert(session)
        
        return NavigationStack {
            
            TrackingPage(session: session)
            
        }
        .modelContainer(container)
        
    } catch {
        
        return Text("Preview Error")
        
    }
}
