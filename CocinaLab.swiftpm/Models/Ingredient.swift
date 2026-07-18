import Foundation
import SwiftData

@Model
final class Ingredient {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var orderIndex: Int
    var recipe: Recipe?

    init(name: String, quantity: Double, unit: String, orderIndex: Int) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.orderIndex = orderIndex
    }

    /// Scales this ingredient's quantity proportionally from the recipe's base
    /// servings to a target serving count chosen by the user in the read view.
    func scaledQuantity(baseServings: Int, targetServings: Int) -> Double {
        guard baseServings > 0 else { return quantity }
        return quantity * (Double(targetServings) / Double(baseServings))
    }
}
