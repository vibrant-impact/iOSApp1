# 🚘 TimsRunner (iOS)

An intelligent, high-fidelity SwiftUI group-order coordinator and performance-tracking dashboard designed to optimize coffee runs. Built with custom interactive search states, live analytical metrics logging, and local JSON-backed account persistence frameworks.

![TimsRunner Core Application Walkthrough](app_walkthrough.gif)

## 🎯 Project Overview

TimsRunner eliminates the chaos of group coffee runs. Instead of scratching orders on napkins or translating messy text threads, the app allows a designated "Runner" to build individual custom baskets for team members, monitors their driving speed performance against an interactive 15-minute challenge clock, tracks historical run logs, and rewards efficient drivers with a dynamic free drink credit ledger balance system.

### 📐 Design Philosophy
The user interface combines high-tech geometric logic with natural, organic curves. It utilizes a custom-blended, warm typographic color palette of deep Tim's browns, golds, vibrant oranges, and soft canvas tans to deliver a warm, modern, and highly responsive user experience.

---

## ✨ Core Features & UX Systems

* **Multi-Dimensional Filtering Pipeline:** Completely decouples visual menu category and subcategory button selections from standard text field queries. Users can type custom keywords freely or tap nested category tags without unwanted input-clearing interactions.
* **Persistent User Profiles:** Automatically scans, loads, and writes driver/passenger profile models onto device hardware via `UserDefaults` caching. 
* **One-Tap Favoriting & Auto-Load:** Users can save an individual's entire grouped multi-item basket combination as a single favorite routine. Typing their name on a subsequent run exposes a spring-animated "Auto-Load" action banner that pre-fills their basket instantly.
* **Interactive Challenge Clock:** A live background timer loop publisher tracking speed performance. Completing a run under 15 minutes updates the driver's profile, increments their available drink credit balance, and appends a speed-run analytical record to their account history.
* **Bottom-Anchored Checkout Sheet:** A custom overlay modal summary card containing full itemized lists of all chosen products, custom textual customization notes, live quantity manipulation steppers, and single-item inline deletions.
* **Capped Reward Redemption Logic:** Real-world simulated credit systems limit reward tokens strictly to one eligible specialty beverage item with a hard restriction cap of up to \$6.00, instantly calculating cents deductions across the entire run manifest.
* **Thematic Audio & Media Subsystems:** Implements a layered, multi-stream `SoundManager` audio subsystem handling simultaneous context-driven playback (e.g., fluid pouring effects, warning buzzers, and success chimes) working alongside native hardware looping background video playback wrappers.

---

## 🏗️ Technical Architecture & Data Schema

The application is engineered strictly around clean **MVVM (Model-View-ViewModel)** structural separation principles, utilizing reactive data publishers to drive predictable UI re-renders.

### 📂 File Structure Directory
```text
├── DataLoader
│   └── productData.json          # Decoupled flat static menu asset catalogue dataset
├── Extensions
│   ├── Color+Palette.swift       # Warm custom thematic brand colors asset palette configurations
│   └── View+Extensions.swift     # Visual corner radius layout modifiers
├── Managers
│   └── SoundManager.swift        # Multi-stream concurrent AVAudioPlayer audio framework manager
├── Models
│   ├── Order.swift               # Individual line item definitions and aggregate cost tools
│   └── UserProfile.swift         # Structural blueprints for profiles, runs, and favorites caching
├── Resources                     # Shared application localization bundles
├── ViewModels
│   └── OrderStore.swift          # Centralized dynamic local cache database core state view model engine
└── Views
    ├── AddOrderView.swift        # Product search filter grids & fluid checkout sheet layer
    ├── LoopingVideoPlayerView.swift # Native AVPlayer container for background multimedia playback
    ├── ManifestBuilderView.swift # Current active manifest run construction workshop board
    ├── ProductCardView.swift     # Individual visual item grid panel components
    ├── TimerView.swift           # Live performance challenge tracking system overlay interface
    ├── WelcomeView.swift         # Dynamic app launcher dashboard and onboarding greeting sheet
    ├── ContentView.swift         # Parent structural routing navigation canvas wrapper
    ├── iOSApp1App.swift          # Application entry point lifecycle hub
    └── welcomeAnimation.mp4      # Embedded background high-fidelity multimedia looping mp4 video asset
