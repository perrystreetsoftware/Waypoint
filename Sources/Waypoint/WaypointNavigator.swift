import Foundation
import Observation
import SwiftUI

@Observable
public final class WaypointNavigator {
    // MARK: - Public Properties

    public static let shared = WaypointNavigator()

    public var selectedTab: NavigatorTab!

    // MARK: - Private Properties

    @ObservationIgnored private var tabRouters: [NavigatorTab: Router] = [:]

    private var activeRouter: Router {
        var router = router(for: selectedTab)
        while let presented = router.presentedRouter {
            router = presented
        }
        return router
    }

    // MARK: - Init

    init() {}

    // MARK: - Public Methods

    public func navigate(to destination: some View, mode: NavigationMode) {
        let erasedDestination = AnyNavigatorDestination(destination)

        switch mode {
        case .push:
            activeRouter.push(erasedDestination)
        case .present(let style):
            activeRouter.present(erasedDestination, style: style)
        }
    }

    public func switchTab(to tab: NavigatorTab) {
        guard let targetRouter = tabRouters[tab] else {
            fatalError("Tab \(tab) is not registered")
        }
        router(for: selectedTab).dismissPresented()
        targetRouter.dismissPresented()
        targetRouter.popToRoot()
        selectedTab = tab
    }

    public func dismiss() {
        activeRouter.dismiss()
    }

    public func navigateBack() {
        activeRouter.pop()
    }

    public func navigateToRoot() {
        activeRouter.popToRoot()
    }

    // MARK: - Internal Methods

    func router(for tab: NavigatorTab) -> Router {
        tabRouters[tab]!
    }

    func update(tabs: [NavigatorTab]) {
        precondition(!tabs.isEmpty, "WaypointTabView needs at least one tab")
        precondition(Set(tabs).count == tabs.count, "WaypointTabView tabs must have unique ids")

        tabRouters
            .filter { !tabs.contains($0.key) }
            .values
            .forEach { $0.dismissPresented() }

        tabRouters = Dictionary(uniqueKeysWithValues: tabs.map { ($0, tabRouters[$0] ?? Router()) })

        if selectedTab == nil || !tabs.contains(selectedTab) {
            selectedTab = tabs[0]
        }
    }
}
