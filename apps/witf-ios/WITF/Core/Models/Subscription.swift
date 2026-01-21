// WITF? - What's In That Fridge?
// Core/Models/Subscription.swift

import Foundation

/// Subscription tier levels for the app
enum SubscriptionTier: String, Codable, CaseIterable, Identifiable {
    case free
    case premiumMonthly
    case premiumYearly
    case lifetime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: return String(localized: "subscription.free")
        case .premiumMonthly: return String(localized: "subscription.premium.monthly")
        case .premiumYearly: return String(localized: "subscription.premium.yearly")
        case .lifetime: return String(localized: "subscription.lifetime")
        }
    }

    var description: String {
        switch self {
        case .free: return String(localized: "subscription.free.description")
        case .premiumMonthly: return String(localized: "subscription.premium.monthly.description")
        case .premiumYearly: return String(localized: "subscription.premium.yearly.description")
        case .lifetime: return String(localized: "subscription.lifetime.description")
        }
    }

    var isPremium: Bool {
        self != .free
    }

    /// Maximum AI recipe generations per month
    var monthlyGenerationLimit: Int {
        switch self {
        case .free: return 5
        case .premiumMonthly, .premiumYearly, .lifetime: return .max
        }
    }

    /// Price hint for display (actual prices come from StoreKit)
    var priceHint: String {
        switch self {
        case .free: return String(localized: "subscription.free.price")
        case .premiumMonthly: return "€3.99 / " + String(localized: "subscription.period.month")
        case .premiumYearly: return "€29.99 / " + String(localized: "subscription.period.year")
        case .lifetime: return "€59.99"
        }
    }

    /// Features included in this tier
    var features: [SubscriptionFeature] {
        switch self {
        case .free:
            return [
                SubscriptionFeature(name: String(localized: "feature.basic.scan"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.limited.generations"), isIncluded: true, limit: "5/" + String(localized: "subscription.period.month")),
                SubscriptionFeature(name: String(localized: "feature.basic.cuisines"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.save.recipes"), isIncluded: true, limit: "10")
            ]
        case .premiumMonthly, .premiumYearly, .lifetime:
            return [
                SubscriptionFeature(name: String(localized: "feature.unlimited.scan"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.unlimited.generations"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.all.cuisines"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.unlimited.recipes"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.smart.suggestions"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.nutrition.details"), isIncluded: true),
                SubscriptionFeature(name: String(localized: "feature.no.ads"), isIncluded: true)
            ]
        }
    }

    // MARK: - StoreKit Product IDs

    /// Product identifier for StoreKit
    /// TODO: Replace with actual App Store Connect product IDs
    var productId: String? {
        switch self {
        case .free: return nil
        case .premiumMonthly: return "com.witf.premium.monthly"
        case .premiumYearly: return "com.witf.premium.yearly"
        case .lifetime: return "com.witf.premium.lifetime"
        }
    }

    static var allProductIds: [String] {
        [
            "com.witf.premium.monthly",
            "com.witf.premium.yearly",
            "com.witf.premium.lifetime"
        ]
    }
}

// MARK: - Subscription Feature

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let name: String
    let isIncluded: Bool
    var limit: String?
}

// MARK: - User Subscription State

/// Represents the current subscription state of the user
struct UserSubscription: Codable {
    var tier: SubscriptionTier
    var expirationDate: Date?
    var isActive: Bool
    var monthlyGenerationsUsed: Int
    var lastResetDate: Date

    init(
        tier: SubscriptionTier = .free,
        expirationDate: Date? = nil,
        isActive: Bool = true,
        monthlyGenerationsUsed: Int = 0,
        lastResetDate: Date = Date()
    ) {
        self.tier = tier
        self.expirationDate = expirationDate
        self.isActive = isActive
        self.monthlyGenerationsUsed = monthlyGenerationsUsed
        self.lastResetDate = lastResetDate
    }

    var isPremium: Bool {
        tier.isPremium && isActive
    }

    var remainingGenerations: Int {
        if isPremium {
            return .max
        }
        return max(0, tier.monthlyGenerationLimit - monthlyGenerationsUsed)
    }

    var canGenerate: Bool {
        remainingGenerations > 0
    }

    /// Check if the monthly counter should be reset
    mutating func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        if !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month) {
            monthlyGenerationsUsed = 0
            lastResetDate = now
        }
    }

    /// Record a generation usage
    mutating func recordGeneration() {
        if !isPremium {
            monthlyGenerationsUsed += 1
        }
    }

    static let free = UserSubscription()
}
