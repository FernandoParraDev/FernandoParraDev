import SwiftUI
import PhotosUI
import UIKit

/// Row editor for one step inside the recipe form. Edits the step's title
/// and its default variant (instructions, optional timer, photos). Extra
/// variants are added later from the read view, not here.
struct StepEditorView: View {
    @Binding var draft: StepDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Título del paso", text: $draft.title)
                .font(.headline)
            TextField("Instrucción", text: $draft.instructions, axis: .vertical)
                .lineLimit(2...5)

            Toggle("Temporizador", isOn: $draft.hasTimer)
            if draft.hasTimer {
                HStack {
                    Stepper("Min: \(draft.timerMinutes)", value: $draft.timerMinutes, in: 0...180)
                    Stepper("Seg: \(draft.timerSeconds)", value: $draft.timerSeconds, in: 0...59, step: 5)
                }
                .font(.caption)
            }

            PhotosPicker(selection: $draft.newPhotoItems, matching: .images) {
                Label("Fotos del resultado", systemImage: "camera")
            }

            if !draft.existingPhotoFileNames.isEmpty || !draft.newPhotoData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(draft.existingPhotoFileNames, id: \.self) { fileName in
                            StoredPhotoView(fileName: fileName)
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(alignment: .topTrailing) {
                                    removeButton {
                                        draft.existingPhotoFileNames.removeAll { $0 == fileName }
                                    }
                                }
                        }
                        ForEach(draft.newPhotoData.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: draft.newPhotoData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .topTrailing) {
                                        removeButton {
                                            draft.newPhotoData.remove(at: index)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .onChange(of: draft.newPhotoItems) { _, newItems in
            Task {
                var datas: [Data] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        datas.append(data)
                    }
                }
                draft.newPhotoData = datas
            }
        }
    }

    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.white, .black.opacity(0.6))
        }
        .padding(2)
    }
}
