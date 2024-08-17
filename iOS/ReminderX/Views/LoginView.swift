import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var showingNoInternetAlert = false
    @State private var showingMakeAccountView = false 
    @State private var showingLoginAccountView = false 

    var body: some View {
        VStack {
            Image("login_banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(30)
            Spacer()

            Button(action: {
                checkInternetConnection(for: "login")
            }) {
                loginButtonContent(title: "I Have an Account", imageName: "person.fill")
            }
            .padding(3)
            Button(action: {
                checkInternetConnection(for: "makeAccount")
            }) {
                loginButtonContent(title: "Make an Account", imageName: "person.badge.plus")
            }
            .padding(3)
            Button(action: {
            }) {
                Text("Privacy Policy")
                    .underline()
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top)
        }
        .alert(isPresented: $showingNoInternetAlert) {
            Alert(title: Text("No Internet Connection"), message: Text("Please check your internet connection."), dismissButton: .default(Text("OK")))
        }
        .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingMakeAccountView) {
            MakeAccountView(isAuthenticated: $isAuthenticated)
        }
        .sheet(isPresented: $showingLoginAccountView) {
            LoginAccountView(isAuthenticated: $isAuthenticated)
        }
    }

    private func loginButtonContent(title: String, imageName: String) -> some View {
        HStack {
            Image(systemName: imageName)
            Text(title)
                .fontWeight(.bold)
                .font(.title2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(title == "I Have an Account" ? Color.black.opacity(0.8) : Color.white)
        .foregroundColor(title == "I Have an Account" ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.75), lineWidth: title == "I Have an Account" ? 0 : 2)
        )
        .padding(.horizontal)
        .shadow(radius: 3)
    }

    private func checkInternetConnection(for action: String) {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    DispatchQueue.main.async {
                        switch action {
                        case "makeAccount":
                            self.showingMakeAccountView = true
                        case "login":
                            self.showingLoginAccountView = true
                        default:
                            break
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showingNoInternetAlert = true
                    }
                }
                monitor.cancel()
            }
            let queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)
        }
    }
