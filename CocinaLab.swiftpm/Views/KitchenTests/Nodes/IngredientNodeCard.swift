import SwiftUI
import SwiftData

/// A single ingredient's node. When it has more than one tested amount, a
/// segmented control lets you flip between them right here — same
/// underlying data as the branch indicator in the published read view.
struct IngredientNodeCard: View {
    @Bindable var ingredient: Ingredient

    @State private var selectedVariantID: UUID?
    @State private var isAddingVariant = false
    @Environment(\.modelContext) private var modelContext

    private var variants: [IngredientVariant] { ingredient.orderedVariants }

    private var currentVariant: IngredientVariant? {
        variants.first { $0.id == selectedVariantID } ?? variants.first
    }

    private var variantSelectionBinding: Binding<UUID?> {
        Binding(
            get: { selectedVariantID ?? variants.first?.id },
            set: { selectedVariantID = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Ingrediente").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        isAddingVariant = true
                    } label: {
                        Label("Nueva variante", systemImage: "plus.square.on.square")
                            .font(.caption)
                    }
                }

                TextField("Nombre del ingrediente", text: $ingredient.name)
                    .font(.title2.bold())
                    .textFieldStyle(.roundedBorder)

                if variants.count > 1 {
                    Picker("Variante", selection: variantSelectionBinding) {
                        ForEach(variants) { variant in
                            Text("\(Formatters.quantity(variant.quantity)) \(variant.unit)")
                                .tag(variant.id as UUID?)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let variant = currentVariant {
                    IngredientVariantEditor(variant: variant)
                } else {
                    Text("Añade una cantidad para este ingrediente.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button {
                        addFirstVariant()
                    } label: {
                        Label("Añadir cantidad", systemImage: "plus")
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if selectedVariantID == nil {
                selectedVariantID = ingredient.primaryVariant?.id
            }
        }
        .sheet(isPresented: $isAddingVariant) {
            IngredientVariantEditorView(ingredient: ingredient)
        }
    }

    private func addFirstVariant() {
        let variant = IngredientVariant(quantity: 0, unit: "", orderIndex: 0)
        variant.ingredient = ingredient
        ingredient.variants.append(variant)
        modelContext.insert(variant)
        selectedVariantID = variant.id
    }
}

private struct IngredientVariantEditor: View {
    @Bindable var variant: IngredientVariant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cantidad").font(.caption).foregroundStyle(.secondary)
                    TextField("Cantidad", value: $variant.quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unidad").font(.caption).foregroundStyle(.secondary)
                    TextField("ej. ml, g, cdas", text: $variant.unit)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Notas").font(.caption).foregroundStyle(.secondary)
                TextField("Notas de esta variante", text: $variant.notes, axis: .vertical)
                    .lineLimit(2...5)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}
