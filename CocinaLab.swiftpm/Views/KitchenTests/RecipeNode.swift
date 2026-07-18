import Foundation

/// One stop along the guided "Pruebas de cocina" path.
enum RecipeNode: Hashable, Identifiable {
    case info
    case ingredients
    case step(UUID)
    case addStep
    case publish

    var id: String {
        switch self {
        case .info: return "info"
        case .ingredients: return "ingredients"
        case .step(let id): return "step-\(id.uuidString)"
        case .addStep: return "addStep"
        case .publish: return "publish"
        }
    }
}
