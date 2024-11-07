import SwiftUI
import Foundation
import ChatGPTSwift

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var webLinks: [WebLink]?
}

struct WebLink: Identifiable, Codable {
    let id = UUID()
    let url: String
    let title: String
    let index: Int
}

struct AiView: View {
    @State private var userMessage = ""
    @State private var messages: [ChatMessage] = []
    @State private var isWaitingForResponse = false
    @State private var showMiniCards = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var navbarVisible: Bool = true
    @State private var isTyping = false
    @State private var typingMessage = ""
    @State private var lastSentMessageDate = Date(timeIntervalSince1970: 0)
    @State private var gradientRotation: Double = 0
    @State private var showWebView: Bool = false
    @State private var selectedURL: String = ""
    @State private var safeData: SafeDataResponse?
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]
    let api = ChatGPTAPI(apiKey: "")

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center,
                                startAngle: .degrees(gradientRotation),
                                endAngle: .degrees(gradientRotation + 360)
                            )
                        )
                        .blur(radius: 70)
                        .edgesIgnoringSafeArea(.vertical)
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: -5, y: -5)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
                        .padding(.horizontal)
                    
                    VStack {
                        if !navbarVisible { Spacer(minLength: 10) }
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack {
                                    ForEach(messages) { message in
                                        chatMessageView(message: message)
                                    }
                                    if isWaitingForResponse {
                                        loadingMessageView()
                                    }
                                }
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                TextField("Ask Anything", text: $userMessage)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.07))
                                    .cornerRadius(15)
                                Button(action: sendMessage) {
                                    Image(systemName: "paperplane")
                                        .foregroundColor(.gray)
                                        .padding(10)
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.bottom, 70)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWebView) {
                if let validURL = URL(string: selectedURL) {
                    SafariView(url: validURL)
                } else {
                    Text("Invalid URL")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .onAppear {
                loadMessages()
                startListeningForKeyboardNotifications()
                fetchSafeData()
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
        }
    }
    
    private func fetchSafeData() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {
            
            print("Fetching safedata for memberId: \(memberId)")
            NetworkManager.fetchSafeData(for: memberId, authKey: authKey) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.safeData = data
                    }
                case .failure(let error):
                    print("Failed to fetch safe data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadingMessageView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Node")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.horizontal)
                
                HStack {
                    VStack {
                        Text("Thinking...")
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 2, y: 2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: isWaitingForResponse)
    }
    
    private func sendMessage() {
        let message = ChatMessage(text: userMessage, isUser: true, webLinks: nil)
        messages.append(message)
        userMessage = ""
        lastSentMessageDate = Date()
        
        isWaitingForResponse = true
        fetchChatGPTResponse(prompt: message.text) { result in
            switch result {
            case .success(let aiMessageText):
                DispatchQueue.main.async {
                    let webLinks = extractWebLinks(from: aiMessageText)
                    let processedText = replaceLinksWithNumbers(text: aiMessageText, links: webLinks)
                    messages.append(ChatMessage(text: processedText, isUser: false, webLinks: webLinks))
                    saveMessages()
                    isWaitingForResponse = false
                }
            case .failure(let error):
                print(error.localizedDescription)
                isWaitingForResponse = false
            }
        }
    }

    private func extractWebLinks(from text: String) -> [WebLink] {
        let pattern = #"\b((https?://)|(www\.))(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})(/[^\s]*)?\b"#
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        
        guard let matches = regex?.matches(in: text, options: [], range: nsRange) else { return [] }
        
        return matches.enumerated().compactMap { index, match in
            guard let range = Range(match.range, in: text) else { return nil }
            var url = String(text[range])
            
            if !url.lowercased().hasPrefix("http://") && !url.lowercased().hasPrefix("https://") {
                url = "https://" + url
            }
            
            if let urlRange = url.range(of: "/"), url.lowercased().suffix(from: urlRange.upperBound) != "" {
                return WebLink(url: url, title: "Web Resource", index: index + 1)
            }
            
            return nil
        }
    }
    
    private func replaceLinksWithNumbers(text: String, links: [WebLink]) -> String {
        var modifiedText = text
        for link in links.sorted(by: { $0.index < $1.index }) {
            modifiedText = modifiedText.replacingOccurrences(of: link.url, with: "[\(link.index)]")
        }
        return modifiedText
    }

    private func fetchChatGPTResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let currentTime = dateFormatter.string(from: Date())
                
                var userDataPrompt = ""
                if let safeData = self.safeData {
                    let workoutDetails = safeData.workouts.map { workout in
                        let exercises = workout.exerciseTitles.joined(separator: ", ")
                        return "\(workout.workoutName): \(exercises)"
                    }.joined(separator: " | ")

                    userDataPrompt = "User: \(safeData.firstName), DOB: \(safeData.dateOfBirth). " +
                                     "Workouts: \(workoutDetails)."
                }
                let chat = "Act as FitnessAI, an intelligent fitness assistant specializing in providing workout advice, exercise suggestions, and fitness planning." +
                "You're equipped with knowledge about various exercises, workout routines, fitness tips, and basic nutrition advice." +
                "Respond to user queries with helpful, accurate, and concise fitness guidance. The chatbot includes a web embeddor for links that you include in your response message and you are encouraged to include useful relevant fitness links when prompted." +
                "Current date: \(currentTime). User's prompt: \(prompt). \(userDataPrompt)"
                
                let aiMessageText = try await api.sendMessage(text: chat)
                completion(.success(aiMessageText))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func chatMessageView(message: ChatMessage) -> some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            
            // Header with User or Node Label
            HStack {
                if !message.isUser {
                    Text("Node")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
                Spacer()
                if message.isUser {
                    Text("You")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal)
            
            // Message Content
            VStack {
                HStack {
                    if message.isUser { Spacer() }
                    VStack(alignment: .leading) {
                        Text(message.text)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 2, y: 2)
                            .foregroundColor(.black)
                    }
                    if !message.isUser { Spacer() }
                }
                .padding(.horizontal)
                
                if let links = message.webLinks, !links.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(links) { link in
                                Button(action: {
                                    selectedURL = link.url
                                    showWebView = true
                                }) {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text("[\(link.index)]")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 16, weight: .medium))
                                            )
                                        
                                        VStack(alignment: .leading) {
                                            Text(link.title)
                                                .font(.system(size: 14, weight: .medium))
                                            Text(link.url)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.3), radius: 2)
                            }
                        }
                        .padding([.top], 8)
                        .padding(.horizontal, 20) // Adjusted to account for increased button padding
                    }
                }
            }
        }
    }
}

extension AiView {
    private func startListeningForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo else { return }
            guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = keyboardSize.height
            navbarVisible = false
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
            navbarVisible = true
        }
    }
}
extension AiView {
    private static let messagesKey = "chatMessages"

    private func saveMessages() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(messages) {
            UserDefaults.standard.set(encoded, forKey: Self.messagesKey)
        }
    }

    private func loadMessages() {
        if let savedMessages = UserDefaults.standard.data(forKey: Self.messagesKey) {
            let decoder = JSONDecoder()
            if let loadedMessages = try? decoder.decode([ChatMessage].self, from: savedMessages) {
                messages = loadedMessages
            }
        }
    }
}
