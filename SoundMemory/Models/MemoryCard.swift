import Foundation

struct MemoryCard: Identifiable, Equatable {
    let id: Int
    let imageFileName: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}
