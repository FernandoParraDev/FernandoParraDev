import SwiftUI

/// Guided, node-by-node experimentation flow for a draft recipe: general
/// info, one node per ingredient, one node per step (forking visually when
/// an ingredient or step has multiple variants), "add" nodes, and finally
/// publish.
struct NodeFlowView: View {
    let recipe: Recipe
    var onPublish: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selection: RecipeNode = .info

    private var nodes: [RecipeNode] {
        var items: [RecipeNode] = [.info]
        items += recipe.orderedIngredients.map { .ingredient($0.id) }
        items += [.addIngredient]
        items += recipe.orderedSteps.map { .step($0.id) }
        items += [.addStep, .publish]
        return items
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NodeTrailView(recipe: recipe, nodes: nodes, selection: $selection)

                TabView(selection: $selection) {
                    ForEach(nodes) { node in
                        nodeCard(for: node)
                            .tag(node)
                            .padding()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Theme.background)
            .navigationTitle(recipe.name.isEmpty ? "Nueva prueba" : recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .tint(Theme.terracotta)
    }

    @ViewBuilder
    private func nodeCard(for node: RecipeNode) -> some View {
        switch node {
        case .info:
            InfoNodeCard(recipe: recipe)
        case .ingredient(let id):
            if let ingredient = recipe.ingredients.first(where: { $0.id == id }) {
                IngredientNodeCard(ingredient: ingredient)
            }
        case .addIngredient:
            AddIngredientNodeCard(recipe: recipe) { newIngredient in
                withAnimation { selection = .ingredient(newIngredient.id) }
            }
        case .step(let id):
            if let step = recipe.steps.first(where: { $0.id == id }) {
                StepNodeCard(step: step)
            }
        case .addStep:
            AddStepNodeCard(recipe: recipe) { newStep in
                withAnimation { selection = .step(newStep.id) }
            }
        case .publish:
            PublishNodeCard(recipe: recipe) {
                onPublish(recipe)
                dismiss()
            }
        }
    }
}
