import SwiftUI

/// A tab bar whose last tab is an action button: it takes the `.search` role (rendered detached from the
/// other tabs) and is never selected — tapping it runs `action` and selection stays where it was.
public struct WaypointActionTabView: View {
    private let navigator = WaypointNavigator.shared
    private let tabs: [RootTab]
    private let actionTab: RootTab
    private let action: () -> Void
    // Local mirror of navigator.selectedTab: the action tab id must never reach the navigator,
    // or update(tabs:) would treat it as unregistered and reset selection to the first tab.
    @State private var selection: NavigatorTab

    public init(tabs: [RootTab], action: @escaping () -> Void) {
        precondition(tabs.count >= 2, "WaypointActionableTabView needs at least one selectable tab plus the action tab")
        self.tabs = Array(tabs.dropLast())
        self.actionTab = tabs[tabs.count - 1]
        self.action = action
        self.navigator.update(tabs: self.tabs.map(\.id))
        self._selection = State(initialValue: navigator.selectedTab!)
    }

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(positionedTabs, id: \.identity) { positioned in
                let tab = positioned.tab
                Tab(value: tab.id) {
                    RoutedStackView(router: navigator.router(for: tab.id)) {
                        tab.view
                    }
                } label: {
                    tab.label(isSelected: navigator.selectedTab == tab.id)
                }
            }

            Tab(value: actionTab.id, role: .search) {
                actionTab.view
            } label: {
                actionTab.label(isSelected: false)
            }
        }
        .environment(navigator)
        .onChange(of: selection) { previousTab, selectedTab in
            if selectedTab == actionTab.id {
                selection = previousTab
                action()
            } else {
                navigator.selectedTab = selectedTab
            }
        }
        .onChange(of: navigator.selectedTab) { _, selectedTab in
            if let selectedTab, selectedTab != selection {
                selection = selectedTab
            }
        }
    }

    private var positionedTabs: [PositionedTab] {
        tabs.positioned()
    }
}
