// WITF? - What's In That Fridge?
// Core/Models/Ingredient.swift

import Foundation
import SwiftUI

/// Represents a food ingredient in the user's fridge or pantry
struct Ingredient: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: IngredientCategory
    var quantity: Double?
    var unit: MeasurementUnit?
    var iconName: String
    var addedDate: Date
    var expirationDate: Date?
    var isScanned: Bool // Whether this was detected via camera or manually added

    init(
        id: UUID = UUID(),
        name: String,
        category: IngredientCategory = .other,
        quantity: Double? = nil,
        unit: MeasurementUnit? = nil,
        iconName: String? = nil,
        addedDate: Date = Date(),
        expirationDate: Date? = nil,
        isScanned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.iconName = iconName ?? category.defaultIcon
        self.addedDate = addedDate
        self.expirationDate = expirationDate
        self.isScanned = isScanned
    }
}

// MARK: - Ingredient Category

enum IngredientCategory: String, Codable, CaseIterable, Identifiable {
    case vegetables
    case fruits
    case dairy
    case meat
    case seafood
    case grains
    case condiments
    case spices
    case beverages
    case frozen
    case canned
    case bakery
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vegetables: return String(localized: "ingredient.category.vegetables")
        case .fruits: return String(localized: "ingredient.category.fruits")
        case .dairy: return String(localized: "ingredient.category.dairy")
        case .meat: return String(localized: "ingredient.category.meat")
        case .seafood: return String(localized: "ingredient.category.seafood")
        case .grains: return String(localized: "ingredient.category.grains")
        case .condiments: return String(localized: "ingredient.category.condiments")
        case .spices: return String(localized: "ingredient.category.spices")
        case .beverages: return String(localized: "ingredient.category.beverages")
        case .frozen: return String(localized: "ingredient.category.frozen")
        case .canned: return String(localized: "ingredient.category.canned")
        case .bakery: return String(localized: "ingredient.category.bakery")
        case .other: return String(localized: "ingredient.category.other")
        }
    }

    var defaultIcon: String {
        switch self {
        case .vegetables: return "leaf.fill"
        case .fruits: return "apple.logo"
        case .dairy: return "drop.fill"
        case .meat: return "fork.knife"
        case .seafood: return "fish.fill"
        case .grains: return "oval.fill"
        case .condiments: return "drop.halffull"
        case .spices: return "sparkle"
        case .beverages: return "cup.and.saucer.fill"
        case .frozen: return "snowflake"
        case .canned: return "cylinder.fill"
        case .bakery: return "birthday.cake.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .vegetables: return .green
        case .fruits: return .orange
        case .dairy: return .blue
        case .meat: return .red
        case .seafood: return .cyan
        case .grains: return .brown
        case .condiments: return .yellow
        case .spices: return .purple
        case .beverages: return .mint
        case .frozen: return .indigo
        case .canned: return .gray
        case .bakery: return .pink
        case .other: return .secondary
        }
    }
}

// MARK: - Measurement Unit

enum MeasurementUnit: String, Codable, CaseIterable, Identifiable {
    case pieces
    case grams
    case kilograms
    case milliliters
    case liters
    case cups
    case tablespoons
    case teaspoons
    case slices
    case bunches

    var id: String { rawValue }

    var abbreviation: String {
        switch self {
        case .pieces: return String(localized: "unit.pieces.abbr")
        case .grams: return "g"
        case .kilograms: return "kg"
        case .milliliters: return "ml"
        case .liters: return "L"
        case .cups: return String(localized: "unit.cups.abbr")
        case .tablespoons: return String(localized: "unit.tbsp.abbr")
        case .teaspoons: return String(localized: "unit.tsp.abbr")
        case .slices: return String(localized: "unit.slices.abbr")
        case .bunches: return String(localized: "unit.bunches.abbr")
        }
    }

    var displayName: String {
        switch self {
        case .pieces: return String(localized: "unit.pieces")
        case .grams: return String(localized: "unit.grams")
        case .kilograms: return String(localized: "unit.kilograms")
        case .milliliters: return String(localized: "unit.milliliters")
        case .liters: return String(localized: "unit.liters")
        case .cups: return String(localized: "unit.cups")
        case .tablespoons: return String(localized: "unit.tablespoons")
        case .teaspoons: return String(localized: "unit.teaspoons")
        case .slices: return String(localized: "unit.slices")
        case .bunches: return String(localized: "unit.bunches")
        }
    }
}

// MARK: - Sample Data

extension Ingredient {
    static let sampleIngredients: [Ingredient] = [
        Ingredient(name: "Tomatoes", category: .vegetables, quantity: 4, unit: .pieces),
        Ingredient(name: "Eggs", category: .dairy, quantity: 6, unit: .pieces),
        Ingredient(name: "Cheese", category: .dairy, quantity: 200, unit: .grams),
        Ingredient(name: "Chicken Breast", category: .meat, quantity: 500, unit: .grams),
        Ingredient(name: "Rice", category: .grains, quantity: 1, unit: .kilograms),
        Ingredient(name: "Pasta", category: .grains, quantity: 500, unit: .grams),
        Ingredient(name: "Onion", category: .vegetables, quantity: 2, unit: .pieces),
        Ingredient(name: "Garlic", category: .vegetables, quantity: 1, unit: .bunches),
        Ingredient(name: "Olive Oil", category: .condiments, quantity: 500, unit: .milliliters),
        Ingredient(name: "Milk", category: .dairy, quantity: 1, unit: .liters)
    ]

    /// Quick-add preset ingredients for easy selection
    static let presets: [Ingredient] = [
        Ingredient(name: "Potatoes", category: .vegetables, iconName: "leaf.fill"),
        Ingredient(name: "Rice", category: .grains, iconName: "oval.fill"),
        Ingredient(name: "Pasta", category: .grains, iconName: "oval.fill"),
        Ingredient(name: "Milk", category: .dairy, iconName: "drop.fill"),
        Ingredient(name: "Eggs", category: .dairy, iconName: "oval.fill"),
        Ingredient(name: "Chicken", category: .meat, iconName: "fork.knife"),
        Ingredient(name: "Tomatoes", category: .vegetables, iconName: "leaf.fill"),
        Ingredient(name: "Onion", category: .vegetables, iconName: "leaf.fill"),
        Ingredient(name: "Cheese", category: .dairy, iconName: "drop.fill"),
        Ingredient(name: "Bread", category: .bakery, iconName: "birthday.cake.fill"),
        Ingredient(name: "Butter", category: .dairy, iconName: "drop.fill"),
        Ingredient(name: "Garlic", category: .vegetables, iconName: "leaf.fill")
    ]
}
