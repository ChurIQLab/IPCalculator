import Foundation

struct IPCalculatorTableViewModel {
    let title: String
    let value: String
    let isMonospaced: Bool

    init(title: String, value: String, isMonospaced: Bool = false) {
        self.title = title
        self.value = value
        self.isMonospaced = isMonospaced
    }
}
