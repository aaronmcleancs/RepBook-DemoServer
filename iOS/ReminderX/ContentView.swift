import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var userInfo: UserInfo?
    @State private var userMetrics: [MemberMetric] = []
    
    var body: some View {
        Group {
            if isAuthenticated, let userInfo = userInfo {
                MainAppView(userMetrics: userMetrics, userInfo: userInfo)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = KeychainManager.load(service: "YourAppService", account: "userId") != nil
                       fetchUserDataIfNeeded()
                       fetchUserMetricsIfNeeded()
        }
        .environment(\.colorScheme, .light)
    }
    
    private func fetchUserDataIfNeeded() {
        if isAuthenticated {
            if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
               let memberIdString = String(data: memberIdData, encoding: .utf8),
               let memberId = Int(memberIdString),
               let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
               let authKey = String(data: authKeyData, encoding: .utf8) {
               NetworkManager.fetchUserDataAndMetrics(memberId: memberId, authKey: authKey) { fetchedUserInfo in
                    DispatchQueue.main.async {
                        self.userInfo = fetchedUserInfo
                    }
                }
            }
        }
    }
    private func fetchUserMetricsIfNeeded() {
        if isAuthenticated {
            if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
               let memberIdString = String(data: memberIdData, encoding: .utf8),
               let memberId = Int(memberIdString),
               let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
               let authKey = String(data: authKeyData, encoding: .utf8) {
                
                NetworkManager.fetchMemberMetrics(memberId: memberId, authKey: authKey) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedMetrics):
                            self.userMetrics = fetchedMetrics
                        case .failure(let error):
                            print("Error fetching user metrics: \(error)")
                        }
                    }
                }
            }
        }
    }
}
struct MainAppView: View {
    var userMetrics: [MemberMetric]
    var userInfo: UserInfo
    @State private var selection: Int = 0
    @State private var keyboardVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                Group {
                    switch selection {
                    case 0:
                        HomeView(userInfo: userInfo, userMetrics: userMetrics)
                    case 1:
                        WorkoutView()
                    case 2:
                        AiView()
                    case 3:
                        SettingsView(userInfo: userInfo, userMetrics: userMetrics)
                    default:
                        EmptyView()
                    }
                }
            }
            if !keyboardVisible {
                CustomTabBar(selection: $selection)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil, queue: .main) { _ in
                    keyboardVisible = true
                }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil, queue: .main) { _ in
                    keyboardVisible = false
                }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}
