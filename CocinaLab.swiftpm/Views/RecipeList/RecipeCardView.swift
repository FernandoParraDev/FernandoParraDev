import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    private var lastTestedText: String {
        guard let lastTestedAt = recipe.lastTestedAt else { return "Sin probar todavía" }
        return "Última prueba: \(lastTestedAt.formatted(date: .abbreviated, time: .omitted))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StoredPhotoView(fileName: recipe.coverPhotoFileName)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(lastTestedText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}
