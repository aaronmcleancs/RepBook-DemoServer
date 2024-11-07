import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        safariViewController.dismissButtonStyle = .close
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
    
    static func dismantleUIViewController(_ uiViewController: SFSafariViewController, coordinator: ()) {
        uiViewController.dismiss(animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true)
        }
    }
}

extension View {
    func safariSheet(isPresented: Binding<Bool>, url: URL) -> some View {
        self.sheet(isPresented: isPresented) {
            SafariView(url: url)
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(.light)
        }
    }
}
