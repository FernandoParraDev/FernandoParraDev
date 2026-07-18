import SwiftUI
import SwiftData

/// Deep-link destination for a single step's variants. Reached directly from
/// the branch indicator in the read view — never requires entering the full
/// recipe editor. Lets the user flip between variants via a segmented
/// control or swipe, and add new ones.
struct StepVariantsView: View {
    let step: Step

    @State private var selectedVariantID: UUID?
    @State private var isAddingVariant = false

    private var variants: [StepVariant] {
        step.orderedVariants
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
                        Text(variant.label).tag(variant.id as UUID?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)
            }

            TabView(selection: selectionBinding) {
                ForEach(variants) { variant in
                    VariantDetailCard(variant: variant)
                        .tag(variant.id as UUID?)
                        .padding()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: variants.count > 1 ? .automatic : .never))
        }
        .navigationTitle(step.title)
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
                    step.selectedVariantID = selectionBinding.wrappedValue
                } label: {
                    Label("Marcar como preferida", systemImage: "star")
                }
                .disabled(variants.count <= 1)
            }
        }
        .sheet(isPresented: $isAddingVariant) {
            VariantEditorView(step: step)
        }
        .onAppear {
            if selectedVariantID == nil {
                selectedVariantID = step.primaryVariant?.id ?? variants.first?.id
            }
        }
    }
}

private struct VariantDetailCard: View {
    let variant: StepVariant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if !variant.orderedPhotos.isEmpty {
                    TabView {
                        ForEach(variant.orderedPhotos) { photo in
                            StoredPhotoView(fileName: photo.fileName)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                if let seconds = variant.timerDurationSeconds {
                    TimerView(totalSeconds: seconds)
                }

                if !variant.instructions.isEmpty {
                    Text("Instrucciones")
                        .font(.headline)
                    Text(variant.instructions)
                        .font(.body)
                }

                if !variant.resultNotes.isEmpty {
                    Text("Notas del resultado")
                        .font(.headline)
                    Text(variant.resultNotes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
