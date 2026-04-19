import SwiftUI

struct NeoTheme: Identifiable {
    let id = UUID()
    let name: String
    let backgroundColor: Color
    let tileColors: [Color]
    let accentColor: Color
    let textColor: Color
}

struct ThemeManager {
    static let themes: [NeoTheme] = [
        // 1. The General (Olive & Tan)
        NeoTheme(
            name: "General",
            backgroundColor: Color(red: 85/255, green: 107/255, blue: 47/255), // Olive Drab
            tileColors: [
                Color(red: 210/255, green: 180/255, blue: 140/255), // Tan
                Color(red: 107/255, green: 142/255, blue: 35/255),  // Olive Green
                Color(red: 139/255, green: 69/255, blue: 19/255),   // Saddle Brown
                Color.black
            ],
            accentColor: .black,
            textColor: .white
        ),
        
        // 2. Naval Officer (Navy & Gold)
        NeoTheme(
            name: "Navy",
            backgroundColor: Color(red: 0/255, green: 0/255, blue: 128/255), // Navy
            tileColors: [
                Color(red: 255/255, green: 215/255, blue: 0/255),  // Gold
                .white,
                Color(red: 70/255, green: 130/255, blue: 180/255), // Steel Blue
                Color(red: 25/255, green: 25/255, blue: 112/255)   // Midnight
            ],
            accentColor: .white,
            textColor: .white
        ),
        
        // 3. Desert Recon (Khaki & Coyote)
        NeoTheme(
            name: "Desert",
            backgroundColor: Color(red: 194/255, green: 178/255, blue: 128/255), // Khaki
            tileColors: [
                Color(red: 139/255, green: 115/255, blue: 85/255),  // Coyote
                Color(red: 245/255, green: 245/255, blue: 220/255), // Beige
                Color(red: 222/255, green: 184/255, blue: 135/255), // Burlywood
                Color(red: 101/255, green: 67/255, blue: 33/255)    // Dark Brown
            ],
            accentColor: .black,
            textColor: .black
        ),
        
        // 4. Airborne (Slate & Sky)
        NeoTheme(
            name: "Airborne",
            backgroundColor: Color(red: 112/255, green: 128/255, blue: 144/255), // Slate Gray
            tileColors: [
                Color(red: 135/255, green: 206/255, blue: 235/255), // Sky Blue
                Color(red: 176/255, green: 196/255, blue: 222/255), // Light Steel
                Color(red: 240/255, green: 248/255, blue: 255/255), // Alice Blue
                Color(red: 47/255, green: 79/255, blue: 79/255)    // Dark Slate
            ],
            accentColor: .black,
            textColor: .black
        ),
        
        // 5. Semper Fi (Scarlet & Gold)
        NeoTheme(
            name: "Marine",
            backgroundColor: Color(red: 139/255, green: 0/255, blue: 0/255), // Dark Red
            tileColors: [
                Color(red: 255/255, green: 215/255, blue: 0/255), // Gold
                Color(red: 178/255, green: 34/255, blue: 34/255), // Firebrick
                Color(red: 255/255, green: 255/255, blue: 255/255), // White
                .black
            ],
            accentColor: .white,
            textColor: .white
        ),
        
        // 6. Liberty (Patriotic)
        NeoTheme(
            name: "Liberty",
            backgroundColor: Color(red: 10/255, green: 49/255, blue: 97/255), // Old Glory Blue
            tileColors: [
                Color(red: 191/255, green: 10/255, blue: 48/255), // Old Glory Red
                .white,
                Color(red: 0/255, green: 33/255, blue: 71/255),   // Navy
                Color(red: 245/255, green: 245/255, blue: 245/255) // Off-white
            ],
            accentColor: .white,
            textColor: .white
        ),
        
        // 7. Stealth (Graphite)
        NeoTheme(
            name: "Stealth",
            backgroundColor: Color(white: 0.1),
            tileColors: [
                Color(white: 0.3),                 // Charcoal
                Color(red: 1.0, green: 0.0, blue: 0.0), // Tactical Red accent
                Color(white: 0.2),                 // Onyx
                Color(white: 0.8)                  // Ash
            ],
            accentColor: .white,
            textColor: .white
        ),
        
        // 8. Coast Guard (Blue & Red)
        NeoTheme(
            name: "Rescue",
            backgroundColor: Color(red: 0/255, green: 90/255, blue: 156/255), // CG Blue
            tileColors: [
                Color(red: 239/255, green: 51/255, blue: 64/255), // CG Red
                .white,
                Color(red: 176/255, green: 196/255, blue: 222/255), // Light Steel
                Color(red: 0/255, green: 32/255, blue: 91/255)    // Deep Navy
            ],
            accentColor: .white,
            textColor: .white
        ),
        
        // 9. Medal of Honor (Sky Blue & Gold)
        NeoTheme(
            name: "Medal",
            backgroundColor: Color(red: 135/255, green: 206/255, blue: 250/255), // Ribbon Blue
            tileColors: [
                Color(red: 212/255, green: 175/255, blue: 55/255), // Medal Gold
                .white,
                Color(red: 70/255, green: 130/255, blue: 180/255), // Steel Blue
                Color(red: 0/255, green: 0/255, blue: 128/255)    // Navy
            ],
            accentColor: .black,
            textColor: .black
        ),
        
        // 10. Woodland (Forest & Earth)
        NeoTheme(
            name: "Woodland",
            backgroundColor: Color(red: 34/255, green: 139/255, blue: 34/255), // Forest Green
            tileColors: [
                Color(red: 101/255, green: 67/255, blue: 33/255),  // Dark Earth
                Color(red: 85/255, green: 107/255, blue: 47/255),  // Olive
                Color(red: 139/255, green: 115/255, blue: 85/255), // Coyote
                .black
            ],
            accentColor: .white,
            textColor: .white
        )
    ]
}
