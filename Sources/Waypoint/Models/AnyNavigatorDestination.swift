import SwiftUI

struct AnyNavigatorDestination: Hashable, Identifiable {
    let id = UUID()
    let view: AnyView

    init(_ view: some View) {
        self.view = AnyView(view)
    }

    static func == (lhs: AnyNavigatorDestination, rhs: AnyNavigatorDestination) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
