// WITF? - What's In That Fridge?
// Core/Services/SubscriptionManager.swift

import Foundation
import StoreKit

// MARK: - Subscription Manager

/// Manages in-app purchases and subscriptions using StoreKit 2
/// TODO: Replace mock product IDs with real App Store Connect product identifiers
@Observable
class SubscriptionManager {

    // MARK: - Properties

    /// Available products from the App Store
    private(set) var products: [Product] = []

    /// Currently active subscription tier
    private(set) var currentTier: SubscriptionTier = .free

    /// Whether the user has premium access
    var isPremium: Bool {
        currentTier != .free
    }

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var errorMessage: String?

    /// Transaction listener task
    private var transactionListener: Task<Void, Error>?

    /// User settings storage for subscription state
    private let settingsStorage: UserSettingsStorage

    // MARK: - Product IDs

    /// Product identifiers for StoreKit
    /// TODO: Replace with actual App Store Connect product IDs
    private let productIds: Set<String> = [
        "com.witf.premium.monthly",
        "com.witf.premium.yearly",
        "com.witf.premium.lifetime"
    ]

    // MARK: - Mock Mode

    /// Enable mock mode for development/testing without real StoreKit
    private let useMockPurchases: Bool

    // MARK: - Initialization

    init(settingsStorage: UserSettingsStorage, useMockPurchases: Bool = true) {
        self.settingsStorage = settingsStorage
        self.useMockPurchases = useMockPurchases

        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load initial subscription state from local storage
        currentTier = settingsStorage.subscription.tier

        // Load products
        Task {
            await loadProducts()
            await checkEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public Methods

    /// Loads available products from the App Store
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            if useMockPurchases {
                // Use mock products for development
                products = createMockProducts()
            } else {
                // Fetch real products from App Store
                products = try await Product.products(for: productIds)
                    .sorted { $0.price < $1.price }
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("StoreKit Error: \(error)")
        }

        isLoading = false
    }

    /// Purchases a product
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        if useMockPurchases {
            // Simulate purchase for development
            return await simulatePurchase(product)
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscription(for: transaction)
                await transaction.finish()
                return true

            case .userCancelled:
                return false

            case .pending:
                errorMessage = String(localized: "purchase.pending")
                return false

            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }

    /// Restores previous purchases
    @MainActor
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        if useMockPurchases {
            // In mock mode, just reset to free
            // In production, this would restore from App Store
            return
        }

        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    /// Checks current entitlements
    @MainActor
    func checkEntitlements() async {
        if useMockPurchases {
            // In mock mode, use stored subscription
            currentTier = settingsStorage.subscription.tier
            return
        }

        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                await updateSubscription(for: transaction)
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }

    /// Records a recipe generation usage (for free tier limits)
    func recordGeneration() {
        settingsStorage.subscription.recordGeneration()
    }

    /// Checks if user can generate more recipes
    var canGenerate: Bool {
        settingsStorage.subscription.canGenerate
    }

    /// Remaining generations for free tier
    var remainingGenerations: Int {
        settingsStorage.subscription.remainingGenerations
    }

    // MARK: - Private Methods

    /// Listens for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscription(for: transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }

    /// Verifies a transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    /// Updates subscription state based on transaction
    @MainActor
    private func updateSubscription(for transaction: Transaction) async {
        let tier = tierFromProductId(transaction.productID)

        if transaction.revocationDate == nil {
            currentTier = tier
            settingsStorage.subscription.tier = tier
            settingsStorage.subscription.isActive = true

            if let expirationDate = transaction.expirationDate {
                settingsStorage.subscription.expirationDate = expirationDate
            }
        } else {
            // Subscription was revoked
            currentTier = .free
            settingsStorage.subscription.tier = .free
            settingsStorage.subscription.isActive = false
        }
    }

    /// Maps product ID to subscription tier
    private func tierFromProductId(_ productId: String) -> SubscriptionTier {
        switch productId {
        case "com.witf.premium.monthly":
            return .premiumMonthly
        case "com.witf.premium.yearly":
            return .premiumYearly
        case "com.witf.premium.lifetime":
            return .lifetime
        default:
            return .free
        }
    }

    // MARK: - Mock Implementation

    /// Creates mock products for development/testing
    private func createMockProducts() -> [Product] {
        // In real app, these would come from StoreKit
        // For development, we return empty array and handle UI separately
        return []
    }

    /// Simulates a purchase for development
    @MainActor
    private func simulatePurchase(_ product: Product) async -> Bool {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Update subscription based on mock product
        let tier = tierFromProductId(product.id)
        currentTier = tier
        settingsStorage.subscription.tier = tier
        settingsStorage.subscription.isActive = true

        if tier == .premiumMonthly {
            settingsStorage.subscription.expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        } else if tier == .premiumYearly {
            settingsStorage.subscription.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        } else if tier == .lifetime {
            settingsStorage.subscription.expirationDate = nil // Never expires
        }

        return true
    }
}

// MARK: - Store Error

enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return String(localized: "error.purchase.verification")
        case .productNotFound:
            return String(localized: "error.product.not.found")
        case .purchaseFailed:
            return String(localized: "error.purchase.failed")
        }
    }
}

// MARK: - Mock Product Info (for UI display when StoreKit unavailable)

/// Mock product information for development UI
struct MockProductInfo: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let displayPrice: String
    let tier: SubscriptionTier

    static let allProducts: [MockProductInfo] = [
        MockProductInfo(
            id: "com.witf.premium.monthly",
            displayName: "Premium Monthly",
            description: "Unlimited recipes, all cuisines, smart suggestions",
            displayPrice: "€3.99/month",
            tier: .premiumMonthly
        ),
        MockProductInfo(
            id: "com.witf.premium.yearly",
            displayName: "Premium Yearly",
            description: "Save 37% with annual subscription",
            displayPrice: "€29.99/year",
            tier: .premiumYearly
        ),
        MockProductInfo(
            id: "com.witf.premium.lifetime",
            displayName: "Lifetime Access",
            description: "One-time purchase, unlimited forever",
            displayPrice: "€59.99",
            tier: .lifetime
        )
    ]
}
