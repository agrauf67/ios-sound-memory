import StoreKit
import SwiftUI

@Observable
class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchaseInProgress = false
    private(set) var productsLoaded = false
    var unlockCredits: Int {
        didSet { UserDefaults.standard.set(unlockCredits, forKey: "unlockCredits") }
    }
    var unlockedCategories: Set<Int> {
        didSet {
            UserDefaults.standard.set(Array(unlockedCategories), forKey: "unlockedCategories")
        }
    }

    static let freeCategoryIndex = 0

    static let productIDs: [String] = [
        "de.djvlk.soundmemory.pack1",
        "de.djvlk.soundmemory.pack2",
        "de.djvlk.soundmemory.pack3",
        "de.djvlk.soundmemory.pack5"
    ]

    init() {
        let ud = UserDefaults.standard
        unlockCredits = ud.integer(forKey: "unlockCredits")
        let saved = ud.array(forKey: "unlockedCategories") as? [Int] ?? []
        unlockedCategories = Set(saved)
        unlockedCategories.insert(Self.freeCategoryIndex)
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { creditsForProduct($0) < creditsForProduct($1) }
        } catch {
            products = []
        }
        productsLoaded = true
    }

    func purchase(_ product: Product) async -> Bool {
        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                let credits = creditsForProduct(product)
                unlockCredits += credits
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func isCategoryUnlocked(_ categoryIndex: Int) -> Bool {
        categoryIndex == Self.freeCategoryIndex || unlockedCategories.contains(categoryIndex)
    }

    func unlockCategory(_ categoryIndex: Int) -> Bool {
        guard unlockCredits > 0 else { return false }
        guard !isCategoryUnlocked(categoryIndex) else { return true }
        unlockCredits -= 1
        unlockedCategories.insert(categoryIndex)
        return true
    }

    func creditsForProduct(_ product: Product) -> Int {
        switch product.id {
        case "de.djvlk.soundmemory.pack1": return 1
        case "de.djvlk.soundmemory.pack2": return 2
        case "de.djvlk.soundmemory.pack3": return 3
        case "de.djvlk.soundmemory.pack5": return 5
        default: return 0
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
    }
}

enum StoreError: Error {
    case failedVerification
}
