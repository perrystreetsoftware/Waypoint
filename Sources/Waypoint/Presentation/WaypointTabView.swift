import SwiftUI

public struct WaypointTabView: View {
    @Environment(WaypointNavigator.self) private var navigator

    public init() {}

    public var body: some View {
        @Bindable var navigator = navigator

        TabView(selection: $navigator.selectedTab) {
            ForEach(navigator.rootTabs, id: \.id) { tab in
                RoutedStackView(router: navigator.router(for: tab.id)) {
                    tab.view
                }
                .tag(tab.id)
            }
        }
    }
}
