import SwiftUI
import SwiftData

@main
struct CocinaLabApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            Step.self,
            StepVariant.self,
            PhotoAsset.self
        ])
    }
}
