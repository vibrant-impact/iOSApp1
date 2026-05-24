# ☕ Tims Coffee Runner (iOS Prototype)

An interactive iOS application designed to streamline daily Tim Hortons coffee runs for collaborative teams. This app replaces traditional paper order tracking by providing a digital manifest manager, dynamic preference configurations, and a gamified delivery loop system.

## 🛠️ Application Architecture & Core Logic

This project is built using modern SwiftUI design patterns, focusing on clear separation of concerns, dynamic state tracking, and reusable layout containers:

* **State-Driven Layout Flows:** Uses multi-phase condition gates to transition the user seamlessly through different parts of the app (Welcome Dashboard ➔ Manifest Builder ➔ Live Countdown Loop).
* **Persistent View Models:** Leveraged an `ObservableObject` state store (`OrderStore`) to broadcast order mutations globally across isolated view layers, ensuring data stays synchronized.
* **Modular View Design:** Form inputs and data lists are kept decoupled, allowing individual structural components to handle their own data bindings independently.
* **Interactive Countdown Engine:** Features a custom background timer loop that dynamically updates the UI second-by-second while monitoring user performance metrics.

---

## 🚀 Key Features Implemented

* **Welcome Phase Splash Screen:** A clean point-of-entry dashboard featuring custom imagery and a quick-start sequence trigger button.
* **Dynamic Manifest Builder:** Allows team members to compile item entries before a coffee run loop begins.
* **Scrollable Dropdown Form:** Features optimized `.navigationLink` picker sheets that keep form controls accessible and compact on all device viewports.
* **Dual Item Categorization:** Simultaneously tracks custom drink metrics (with quantities/notes) and food orders for every single person.
* **🌟 Quick-Load Favorites Profiles:** Users can tag profiles to save preferences. Selecting a saved team member instantly autofills the entire order form.
* **Tap-To-Edit & Swipe-to-Delete Modifications:** Manifest arrays are fully mutable, permitting line modifications or item strikes on the fly.
* **Contextual Runner Selection:** The designated runner selector dropdown populates dynamically—showing *only* the names of team members who placed an order that day.
* **⏱️ Gamified Delivery Challenge:** A 15-minute countdown clock tracks delivery speed. Returning on time awards the runner a digital future drink credit; exceeding the window displays the exact time overage.

---

## 🗂️ File Architecture & Directory Mapping

The codebase strictly adheres to a clean structural layout pattern, isolated by functional responsibility rules:

```text
Tims2/
├── Models/
│   └── Order.swift          # Core structs (TeamOrder, OrderItem, CompletedRunSummary)
├── ViewModels/
│   └── OrderStore.swift     # Core data engine, dropdown sources, and array stores
├── Views/
│   ├── AddOrderView.swift   # Scrollable entry form, picker menus, and favorites loader
│   └── TimerView.swift      # 15-minute countdown engine, reward triggers, and alert controllers
└── Root/
    ├── ContentView.swift    # Core navigation hub orchestrating sequence phases
    └── Tims2App.swift       # Standard application life-cycle boot entry point
