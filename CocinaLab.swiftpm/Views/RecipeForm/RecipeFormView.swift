import SwiftUI
import PhotosUI
import SwiftData
import UIKit

/// Create or edit a recipe: name, description, servings, ingredients and
/// steps. Editing preserves any extra variants a step already has — this
/// form only ever touches a step's title and its default (first) variant.
struct RecipeFormView: View {
    let existingRecipe: Recipe?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var baseServings: Int
    @State private var notes: String
    @State private var coverPhotoItem: PhotosPickerItem?
    @State private var coverPhotoData: Data?
    @State private var existingCoverFileName: String?

    @State private var ingredientDrafts: [IngredientDraft]
    @State private var stepDrafts: [StepDraft]

    init(existingRecipe: Recipe?) {
        self.existingRecipe = existingRecipe
        _name = State(initialValue: existingRecipe?.name ?? "")
        _description = State(initialValue: existingRecipe?.recipeDescription ?? "")
        _baseServings = State(initialValue: existingRecipe?.baseServings ?? 4)
        _notes = State(initialValue: existingRecipe?.notes ?? "")
        _existingCoverFileName = State(initialValue: existingRecipe?.coverPhotoFileName)

        if let existingRecipe {
            _ingredientDrafts = State(initialValue: existingRecipe.orderedIngredients.map {
                IngredientDraft(name: $0.name, quantity: $0.quantity, unit: $0.unit)
            })
            _stepDrafts = State(initialValue: existingRecipe.orderedSteps.map { step in
                let variant = step.primaryVariant
                let duration = variant?.timerDurationSeconds ?? 0
                return StepDraft(
                    existingStepID: step.id,
                    title: step.title,
                    instructions: variant?.instructions ?? "",
                    hasTimer: variant?.timerDurationSeconds != nil,
                    timerMinutes: duration / 60,
                    timerSeconds: duration % 60,
                    existingPhotoFileNames: variant?.orderedPhotos.map(\.fileName) ?? []
                )
            })
        } else {
            _ingredientDrafts = State(initialValue: [IngredientDraft()])
            _stepDrafts = State(initialValue: [StepDraft()])
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Información general") {
                    TextField("Nombre de la receta", text: $name)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                    Stepper("Porciones base: \(baseServings)", value: $baseServings, in: 1...50)

                    PhotosPicker(selection: $coverPhotoItem, matching: .images) {
                        HStack {
                            Label("Foto de portada", systemImage: "photo")
                            Spacer()
                            coverPreview
                        }
                    }
                }

                Section("Ingredientes") {
                    ForEach($ingredientDrafts) { $draft in
                        HStack {
                            TextField("Cant.", value: $draft.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            TextField("Unidad", text: $draft.unit)
                                .frame(width: 70)
                            TextField("Ingrediente", text: $draft.name)
                        }
                    }
                    .onDelete { indexSet in
                        ingredientDrafts.remove(atOffsets: indexSet)
                    }

                    Button {
                        ingredientDrafts.append(IngredientDraft())
                    } label: {
                        Label("Añadir ingrediente", systemImage: "plus")
                    }
                }

                Section("Pasos") {
                    ForEach($stepDrafts) { $draft in
                        StepEditorView(draft: $draft)
                    }
                    .onDelete { indexSet in
                        stepDrafts.remove(atOffsets: indexSet)
                    }

                    Button {
                        stepDrafts.append(StepDraft())
                    } label: {
                        Label("Añadir paso", systemImage: "plus")
                    }
                }

                Section("Notas") {
                    TextField("Notas generales", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }
            }
            .navigationTitle(existingRecipe == nil ? "Nueva receta" : "Editar receta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: coverPhotoItem) { _, newItem in
                Task {
                    if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        coverPhotoData = data
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var coverPreview: some View {
        if let coverPhotoData, let uiImage = UIImage(data: coverPhotoData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if let existingCoverFileName {
            StoredPhotoView(fileName: existingCoverFileName)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "photo.on.rectangle")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Save

    private func save() {
        let recipe = existingRecipe ?? Recipe(name: name)
        if existingRecipe == nil {
            modelContext.insert(recipe)
        }

        recipe.name = name.trimmingCharacters(in: .whitespaces)
        recipe.recipeDescription = description
        recipe.baseServings = baseServings
        recipe.notes = notes

        if let coverPhotoData, let fileName = PhotoStore.save(coverPhotoData) {
            if let oldFileName = existingCoverFileName {
                PhotoStore.delete(fileName: oldFileName)
            }
            recipe.coverPhotoFileName = fileName
        }

        syncIngredients(into: recipe)
        syncSteps(into: recipe)

        dismiss()
    }

    private func syncIngredients(into recipe: Recipe) {
        for existing in recipe.ingredients {
            modelContext.delete(existing)
        }
        recipe.ingredients.removeAll()

        for (index, draft) in ingredientDrafts.enumerated() where !draft.name.trimmingCharacters(in: .whitespaces).isEmpty {
            let ingredient = Ingredient(name: draft.name, quantity: draft.quantity, unit: draft.unit, orderIndex: index)
            ingredient.recipe = recipe
            recipe.ingredients.append(ingredient)
            modelContext.insert(ingredient)
        }
    }

    /// Updates steps in place when they map to an existing step (preserving
    /// any extra variants), creates new steps for new drafts, and deletes
    /// steps whose draft was removed or left blank.
    private func syncSteps(into recipe: Recipe) {
        var updatedSteps: [Step] = []
        let existingStepsByID = Dictionary(uniqueKeysWithValues: (existingRecipe?.steps ?? []).map { ($0.id, $0) })

        for draft in stepDrafts {
            let trimmedTitle = draft.title.trimmingCharacters(in: .whitespaces)
            guard !trimmedTitle.isEmpty else { continue }

            let step: Step
            if let existingID = draft.existingStepID, let matched = existingStepsByID[existingID] {
                step = matched
            } else {
                step = Step(title: trimmedTitle, orderIndex: 0)
                step.recipe = recipe
                recipe.steps.append(step)
                modelContext.insert(step)
            }

            step.title = trimmedTitle
            step.orderIndex = updatedSteps.count

            let variant: StepVariant
            if let existingVariant = step.primaryVariant {
                variant = existingVariant
            } else {
                let newVariant = StepVariant(label: "Original", instructions: "", orderIndex: 0)
                newVariant.step = step
                step.variants.append(newVariant)
                modelContext.insert(newVariant)
                variant = newVariant
            }

            variant.instructions = draft.instructions
            variant.timerDurationSeconds = draft.hasTimer ? (draft.timerMinutes * 60 + draft.timerSeconds) : nil

            let removedFileNames = Set(variant.photos.map(\.fileName)).subtracting(draft.existingPhotoFileNames)
            for photo in variant.photos.filter({ removedFileNames.contains($0.fileName) }) {
                PhotoStore.delete(fileName: photo.fileName)
                modelContext.delete(photo)
            }
            variant.photos.removeAll { removedFileNames.contains($0.fileName) }

            for data in draft.newPhotoData {
                if let fileName = PhotoStore.save(data) {
                    let photo = PhotoAsset(fileName: fileName)
                    photo.stepVariant = variant
                    variant.photos.append(photo)
                    modelContext.insert(photo)
                }
            }

            updatedSteps.append(step)
        }

        let removedSteps = (existingRecipe?.steps ?? []).filter { existing in
            !updatedSteps.contains { $0.id == existing.id }
        }
        for removed in removedSteps {
            for variant in removed.variants {
                for photo in variant.photos {
                    PhotoStore.delete(fileName: photo.fileName)
                }
            }
            modelContext.delete(removed)
        }
    }
}
