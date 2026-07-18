import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: \Recipe.name) private var recipes: [Recipe]

    @State private var searchText = ""
    @State private var isPresentingNewRecipe = false

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
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    EmptyStateView(
                        title: "Sin recetas todavía",
                        message: "Crea tu primera receta y empieza a experimentar en la cocina.",
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
            .navigationTitle("Mis recetas")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingNewRecipe = true
                    } label: {
                        Label("Nueva receta", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar por nombre o ingrediente")
            .sheet(isPresented: $isPresentingNewRecipe) {
                RecipeFormView(existingRecipe: nil)
            }
        }
    }
}
