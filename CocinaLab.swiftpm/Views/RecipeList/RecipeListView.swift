import SwiftUI
import SwiftData

/// The "Recetas" tab: published recipes only. Creation and experimentation
/// happen in the "Pruebas de cocina" tab; a recipe only lands here once
/// it's been published from there.
struct RecipeListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(filter: #Predicate<Recipe> { $0.isPublished }, sort: \Recipe.name)
    private var recipes: [Recipe]

    @Binding var path: NavigationPath
    @State private var searchText = ""

    private var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return recipes }
        let query = searchText.lowercased()
        return recipes.filter { recipe in
            if recipe.name.lowercased().contains(query) { return true }
            return recipe.ingredients.contains { $0.name.lowercased().contains(query) }
        }
    }

    /// Adaptive grid: more, wider columns on iPad; a tighter grid on iPhone.
    private var columns: [GridItem] {
        let minWidth: CGFloat = horizontalSizeClass == .regular ? 260 : 160
        return [GridItem(.adaptive(minimum: minWidth), spacing: 16)]
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if recipes.isEmpty {
                    EmptyStateView(
                        title: "Sin recetas publicadas",
                        message: "Termina una prueba de cocina y publícala para verla aquí.",
                        systemImage: "fork.knife.circle"
                    )
                } else if filteredRecipes.isEmpty {
                    EmptyStateView(
                        title: "Sin resultados",
                        message: "No encontramos recetas ni ingredientes que coincidan con \"\(searchText)\".",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle("Mis recetas")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .searchable(text: $searchText, prompt: "Buscar por nombre o ingrediente")
        }
    }
}
