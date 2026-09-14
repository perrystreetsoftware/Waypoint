import Foundation

struct PositionedTab {
    struct Identity: Hashable {
        let index: Int
        let id: NavigatorTab
    }

    let identity: Identity
    let tab: RootTab
}

extension [RootTab] {
    func positioned() -> [PositionedTab] {
        enumerated().map { PositionedTab(identity: .init(index: $0.offset, id: $0.element.id), tab: $0.element) }
    }
}
