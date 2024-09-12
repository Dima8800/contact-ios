import SwiftUI
import MessageUI

struct MessageComposeView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var message: String
    var recipients: [String]

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(parent: MessageComposeView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult, error: Error?) {
            parent.isShowing = false
            controller.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = message
        controller.recipients = recipients
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}

struct ContentView: View {
    @State private var isShowingMessageComposer = false

    var body: some View {
        VStack {
            Button("Отправить сообщение") {
                if MFMessageComposeViewController.canSendText() {
                    isShowingMessageComposer = true
                } else {
                    // Показать предупреждение о том, что отправка сообщений невозможна
                    print("Сообщения не могут быть отправлены.")
                }
            }
            .sheet(isPresented: $isShowingMessageComposer) {
                MessageComposeView(isShowing: $isShowingMessageComposer, message: "Привет!", recipients: ["1234567890"])
            }
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
