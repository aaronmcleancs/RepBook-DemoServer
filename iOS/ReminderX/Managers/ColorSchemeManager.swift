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
    static let darkColor = Color(red: 0.52, green: 0, blue: 0)
    static let medColor = Color(red: 0.95, green: 0.27, blue: 0.26)
    static let lightColor = Color(red: 1.00, green: 0.63, blue: 0.64)
    
    static let darkBlue = Color(red: 0.85, green: 0.45, blue: 0.00) 
    static let medBlue = Color(red: 0.98, green: 0.65, blue: 0.20) 
    static let lightBlue = Color(red: 1.00, green: 0.80, blue: 0.40) 
    
    static let darkGreen = Color(red: 0.74, green: 0.51, blue: 0)
    static let medGreen = Color(red: 0.99, green: 0.86, blue: 0.38)
    static let lightGreen = Color(red: 1.00, green: 0.98, blue: 0.80)
    
    static let darkOrange = Color(red: 0.15, green: 0.43, blue: 0)
    static let medOrange = Color(red: 0.38, green: 0.80, blue: 0.25) 
    static let lightOrange = Color(red: 0.67, green: 0.95, blue: 0.63)

    static let darkRed = Color(red: 0, green: 0.05, blue: 0.65)
    static let medRed = Color(red: 0.45, green: 0.55, blue: 0.97)
    static let lightRed = Color(red: 0.85, green: 0.87, blue: 1.00)
    
    static let darkViolet = Color(red: 0.15, green: 0, blue: 0.45)
    static let medViolet = Color(red: 0.60, green: 0.45, blue: 0.85)
    static let lightViolet = Color(red: 0.91, green: 0.79, blue: 0.99)
    
    static let darkPink = Color(red: 0.72, green: 0.20, blue: 0.40)
    static let medPink = Color(red: 0.99, green: 0.45, blue: 0.65)
    static let lightPink = Color(red: 1.00, green: 0.79, blue: 0.86)
    
    static let darkMulti1 = Color(red: 0.0, green: 0.2, blue: 0.4)
    static let medMulti1 = Color(red: 0.4, green: 0.7, blue: 0.9)
    static let lightMulti1 = Color(red: 0.8, green: 0.9, blue: 0.98)

}
