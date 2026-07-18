import Foundation
import SwiftData

/// Stores only a reference to a JPEG file inside the app sandbox; the actual
/// image bytes live on disk via `PhotoStore`, not in the SwiftData store.
@Model
final class PhotoAsset {
    var id: UUID
    var fileName: String
    var createdAt: Date
    var stepVariant: StepVariant?

    init(fileName: String) {
        self.id = UUID()
        self.fileName = fileName
        self.createdAt = .now
    }
}
