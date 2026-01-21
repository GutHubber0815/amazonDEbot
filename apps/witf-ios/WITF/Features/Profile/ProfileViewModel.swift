// WITF? - What's In That Fridge?
// Features/Profile/ProfileViewModel.swift

import Foundation

// MARK: - Profile View Model

@Observable
class ProfileViewModel {

    // MARK: - Properties

    /// User settings storage
    var settingsStorage: UserSettingsStorage

    /// Subscription manager
    var subscriptionManager: SubscriptionManager

    /// Show paywall
    var showPaywall = false

    /// Show language picker
    var showLanguagePicker = false

    /// Show cuisine preferences
    var showCuisinePreferences = false

    // MARK: - Computed Properties

    var selectedLanguage: AppLanguage {
        get { settingsStorage.settings.selectedLanguage }
        set {
            settingsStorage.settings.selectedLanguage = newValue
        }
    }

    var defaultServings: Int {
        get { settingsStorage.settings.defaultServings }
        set {
            settingsStorage.settings.defaultServings = newValue
        }
    }

    var darkModePreference: DarkModePreference {
        get { settingsStorage.settings.darkModePreference }
        set {
            settingsStorage.settings.darkModePreference = newValue
        }
    }

    var preferredCuisines: [CuisinePreference] {
        get { settingsStorage.settings.cuisineSettings.preferredCuisines }
        set {
            settingsStorage.settings.cuisineSettings.preferredCuisines = newValue
        }
    }

    var currentTier: SubscriptionTier {
        subscriptionManager.currentTier
    }

    var isPremium: Bool {
        subscriptionManager.isPremium
    }

    var remainingGenerations: Int {
        subscriptionManager.remainingGenerations
    }

    // MARK: - Initialization

    init(settingsStorage: UserSettingsStorage, subscriptionManager: SubscriptionManager) {
        self.settingsStorage = settingsStorage
        self.subscriptionManager = subscriptionManager
    }

    // MARK: - Methods

    func restorePurchases() async {
        await subscriptionManager.restorePurchases()
    }
}
