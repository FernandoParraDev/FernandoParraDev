import SwiftUI
import SwiftData

struct IngredientsNodeCard: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ingredientes")
                    .font(.title2.bold())

                ForEach(recipe.orderedIngredients) { ingredient in
                    IngredientNodeRow(ingredient: ingredient) {
                        delete(ingredient)
                    }
                }

                Button {
                    addIngredient()
                } label: {
                    Label("Añadir ingrediente", systemImage: "plus.circle.fill")
                }
                .padding(.top, 4)
            }
            .padding()
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(name: "", quantity: 0, unit: "", orderIndex: recipe.ingredients.count)
        ingredient.recipe = recipe
        recipe.ingredients.append(ingredient)
        modelContext.insert(ingredient)
    }

    private func delete(_ ingredient: Ingredient) {
        recipe.ingredients.removeAll { $0.id == ingredient.id }
        modelContext.delete(ingredient)
    }
}

private struct IngredientNodeRow: View {
    @Bindable var ingredient: Ingredient
    var onDelete: () -> Void

    var body: some View {
        HStack {
            TextField("Cant.", value: $ingredient.quantity, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
            TextField("Unidad", text: $ingredient.unit)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
            TextField("Ingrediente", text: $ingredient.name)
                .textFieldStyle(.roundedBorder)
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
        }
    }
}
