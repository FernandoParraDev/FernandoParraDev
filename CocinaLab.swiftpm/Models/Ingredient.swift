import Foundation
import SwiftData

/// An ingredient is a node in the recipe's decision tree, same shape as
/// Step: it always holds at least one variant (quantity + unit), and can
/// gather more as you test different amounts or substitutions.
@Model
final class Ingredient {
    var id: UUID
    var name: String
    var orderIndex: Int
    var recipe: Recipe?
    var selectedVariantID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \IngredientVariant.ingredient)
    var variants: [IngredientVariant] = []

    init(name: String, orderIndex: Int) {
        self.id = UUID()
        self.name = name
        self.orderIndex = orderIndex
    }

    var orderedVariants: [IngredientVariant] {
        variants.sorted { $0.orderIndex < $1.orderIndex }
    }

    var hasMultipleVariants: Bool {
        variants.count > 1
    }

    var primaryVariant: IngredientVariant? {
        if let selectedVariantID, let match = variants.first(where: { $0.id == selectedVariantID }) {
            return match
        }
        return orderedVariants.first
    }

    /// Scales this ingredient's primary-variant quantity proportionally
    /// from the recipe's base servings to a target serving count.
    func scaledQuantity(baseServings: Int, targetServings: Int) -> Double {
        let quantity = primaryVariant?.quantity ?? 0
        guard baseServings > 0 else { return quantity }
        return quantity * (Double(targetServings) / Double(baseServings))
    }
}
