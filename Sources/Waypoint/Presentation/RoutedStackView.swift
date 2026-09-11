import SwiftUI

struct RoutedStackView<Root: View>: View {
    @Bindable var router: Router
    @ViewBuilder let root: () -> Root

    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: AnyNavigatorDestination.self) { destination in
                    destination.view
                }
        }
        .sheet(item: $router.presentedSheet) { presentation in
            SheetModalFlowView(presentation: presentation)
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { presentation in
            FullscreenModalFlowView(presentation: presentation)
        }
    }
}
