import SwiftUI
import UIKit

/// Renders a photo saved via `PhotoStore` by file name, falling back to a
/// neutral placeholder when there is no photo yet.
struct StoredPhotoView: View {
    let fileName: String?
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let fileName, let uiImage = PhotoStore.loadImage(fileName: fileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    Rectangle().fill(Color.secondary.opacity(0.15))
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipped()
    }
}
