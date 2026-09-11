import Foundation
import Observation
import SwiftUI

@Observable
public final class WaypointNavigator {
    public var selectedTab: NavigatorTab
    let rootTabs: [RootTab]
    private var tabRouters: [NavigatorTab: Router] = [:]

    private var activeRouter: Router {
        var router = tabRouters[selectedTab]!
        while let presented = router.presentedRouter {
            router = presented
        }
        return router
    }

    public init(tabProvider: RootTabProviding) {
        let rootTabs = tabProvider.rootTabs
        precondition(!rootTabs.isEmpty, "RootTabProviding must provide at least one tab")
        self.rootTabs = rootTabs
        self.selectedTab = rootTabs[0].id
        self.registerRouters(for: rootTabs.map(\.id))
    }

    func router(for tab: NavigatorTab) -> Router {
        tabRouters[tab]!
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
            assertionFailure("Tab \(tab) is not registered")
            return
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

    private func registerRouters(for tabs: [NavigatorTab]) {
        tabs.forEach {
            tabRouters[$0] = Router()
        }
    }
}
