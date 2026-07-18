import SwiftUI

/// Guided, node-by-node experimentation flow for a draft recipe: general
/// info, ingredients, then one node per step (forking visually when a step
/// has multiple variants), an "add step" node, and finally publish.
struct NodeFlowView: View {
    let recipe: Recipe
    var onPublish: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selection: RecipeNode = .info

    private var nodes: [RecipeNode] {
        var items: [RecipeNode] = [.info, .ingredients]
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
            .navigationTitle(recipe.name.isEmpty ? "Nueva prueba" : recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func nodeCard(for node: RecipeNode) -> some View {
        switch node {
        case .info:
            InfoNodeCard(recipe: recipe)
        case .ingredients:
            IngredientsNodeCard(recipe: recipe)
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
