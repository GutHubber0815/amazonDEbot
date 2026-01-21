// WITF? - What's In That Fridge?
// Core/Models/CuisinePreference.swift

import Foundation
import SwiftUI

/// Represents cuisine/region preferences for recipe generation
enum CuisinePreference: String, Codable, CaseIterable, Identifiable {
    case german
    case italian
    case mediterranean
    case asian
    case french
    case spanish
    case american
    case mexican
    case indian
    case international
    case surprise // "Surprise me" option

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .german: return String(localized: "cuisine.german")
        case .italian: return String(localized: "cuisine.italian")
        case .mediterranean: return String(localized: "cuisine.mediterranean")
        case .asian: return String(localized: "cuisine.asian")
        case .french: return String(localized: "cuisine.french")
        case .spanish: return String(localized: "cuisine.spanish")
        case .american: return String(localized: "cuisine.american")
        case .mexican: return String(localized: "cuisine.mexican")
        case .indian: return String(localized: "cuisine.indian")
        case .international: return String(localized: "cuisine.international")
        case .surprise: return String(localized: "cuisine.surprise")
        }
    }

    var subtitle: String {
        switch self {
        case .german: return String(localized: "cuisine.german.subtitle")
        case .italian: return String(localized: "cuisine.italian.subtitle")
        case .mediterranean: return String(localized: "cuisine.mediterranean.subtitle")
        case .asian: return String(localized: "cuisine.asian.subtitle")
        case .french: return String(localized: "cuisine.french.subtitle")
        case .spanish: return String(localized: "cuisine.spanish.subtitle")
        case .american: return String(localized: "cuisine.american.subtitle")
        case .mexican: return String(localized: "cuisine.mexican.subtitle")
        case .indian: return String(localized: "cuisine.indian.subtitle")
        case .international: return String(localized: "cuisine.international.subtitle")
        case .surprise: return String(localized: "cuisine.surprise.subtitle")
        }
    }

    var iconName: String {
        switch self {
        case .german: return "mappin.circle.fill"
        case .italian: return "leaf.circle.fill"
        case .mediterranean: return "sun.max.circle.fill"
        case .asian: return "wand.and.stars"
        case .french: return "sparkles"
        case .spanish: return "flame.circle.fill"
        case .american: return "star.circle.fill"
        case .mexican: return "flame.fill"
        case .indian: return "sparkle.magnifyingglass"
        case .international: return "globe"
        case .surprise: return "dice.fill"
        }
    }

    var flagEmoji: String {
        switch self {
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .mediterranean: return "🌊"
        case .asian: return "🌏"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .american: return "🇺🇸"
        case .mexican: return "🇲🇽"
        case .indian: return "🇮🇳"
        case .international: return "🌍"
        case .surprise: return "🎲"
        }
    }

    var color: Color {
        switch self {
        case .german: return .yellow
        case .italian: return .green
        case .mediterranean: return .blue
        case .asian: return .red
        case .french: return .purple
        case .spanish: return .orange
        case .american: return .indigo
        case .mexican: return .pink
        case .indian: return .orange
        case .international: return .teal
        case .surprise: return .mint
        }
    }

    /// Main cuisines to show in the UI (excluding surprise initially)
    static var mainCuisines: [CuisinePreference] {
        [.german, .italian, .mediterranean, .asian, .international, .surprise]
    }

    /// All cuisines for settings/preferences
    static var allCuisines: [CuisinePreference] {
        allCases
    }
}

// MARK: - User Cuisine Settings

/// Stores user's cuisine preferences
struct CuisineSettings: Codable {
    var preferredCuisines: [CuisinePreference]
    var excludedCuisines: [CuisinePreference]
    var defaultCuisine: CuisinePreference

    init(
        preferredCuisines: [CuisinePreference] = [],
        excludedCuisines: [CuisinePreference] = [],
        defaultCuisine: CuisinePreference = .international
    ) {
        self.preferredCuisines = preferredCuisines
        self.excludedCuisines = excludedCuisines
        self.defaultCuisine = defaultCuisine
    }

    static let `default` = CuisineSettings()
}
