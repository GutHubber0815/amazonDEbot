// WITF? - What's In That Fridge?
// WITFApp.swift
// Main app entry point

import SwiftUI

// MARK: - App Entry Point

@main
struct WITFApp: App {

    // MARK: - App State

    @State private var appState = AppState()

    // MARK: - Services & Storage

    @State private var settingsStorage = UserSettingsStorage()
    @State private var subscriptionManager: SubscriptionManager?
    @State private var fridgeStorage = LocalFridgeStorageService()
    @State private var recipeStorage = LocalRecipeStorageService()

    // MARK: - View Models

    @State private var homeViewModel: HomeViewModel?
    @State private var recipesViewModel = RecipesViewModel()
    @State private var myFridgeViewModel = MyFridgeViewModel()
    @State private var profileViewModel: ProfileViewModel?

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            Group {
                if !settingsStorage.settings.hasCompletedOnboarding {
                    OnboardingView(isComplete: $settingsStorage.settings.hasCompletedOnboarding)
                } else {
                    MainTabView(
                        appState: appState,
                        homeViewModel: homeViewModel,
                        recipesViewModel: recipesViewModel,
                        myFridgeViewModel: myFridgeViewModel,
                        profileViewModel: profileViewModel
                    )
                }
            }
            .preferredColorScheme(settingsStorage.settings.darkModePreference.colorScheme)
            .onAppear {
                initializeServices()
            }
        }
    }

    // MARK: - Initialization

    private func initializeServices() {
        // Initialize subscription manager
        if subscriptionManager == nil {
            subscriptionManager = SubscriptionManager(
                settingsStorage: settingsStorage,
                useMockPurchases: true // Set to false for production
            )
        }

        // Initialize view models with dependencies
        if let subscriptionManager = subscriptionManager {
            if homeViewModel == nil {
                homeViewModel = HomeViewModel(
                    fridgeStorage: fridgeStorage,
                    recipeStorage: recipeStorage,
                    subscriptionManager: subscriptionManager
                )
            }

            if profileViewModel == nil {
                profileViewModel = ProfileViewModel(
                    settingsStorage: settingsStorage,
                    subscriptionManager: subscriptionManager
                )
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Bindable var appState: AppState
    var homeViewModel: HomeViewModel?
    @Bindable var recipesViewModel: RecipesViewModel
    @Bindable var myFridgeViewModel: MyFridgeViewModel
    var profileViewModel: ProfileViewModel?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // Home Tab
            Group {
                if let viewModel = homeViewModel {
                    HomeView(viewModel: viewModel)
                } else {
                    LoadingView(message: "Loading...")
                }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.iconName)
            }
            .tag(AppTab.home)

            // Recipes Tab
            RecipesView(viewModel: recipesViewModel)
                .tabItem {
                    Label(AppTab.recipes.title, systemImage: AppTab.recipes.iconName)
                }
                .tag(AppTab.recipes)

            // My Fridge Tab
            MyFridgeView(viewModel: myFridgeViewModel)
                .tabItem {
                    Label(AppTab.myFridge.title, systemImage: AppTab.myFridge.iconName)
                }
                .tag(AppTab.myFridge)

            // Profile Tab
            Group {
                if let viewModel = profileViewModel {
                    ProfileView(viewModel: viewModel)
                } else {
                    LoadingView(message: "Loading...")
                }
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.iconName)
            }
            .tag(AppTab.profile)
        }
        .tint(AppTheme.primaryFallback)
    }
}

// MARK: - Preview

#Preview("Main App") {
    let settingsStorage = UserSettingsStorage()
    settingsStorage.settings.hasCompletedOnboarding = true

    let subscriptionManager = SubscriptionManager(settingsStorage: settingsStorage)
    let homeViewModel = HomeViewModel(subscriptionManager: subscriptionManager)
    let profileViewModel = ProfileViewModel(settingsStorage: settingsStorage, subscriptionManager: subscriptionManager)

    return MainTabView(
        appState: AppState(),
        homeViewModel: homeViewModel,
        recipesViewModel: RecipesViewModel(),
        myFridgeViewModel: MyFridgeViewModel(),
        profileViewModel: profileViewModel
    )
}

#Preview("Onboarding") {
    OnboardingView(isComplete: .constant(false))
}
