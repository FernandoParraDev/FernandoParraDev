import XCTest
@testable import CocinaLab

final class CocinaLabTests: XCTestCase {
    func testIngredientScalesProportionallyToServings() {
        let ingredient = Ingredient(name: "Harina", quantity: 200, unit: "g", orderIndex: 0)
        let scaled = ingredient.scaledQuantity(baseServings: 4, targetServings: 8)
        XCTAssertEqual(scaled, 400)
    }

    func testStepDetectsMultipleVariantsOnlyWithMoreThanOne() {
        let step = Step(title: "Hornear", orderIndex: 0)
        let variantA = StepVariant(label: "10 min", instructions: "Hornear 10 minutos", orderIndex: 0)
        step.variants.append(variantA)
        XCTAssertFalse(step.hasMultipleVariants)

        let variantB = StepVariant(label: "15 min", instructions: "Hornear 15 minutos", orderIndex: 1)
        step.variants.append(variantB)
        XCTAssertTrue(step.hasMultipleVariants)
    }

    func testPrimaryVariantFallsBackToEarliestOrderedVariant() {
        let step = Step(title: "Hornear", orderIndex: 0)
        let variantA = StepVariant(label: "10 min", instructions: "A", orderIndex: 1)
        let variantB = StepVariant(label: "15 min", instructions: "B", orderIndex: 0)
        step.variants = [variantA, variantB]
        XCTAssertEqual(step.primaryVariant?.label, "15 min")
    }

    func testPrimaryVariantHonorsExplicitSelection() {
        let step = Step(title: "Hornear", orderIndex: 0)
        let variantA = StepVariant(label: "10 min", instructions: "A", orderIndex: 0)
        let variantB = StepVariant(label: "15 min", instructions: "B", orderIndex: 1)
        step.variants = [variantA, variantB]
        step.selectedVariantID = variantB.id
        XCTAssertEqual(step.primaryVariant?.label, "15 min")
    }
}
