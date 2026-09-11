import SwiftUI

@Observable
final class Router {
    var path: [AnyNavigatorDestination] = []
    var presentedSheet: ModalPresentationWrapper?
    var presentedFullScreenCover: ModalPresentationWrapper?
    private(set) weak var parent: Router?

    init(parent: Router? = nil) {
        self.parent = parent
    }

    var presentedRouter: Router? {
        presentedFullScreenCover?.router ?? presentedSheet?.router
    }

    func push(_ destination: AnyNavigatorDestination) {
        path.append(destination)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func present(_ destination: AnyNavigatorDestination, style: ModalStyle) {
        let presentation = ModalPresentationWrapper(destination: destination, parent: self)
        switch style {
        case .sheet:
            self.presentedSheet = presentation
        case .fullScreenCover:
            self.presentedFullScreenCover = presentation
        }
    }

    func dismiss() {
        parent?.presentedSheet = nil
        parent?.presentedFullScreenCover = nil
    }

    func dismissPresented() {
        presentedSheet = nil
        presentedFullScreenCover = nil
    }
}
