import SwiftUI

/// Horizontal trail of connected dots showing where you are in the guided
/// node path. Step-nodes with more than one variant show a small branch
/// glyph, echoing the recipe's decision-tree structure. Tapping a dot jumps
/// straight to that node.
struct NodeTrailView: View {
    let recipe: Recipe
    let nodes: [RecipeNode]
    @Binding var selection: RecipeNode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(nodes.enumerated()), id: \.element) { index, node in
                    HStack(spacing: 4) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = node
                            }
                        } label: {
                            dot(for: node)
                        }
                        .buttonStyle(.plain)

                        if index < nodes.count - 1 {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 16, height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func dot(for node: RecipeNode) -> some View {
        let isSelected = node == selection
        ZStack {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.25))
                .frame(width: isSelected ? 14 : 10, height: isSelected ? 14 : 10)

            if hasMultipleVariants(node) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .offset(y: -16)
            }
        }
        .frame(width: 20, height: 24)
    }

    private func hasMultipleVariants(_ node: RecipeNode) -> Bool {
        switch node {
        case .step(let id):
            return recipe.steps.first(where: { $0.id == id })?.hasMultipleVariants ?? false
        case .ingredient(let id):
            return recipe.ingredients.first(where: { $0.id == id })?.hasMultipleVariants ?? false
        default:
            return false
        }
    }
}
