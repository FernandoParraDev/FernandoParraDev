import Foundation
import SwiftData

/// One tested amount/notes for an ingredient (e.g. "200 ml" vs "150 ml" of
/// milk) — the ingredient-side counterpart to StepVariant.
@Model
final class IngredientVariant {
    var id: UUID
    var quantity: Double
    var unit: String
    var notes: String
    var createdAt: Date
    var orderIndex: Int
    var ingredient: Ingredient?

    init(quantity: Double, unit: String, notes: String = "", orderIndex: Int = 0) {
        self.id = UUID()
        self.quantity = quantity
        self.unit = unit
        self.notes = notes
        self.createdAt = .now
        self.orderIndex = orderIndex
    }
}
