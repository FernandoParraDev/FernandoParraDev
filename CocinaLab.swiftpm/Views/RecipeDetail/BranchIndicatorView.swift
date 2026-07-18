import SwiftUI

/// Small "stacked cards" badge shown next to a step that has more than one
/// variant. Tapping the row it's attached to jumps straight into that step's
/// variants, bypassing the full recipe edit flow.
struct BranchIndicatorView: View {
    let count: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(-6))
                .offset(x: -3, y: 2)

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.accentColor.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 0.75)
                )
                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
                .frame(width: 26, height: 26)
                .overlay(
                    Text("\(count)")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.accentColor)
                )
        }
        .frame(width: 34, height: 30)
        .accessibilityLabel("\(count) variantes disponibles")
    }
}
