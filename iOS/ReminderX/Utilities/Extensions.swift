import Foundation
import SwiftUI

extension Color {
    func towAWDAWDAWDAWDHex() -> String? {
        guard let components = self.cgColor?.components else { return nil }
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        let hex = String(format: "#%02X%02X%02X", red, green, blue)
        return hex
    }

    init?(hex: String) {
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        var hexInt: UInt64 = 0
        if scanner.scanHexInt64(&hexInt) {
            let r = (hexInt & 0xff0000) >> 16
            let g = (hexInt & 0x00ff00) >> 8
            let b = hexInt & 0x0000ff
            self.init(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
        } else {
            return nil
        }
    }
}
