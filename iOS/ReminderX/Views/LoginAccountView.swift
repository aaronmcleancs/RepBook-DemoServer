import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct LoginAccountView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        VStack {
            Image("login_banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(30)
            
            TextField("Username or Email", text: $email)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            Button(action: {
                loginUser()
            }) {
                Text("Login")
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.85))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
            }
            Spacer()
            Button(action: {
            }) {
                Text("Privacy Policy")
                    .underline()
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
        }
        .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
    
    func loginUser() {
        guard let url = URL(string: "http://192.168.0.146:3000/login") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let userData: [String: Any] = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Attempting login with Email: \(email), Password: \(password)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch let error {
            errorMessage = "Failed to encode user data: \(error.localizedDescription)"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { 
                if let error = error {
                    self.errorMessage = "Error occurred: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.handleSuccessfulLogin(data: data)
                    } else {
                        self.errorMessage = httpResponse.statusCode == 401 ? "Invalid credentials" : "Server error"
                    }
                } else {
                    self.errorMessage = "No server response"
                }
            }
        }.resume()
    }
    
    private func handleSuccessfulLogin(data: Data?) {
        DispatchQueue.main.async {
            guard let data = data else {
                self.errorMessage = "Invalid server response"
                return
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                // Save to Keychain
                let userIdStatus = KeychainManager.save("\(loginResponse.memberId)".data(using: .utf8)!,
                                                        service: "YourAppService",
                                                        account: "userId")
                let authKeyStatus = KeychainManager.save(loginResponse.authKey.data(using: .utf8)!,
                                                         service: "YourAppService",
                                                         account: "authKey")
                
                if userIdStatus == noErr && authKeyStatus == noErr {
                    self.isAuthenticated = true
                } else {
                    self.errorMessage = "Failed to save credentials"
                }
            } catch {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }
    }
}
