import SwiftUI
import PhotosUI
import SwiftData

/// A single step's node. When the step has more than one variant, a
/// segmented control lets you flip between branches right here — same
/// underlying data as the branch indicator in the published read view.
struct StepNodeCard: View {
    @Bindable var step: Step

    @State private var selectedVariantID: UUID?
    @State private var isAddingVariant = false

    private var variants: [StepVariant] { step.orderedVariants }

    private var currentVariant: StepVariant? {
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
                    Text("Paso").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        isAddingVariant = true
                    } label: {
                        Label("Nueva variante", systemImage: "plus.square.on.square")
                            .font(.caption)
                    }
                }

                TextField("Título del paso", text: $step.title)
                    .font(.title2.bold())
                    .textFieldStyle(.roundedBorder)

                if variants.count > 1 {
                    Picker("Variante", selection: variantSelectionBinding) {
                        ForEach(variants) { variant in
                            Text(variant.label).tag(variant.id as UUID?)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let variant = currentVariant {
                    StepVariantEditor(variant: variant, hasMultipleVariants: variants.count > 1)
                }
            }
            .padding()
        }
        .onAppear {
            if selectedVariantID == nil {
                selectedVariantID = step.primaryVariant?.id
            }
        }
        .sheet(isPresented: $isAddingVariant) {
            VariantEditorView(step: step)
        }
    }
}

private struct StepVariantEditor: View {
    @Bindable var variant: StepVariant
    let hasMultipleVariants: Bool

    @State private var hasTimer: Bool
    @State private var timerMinutes: Int
    @State private var timerSeconds: Int
    @State private var newPhotoItems: [PhotosPickerItem] = []

    @Environment(\.modelContext) private var modelContext

    init(variant: StepVariant, hasMultipleVariants: Bool) {
        self.variant = variant
        self.hasMultipleVariants = hasMultipleVariants
        let duration = variant.timerDurationSeconds ?? 0
        _hasTimer = State(initialValue: variant.timerDurationSeconds != nil)
        _timerMinutes = State(initialValue: duration / 60)
        _timerSeconds = State(initialValue: duration % 60)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasMultipleVariants {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Etiqueta de la variante").font(.caption).foregroundStyle(.secondary)
                    TextField("ej. 15 min a 200°C", text: $variant.label)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Instrucción").font(.caption).foregroundStyle(.secondary)
                TextField("Instrucción", text: $variant.instructions, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
            }

            Toggle("Temporizador", isOn: $hasTimer)
            if hasTimer {
                HStack {
                    Stepper("Min: \(timerMinutes)", value: $timerMinutes, in: 0...180)
                    Stepper("Seg: \(timerSeconds)", value: $timerSeconds, in: 0...59, step: 5)
                }
                .font(.caption)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Notas del resultado").font(.caption).foregroundStyle(.secondary)
                TextField("Notas del resultado", text: $variant.resultNotes, axis: .vertical)
                    .lineLimit(2...5)
                    .textFieldStyle(.roundedBorder)
            }

            PhotosPicker(selection: $newPhotoItems, matching: .images) {
                Label("Fotos del resultado", systemImage: "camera")
            }

            if !variant.orderedPhotos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(variant.orderedPhotos) { photo in
                            StoredPhotoView(fileName: photo.fileName)
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
            }
        }
        .onChange(of: hasTimer) { _, _ in syncTimer() }
        .onChange(of: timerMinutes) { _, _ in syncTimer() }
        .onChange(of: timerSeconds) { _, _ in syncTimer() }
        .onChange(of: newPhotoItems) { _, items in
            Task {
                for item in items {
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let fileName = PhotoStore.save(data) else { continue }
                    let photo = PhotoAsset(fileName: fileName)
                    photo.stepVariant = variant
                    variant.photos.append(photo)
                    modelContext.insert(photo)
                }
                newPhotoItems = []
            }
        }
    }

    private func syncTimer() {
        variant.timerDurationSeconds = hasTimer ? (timerMinutes * 60 + timerSeconds) : nil
    }
}
