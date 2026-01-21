// WITF? - What's In That Fridge?
// Features/Profile/ProfileView.swift

import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            List {
                // Subscription section
                subscriptionSection

                // Preferences section
                preferencesSection

                // Settings section
                settingsSection

                // About section
                aboutSection
            }
            .listStyle(.insetGrouped)
            .background(AppTheme.background(colorScheme).ignoresSafeArea())
            .navigationTitle(String(localized: "profile.title"))
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $viewModel.showCuisinePreferences) {
                CuisinePreferencesView(selected: $viewModel.preferredCuisines)
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        Section {
            // Current status
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    HStack {
                        Image(systemName: viewModel.isPremium ? AppIcons.crown : AppIcons.star)
                            .foregroundColor(viewModel.isPremium ? .yellow : .secondary)
                        Text(viewModel.currentTier.displayName)
                            .font(AppTheme.Typography.headline)
                    }

                    if !viewModel.isPremium {
                        Text(String(localized: "subscription.remaining.\(viewModel.remainingGenerations)"))
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if !viewModel.isPremium {
                    Button {
                        viewModel.showPaywall = true
                    } label: {
                        Text(String(localized: "subscription.upgrade"))
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primaryFallback)
                }
            }
            .padding(.vertical, AppTheme.Spacing.xs)

            // Restore purchases
            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                Label(String(localized: "subscription.restore"), systemImage: "arrow.clockwise")
            }
        } header: {
            Text(String(localized: "profile.subscription"))
        } footer: {
            if viewModel.isPremium {
                Text(String(localized: "subscription.premium.footer"))
            }
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        Section {
            // Language
            Picker(String(localized: "profile.language"), selection: $viewModel.selectedLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    HStack {
                        Text(language.flagEmoji)
                        Text(language.displayName)
                    }
                    .tag(language)
                }
            }

            // Default servings
            Stepper(value: $viewModel.defaultServings, in: 1...10) {
                HStack {
                    Text(String(localized: "profile.default.servings"))
                    Spacer()
                    Text("\(viewModel.defaultServings)")
                        .foregroundColor(.secondary)
                }
            }

            // Cuisine preferences
            Button {
                viewModel.showCuisinePreferences = true
            } label: {
                HStack {
                    Text(String(localized: "profile.cuisine.preferences"))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(viewModel.preferredCuisines.count) " + String(localized: "profile.selected"))
                        .foregroundColor(.secondary)
                    Image(systemName: AppIcons.chevronRight)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        } header: {
            Text(String(localized: "profile.preferences"))
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        Section {
            // Appearance
            Picker(String(localized: "profile.appearance"), selection: $viewModel.darkModePreference) {
                ForEach(DarkModePreference.allCases) { preference in
                    Text(preference.displayName).tag(preference)
                }
            }
        } header: {
            Text(String(localized: "profile.settings"))
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            // Version
            HStack {
                Text(String(localized: "profile.version"))
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            // Privacy Policy
            Link(destination: URL(string: "https://witf.app/privacy")!) {
                HStack {
                    Text(String(localized: "profile.privacy"))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // Terms of Service
            Link(destination: URL(string: "https://witf.app/terms")!) {
                HStack {
                    Text(String(localized: "profile.terms"))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // Support
            Link(destination: URL(string: "mailto:support@witf.app")!) {
                HStack {
                    Text(String(localized: "profile.support"))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text(String(localized: "profile.about"))
        } footer: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("WITF? - What's In That Fridge?")
                    .font(AppTheme.Typography.caption)
                Text(String(localized: "profile.tagline"))
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Cuisine Preferences View

struct CuisinePreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: [CuisinePreference]

    var body: some View {
        NavigationStack {
            List {
                ForEach(CuisinePreference.allCuisines.filter { $0 != .surprise }) { cuisine in
                    Button {
                        toggleCuisine(cuisine)
                    } label: {
                        HStack {
                            Text(cuisine.flagEmoji)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(cuisine.displayName)
                                    .foregroundColor(.primary)
                                Text(cuisine.subtitle)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selected.contains(cuisine) {
                                Image(systemName: AppIcons.checkmark)
                                    .foregroundColor(AppTheme.primaryFallback)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "cuisine.preferences.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleCuisine(_ cuisine: CuisinePreference) {
        if let index = selected.firstIndex(of: cuisine) {
            selected.remove(at: index)
        } else {
            selected.append(cuisine)
        }
    }
}

// MARK: - Preview

#Preview {
    let settings = UserSettingsStorage()
    let subscription = SubscriptionManager(settingsStorage: settings)
    let viewModel = ProfileViewModel(settingsStorage: settings, subscriptionManager: subscription)

    return ProfileView(viewModel: viewModel)
}
