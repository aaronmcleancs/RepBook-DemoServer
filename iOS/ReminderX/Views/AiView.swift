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
    
    @State private var conversationTitle: String = ""
    @State private var hasGeneratedTitle: Bool = false
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]
    let api = ChatGPTAPI(apiKey: "") 
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
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
                                // Title Section
                                VStack(alignment: .leading, spacing: 4) {
                                    if !conversationTitle.isEmpty {
                                        Text(conversationTitle)
                                            .font(.title)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                LazyVStack {
                                    ForEach(messages) { message in
                                        chatMessageView(message: message)
                                    }
                                    if isWaitingForResponse {
                                        loadingMessageView()
                                    }
                                    // Hidden Scroll Anchor
                                    Color.clear
                                        .frame(height: 1)
                                        .id("bottom")
                                }
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                            }
                            // Automatic Scrolling to Bottom
                            .onChange(of: messages.count) { _ in
                                withAnimation(.easeOut(duration: 0.25)) {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                }
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
                .padding(.bottom, keyboardHeight > 0 ? 0 : 70)
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
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
                startListeningForKeyboardNotifications()
                fetchSafeData()
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                messages.removeAll()
                conversationTitle = ""
                hasGeneratedTitle = false
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
        guard !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return } // Prevent sending empty messages
        let message = ChatMessage(text: userMessage, isUser: true, webLinks: nil)
        messages.append(message)
        userMessage = ""
        lastSentMessageDate = Date()
        
        isWaitingForResponse = true
        fetchChatGPTResponse(prompt: message.text) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let aiMessageText):
                    let webLinks = extractWebLinks(from: aiMessageText)
                    let processedText = replaceLinksWithNumbers(text: aiMessageText, links: webLinks)
                    messages.append(ChatMessage(text: processedText, isUser: false, webLinks: webLinks))
                    
                    if !hasGeneratedTitle, messages.count >= 2 {
                        let firstUserMessage = messages.first { $0.isUser }?.text ?? ""
                        let firstAIResponse = messages.first { !$0.isUser }?.text ?? ""
                        generateConversationTitle(firstUserMessage: firstUserMessage, firstAIResponse: firstAIResponse)
                    }
                case .failure(let error):
                    messages.append(ChatMessage(text: "Failed to get response: \(error.localizedDescription)", isUser: false, webLinks: nil))
                }
                isWaitingForResponse = false
            }
        }
    }

    private func generateConversationTitle(firstUserMessage: String, firstAIResponse: String) {
        let prompt = "Create a concise 5-10 word title summarizing the following conversation, return nothing but the title in your response, it will be directly placed in the title card on the ui of the app, so any extra syntax or 'Title: ' for example is not wanted and should never be included :\nUser: \(firstUserMessage)\nAI: \(firstAIResponse)"
        fetchChatGPTTitle(prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let title):
                    self.conversationTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.hasGeneratedTitle = true
                case .failure(let error):
                    print("Failed to generate title: \(error.localizedDescription)")
                    self.conversationTitle = "Conversation"
                }
            }
        }
    }

    private func fetchChatGPTTitle(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let title = try await api.sendMessage(text: prompt)
                completion(.success(title))
            } catch {
                completion(.failure(error))
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
                let chat = """
                Act as FitnessAI, an intelligent fitness assistant specializing in providing workout advice, exercise suggestions, and fitness planning. \
                You're equipped with knowledge about various exercises, workout routines, fitness tips, and basic nutrition advice. \
                Respond to user queries with helpful, accurate, and concise fitness guidance. The chatbot includes a web embeddor for links that you include in your response message and you are encouraged to include useful relevant fitness links when prompted. \
                Current date: \(currentTime). User's prompt: \(prompt). \(userDataPrompt)
                """
                
                let aiMessageText = try await api.sendMessage(text: chat)
                print("AI Response Received: \(aiMessageText)") // Debugging
                completion(.success(aiMessageText))
            } catch {
                print("Error fetching AI response: \(error.localizedDescription)") // Debugging
                completion(.failure(error))
            }
        }
    }
    
    private func chatMessageView(message: ChatMessage) -> some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            
            HStack {
                if !message.isUser {
                    Text("RepBot")
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
                        .padding(.horizontal, 20) 
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
