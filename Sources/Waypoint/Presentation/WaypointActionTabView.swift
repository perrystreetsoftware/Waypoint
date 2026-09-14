import SwiftUI

/// A tab bar whose last tab is an action button: it takes the `.search` role (rendered detached from the
/// other tabs) and is never selected — tapping it runs `action` and selection stays where it was.
public struct WaypointActionTabView: View {
    private let navigator = WaypointNavigator.shared
    private let tabs: [RootTab]
    private let actionTab: RootTab
    private let action: () -> Void

    public init(tabs: [RootTab], action: @escaping () -> Void) {
        precondition(tabs.count >= 2, "WaypointActionableTabView needs at least one selectable tab plus the action tab")
        self.tabs = Array(tabs.dropLast())
        self.actionTab = tabs[tabs.count - 1]
        self.action = action
        self.navigator.update(tabs: self.tabs.map(\.id))
    }

    public var body: some View {
        TabView(selection: selection) {
            ForEach(positionedTabs, id: \.identity) { positioned in
                let tab = positioned.tab
                Tab(value: tab.id) {
                    RoutedStackView(router: navigator.router(for: tab.id)) {
                        tab.view
                    }
                } label: {
                    tab.label
                }
            }

            Tab(value: actionTab.id, role: .search) {
                actionTab.view
            } label: {
                actionTab.label
            }
        }
        .environment(navigator)
    }

    private var selection: Binding<NavigatorTab> {
        Binding(
            get: { navigator.selectedTab },
            set: { newValue in
                if newValue == actionTab.id {
                    action()
                } else {
                    navigator.selectedTab = newValue
                }
            })
    }

    private var positionedTabs: [PositionedTab] {
        tabs.positioned()
    }
}
