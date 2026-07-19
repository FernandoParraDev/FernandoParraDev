import SwiftUI
import SwiftData

/// The "Pruebas de cocina" tab: draft recipes still being experimented on.
/// Tapping a card (or "+") opens the guided node flow; publishing a draft
/// moves it into the "Recetas" tab and drops it out of this list.
struct KitchenTestsListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Recipe> { !$0.isPublished }, sort: \Recipe.createdAt, order: .reverse)
    private var drafts: [Recipe]

    @Binding var publishedPath: NavigationPath
    @Binding var selectedTab: RootTab

    @State private var activeDraft: Recipe?

    private var columns: [GridItem] {
        let minWidth: CGFloat = horizontalSizeClass == .regular ? 260 : 160
        return [GridItem(.adaptive(minimum: minWidth), spacing: 16)]
    }

    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    EmptyStateView(
                        title: "Sin pruebas activas",
                        message: "Empieza una nueva prueba de cocina y avanza paso a paso hasta publicarla.",
                        systemImage: "testtube.2"
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(drafts) { draft in
                                Button {
                                    activeDraft = draft
                                } label: {
                                    RecipeCardView(recipe: draft)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle("Pruebas de cocina")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        startNewDraft()
                    } label: {
                        Label("Nueva prueba", systemImage: "plus")
                    }
                }
            }
            .fullScreenCover(item: $activeDraft) { draft in
                NodeFlowView(recipe: draft, onPublish: publish)
            }
        }
    }

    private func startNewDraft() {
        let recipe = Recipe(name: "")
        modelContext.insert(recipe)
        activeDraft = recipe
    }

    private func publish(_ recipe: Recipe) {
        recipe.isPublished = true
        selectedTab = .recetas
        publishedPath.append(recipe)
    }
}
