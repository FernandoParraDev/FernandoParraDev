import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var recipeDescription: String
    var baseServings: Int
    var createdAt: Date
    var lastTestedAt: Date?
    var coverPhotoFileName: String?
    var notes: String
    /// false while the recipe is still being experimented on in "Pruebas de
    /// cocina"; true once published into the main "Recetas" library.
    var isPublished: Bool

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient] = []

    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step] = []

    init(
        name: String,
        recipeDescription: String = "",
        baseServings: Int = 4,
        notes: String = "",
        coverPhotoFileName: String? = nil,
        isPublished: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.recipeDescription = recipeDescription
        self.baseServings = max(1, baseServings)
        self.createdAt = .now
        self.lastTestedAt = nil
        self.coverPhotoFileName = coverPhotoFileName
        self.notes = notes
        self.isPublished = isPublished
    }

    var orderedIngredients: [Ingredient] {
        ingredients.sorted { $0.orderIndex < $1.orderIndex }
    }

    var orderedSteps: [Step] {
        steps.sorted { $0.orderIndex < $1.orderIndex }
    }
}
