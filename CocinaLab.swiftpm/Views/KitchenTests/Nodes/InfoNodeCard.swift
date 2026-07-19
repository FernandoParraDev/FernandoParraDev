import SwiftUI
import PhotosUI

struct InfoNodeCard: View {
    @Bindable var recipe: Recipe
    @State private var coverPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Información general")
                    .cookbookTitle()
                    .foregroundStyle(Theme.ink)

                PhotosPicker(selection: $coverPhotoItem, matching: .images) {
                    StoredPhotoView(fileName: recipe.coverPhotoFileName)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "camera.fill")
                                .padding(8)
                                .background(.thinMaterial, in: Circle())
                                .padding(8)
                        }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Nombre").font(.caption).foregroundStyle(.secondary)
                    TextField("Nombre de la receta", text: $recipe.name)
                        .font(.title3)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Descripción").font(.caption).foregroundStyle(.secondary)
                    TextField("Descripción", text: $recipe.recipeDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                }

                Stepper("Porciones base: \(recipe.baseServings)", value: $recipe.baseServings, in: 1...50)
            }
            .padding()
        }
        .onChange(of: coverPhotoItem) { _, newItem in
            Task {
                guard let newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                guard let fileName = PhotoStore.save(data) else { return }
                if let old = recipe.coverPhotoFileName {
                    PhotoStore.delete(fileName: old)
                }
                recipe.coverPhotoFileName = fileName
            }
        }
    }
}
