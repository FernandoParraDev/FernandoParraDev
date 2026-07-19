import SwiftUI
import SwiftData

/// Creates a new tested amount (branch) for an existing ingredient.
struct IngredientVariantEditorView: View {
    let ingredient: Ingredient

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var quantity: Double = 0
    @State private var unit = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Cantidad") {
                    TextField("Cantidad", value: $quantity, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Unidad (ej. ml, g, cdas)", text: $unit)
                }

                Section("Notas") {
                    TextField("Notas de esta variante", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("Nueva variante")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(unit.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let variant = IngredientVariant(
            quantity: quantity,
            unit: unit.trimmingCharacters(in: .whitespaces),
            notes: notes,
            orderIndex: ingredient.variants.count
        )
        variant.ingredient = ingredient
        ingredient.variants.append(variant)
        modelContext.insert(variant)
        dismiss()
    }
}
