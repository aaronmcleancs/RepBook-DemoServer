import SwiftUI

class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    
    private init() { }
    
    @Published var transitionDuration: Double = 0.45
    
    private var userColorSchemeRawValue: Int {
        get {
            return UserDefaults.standard.integer(forKey: "userColorScheme")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userColorScheme")
        }
    }
    
    var currentColorScheme: (dark: Color, med: Color, light: Color) {
        return ColorSchemeOption(rawValue: userColorSchemeRawValue)?.colors ?? (.darkMulti1, .medMulti1, .lightMulti1)
    }
    
    func updateColorScheme(to newColorScheme: ColorSchemeOption) {
        withAnimation(.easeInOut(duration: self.transitionDuration)) {
            self.userColorSchemeRawValue = newColorScheme.rawValue
        }
    }
}

enum ColorSchemeOption: Int, CaseIterable {
    case system
    case red
    case orange
    case green
    case newColor
    case blue
    case violet
    case pink

    var colors: (dark: Color, med: Color, light: Color) {
        switch self {
        case .system:
            return (Color.black.opacity(0.5), Color.black.opacity(0.70), Color(UIColor.systemGray5))
        case .red:
            return (ColorScheme.darkColor, ColorScheme.medColor, ColorScheme.lightColor)
        case .orange:
            return (ColorScheme.darkBlue, ColorScheme.medBlue, ColorScheme.lightBlue)
        case .green:
            return (ColorScheme.darkOrange, ColorScheme.medOrange, ColorScheme.lightOrange)
        case .blue:
            return (ColorScheme.darkRed, ColorScheme.medRed, ColorScheme.lightRed)
        case .violet:
            return (ColorScheme.darkViolet, ColorScheme.medViolet, ColorScheme.lightViolet)
        case .pink:
            return (ColorScheme.darkPink, ColorScheme.medPink, ColorScheme.lightPink)
        case .newColor:
            return (ColorScheme.darkMulti1, ColorScheme.medMulti1, ColorScheme.lightMulti1)
        }
    }
}

struct ColorScheme {
    // Base Colors
    static let darkColor = Color(red: 0.50, green: 0.02, blue: 0.02)
    static let medColor = Color(red: 0.92, green: 0.30, blue: 0.28)
    static let lightColor = Color(red: 1.00, green: 0.65, blue: 0.67)
    
    // Blue Palette
    static let darkBlue = Color(red: 0.80, green: 0.40, blue: 0.05)
    static let medBlue = Color(red: 0.95, green: 0.70, blue: 0.25)
    static let lightBlue = Color(red: 1.00, green: 0.85, blue: 0.50)
    
    // Green Palette
    static let darkGreen = Color(red: 0.70, green: 0.45, blue: 0.05)
    static let medGreen = Color(red: 0.95, green: 0.90, blue: 0.45)
    static let lightGreen = Color(red: 1.00, green: 0.95, blue: 0.85)
    
    // Orange Palette
    static let darkOrange = Color(red: 0.12, green: 0.40, blue: 0.05)
    static let medOrange = Color(red: 0.35, green: 0.75, blue: 0.30)
    static let lightOrange = Color(red: 0.70, green: 0.98, blue: 0.68)
    
    // Red Palette
    static let darkRed = Color(red: 0.10, green: 0.20, blue: 0.80)
    static let medRed = Color(red: 0.30, green: 0.50, blue: 0.90)
    static let lightRed = Color(red: 0.60, green: 0.80, blue: 1.00)
    
    // Violet Palette
    static let darkViolet = Color(red: 0.10, green: 0.05, blue: 0.50)
    static let medViolet = Color(red: 0.65, green: 0.50, blue: 0.90)
    static let lightViolet = Color(red: 0.95, green: 0.85, blue: 1.00)
    
    // Pink Palette
    static let darkPink = Color(red: 0.70, green: 0.25, blue: 0.45)
    static let medPink = Color(red: 0.95, green: 0.50, blue: 0.75)
    static let lightPink = Color(red: 1.00, green: 0.85, blue: 0.90)
    
    // Multi Palette
    static let darkMulti1 = Color(red: 0.05, green: 0.25, blue: 0.45)
    static let medMulti1 = Color(red: 0.45, green: 0.75, blue: 0.95)
    static let lightMulti1 = Color(red: 0.85, green: 0.95, blue: 0.99)
}
