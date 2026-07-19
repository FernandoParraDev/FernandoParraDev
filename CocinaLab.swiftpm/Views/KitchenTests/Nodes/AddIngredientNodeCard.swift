import SwiftUI
import SwiftData

/// Trailing "+" node in the ingredients section: creates a new ingredient
/// (with a first variant) and appends it just before this node.
struct AddIngredientNodeCard: View {
    let recipe: Recipe
    var onCreate: (Ingredient) -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "carrot")
                .font(.system(size: 48))
                .foregroundStyle(Theme.terracotta)
            Text("Añadir ingrediente")
                .font(.title3.bold())
            Text("Suma un ingrediente más a esta receta.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                addIngredient()
            } label: {
                Label("Nuevo ingrediente", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(Theme.terracotta.opacity(0.4))
        )
    }

    private func addIngredient() {
        let ingredient = Ingredient(name: "", orderIndex: recipe.ingredients.count)
        ingredient.recipe = recipe
        recipe.ingredients.append(ingredient)
        modelContext.insert(ingredient)

        let variant = IngredientVariant(quantity: 0, unit: "", orderIndex: 0)
        variant.ingredient = ingredient
        ingredient.variants.append(variant)
        modelContext.insert(variant)

        onCreate(ingredient)
    }
}
