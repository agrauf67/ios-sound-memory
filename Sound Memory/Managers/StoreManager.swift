import StoreKit
import SwiftUI

@Observable
class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchaseInProgress = false
    private(set) var productsLoaded = false
    var unlockCredits: Int {
        didSet { save() }
    }
    var unlockedCategories: Set<Int> {
        didSet { save() }
    }

    static let freeCategoryIndex = 0

    private static let creditsKey = "unlockCredits"
    private static let categoriesKey = "unlockedCategories"

    static let productIDs: [String] = [
        "de.djvlk.soundmemory.pack1",
        "de.djvlk.soundmemory.pack2",
        "de.djvlk.soundmemory.pack3",
        "de.djvlk.soundmemory.pack5"
    ]

    init() {
        let cloud = NSUbiquitousKeyValueStore.default
        let ud = UserDefaults.standard

        // Prefer iCloud values; fall back to local UserDefaults (migration)
        let cloudCredits = cloud.object(forKey: Self.creditsKey) as? Int
        let localCredits = ud.integer(forKey: Self.creditsKey)
        unlockCredits = cloudCredits ?? localCredits

        let cloudCategories = cloud.object(forKey: Self.categoriesKey) as? [Int]
        let localCategories = ud.array(forKey: Self.categoriesKey) as? [Int] ?? []
        unlockedCategories = Set(cloudCategories ?? localCategories)
        unlockedCategories.insert(Self.freeCategoryIndex)

        // Sync initial state to both stores
        save()

        // Listen for iCloud changes from other devices
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud,
            queue: .main
        ) { [weak self] _ in
            self?.loadFromCloud()
        }
        cloud.synchronize()
    }

    private func save() {
        let ud = UserDefaults.standard
        ud.set(unlockCredits, forKey: Self.creditsKey)
        ud.set(Array(unlockedCategories), forKey: Self.categoriesKey)

        let cloud = NSUbiquitousKeyValueStore.default
        cloud.set(unlockCredits, forKey: Self.creditsKey)
        cloud.set(Array(unlockedCategories), forKey: Self.categoriesKey)
    }

    private func loadFromCloud() {
        let cloud = NSUbiquitousKeyValueStore.default
        if let credits = cloud.object(forKey: Self.creditsKey) as? Int {
            unlockCredits = max(unlockCredits, credits)
        }
        if let categories = cloud.object(forKey: Self.categoriesKey) as? [Int] {
            unlockedCategories.formUnion(categories)
            unlockedCategories.insert(Self.freeCategoryIndex)
        }
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
