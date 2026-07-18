import Foundation
import SwiftData

@Model
final class StepVariant {
    var id: UUID
    var label: String
    var instructions: String
    var timerDurationSeconds: Int?
    var resultNotes: String
    var createdAt: Date
    var orderIndex: Int
    var step: Step?

    @Relationship(deleteRule: .cascade, inverse: \PhotoAsset.stepVariant)
    var photos: [PhotoAsset] = []

    init(
        label: String,
        instructions: String,
        timerDurationSeconds: Int? = nil,
        resultNotes: String = "",
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.label = label
        self.instructions = instructions
        self.timerDurationSeconds = timerDurationSeconds
        self.resultNotes = resultNotes
        self.createdAt = .now
        self.orderIndex = orderIndex
    }

    var orderedPhotos: [PhotoAsset] {
        photos.sorted { $0.createdAt < $1.createdAt }
    }
}
