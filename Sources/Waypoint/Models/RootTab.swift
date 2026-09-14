import SwiftUI

public typealias NavigatorTab = AnyHashable

public struct RootTab {
    let id: NavigatorTab
    let view: AnyView
    let label: AnyView?

    public init(id: some Hashable, @ViewBuilder view: () -> some View) {
        self.id = id
        self.view = AnyView(view())
        self.label = nil
    }

    public init(id: some Hashable, @ViewBuilder label: () -> some View, @ViewBuilder view: () -> some View) {
        self.id = id
        self.view = AnyView(view())
        self.label = AnyView(label())
    }
}
