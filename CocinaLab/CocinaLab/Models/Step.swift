import Foundation
import SwiftData

/// A step is a node in the recipe's decision tree: it always holds at least
/// one variant (the version created with the recipe), and can accumulate
/// additional variants over time as the same step gets re-tested differently
/// (e.g. baked 10 min vs. 15 min).
@Model
final class Step {
    var id: UUID
    var title: String
    var orderIndex: Int
    var recipe: Recipe?
    var selectedVariantID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \StepVariant.step)
    var variants: [StepVariant] = []

    init(title: String, orderIndex: Int) {
        self.id = UUID()
        self.title = title
        self.orderIndex = orderIndex
    }

    var orderedVariants: [StepVariant] {
        variants.sorted { $0.orderIndex < $1.orderIndex }
    }

    var hasMultipleVariants: Bool {
        variants.count > 1
    }

    /// The variant shown by default in the read view: the user's preferred
    /// pick if one was marked, otherwise the earliest variant.
    var primaryVariant: StepVariant? {
        if let selectedVariantID, let match = variants.first(where: { $0.id == selectedVariantID }) {
            return match
        }
        return orderedVariants.first
    }
}
