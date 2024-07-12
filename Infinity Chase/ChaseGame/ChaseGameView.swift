import SwiftUI
import SpriteKit

struct ChaseGameView: View {
    @Environment(\.presentationMode) var prm
    var body: some View {
        VStack {
            SpriteView(scene: ChaseGameScene())
                .ignoresSafeArea()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("back_btn")), perform: { _ in
                    prm.wrappedValue.dismiss()
                })
        }
        .onAppear {
            ApplicationOrigentationChecker.orientationLock = .landscape
        }
        .onDisappear {
            ApplicationOrigentationChecker.orientationLock = .portrait
        }
    }
}

#Preview {
    ChaseGameView()
}
