import Observation

struct ModalPresentationWrapper: Identifiable {
    let destination: AnyNavigatorDestination
    let router: Router

    var id: UUID { destination.id }

    init(destination: AnyNavigatorDestination, parent: Router) {
        self.destination = destination
        self.router = Router(parent: parent)
    }
}
