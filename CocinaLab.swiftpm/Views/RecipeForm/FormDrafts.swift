import Foundation
import SwiftUI
import PhotosUI

/// Lightweight, non-persisted editing state for the recipe form. Keeping
/// this separate from the SwiftData models means an in-progress edit can be
/// cancelled without ever touching the store.
struct IngredientDraft: Identifiable {
    let id = UUID()
    /// Set when this draft mirrors an already-persisted ingredient, so
    /// saving can update its primary variant (and preserve any extra
    /// tested amounts) instead of creating a new one.
    var existingIngredientID: UUID?
    var name: String = ""
    var quantity: Double = 0
    var unit: String = ""
}

struct StepDraft: Identifiable {
    let id = UUID()
    /// Set when this draft mirrors an already-persisted step, so saving can
    /// update that step (and preserve its extra variants) instead of
    /// creating a new one.
    var existingStepID: UUID?
    var title: String = ""
    var instructions: String = ""
    var hasTimer: Bool = false
    var timerMinutes: Int = 0
    var timerSeconds: Int = 0
    var newPhotoItems: [PhotosPickerItem] = []
    var newPhotoData: [Data] = []
    var existingPhotoFileNames: [String] = []
}
