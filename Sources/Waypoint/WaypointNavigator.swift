import Foundation
import Observation
import SwiftUI

@Observable
public final class WaypointNavigator {
    // MARK: - Public Properties

    public static let shared = WaypointNavigator()

    public var selectedTab: NavigatorTab!

    // MARK: - Internal Properties

    private(set) var rootTabs: [RootTab]!

    // MARK: - Private Properties

    private var tabRouters: [NavigatorTab: Router]!

    private var activeRouter: Router {
        guard var router = tabRouters[selectedTab] else {
            fatalError("WaypointNavigator.register(tabProvider:) must be called before navigating")
        }
        while let presented = router.presentedRouter {
            router = presented
        }
        return router
    }

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    public func register(tabProvider: RootTabProviding) {
        precondition(tabRouters == nil, "WaypointNavigator is already registered")
        let rootTabs = tabProvider.rootTabs
        precondition(!rootTabs.isEmpty, "RootTabProviding must provide at least one tab")
        self.tabRouters = [:]
        self.rootTabs = rootTabs
        self.selectedTab = rootTabs[0].id
        registerRouters(for: rootTabs.map(\.id))
    }

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
        tabRouters[selectedTab]?.dismissPresented()
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

    // MARK: - Private Methods

    private func registerRouters(for tabs: [NavigatorTab]) {
        tabs.forEach {
            tabRouters[$0] = Router()
        }
    }
}
