# Tech & Framework Challenge

> A project-based challenge focused on exploring Apple's technologies and frameworks by designing and building innovative applications that solve real-world problems.

This repository documents our team's journey throughout the **Tech & Framework Challenge**, where each team selects a technology theme, researches Apple's frameworks, explores different approaches, and develops a solution while documenting the entire engineering process—from initial assumptions to the final design decisions.

For this challenge, our team chose the **Internet of Things (IoT)** theme and built **StressLess**, an application that integrates Apple frameworks with an IoT-enabled smart pillow to provide an interactive stress detection and relief experience.

---

# 📖 Overview

Stress often builds up silently during work or study sessions. While wearable devices can continuously monitor physiological signals, they rarely provide immediate physical intervention.

Our project proposes an integrated ecosystem that detects potential stress episodes using Apple frameworks and responds by activating an IoT-enabled smart pillow that encourages healthy stress release. After each session, users can review their stress history and recovery progress through an interactive dashboard.

---

# 👥 Team

| Name | Role |
|------|------|
| Ahmad Taufiq Hidayat | Coder |
| Johnny Khang | Coder |
| Stevanus Felixiano | Coder |
| Valentica Ongke | Designer |
| Ni Ketut Lela Berliani | Designer |

---

# 🎯 Challenge Theme

Among several available challenge themes, we chose **IoT** because we wanted to explore how Apple frameworks can interact with physical devices rather than remaining purely software-based.

### Main Theme
- Internet of Things (IoT)

### Primary Framework
- Core Bluetooth

### Supporting Frameworks
- HealthKit
- Core Motion

---

# 💡 Problem Statement

Many stress-monitoring applications stop at notifying users that they are stressed.

We wanted to answer a different question:

> **What if the app could immediately help users release stress through a connected physical device?**

---

# 🚀 Proposed Solution

Our application automatically detects possible stress episodes by combining:

- elevated heart rate
- user inactivity
- Bluetooth-connected IoT device

When stress is detected:

1. Heart rate is continuously monitored through HealthKit.
2. Core Motion verifies the user is physically inactive.
3. The application determines a potential stress episode.
4. Core Bluetooth sends a command to a smart pillow.
5. The pillow inflates and becomes a safe punching bag.
6. The user performs guided stress-relief exercises.
7. Recovery data is visualized inside the dashboard.

---

# 🛠 Framework Architecture

## Core Bluetooth (Main Framework)

Purpose:
- Connect with the IoT smart pillow
- Send commands
- Receive device status

Responsibilities:
- BLE discovery
- Device pairing
- Command transmission
- Device communication

---

## HealthKit

Purpose:
- Read heart rate data from Apple Watch

Responsibilities:
- Continuous heart rate monitoring
- Detect elevated heart rate
- Record recovery trends

---

## Core Motion

Purpose:
- Determine whether the user is stationary.

Responsibilities:
- Detect inactivity
- Reduce false positives
- Ensure high heart rate is not caused by exercise

---

# 🔄 System Workflow

```text
Apple Watch
      │
      ▼
HealthKit reads heart rate
      │
      ▼
Core Motion checks inactivity
      │
      ▼
Potential Stress Episode?
      │
      ├── No → Continue Monitoring
      │
      ▼ Yes
Core Bluetooth
      │
      ▼
Smart Pillow Activated
      │
      ▼
Guided Stress Relief
      │
      ▼
Recovery Analytics Dashboard
```

---

# 🧠 Starting Assumption

Before conducting any research, we assumed:

- Heart rate alone would be sufficient to detect stress.
- Bluetooth communication with an IoT device would be relatively straightforward.
- Apple Watch could continuously monitor stress without additional conditions.
- The biggest challenge would be building the physical smart pillow.

---

# 🔍 Exploration Log

Our research process focused on understanding each framework and validating whether our assumptions were correct.

### Step 1
Explored Apple IoT-related frameworks.

Considered:
- Core Bluetooth ✅
- Matter Support
- HomeKit

Result:
Core Bluetooth provided the flexibility required for a custom IoT device.

---

### Step 2

Investigated methods for stress detection.

Research included:

- Heart rate monitoring
- Motion detection
- HealthKit capabilities

Finding:

High heart rate alone generates many false positives.

---

### Step 3

Studied Apple Watch capabilities.

Finding:

Stress cannot be directly measured.

Instead, we infer stress by combining:

- elevated heart rate
- inactivity

---

### Step 4

Designed an appropriate IoT response.

Instead of sending notifications, we wanted a physical intervention.

This led to the smart punching pillow concept.

---

# ❌ What We Tried and Dropped

## Matter Support

Reason explored:
- Easier smart-home integration.

Why dropped:
- Requires Matter-compatible hardware.
- Less suitable for a fully custom prototype.

---

## HomeKit

Reason explored:
- Native Apple smart-home ecosystem.

Why dropped:
- Primarily designed for certified smart-home accessories.
- Less flexible than Core Bluetooth for our custom device.

---

## Heart Rate Only Detection

Reason explored:
- Simpler implementation.

Why dropped:
- Unable to distinguish stress from physical exercise.
- Too many false positives.

---

# ⚠️ Real Limitations

During development, we identified several practical limitations.

## HealthKit

- Cannot directly determine emotional stress.
- Depends on Apple Watch measurements.

---

## Core Motion

- Cannot guarantee emotional state.
- Only identifies whether the user is stationary.

---

## Core Bluetooth

- Limited BLE range.
- Requires pairing and connection stability.

---

## IoT Device

- Requires custom hardware.
- Motor inflation timing must be carefully calibrated.
- Battery life and portability remain challenges.

---

# 🔄 Revised Decision

After exploration, our approach evolved.

| Initial Idea | Final Decision |
|--------------|----------------|
| Detect stress from heart rate only | Combine heart rate + inactivity |
| Focus mainly on software | Integrate software with IoT hardware |
| Simple notification | Physical stress-relief intervention |
| Display heart rate | Provide recovery analytics dashboard |

---

# 📊 Expected User Flow

1. Wear Apple Watch.
2. Heart rate monitored continuously.
3. User remains inactive.
4. Elevated heart rate detected.
5. Stress episode inferred.
6. Smart pillow inflates.
7. Guided punching session begins.
8. Session ends.
9. Dashboard visualizes recovery metrics.

---

# 📈 Dashboard

The dashboard provides:

- Stress episode history
- Heart rate trends
- Recovery time
- Daily statistics
- Weekly analytics
- Session summaries

---

# 🔮 Future Improvements

- AI-based personalized stress prediction
- Apple Intelligence integration
- Breathing exercise recommendations
- Haptic feedback on Apple Watch
- Adaptive pillow firmness
- Cloud synchronization
- Multi-user support

---

# 📚 Technologies

| Category | Technology |
|-----------|------------|
| Language | Swift |
| UI | SwiftUI |
| IoT Communication | Core Bluetooth |
| Health Data | HealthKit |
| Motion Detection | Core Motion |
| Wearable | Apple Watch |
| Hardware | BLE-enabled Smart Pillow |

---

# 🌟 Why This Project?

Instead of merely notifying users that they may be stressed, our system bridges digital health monitoring with tangible physical interaction.

By combining **Core Bluetooth**, **HealthKit**, and **Core Motion**, we create a seamless experience where Apple devices not only detect stress but also trigger an IoT-enabled intervention designed to promote healthier stress management.
