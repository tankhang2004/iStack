# Tech & Framework Challenge: Thump (Team IoTry)

## 👥 Present Your Team
* **Ahmad Taufiq Hidayat** - Coder
* **Johnny Khang** - Coder
* **Stevanus Felixiano** - Coder
* **Valentica Ongke** - Designer
* **Ni Ketut Lela Berliani** - Designer

## 🧠 Starting Assumption

**We think we'll end up using:**
HealthKit (for detecting stress via Heart Rate) and Core Bluetooth (to connect to a custom IoT ESP32 smart pillow). 

**Because:**
It sounded like the most obvious fit. We assumed that elevated heart rate naturally means the user is stressed. We also thought the biggest hurdle would be building the physical ESP32 hardware, while the Apple Watch could easily and seamlessly stream continuous heart rate data to the iPhone in the background. Lastly, we assumed calling the event "Stress" in our UI was the most accurate term.

## 🔍 The Exploration Log

**What we browsed, and what surprised us:**
* We explored Apple's IoT integration options (Matter, HomeKit, and Core Bluetooth). We were surprised to find that HomeKit/Matter are too strict for custom, non-certified prototypes. 
* We were also surprised by Apple's strict privacy and battery policies: `WCSession` messages from iPhone to Apple Watch are blocked if the Watch screen is off. 

**What we actually built or tested in code (not just read about):**
* We built an ESP32 firmware integrating an MPU6050 shock sensor and LED, communicating via BLE.
* We developed an iOS app with `CBCentralManager` to automatically handshake and trigger the pillow's LED.
* We built a watchOS app using `WKExtendedRuntimeSession` to continuously query heart rate (`HKAnchoredObjectQuery`) and track user movement using Core Motion (`CMMotionActivityManager`).

**What we discovered that we didn't expect:**
* Heart rate alone is a terrible indicator of tension. Walking up the stairs mimics a "stress" spike, causing massive false positives.
* "Stress" is a medical/psychological diagnosis. Our app only reads physiological data. Calling it "stress" created a negative user experience.

## ❌ What We Tried and Dropped

**We considered:**
Relying exclusively on Heart Rate to detect stress, and integrating via HomeKit for a more "native" Apple ecosystem feel.

**We dropped it because:**
* **Heart Rate Only:** Dropped because it generated too many false positives during physical activity. We added Core Motion to ensure the user is strictly *stationary* when the heart rate spikes.
* **HomeKit:** Dropped because it requires certified hardware. Core Bluetooth gave us the raw byte-level control we needed for our custom ESP32 payload.
* **"Stress" Terminology:** Dropped after feedback. We pivoted to the term "potential tension episode" to avoid implying a medical diagnosis.

## ⚠️ Real Limitations Hit

**What broke, what didn't behave the way the documentation said it would, where AI genuinely couldn't help you:**
We hit a major wall with watchOS background execution and `WCSession`. When the iPhone sent a "Start Session" command to the Watch, it would silently fail and return *“Apple Watch is not reachable”* if the Watch screen was asleep. Furthermore, Apple Watch stops reading HealthKit data frequently to save battery unless explicitly forced into a specific session state.

**How we worked around it (or how it changed our use case / mechanic):**
We had to architect a robust `WKExtendedRuntimeSession` delegate in the watchOS app to keep the sensors alive. We also implemented a "Lazy Initialization" fix (`_ = ConnectivityManager.shared` on init) to force the Watch to wake up its communication channel the moment the app opens, preventing the iPhone from thinking the Watch was disconnected.

## 🔄 The Revised Decision

**Final decision:**
Core Bluetooth (Primary) + HealthKit + Core Motion. 

**What changed since Section 1, and why:**
Our core stack remained the same, but the *logic* changed drastically. Instead of just reading HR, we now use Core Motion to verify inactivity. Instead of a background autonomous monitor, it became an interactive session: Watch detects potential tension -> iPhone triggers ESP32 via BLE -> LED turns on -> User punches the pillow -> MPU6050 detects impact magnitude -> iOS logs the recovery analytics. We successfully bridged a digital Apple framework state into a physical IoT tension-relief action.

## 📱 App Track Addendum

### About the Frameworks
**Does your use case genuinely need both frameworks working together, or could it work with just your main one?**
Yes, it genuinely needs all three. Without HealthKit, we can't detect the physiological trigger. Without Core Motion, we get false positives from walking. Without Core Bluetooth, we just have a passive dashboard with no physical tension-relief mechanism (the smart pillow).

### About Accessibility and Localization
**What did you decide to support, what did you decide not to, and why?**
We did not localize the app yet, keeping it strictly in English. For this specific challenge timeline, our engineering priority was ensuring the complex End-to-End hardware communication (Watch -> iPhone -> ESP32) worked seamlessly without latency. We supported basic accessibility via Dynamic Type for the analytics dashboard to ensure the heart rate metrics remain readable.

### About Privacy
**What data does your app actually need? What happens in your app when the user says no to a permission?**
The app strictly needs `NSBluetoothAlwaysUsageDescription`, Health (Heart Rate & Resting Heart Rate), and Motion access. If the user denies HealthKit, the app gracefully degrades: the Watch UI explicitly shows a "Need Sensor Access" state, and we provide a "Simulation Mode" (via manual UI buttons) to manually trigger a tension spike so the user can still experience punching the IoT pillow without biometric data.

---

## 📎 Appendix: System Architecture & Data Flow

*Although this challenge focuses on the engineering journey, we have included our system architecture diagrams below for broader context on how the end-to-end IoT communication was implemented.*

### 🔄 System Workflow

```text
                  User starts monitoring session
                                │
                                ▼
                    Create a new Session record
                                │
                                ▼
        Apple Watch continuously monitors heart rate
                                │
                                ▼
        Core Motion verifies user is stationary
                                │
                                ▼
      Heart Rate > Baseline + Threshold (30–60 sec)
                                │
                                ▼
          Possible Tension Episode Detected
                                │
                                ▼
   Core Bluetooth sends command to ESP32 Smart Pillow
                                │
                                ▼
          Smart Pillow activates (Green LED ON)
                                │
                                ▼
 User receives prompt:
 "Feeling tense? Try a tension relief session."
                                │
                                ▼
          Wait up to 1 minute for first punch
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
         No punch within 1 minute    First punch detected
                    │                       │
                    ▼                       ▼
             False Positive         Create TensionEvent
         (No TensionEvent saved)            │
         (Not counted)                      ▼
                                    Save first PunchData
                                    (First punch)
                                            │
                                            ▼
                              Recovery timer starts
                         (recoveryStartedAt = first punch)
                                            │
                                            ▼
                          Continue recording PunchData
                          for every subsequent punch
                                            │
                                            ▼
                        Apple Watch continues monitoring
                                heart rate
                                            │
                                            ▼
                    Heart rate returns near baseline
                                            │
                                            ▼
                           Update TensionEvent
                           • recoveredAt
                           • recoveryDuration
                                            │
                                            ▼
                       Resume monitoring for additional
                           possible tension episodes
                                            │
                                            ▼
                      User ends monitoring session
                                            │
                                            ▼
                         Update Session endTime
                                            │
                                            ▼
                      Dashboard displays analytics
                      • Number of validated tension events
                      • Recovery time for each event
                      • Heart rate timeline
                      • Punch count & intensity
                      • Overall session statistics

### 📡 Detailed Interaction Flow
sequenceDiagram
    autonumber

    actor User
    participant Watch as Apple Watch (watchOS)
    participant HK as HealthKit
    participant App as iPhone App (SwiftUI)
    participant IoT as Smart Pillow (ESP32)

    Note over User,IoT: Phase 1 — Monitoring

    User->>Watch: Start Monitoring Session
    Watch->>Watch: Start Extended Runtime Session
    Watch->>HK: Observe heart rate continuously
    Watch->>Watch: Monitor user activity with Core Motion
    App->>App: Create Session

    loop During Monitoring
        HK-->>Watch: New heart rate sample
        Watch->>App: Save HeartRate sample

        Watch->>Watch: Validate HR > baseline + threshold<br/>AND user is stationary for 30–60 seconds

        alt Possible Tension Episode Detected

            Note over User,IoT: Phase 2 — Validation

            Watch->>App: Potential Tension Detected
            App->>IoT: BLE command → Turn ON Green LED
            IoT-->>User: Smart pillow becomes active
            App-->>User: "Feeling tense?\nTry a tension relief session."

            App->>App: Wait up to 1 minute for first punch

            alt First punch detected within 1 minute

                User->>IoT: First punch
                IoT->>IoT: Detect impact (Shock Sensor + MPU6050)
                IoT-->>App: Send first PunchData

                App->>App: Create TensionEvent
                App->>App: Save first PunchData
                App->>App: Set recoveryStartedAt
                App->>App: Start recovery timer

                loop Subsequent punches
                    User->>IoT: Punch / slap pillow
                    IoT->>IoT: Detect impact
                    IoT-->>App: Send PunchData
                    App->>App: Save PunchData
                end

                Note over User,IoT: Phase 3 — Recovery

                HK-->>Watch: Heart rate returns near baseline
                Watch->>App: Recovered
                App->>App: Stop recovery timer
                App->>App: Update TensionEvent<br/>recoveredAt & recoveryDuration
                App->>IoT: BLE command → Turn OFF Green LED
                IoT-->>User: Pillow deactivates

            else No punch within 1 minute

                App->>App: False Positive
                App->>IoT: BLE command → Turn OFF Green LED
                IoT-->>User: Pillow deactivates

                Note over App: No TensionEvent created<br/>Not counted in tension history

            end
        end
    end

    Note over User,IoT: Phase 4 — Session End

    User->>Watch: End Monitoring Session
    Watch->>Watch: End Extended Runtime Session
    App->>App: Update Session endTime
    App-->>User: Display dashboard<br/>• Validated tension events<br/>• Recovery times<br/>• Heart rate timeline<br/>• Punch statistics