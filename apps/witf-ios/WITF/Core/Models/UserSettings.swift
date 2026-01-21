// WITF? - What's In That Fridge?
// Core/Models/UserSettings.swift

import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case english
    case german
    case french
    case spanish
    case italian

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return String(localized: "language.system")
        case .english: return "English"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .italian: return "Italiano"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .english: return "en"
        case .german: return "de"
        case .french: return "fr"
        case .spanish: return "es"
        case .italian: return "it"
        }
    }

    var flagEmoji: String {
        switch self {
        case .system: return "🌐"
        case .english: return "🇬🇧"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .italian: return "🇮🇹"
        }
    }
}

/// User preferences and settings
struct UserSettings: Codable {
    var hasCompletedOnboarding: Bool
    var selectedLanguage: AppLanguage
    var cuisineSettings: CuisineSettings
    var defaultServings: Int
    var notificationsEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var darkModePreference: DarkModePreference

    init(
        hasCompletedOnboarding: Bool = false,
        selectedLanguage: AppLanguage = .system,
        cuisineSettings: CuisineSettings = .default,
        defaultServings: Int = 2,
        notificationsEnabled: Bool = true,
        hapticFeedbackEnabled: Bool = true,
        darkModePreference: DarkModePreference = .system
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedLanguage = selectedLanguage
        self.cuisineSettings = cuisineSettings
        self.defaultServings = defaultServings
        self.notificationsEnabled = notificationsEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.darkModePreference = darkModePreference
    }

    static let `default` = UserSettings()
}

/// Dark mode preference
enum DarkModePreference: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return String(localized: "appearance.system")
        case .light: return String(localized: "appearance.light")
        case .dark: return String(localized: "appearance.dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - App State

/// Global app state for navigation and UI
@Observable
class AppState {
    var selectedTab: AppTab = .home
    var showOnboarding: Bool = true
    var showPaywall: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    func showError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }
}

/// Tab identifiers for main navigation
enum AppTab: String, CaseIterable, Identifiable {
    case home
    case recipes
    case myFridge
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return String(localized: "tab.home")
        case .recipes: return String(localized: "tab.recipes")
        case .myFridge: return String(localized: "tab.myfridge")
        case .profile: return String(localized: "tab.profile")
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .recipes: return "book.fill"
        case .myFridge: return "refrigerator.fill"
        case .profile: return "person.fill"
        }
    }
}
