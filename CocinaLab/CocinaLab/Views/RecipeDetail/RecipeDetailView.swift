import SwiftUI
import SwiftData

/// The recipe's read view: scalable ingredients, numbered steps with
/// integrated timers, and branch indicators on any step that has variants.
struct RecipeDetailView: View {
    let recipe: Recipe

    @State private var targetServings: Int
    @State private var isPresentingEdit = false

    init(recipe: Recipe) {
        self.recipe = recipe
        _targetServings = State(initialValue: recipe.baseServings)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                servingsControl
                ingredientsSection
                stepsSection
                notesSection
            }
            .padding(20)
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Step.self) { step in
            StepVariantsView(step: step)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentingEdit = true
                    } label: {
                        Label("Editar receta", systemImage: "pencil")
                    }
                    Button {
                        recipe.lastTestedAt = .now
                    } label: {
                        Label("Marcar como probada hoy", systemImage: "checkmark.seal")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            RecipeFormView(existingRecipe: recipe)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            StoredPhotoView(fileName: recipe.coverPhotoFileName)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if !recipe.recipeDescription.isEmpty {
                Text(recipe.recipeDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let lastTestedAt = recipe.lastTestedAt {
                Label("Última prueba: \(lastTestedAt.formatted(date: .abbreviated, time: .omitted))", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var servingsControl: some View {
        HStack {
            Label("Porciones", systemImage: "person.2")
                .font(.headline)
            Spacer()
            Stepper(value: $targetServings, in: 1...50) {
                Text("\(targetServings)")
                    .font(.headline)
                    .monospacedDigit()
                    .frame(minWidth: 28)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.thinMaterial))
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredientes")
                .font(.title3.bold())

            ForEach(recipe.orderedIngredients) { ingredient in
                HStack {
                    Text(formattedQuantity(for: ingredient))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .leading)
                    Text(ingredient.name)
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }

    private func formattedQuantity(for ingredient: Ingredient) -> String {
        let scaled = ingredient.scaledQuantity(baseServings: recipe.baseServings, targetServings: targetServings)
        return "\(Formatters.quantity(scaled)) \(ingredient.unit)"
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pasos")
                .font(.title3.bold())

            ForEach(Array(recipe.orderedSteps.enumerated()), id: \.element.id) { index, step in
                StepReadRow(step: step, index: index + 1)
            }
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        if !recipe.notes.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Notas")
                    .font(.title3.bold())
                Text(recipe.notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
