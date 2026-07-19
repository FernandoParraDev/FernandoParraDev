import SwiftUI
import SwiftData

@main
struct CocinaLabApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            IngredientVariant.self,
            Step.self,
            StepVariant.self,
            PhotoAsset.self
        ])
    }
}
