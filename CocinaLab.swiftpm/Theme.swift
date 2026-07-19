import SwiftUI
import UIKit

/// Warm, old-cookbook visual language: parchment backgrounds, terracotta
/// accents, and serif headings instead of a plain default system look.
enum Theme {
    static let terracotta = Color(red: 0.72, green: 0.38, blue: 0.24)
    static let parchment = Color(red: 0.98, green: 0.94, blue: 0.86)
    static let parchmentDark = Color(red: 0.16, green: 0.13, blue: 0.10)
    static let sage = Color(red: 0.47, green: 0.55, blue: 0.40)

    /// Warm ink brown in light mode, warm cream in dark mode — always
    /// readable against `cardBackground`/`background`.
    static var ink: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.94, green: 0.88, blue: 0.78, alpha: 1)
                : UIColor(red: 0.30, green: 0.20, blue: 0.14, alpha: 1)
        })
    }

    static var background: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(parchmentDark)
                : UIColor(parchment)
        })
    }

    static var cardBackground: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.22, green: 0.18, blue: 0.14, alpha: 1)
                : UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1)
        })
    }
}

extension Text {
    /// Large serif title, evoking a cookbook's chapter heading.
    func cookbookTitle() -> Text {
        self.font(.system(.title2, design: .serif, weight: .bold))
    }

    /// Small serif section label, like a recipe card's handwritten header.
    func cookbookHeading() -> Text {
        self.font(.system(.title3, design: .serif, weight: .semibold))
    }
}

struct CookbookCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.cardBackground)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.terracotta.opacity(0.18), lineWidth: 1)
            )
    }
}

extension View {
    func cookbookCard() -> some View {
        modifier(CookbookCard())
    }
}
