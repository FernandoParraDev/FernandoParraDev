import Foundation

enum Formatters {
    /// Renders a scaled ingredient quantity without trailing zeros
    /// (e.g. 200, 133.33, 0.5) so scaled amounts stay readable.
    static func quantity(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        var text = String(format: "%.2f", value)
        while text.hasSuffix("0") {
            text.removeLast()
        }
        if text.hasSuffix(".") {
            text.removeLast()
        }
        return text
    }
}
