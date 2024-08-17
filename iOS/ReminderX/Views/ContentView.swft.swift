import SwiftUI
import WebKit

struct ContentView: View {
    private let cameraURL = URL(string: "https://192.168.0.113:8080/jsfs.html")!

    var body: some View {
        VStack {
            WebView(url: cameraURL)
                .edgesIgnoringSafeArea(.top)

            VStack(spacing: 20) {
                Toggle("Setting 1", isOn: .constant(true))
                    .toggleStyle(SwitchToggleStyle(tint: .black))

                Toggle("Setting 2", isOn: .constant(false))
                    .toggleStyle(SwitchToggleStyle(tint: .black))

                // Add more settings here
            }
            .padding()
            .background(Color.white)
        }
        .preferredColorScheme(.dark)
    }
}
