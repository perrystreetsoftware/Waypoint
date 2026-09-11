<p align="center">
  <img src="Assets/icon.png" width="160" alt="Waypoint">
</p>

# Waypoint

Tab-based SwiftUI navigation: one `NavigationStack` per tab, modal flows with their own stacks, and a single `WaypointNavigator` entry point.

## Usage

```swift
import Waypoint

final class AppTabProvider: RootTabProviding {
    let rootTabs = AppTab.allCases.map { tab in
        RootTab(id: tab) { tab.rootView }
    }
}

let navigator = WaypointNavigator.shared

WaypointTabView()

navigator.navigate(to: DetailView(), mode: .push)
navigator.navigate(to: SettingsView(), mode: .present(.sheet))
navigator.switchTab(to: AppTab.inbox)
```

## Registration

Register the tab provider once, in your `App`'s `init`, before any view is built. Registering a second time is a programmer error and traps.

```swift
@main
struct MyApp: App {
    init() {
        WaypointNavigator.shared.register(tabProvider: AppTabProvider())
    }

    var body: some Scene {
        WindowGroup {
            WaypointTabView()
        }
    }
}
```

## Rules

Waypoint is app-agnostic. It has no dependencies beyond SwiftUI; dependency injection and app types stay in the app.
The first root tab is the initially selected one.
