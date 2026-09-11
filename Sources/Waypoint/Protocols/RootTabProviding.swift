import SwiftUI

public typealias NavigatorTab = AnyHashable

public struct RootTab {
    let id: NavigatorTab
    let view: AnyView

    public init(id: some Hashable, @ViewBuilder view: () -> some View) {
        self.id = id
        self.view = AnyView(view())
    }
}

public protocol RootTabProviding {
    var rootTabs: [RootTab] { get }
}
