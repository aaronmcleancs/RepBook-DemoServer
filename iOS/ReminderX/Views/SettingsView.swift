import SwiftUI
import Foundation

struct SettingsView: View {
    var userInfo: UserInfo
    var userMetrics: [MemberMetric]
    @State private var heightFeet: String = "5"
    @State private var heightInches: String = "6"
    @State private var weight: String = "70"
    @State private var weightUnit: WeightUnit = .lbs

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                settingsSection(title: "Personal Information", settings: personalInformationSettings())
                settingsSection(title: "Health Metrics", settings: healthMetricsSettings())
                settingsSection(title: "Workout Preferences", settings: workoutPreferencesSettings())
                settingsSection(title: "Nutrition", settings: nutritionSettings())
                settingsSection(title: "App Settings", settings: appSettings())

                Button(action: logOut) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .font(.title3)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 80)
        }
    }
    
    private func personalInformationSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "person.fill", title: "First Name", actionView: AnyView(Text(userInfo.firstName))),
            SettingItem(iconName: "person.fill", title: "Last Name", actionView: AnyView(Text(userInfo.lastName))),
            SettingItem(iconName: "envelope.fill", title: "Email", actionView: AnyView(Text(userInfo.email))),
            SettingItem(iconName: "calendar", title: "Date of Birth", actionView: AnyView(Text(userInfo.dateOfBirth))),
        ]
    }
    
    private func healthMetricsSettings() -> [SettingItem<AnyView>] {
         [
             SettingItem(iconName: "figure.walk", title: "Gender", actionView: AnyView(Text("Male"))),
             SettingItem(iconName: "arrow.up.and.down", title: "Height", actionView: AnyView(HeightEntryView(heightFeet: $heightFeet, heightInches: $heightInches))),
             SettingItem(iconName: "scalemass.fill", title: "Weight", actionView: AnyView(WeightEntryView(weight: $weight, unit: $weightUnit))),
             SettingItem(iconName: "heart.fill", title: "Resting Heart Rate", actionView: AnyView(Text("70 BPM"))),
         ]
     }
    
    private func workoutPreferencesSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "flame.fill", title: "Fitness Goal", actionView: AnyView(Text("Weight Loss"))),
            SettingItem(iconName: "clock.fill", title: "Preferred Workout Time", actionView: AnyView(Text("Morning"))),
            SettingItem(iconName: "location.fill", title: "Preferred Workout Location", actionView: AnyView(Text("Outdoor"))),
        ]
    }
    
    private func nutritionSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "leaf.fill", title: "Dietary Preferences", actionView: AnyView(Text("Vegetarian"))),
            SettingItem(iconName: "applelogo", title: "Daily Caloric Intake", actionView: AnyView(Text("2000 kcal"))),
            SettingItem(iconName: "cup.and.saucer.fill", title: "Water Intake Goal", actionView: AnyView(Text("2L"))),
        ]
    }
    
    private func appSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "paintbrush.fill", title: "Theme Color", actionView: AnyView(Text("Blue"))),
            SettingItem(iconName: "gear", title: "Language", actionView: AnyView(Text("English"))),
        ]
    }
    
    @ViewBuilder
    private func settingsSection(title: String, settings: [SettingItem<AnyView>]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(settings.indices, id: \.self) { index in
                let isFirst = index == settings.startIndex
                let isLast = index == settings.index(before: settings.endIndex)
                SettingItemView(setting: settings[index], isFirst: isFirst, isLast: isLast)
            }
        }
        .padding(.horizontal)
    }
    
    private func changeName() {
    }
    
    private func changeUsername() {
    }
    
    private func logOut() {
        KeychainManager.delete(service: "YourAppService", account: "userId")
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogOut"), object: nil)
    }
    
    private func settingItemView(iconName: String, title: String) -> some View {
            HStack {
                Image(systemName: iconName)
                Text(title)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }

}

struct SettingItemView<Content: View>: View {
    var setting: SettingItem<Content>
    var isFirst: Bool
    var isLast: Bool

    var body: some View {
        HStack {
            Image(systemName: setting.iconName)
            Text(setting.title)
            Spacer()
            setting.actionView
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15, corners: isFirst ? [.topLeft, .topRight] : isLast ? [.bottomLeft, .bottomRight] : [])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SettingItem<Content: View>: Identifiable {
    var id = UUID()
    var iconName: String
    var title: String
    var actionView: Content
}
