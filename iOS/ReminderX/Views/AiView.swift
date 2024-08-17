import SwiftUI
import Foundation
import ChatGPTSwift

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isUser: Bool
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
    @State private var aiTypingMessage = ""
    @State private var lastSentMessageDate = Date(timeIntervalSince1970: 0)
    @State private var typingMessages: [(UUID, String)] = []
    @State private var gradientRotation: Double = 0
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
                                    ForEach(typingMessages, id: \.0) { message in
                                        typingMessageView(typingMessage: message.1)
                                    }
                                }
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
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
                .padding(.bottom, 76)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startListeningForKeyboardNotifications()
                if messages.isEmpty {
                }
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
        }
    }
        
        private func isSendButtonEnabled() -> Bool {
            let isInputNotEmpty = !userMessage.trimmingCharacters(in: .whitespaces).isEmpty
            let timeSinceLastMessage = Date().timeIntervalSince(lastSentMessageDate)
            let minTimeBetweenMessages: TimeInterval = 3
            return isInputNotEmpty && !isWaitingForResponse && timeSinceLastMessage >= minTimeBetweenMessages
        }
        
        
        private func sendMessage() {
            let message = ChatMessage(text: userMessage, isUser: true)
            messages.append(message)
            userMessage = ""
            lastSentMessageDate = Date()
            
            isWaitingForResponse = true
            fetchChatGPTResponse(prompt: message.text) { result in
                switch result {
                case .success(let (messageID, aiMessageText)):
                    DispatchQueue.main.async {
                        self.typingMessages.append((messageID, aiMessageText))
                        Task {
                            await Task.sleep(UInt64(0.05 * Double(aiMessageText.count) * 1_000_000))
                            messages.append(ChatMessage(text: aiMessageText, isUser: false))
                            typingMessages.removeAll { $0.0 == messageID }
                            isWaitingForResponse = false
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        private func fetchChatGPTResponse(prompt: String, completion: @escaping (Result<(UUID, String), Error>) -> Void) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentTime = dateFormatter.string(from: Date())
            let chat = """
                Act as FitnessAI, an intelligent fitness assistant specializing in providing workout advice, exercise suggestions, and fitness planning. You're equipped with knowledge about various exercises, workout routines, fitness tips, and basic nutrition advice. Respond to user queries with helpful, accurate, and concise fitness guidance. Please do not create or imagine information outside of these topics. Use natural language and ensure proper capitalization. Keep responses relevant to the user's query and fitness goals. Current date: \(currentTime). User's prompt: \(prompt).
                """
            Task {
                do {
                              let stream = try await api.sendMessageStream(text: chat)
                              var aiMessageText = ""
                              let messageID = UUID()
                              for try await line in stream {
                                  DispatchQueue.main.async {
                                      aiMessageText += line
                                      if let index = typingMessages.firstIndex(where: { $0.0 == messageID }) {
                                          typingMessages[index] = (messageID, aiMessageText)
                                      } else {
                                          typingMessages.append((messageID, aiMessageText))
                                      }
                                      print(line)
                                  }
                              }
                    let suggestionsPrompt = """
                    make me a table of prompts i would likely do next as a user to a calender assistant in this format "Replace with prediction 1 : replace with prediction 2 : replace with prediction 3" and output no other text in your response
                    """
                    let suggestionsStream = try await api.sendMessageStream(text: suggestionsPrompt)
                    var suggestionsText = ""
                    for try await line in suggestionsStream {
                        DispatchQueue.main.async {
                            suggestionsText += line
                        }
                    }
                    let responseArray = suggestionsText.split(separator: ":")
                    for suggestion in responseArray {
                        let trimmedSuggestion = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
                        print(trimmedSuggestion)
                    }
                    
                    
                    let result = Result<(UUID, String), Error>.success((messageID, aiMessageText))
                    handleResult(result)
                }
            }
            
            func handleResult(_ result: Result<(UUID, String), Error>) {
                switch result {
                case .success(let (messageID, aiMessageText)):
                    DispatchQueue.main.async {
                        messages.append(ChatMessage(text: aiMessageText, isUser: false))
                        typingMessages.removeAll { $0.0 == messageID }
                        isWaitingForResponse = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
    private func chatMessageView(message: ChatMessage) -> some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
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
        }
    }

        
        private func typingMessageView(typingMessage: String) -> some View {
            VStack(alignment: .leading) {
                HStack {
                            Text("Node")
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.5))
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(typingMessage)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.2), radius: 3, x: 2, y: 2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
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
