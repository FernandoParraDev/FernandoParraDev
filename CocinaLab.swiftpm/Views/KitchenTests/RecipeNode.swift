import Foundation

/// One stop along the guided "Pruebas de cocina" path.
enum RecipeNode: Hashable, Identifiable {
    case info
    case ingredient(UUID)
    case addIngredient
    case step(UUID)
    case addStep
    case publish

    var id: String {
        switch self {
        case .info: return "info"
        case .ingredient(let id): return "ingredient-\(id.uuidString)"
        case .addIngredient: return "addIngredient"
        case .step(let id): return "step-\(id.uuidString)"
        case .addStep: return "addStep"
        case .publish: return "publish"
        }
    }
}
