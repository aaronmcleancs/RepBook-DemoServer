import SwiftUI
import UniformTypeIdentifiers
import SwiftUICharts
import AVKit
import Combine
import CoreImage.CIFilterBuiltins

struct AITool: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct HomeView: View {
    var userInfo: UserInfo
    var userMetrics: [MemberMetric]
    @State private var memberMetrics: MemberMetric?
    @State private var workouts: [Workout] = []
    @State private var blurBackground: Bool = false
    @State private var accentColor: Color = Color.pink
    @State private var showingQuickReminderSheet = false
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage = 0
    @State private var currentTabIndex = 0
    @State private var optionSize: [ColorSchemeOption: CGSize] = [:]
    @State private var currentTime = Date()
    @State private var isScrolled = false
    @State private var showColorOptions = false
    @AppStorage("userColorScheme") private var userColorSchemeRawValue: Int = ColorSchemeOption.red.rawValue
    let totalPages = 3
    let autoSwitchInterval: TimeInterval = 5
    private let cardHeight: CGFloat = 93
    private let cardShadowRadius: CGFloat = 5
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let nameGreeting = " \(userInfo.firstName)"
        
        if hour >= 4 && hour < 12 {
            return "Good Morning" + nameGreeting
        } else if hour >= 12 && hour < 17 {
            return "Good Afternoon" + nameGreeting
        } else {
            return "Good Evening" + nameGreeting
        }
    }
    
    private var currentColorScheme: (dark: Color, med: Color, light: Color) {
        return ColorSchemeOption(rawValue: userColorSchemeRawValue)?.colors ?? (.darkMulti1, .medMulti1, .lightMulti1)
    }
    @State private var selectedCardIndex = 0
    @State private var gradientRotation: Double = 0
    let colorSchemes: [[Color]] = [
        [.darkColor, .medColor, .lightColor],
        [.darkBlue, .medBlue, .lightBlue],
        [.darkGreen, .medGreen, .lightGreen],
        [.darkOrange, .medOrange, .lightOrange],
        [.darkRed, .medRed, .lightRed],
        [.darkViolet, .medViolet, .lightViolet],
        [.darkPink, .medPink, .lightPink],
        [.darkMulti1, .medMulti1, .lightMulti1],
        [.darkMulti2, .medMulti2, .lightMulti2],
        [.darkMulti3, .medMulti3, .lightMulti3]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(
                                    AngularGradient(
                                        gradient: Gradient(colors: [currentColorScheme.dark, currentColorScheme.med, currentColorScheme.light]),
                                        center: .center,
                                        startAngle: .degrees(gradientRotation),
                                        endAngle: .degrees(gradientRotation + 360)
                                    )
                                )
                                .padding(.all, 0)
                                .blur(radius: 45)
                                .frame(height: 60)
                            
                            HStack {
                                VStack() {
                                    Text(greeting)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 2)
                                    HStack {
                                        Image(systemName: "figure.walk.diamond")
                                            .foregroundColor(.white)
                                            .font(Font.system(size: 18, weight: .medium))
                                        Text("1435lb Lifted")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.trailing, 6)
                                        Image(systemName: "calendar")
                                            .foregroundColor(.white)
                                            .font(Font.system(size: 18, weight: .medium))
                                            .padding(.leading, 6)
                                        Text("189 Sessions")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.bottom, 6)
                                }
                            }
                        }
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                            ForEach(0..<1) { _ in
                                wrappedCardView {
                                    TripleHeightCardView(currentColorScheme: [currentColorScheme.dark, currentColorScheme.med, currentColorScheme.light], memberMetrics: $memberMetrics)
                                }
                                VStack(spacing: 20) {
                                    wrappedCardView {
                                        doubleHeightCardView(color: .white)
                                    }
                                    wrappedCardView {
                                        NavigationLink(destination: WorkoutView()) {
                                            cardView(color: .white, text: "Workouts", subtext: "14 workouts saved")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        wrappedCardView {
                            NavigationLink(destination: WorkoutView()) {
                                quadHeightCardView(selectedCardIndex: $selectedCardIndex, color: .blue, currentColorScheme: currentColorScheme)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                                gradientRotation = 360
                            }
                        }
                        .blur(radius: showColorOptions ? 10 : 0)
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(ColorSchemeOption.allCases, id: \.self) { option in
                                        colorButton(option: option)
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .background(Color(.white))
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4)
                        .padding(.horizontal)
                        .blur(radius: showColorOptions ? 10 : 0)
                        .padding(.bottom, 72)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
    private func wrappedCardView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .background(Color(.systemBackground))
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func wrappedCardViewGraph<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .background(Color.green)
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func wrappedCardViewCalender<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func cardView(color: Color, text: String, subtext: String = "", action: (() -> Void)? = nil, doubleHeight: Bool = false, mainTextFontSize: CGFloat = 20, subTextFontSize: CGFloat = 14) -> some View {
        NavigationLink(destination: WorkoutView()) {
            VStack(alignment: .leading) {
                Text(text)
                    .font(.system(size: 20, weight: .bold))
                    .bold()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtext)
                    .font(.system(size: subTextFontSize, weight: .regular, design: .rounded))
                    .foregroundColor(.primary.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(height: doubleHeight ? cardHeight * 2 : cardHeight)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }
    
    let achievements: [Achievement] = [
        Achievement(id: 0, image: "achievement (1)", title: "Plan", subtitle: "Craft your first personalized workout plan and set the foundation for your fitness journey."),
        Achievement(id: 1, image: "achievement (2)", title: "Streak", subtitle: "Maintain a workout streak by hitting the gym or working out at home for several consecutive days."),
        Achievement(id: 2, image: "achievement (3)", title: "PR", subtitle: "Achieve a new personal record in any of your favorite exercises or workouts.")
    ]
    
    private func doubleHeightCardView(color: Color) -> some View {
        VStack(spacing: 10) {
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .cornerRadius(20)
    }
    
    struct InfoCardView: View {
        var symbolName: String
        var title: String
        var subtitle: String
        var colorScheme: Color
        
        private let cardHeight: CGFloat = 45
        private let horizontalSpacing: CGFloat = 6

        var body: some View {
            HStack() {
                Image(systemName: symbolName)
                    .foregroundColor(colorScheme)
                    .font(Font.title)
                    .frame(width: cardHeight, alignment: .center)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(colorScheme)
                    
                    Text(subtitle)
                        .foregroundColor(colorScheme)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: cardHeight)
            .background(colorScheme.opacity(0))
            .shadow(color: Color.black.opacity(0), radius: 3, x: 0, y: 2)
        }
    }
    
    struct TripleHeightCardView: View {
        var currentColorScheme: [Color]
        @Binding var memberMetrics: MemberMetric?

        private let cardHeight: CGFloat = 45
        private let verticalSpacing: CGFloat = 10
        private let additionalPadding: CGFloat = 20

        var body: some View {
            VStack(spacing: verticalSpacing) {
                if let metrics = memberMetrics {
                    InfoCardView(symbolName: "ruler", title: "\(metrics.heightCm) cm", subtitle: "Height", colorScheme: currentColorScheme[1])
                    InfoCardView(symbolName: "scalemass", title: "\(metrics.weightKg) kg", subtitle: "Weight", colorScheme: currentColorScheme[1].opacity(0.85))
                    InfoCardView(symbolName: "person.fill", title: metrics.gender, subtitle: "Gender", colorScheme: currentColorScheme[1].opacity(0.7))
                    InfoCardView(symbolName: "flame.fill", title: "\(metrics.workoutFrequency)", subtitle: "Workout Frequency", colorScheme: currentColorScheme[1].opacity(0.55))
                    
                    if let bodyFat = metrics.bodyFatPercentage {
                        InfoCardView(symbolName: "drop.fill", title: "\(bodyFat)%", subtitle: "Body Fat", colorScheme: currentColorScheme[1].opacity(0.45))
                    }
                    
                    if let activityLevel = metrics.activityLevel {
                        InfoCardView(symbolName: "bolt.fill", title: activityLevel, subtitle: "Activity Level", colorScheme: currentColorScheme[1].opacity(0.37))
                    }
                    
                    if let bmr = metrics.bmrCalories {
                        InfoCardView(symbolName: "flame", title: "\(bmr) kcal", subtitle: "BMR Calories", colorScheme: currentColorScheme[1].opacity(0.3))
                    }
                } else {
                    ForEach(0..<7, id: \.self) { _ in
                        InfoCardLoadingView(colorScheme: currentColorScheme[1])
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: totalHeight())
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [currentColorScheme[1], currentColorScheme[2]]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
            )
        }

        private func totalHeight() -> CGFloat {
            let totalCardHeight = CGFloat(7) * cardHeight
            let totalSpacing = CGFloat(6) * verticalSpacing
            return totalCardHeight + totalSpacing + additionalPadding
        }
    }

    struct InfoCardLoadingView: View {
        var colorScheme: Color
        private let cardHeight: CGFloat = 65

        var body: some View {
            HStack {
                LoadingAnimationView()
                    .frame(width: 30, height: 30)
                    .foregroundColor(colorScheme)
                
                VStack {
                    LoadingAnimationView()
                        .frame(height: 20)
                    LoadingAnimationView()
                        .frame(height: 20)
                }
            }
            .frame(maxWidth: .infinity, minHeight: cardHeight)
            .background(colorScheme.opacity(0))
        }
    }

    struct LoadingAnimationView: View {
        @State private var isAnimating = false
        private let cornerRadius: CGFloat = 10

        var body: some View {
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .cornerRadius(cornerRadius)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.3)
                    .animation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
            }
        }
    }
    private func quadHeightCardView(selectedCardIndex: Binding<Int>, color: Color, subtext: String = "", action: (() -> Void)? = nil, doubleHeight: Bool = false, mainTextFontSize: CGFloat = 20, subTextFontSize: CGFloat = 14, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            aiToolCardView(selectedCardIndex: selectedCardIndex, currentColorScheme: currentColorScheme)
                .frame(maxWidth: .infinity)
            cardSelector(selectedCardIndex: selectedCardIndex, currentColorScheme: currentColorScheme)
        }
    }
    
    private func cardSelector(selectedCardIndex: Binding<Int>, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        HStack {
            let cardTitles = ["Metrics", "Strength", "Friends"]
            ForEach(0..<cardTitles.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedCardIndex.wrappedValue = index
                    }
                }) {
                    Text(cardTitles[index])
                        .font(.system(size: 18))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(selectedCardIndex.wrappedValue == index ? currentColorScheme.med.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedCardIndex.wrappedValue == index ? currentColorScheme.dark : .black.opacity(0.5))
                        .cornerRadius(17)
                }
            }
        }
    }

    private func aiToolCardView(selectedCardIndex: Binding<Int>, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        return CustomGraphCardView(currentColorScheme: currentColorScheme)
    }
    
    private func fetchWorkouts() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching workouts for: \(memberId)")
            NetworkManager.fetchWorkoutsForMember(memberId: memberId, authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedWorkouts):
                        print("Successfully fetched workouts: \(fetchedWorkouts)")
                        self.workouts = fetchedWorkouts
                    case .failure(let error):
                        print("Error fetching workouts: \(error)")
                    }
                }
            }
        } else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
        }
    }
    private func fetchMemberMetrics() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching member metrics for memberId: \(memberId)")
            NetworkManager.fetchMemberMetrics(memberId: memberId, authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedMetrics):
                        print("Successfully fetched member metrics: \(fetchedMetrics)")
                        self.memberMetrics = fetchedMetrics.first
                    case .failure(let error):
                        print("Error fetching member metrics: \(error)")
                    }
                }
            }
        } else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
        }
    }
    private func colorButton(option: ColorSchemeOption) -> some View {
        Button(action: {
            withAnimation {
                userColorSchemeRawValue = option.rawValue
            }
        }) {
            ZStack {
                Circle()
                    .fill(AngularGradient(
                        gradient: Gradient(colors: [option.colors.dark, option.colors.med, option.colors.light, option.colors.med]),
                        center: .center
                    ))
                    .blur(radius: 6)
                    .frame(width: userColorSchemeRawValue == option.rawValue ? 45 : 35, height: userColorSchemeRawValue == option.rawValue ? 45 : 35)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(option.colors.light, lineWidth: 2)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(Circle())
                    )
                    .overlay(
                        Circle()
                            .stroke(option.colors.dark, lineWidth: 2)
                            .blur(radius: 10)
                            .offset(x: 2, y: 2)
                            .mask(Circle())
                    )
                    .scaleEffect(optionSize[option, default: CGSize(width: 35, height: 35)].width / 35)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if userColorSchemeRawValue == option.rawValue {
                                optionSize[option] = CGSize(width: 35, height: 35)
                                userColorSchemeRawValue = ColorSchemeOption.newColor.rawValue
                            } else {
                                optionSize[option] = CGSize(width: 35, height: 35)
                                userColorSchemeRawValue = option.rawValue
                            }
                        }
                    }
            }
        }
        .padding(9)
        .onAppear {
            fetchMemberMetrics()
            fetchWorkouts()
            if userColorSchemeRawValue == option.rawValue {
                DispatchQueue.main.async {
                    optionSize[option] = CGSize(width: 35, height: 35)
                }
            }
        }
    }
}

extension Color {
    func withBrightness(_ brightness: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightnessComponent: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightnessComponent, alpha: &alpha)
        return Color(UIColor(hue: hue, saturation: saturation, brightness: min(brightnessComponent * brightness, 1.0), alpha: alpha))
    }
}

extension Color {
    static let lightColor = Color(red: 0.12, green: 0.26, blue: 0.82)
    static let darkColor = Color(red: 0.38, green: 0.50, blue: 0.96)
    static let medColor = Color(red: 0.64, green: 0.78, blue: 0.96)

    static let darkBlue = Color(red: 0.88, green: 0.14, blue: 0.59)
    static let medBlue = Color(red: 0.94, green: 0.25, blue: 0.25)
    static let lightBlue = Color(red: 0.89, green: 0.75, blue: 0.73)

    static let darkGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let medGreen = Color(red: 0.06, green: 0.53, blue: 0.06)
    static let lightGreen = Color(red: 0.78, green: 0.88, blue: 0.78)

    static let darkOrange = Color(red: 0.96, green: 0.09, blue: 0.00)
    static let medOrange = Color(red: 1.00, green: 0.75, blue: 0.36)
    static let lightOrange = Color(red: 0.79, green: 0.45, blue: 0.59)

    static let darkRed = Color(red: 0.61, green: 0.04, blue: 0.08)
    static let medRed = Color(red: 0.96, green: 0.20, blue: 0.07)
    static let lightRed = Color(red: 0.99, green: 0.67, blue: 0.71)

    static let darkViolet = Color(red: 0.22, green: 0.02, blue: 0.34)
    static let medViolet = Color(red: 0.57, green: 0.19, blue: 0.54)
    static let lightViolet = Color(red: 0.90, green: 0.56, blue: 0.94)

    static let darkPink = Color(red: 0.80, green: 0.08, blue: 0.35)
    static let medPink = Color(red: 0.98, green: 0.43, blue: 0.70)
    static let lightPink = Color(red: 1.0, green: 0.83, blue: 0.92)
    
    static let darkMulti1 = Color(red: 0.114, green: 0.114, blue: 0.522)
    static let medMulti1 = Color(red: 0.427, green: 0.114, blue: 0.522)
    static let lightMulti1 = Color(red: 0.831, green: 0.114, blue: 0.522)

    static let darkMulti2 = Color(red: 1.000, green: 0.408, blue: 0.561)
    static let medMulti2 = Color(red: 1.000, green: 0.627, blue: 0.314)
    static let lightMulti2 = Color(red: 1.000, green: 0.863, blue: 0.314)

    static let darkMulti3 = Color(red: 0.204, green: 0.584, blue: 0.506)
    static let medMulti3 = Color(red: 0.620, green: 0.910, blue: 0.361)
    static let lightMulti3 = Color(red: 0.984, green: 0.973, blue: 0.420)
}
