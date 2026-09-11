import SwiftUI

struct SheetModalFlowView: View {
    let presentation: ModalPresentationWrapper

    var body: some View {
        RoutedStackView(router: presentation.router) {
            presentation.destination.view
        }
    }
}

struct FullscreenModalFlowView: View {
    let presentation: ModalPresentationWrapper
    
    var body: some View {
        RoutedStackView(router: presentation.router) {
            presentation.destination.view
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            presentation.router.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
}
