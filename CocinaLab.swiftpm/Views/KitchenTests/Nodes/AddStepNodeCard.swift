import SwiftUI
import SwiftData

/// Trailing "+" node: creates a new step (with its default variant) and
/// appends it just before this node in the trail.
struct AddStepNodeCard: View {
    let recipe: Recipe
    var onCreate: (Step) -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            Text("Añadir paso")
                .font(.title3.bold())
            Text("Suma un paso más a esta receta.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                addStep()
            } label: {
                Label("Nuevo paso", systemImage: "plus")
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
                .foregroundStyle(Color.secondary.opacity(0.4))
        )
    }

    private func addStep() {
        let step = Step(title: "Paso \(recipe.steps.count + 1)", orderIndex: recipe.steps.count)
        step.recipe = recipe
        recipe.steps.append(step)
        modelContext.insert(step)

        let variant = StepVariant(label: "Original", instructions: "", orderIndex: 0)
        variant.step = step
        step.variants.append(variant)
        modelContext.insert(variant)

        onCreate(step)
    }
}
