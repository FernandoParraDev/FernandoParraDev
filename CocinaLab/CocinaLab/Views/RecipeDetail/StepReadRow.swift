import SwiftUI

/// A single numbered step in the recipe's read view. When the step has
/// multiple variants, the whole row becomes a NavigationLink straight into
/// `StepVariantsView` for that step — no need to open the full editor.
struct StepReadRow: View {
    let step: Step
    let index: Int

    var body: some View {
        if step.hasMultipleVariants {
            NavigationLink(value: step) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.15))
                Text("\(index)")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(step.title)
                        .font(.headline)
                    Spacer()
                    if step.hasMultipleVariants {
                        BranchIndicatorView(count: step.variants.count)
                    }
                }

                if let variant = step.primaryVariant {
                    if !variant.instructions.isEmpty {
                        Text(variant.instructions)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let seconds = variant.timerDurationSeconds {
                        TimerView(totalSeconds: seconds)
                    }

                    if !variant.orderedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(variant.orderedPhotos) { photo in
                                    StoredPhotoView(fileName: photo.fileName)
                                        .frame(width: 84, height: 84)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.separator, lineWidth: 0.5))
    }
}
