<p align="center">
  <img src="Assets/icon.png" width="160" alt="Waypoint">
</p>

<h1 align="center">Waypoint</h1>

<p align="center">
  Tab-based SwiftUI navigation with a single entry point.<br>
  One <code>NavigationStack</code> per tab, modal flows with their own stacks, and a navigator you call from anywhere.
</p>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-blue" alt="iOS 17+"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift 5.9"></a>
  <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen" alt="SPM compatible"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-lightgrey" alt="Apache 2.0"></a>
</p>

---

## Why Waypoint

Apple's `NavigationStack`, `sheet` and `fullScreenCover` are the right primitives, but on their own every view ends up owning navigation state: a path, a flag per modal, a `switch` over destinations, and modifiers wired by hand. Forget one `NavigationStack` and a push silently does nothing.

Waypoint keeps the native primitives underneath and puts one object in front of them:

- **One entry point.** Views call `navigator.navigate(to:mode:)`. They never touch `NavigationStack`, `sheet` or `fullScreenCover`.
- **Navigation is data.** The whole navigation state is a tree: one push stack per tab, plus modal flows that carry their own stack and remember their parent. The framework binds that data to SwiftUI.
- **Modal flows that push.** A sheet or full-screen cover gets its own `NavigationStack`, so it can push inside itself and dismiss back to its parent.
- **Tabs that can change.** Add or remove tabs at runtime. Turn the last tab into an action button that runs code instead of selecting.
- **App-agnostic.** No domain types, no dependency injection, no configuration. SwiftUI is the only dependency.
- **Testable.** Navigation is a method call on an object, not view state. It can live in a view model and be asserted in a unit test. See [Testing](#testing).

### Waypoint vs. `NavigationStack` alone

| | `NavigationStack` alone | Waypoint |
|---|---|---|
| Where navigation state lives | In every view: a path, a flag per modal | One tree, owned by the navigator |
| Who can navigate | Only the view that owns the binding | Any view, view model or coordinator |
| Push, sheet, full-screen cover | Three mechanisms, wired per screen | One method, one `mode` parameter |
| Modal that pushes inside itself | Build a second `NavigationStack` yourself | Every modal flow gets its own stack |
| Switching tabs and resetting stacks | Yours to coordinate | `switchTab(to:)` |
| Forgetting a `NavigationStack` | Push silently does nothing | The stack is always there; the framework owns it |
| Unit-testing a navigation decision | Not possible without rendering the view | Inject the navigator into the view model and assert the call |

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15+

## Installation

Add Waypoint with Swift Package Manager.

**Xcode:** File → Add Package Dependencies… and enter

```
https://github.com/perrystreetsoftware/Waypoint.git
```

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/perrystreetsoftware/Waypoint.git", from: "0.3.2")
],
targets: [
    .target(name: "MyFeature", dependencies: ["Waypoint"])
]
```

## Quick start

Define your tabs, put a `WaypointTabView` at the root of the app, and navigate from any view through the environment.

```swift
import SwiftUI
import Waypoint

enum AppTab: CaseIterable {
    case countries, about
}

@main
struct TravelApp: App {
    var body: some Scene {
        WindowGroup {
            WaypointTabView(tabs: AppTab.allCases.map { tab in
                RootTab(id: tab) {
                    Label(tab.title, systemImage: tab.icon)
                } view: {
                    tab.rootView
                }
            })
        }
    }
}
```

```swift
struct CountryListView: View {
    @Environment(WaypointNavigator.self) private var navigator

    var body: some View {
        List(countries) { country in
            Button(country.name) {
                navigator.navigate(to: CountryDetailsView(country: country), mode: .push)
            }
        }
        .toolbar {
            Button("About") { navigator.switchTab(to: AppTab.about) }
            Button("Filters") { navigator.navigate(to: FiltersView(), mode: .present(.sheet)) }
        }
    }
}
```

`WaypointTabView(tabs:)` is the only setup step. It creates a router for each tab and injects the navigator into the environment.

## Core concepts

Waypoint models navigation as a tree and mutates data; SwiftUI does the rendering.

```
WaypointNavigator
├── selectedTab
└── routers: [tab id → Router]
    └── Router                       one per tab
        ├── path: [destination]      the tab's push stack (NavigationStack path)
        ├── presentedSheet           optional modal flow
        └── presentedFullScreenCover optional modal flow
            └── Router               the modal's own stack; knows its parent
```

| Call | What changes |
|---|---|
| `navigate(to:mode: .push)` | Appends a destination to the **active** stack. |
| `navigate(to:mode: .present(…))` | Creates a new stack whose parent is the active one, and presents it as a sheet or full-screen cover. |
| `dismiss()` | Drops the active modal flow. You are back on its parent. |
| `navigateBack()` | Pops one destination off the active stack. |
| `navigateToRoot()` | Empties the active stack. |
| `switchTab(to:)` | Dismisses any modal on the current and target tabs, pops the target to its root, and selects it. |

The **active** stack is the deepest presented one: if a sheet is showing over a tab, pushes and pops apply to the sheet, not to the tab underneath.

## API

### `WaypointNavigator`

An `@Observable` singleton, available as `WaypointNavigator.shared` and injected into the SwiftUI environment by `WaypointTabView`.

```swift
public var selectedTab: NavigatorTab!

public func navigate(to destination: some View, mode: NavigationMode)
public func switchTab(to tab: NavigatorTab)
public func dismiss()
public func navigateBack()
public func navigateToRoot()
```

`NavigatorTab` is `AnyHashable`: pass the same `Hashable` values you used as `RootTab` ids.

### `NavigationMode`

```swift
public enum NavigationMode {
    case push
    case present(ModalStyle)
}

public enum ModalStyle {
    case sheet
    case fullScreenCover
}
```

```swift
navigator.navigate(to: ProfileView(), mode: .push)
navigator.navigate(to: SettingsView(), mode: .present(.sheet))
navigator.navigate(to: PaywallView(), mode: .present(.fullScreenCover))
```

Full-screen covers get a leading **✕** toolbar button that dismisses the flow. Sheets rely on the system drag-to-dismiss gesture; add your own button if you need one.

### `RootTab`

Describes one tab: an id, a label and a root view. The label can react to selection.

```swift
RootTab(id: AppTab.inbox) {
    Label("Inbox", systemImage: "tray")
} view: {
    InboxView()
}

RootTab(id: AppTab.inbox) { isSelected in
    Label("Inbox", systemImage: isSelected ? "tray.fill" : "tray")
} view: {
    InboxView()
}
```

### `WaypointTabView`

```swift
WaypointTabView(tabs: [RootTab])
```

Renders a `TabView` with one `NavigationStack` per tab. Requirements, enforced with preconditions:

- at least one tab;
- unique ids.

The first tab is selected initially.

### `WaypointActionTabView`

A tab bar whose **last** tab is an action button. It takes the `.search` role, so the system renders it detached from the other tabs, and it is never selected: tapping it runs `action` and the selection stays where it was.

```swift
WaypointActionTabView(tabs: rootTabs, action: openProStore)
```

Requires at least two tabs: one selectable tab plus the action tab. The action tab's `view` is never shown.

## Dynamic tabs

`tabs` may change over time. When it does:

- routers for tabs that remain are kept as they are, stacks included;
- routers for removed tabs are torn down, dismissing anything they were presenting;
- if the selected tab was removed, selection falls back to the first tab.

```swift
struct RootView: View {
    @State private var tabs: [AppTab] = [.home, .inbox]

    var body: some View {
        WaypointTabView(tabs: tabs.map(rootTab))
            .onReceive(entitlements) { tabs = $0.isPro ? [.home, .inbox, .pro] : [.home, .inbox] }
    }
}
```

`switchTab(to:)` traps when asked for a tab that is not in the current list.

## Modal flows

Presenting creates a new stack. Everything you push while the modal is showing goes onto that stack, and `dismiss()` removes the whole flow at once.

```swift
navigator.navigate(to: OnboardingStepOne(), mode: .present(.fullScreenCover))
navigator.navigate(to: OnboardingStepTwo(), mode: .push)      // pushes inside the cover
navigator.navigate(to: OnboardingStepThree(), mode: .push)
navigator.dismiss()                                          // back on the presenting screen
```

## Reaching the navigator

Prefer the environment inside SwiftUI views. It is injected by `WaypointTabView` and `WaypointActionTabView`.

```swift
@Environment(WaypointNavigator.self) private var navigator
```

Outside the view tree, for example in a coordinator or a UIKit bridge, use the singleton.

```swift
WaypointNavigator.shared.navigate(to: DetailView(), mode: .push)
```

## Testing

With `NavigationStack` alone, navigation can only happen where the path binding lives: inside the view. That makes a decision like "open the paywall when a free user taps a locked item" untestable without rendering UI.

With Waypoint, navigation is a method call, so the decision can move into the view model. Put the navigator behind a small protocol your app owns, inject it, and assert the call in a test.

```swift
// App code
protocol Navigating {
    func navigate(to destination: some View, mode: NavigationMode)
    func dismiss()
}

extension WaypointNavigator: Navigating {}

@Observable
final class CountryListViewModel {
    private let navigator: any Navigating
    private let isPro: Bool

    init(navigator: any Navigating = WaypointNavigator.shared, isPro: Bool) {
        self.navigator = navigator
        self.isPro = isPro
    }

    func select(_ country: Country) {
        if country.isPremium && !isPro {
            navigator.navigate(to: PaywallView(), mode: .present(.sheet))
        } else {
            navigator.navigate(to: CountryDetailsView(country: country), mode: .push)
        }
    }
}
```

```swift
// Test code
final class NavigatorSpy: Navigating {
    private(set) var presented: [(type: Any.Type, mode: NavigationMode)] = []

    func navigate(to destination: some View, mode: NavigationMode) {
        presented.append((type(of: destination), mode))
    }

    func dismiss() {}
}

func testLockedCountryOpensPaywallAsSheet() {
    let spy = NavigatorSpy()
    let viewModel = CountryListViewModel(navigator: spy, isPro: false)

    viewModel.select(.premiumSample)

    XCTAssertTrue(spy.presented.first?.type == PaywallView.self)
    guard case .present(.sheet)? = spy.presented.first?.mode else {
        return XCTFail("Expected the paywall to be presented as a sheet")
    }
}
```

The view becomes a thin layer that forwards taps to the view model. It holds no navigation state and does not need to know how it was reached.

If your app navigates by destination (an enum such as `.profile(id)` instead of a concrete view), put that enum in the protocol and let the production implementation map each case to a view before calling Waypoint. Tests then assert on the destination value rather than on a view type.

## Design rules

- Waypoint has no dependencies beyond SwiftUI. Dependency injection and app types stay in the app; Waypoint only ever sees `some View` and `AnyHashable` ids.
- Views should not know how they were reached. Build screens as pure functions of their input and let the caller decide the mode.
- Each destination is identified by its own instance. Navigating to the same view type twice pushes two entries; deduplication is the app's responsibility.

## Contributing

Issues and pull requests are welcome. Keep the framework app-agnostic: anything that needs a domain type belongs in the app, not here.

## License

Waypoint is available under the Apache License 2.0. See [LICENSE](LICENSE) for details.
