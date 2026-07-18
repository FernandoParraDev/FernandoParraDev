import SwiftUI
import PhotosUI
import SwiftData
import UIKit

/// Creates a new variant (branch) for an existing step — reached from
/// `StepVariantsView`, e.g. "same searing step, but 15 min instead of 10".
struct VariantEditorView: View {
    let step: Step

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var label = ""
    @State private var instructions = ""
    @State private var resultNotes = ""
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var hasTimer = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var pendingPhotoData: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Variante") {
                    TextField("Etiqueta (ej. 15 min a 200°C)", text: $label)
                    TextField("Instrucciones", text: $instructions, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Temporizador") {
                    Toggle("Incluir temporizador", isOn: $hasTimer)
                    if hasTimer {
                        Stepper("Minutos: \(timerMinutes)", value: $timerMinutes, in: 0...180)
                        Stepper("Segundos: \(timerSeconds)", value: $timerSeconds, in: 0...59, step: 5)
                    }
                }

                Section("Resultado") {
                    TextField("Notas del resultado", text: $resultNotes, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Fotos") {
                    PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                        Label("Añadir fotos", systemImage: "photo.badge.plus")
                    }
                    if !pendingPhotoData.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(pendingPhotoData.indices, id: \.self) { index in
                                    if let uiImage = UIImage(data: pendingPhotoData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 72, height: 72)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
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
                        .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItems) { _, newItems in
                Task {
                    var datas: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            datas.append(data)
                        }
                    }
                    pendingPhotoData = datas
                }
            }
        }
    }

    private func save() {
        let variant = StepVariant(
            label: label.trimmingCharacters(in: .whitespaces),
            instructions: instructions,
            timerDurationSeconds: hasTimer ? (timerMinutes * 60 + timerSeconds) : nil,
            resultNotes: resultNotes,
            orderIndex: step.variants.count
        )
        variant.step = step
        step.variants.append(variant)
        modelContext.insert(variant)

        for data in pendingPhotoData {
            if let fileName = PhotoStore.save(data) {
                let photo = PhotoAsset(fileName: fileName)
                photo.stepVariant = variant
                variant.photos.append(photo)
                modelContext.insert(photo)
            }
        }

        dismiss()
    }
}
