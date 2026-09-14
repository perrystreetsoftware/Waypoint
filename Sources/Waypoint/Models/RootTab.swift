import SwiftUI

public typealias NavigatorTab = AnyHashable

public struct RootTab {
    let id: NavigatorTab
    let view: AnyView
    private let labelBuilder: (_ isSelected: Bool) -> AnyView

    public init(
        id: some Hashable,
        @ViewBuilder label: @escaping () -> some View,
        @ViewBuilder view: () -> some View
    ) {
        self.init(id: id, label: { _ in label() }, view: view)
    }

    public init(
        id: some Hashable,
        @ViewBuilder label: @escaping (_ isSelected: Bool) -> some View,
        @ViewBuilder view: () -> some View
    ) {
        self.id = id
        self.view = AnyView(view())
        self.labelBuilder = { AnyView(label($0)) }
    }

    func label(isSelected: Bool) -> AnyView {
        labelBuilder(isSelected)
    }
}
