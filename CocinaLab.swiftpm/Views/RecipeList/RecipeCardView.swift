import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    private var lastTestedText: String {
        guard let lastTestedAt = recipe.lastTestedAt else { return "Sin probar todavía" }
        return "Última prueba: \(lastTestedAt.formatted(date: .abbreviated, time: .omitted))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                StoredPhotoView(fileName: recipe.coverPhotoFileName)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if !recipe.isPublished {
                    Image(systemName: "testtube.2")
                        .font(.caption)
                        .padding(6)
                        .background(Theme.terracotta, in: Circle())
                        .foregroundStyle(.white)
                        .padding(8)
                }
            }

            Text(recipe.name.isEmpty ? "Sin nombre" : recipe.name)
                .cookbookHeading()
                .foregroundStyle(Theme.ink)
                .lineLimit(2)

            Text(lastTestedText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .cookbookCard()
    }
}
