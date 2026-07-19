import SwiftUI

/// One ingredient line in the read view. When the ingredient has multiple
/// tested amounts, the row becomes a NavigationLink straight into
/// `IngredientVariantsView` for that ingredient.
struct IngredientReadRow: View {
    let ingredient: Ingredient
    let baseServings: Int
    let targetServings: Int

    private var formattedQuantity: String {
        let scaled = ingredient.scaledQuantity(baseServings: baseServings, targetServings: targetServings)
        let unit = ingredient.primaryVariant?.unit ?? ""
        return "\(Formatters.quantity(scaled)) \(unit)"
    }

    var body: some View {
        if ingredient.hasMultipleVariants {
            NavigationLink(value: ingredient) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack {
            Text(formattedQuantity)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(ingredient.name)
                .font(.subheadline)
            Spacer()
            if ingredient.hasMultipleVariants {
                BranchIndicatorView(count: ingredient.variants.count)
            }
        }
    }
}
