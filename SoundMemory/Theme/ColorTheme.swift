import SwiftUI

extension Color {
    // Purple/Blue palette matching Android Material 3 theme
    static let primaryLight = Color(red: 0x62/255, green: 0x00/255, blue: 0xCC/255)    // Primary40
    static let primaryDark = Color(red: 0xCB/255, green: 0x99/255, blue: 0xFF/255)     // Primary80
    static let primaryContainerLight = Color(red: 0xE5/255, green: 0xCC/255, blue: 0xFF/255)  // Primary90
    static let primaryContainerDark = Color(red: 0x4D/255, green: 0x00/255, blue: 0x99/255)   // Primary30

    static let secondaryLight = Color(red: 0x33/255, green: 0x66/255, blue: 0x99/255)  // Secondary40
    static let secondaryDark = Color(red: 0xB3/255, green: 0xD1/255, blue: 0xE6/255)   // Secondary80

    static let tertiaryLight = Color(red: 0xCC/255, green: 0x99/255, blue: 0x00/255)   // Tertiary40
    static let tertiaryDark = Color(red: 0xFF/255, green: 0xE0/255, blue: 0x99/255)    // Tertiary80

    static let surfaceLight = Color(red: 0xFB/255, green: 0xFD/255, blue: 0xFD/255)    // Neutral99
    static let surfaceDark = Color(red: 0x19/255, green: 0x1C/255, blue: 0x1D/255)     // Neutral10

    static let onSurfaceLight = Color(red: 0x19/255, green: 0x1C/255, blue: 0x1D/255)  // Neutral10
    static let onSurfaceDark = Color(red: 0xE0/255, green: 0xE3/255, blue: 0xE3/255)   // Neutral90

    static let surfaceContainerLight = Color(red: 0xEF/255, green: 0xF1/255, blue: 0xF1/255)  // Neutral95
    static let surfaceContainerDark = Color(red: 0x2D/255, green: 0x31/255, blue: 0x32/255)   // Neutral20
}

struct AppTheme {
    @Environment(\.colorScheme) static var colorScheme

    static func primary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .primaryDark : .primaryLight
    }

    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .surfaceDark : .surfaceLight
    }

    static func onSurface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .onSurfaceDark : .onSurfaceLight
    }

    static func surfaceContainer(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .surfaceContainerDark : .surfaceContainerLight
    }
}
