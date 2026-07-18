import SwiftUI

/// Final node: reviews the draft and moves it into the "Recetas" library.
struct PublishNodeCard: View {
    let recipe: Recipe
    var onPublish: () -> Void

    private var canPublish: Bool {
        !recipe.name.trimmingCharacters(in: .whitespaces).isEmpty
            && !recipe.ingredients.isEmpty
            && !recipe.steps.isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text("¿Lista para publicar?")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 6) {
                Label("\(recipe.ingredients.count) ingredientes", systemImage: "carrot")
                Label("\(recipe.steps.count) pasos", systemImage: "list.number")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if !canPublish {
                Text("Agrega un nombre, al menos un ingrediente y un paso antes de publicar.")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                onPublish()
            } label: {
                Label("Publicar receta", systemImage: "arrow.up.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canPublish)
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
