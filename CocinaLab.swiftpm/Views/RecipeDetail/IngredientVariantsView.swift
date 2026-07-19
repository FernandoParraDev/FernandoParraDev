import SwiftUI

/// Deep-link destination for a single ingredient's tested amounts. Reached
/// directly from its branch indicator in the read view.
struct IngredientVariantsView: View {
    let ingredient: Ingredient

    @State private var selectedVariantID: UUID?
    @State private var isAddingVariant = false

    private var variants: [IngredientVariant] {
        ingredient.orderedVariants
    }

    private var selectionBinding: Binding<UUID?> {
        Binding(
            get: { selectedVariantID ?? variants.first?.id },
            set: { selectedVariantID = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            if variants.count > 1 {
                Picker("Variante", selection: selectionBinding) {
                    ForEach(variants) { variant in
                        Text("\(Formatters.quantity(variant.quantity)) \(variant.unit)")
                            .tag(variant.id as UUID?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)
            }

            TabView(selection: selectionBinding) {
                ForEach(variants) { variant in
                    IngredientVariantDetailCard(variant: variant)
                        .tag(variant.id as UUID?)
                        .padding()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: variants.count > 1 ? .automatic : .never))
        }
        .navigationTitle(ingredient.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingVariant = true
                } label: {
                    Label("Nueva variante", systemImage: "plus.square.on.square")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    ingredient.selectedVariantID = selectionBinding.wrappedValue
                } label: {
                    Label("Marcar como preferida", systemImage: "star")
                }
                .disabled(variants.count <= 1)
            }
        }
        .sheet(isPresented: $isAddingVariant) {
            IngredientVariantEditorView(ingredient: ingredient)
        }
        .onAppear {
            if selectedVariantID == nil {
                selectedVariantID = ingredient.primaryVariant?.id ?? variants.first?.id
            }
        }
    }
}

private struct IngredientVariantDetailCard: View {
    let variant: IngredientVariant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(Formatters.quantity(variant.quantity)) \(variant.unit)")
                    .cookbookTitle()
                    .foregroundStyle(Theme.ink)

                if !variant.notes.isEmpty {
                    Text("Notas")
                        .font(.headline)
                    Text(variant.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
