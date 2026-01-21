// WITF? - What's In That Fridge?
// Features/Home/HomeView.swift

import SwiftUI
import PhotosUI

// MARK: - Home View

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showAddIngredient = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header
                    headerSection

                    // Scan Section
                    scanSection

                    // Scanned Ingredients
                    if !viewModel.scannedIngredients.isEmpty {
                        ingredientsSection
                    }

                    // Cuisine & Servings
                    if !viewModel.scannedIngredients.isEmpty {
                        preferencesSection
                    }

                    // Generate Button
                    if !viewModel.scannedIngredients.isEmpty {
                        generateButton
                    }

                    // Recent Recipes
                    if !viewModel.recentRecipes.isEmpty {
                        recentRecipesSection
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(AppTheme.background(colorScheme).ignoresSafeArea())
            .navigationTitle(String(localized: "home.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.scannedIngredients.isEmpty {
                        Button {
                            viewModel.clearIngredients()
                        } label: {
                            Text(String(localized: "home.clear"))
                                .font(AppTheme.Typography.subheadline)
                        }
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                Task {
                    await viewModel.processSelectedPhoto()
                }
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientSheet(onAdd: { ingredient in
                    viewModel.addIngredient(ingredient)
                })
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .navigationDestination(isPresented: $viewModel.showRecipeResults) {
                RecipeListView(
                    recipes: viewModel.generatedRecipes,
                    title: String(localized: "recipes.generated.title")
                )
            }
            .overlay {
                if viewModel.isScanning || viewModel.isGenerating {
                    LoadingView(message: viewModel.isScanning
                               ? String(localized: "home.scanning")
                               : String(localized: "home.generating"))
                }
            }
            .alert(
                String(localized: "error.title"),
                isPresented: .constant(viewModel.errorMessage != nil)
            ) {
                Button(String(localized: "common.ok")) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(String(localized: "home.greeting"))
                .font(AppTheme.Typography.largeTitle)
                .foregroundColor(.primary)

            Text(String(localized: "home.subtitle"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.secondary)

            // Subscription status
            HStack {
                Image(systemName: AppIcons.sparkles)
                    .foregroundColor(AppTheme.primaryFallback)
                Text(viewModel.remainingGenerationsText)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, AppTheme.Spacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Scan Section

    private var scanSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Preview image or placeholder
            ZStack {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(AppTheme.primaryGradient.opacity(0.15))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: AppIcons.fridge)
                                    .font(.system(size: 50))
                                    .foregroundColor(AppTheme.primaryFallback)

                                Text(String(localized: "home.scan.placeholder"))
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }

            // Action buttons
            HStack(spacing: AppTheme.Spacing.md) {
                // Camera button
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    Label(String(localized: "home.takePhoto"), systemImage: AppIcons.camera)
                }
                .buttonStyle(PrimaryButtonStyle())

                // Manual add button
                Button {
                    showAddIngredient = true
                } label: {
                    Label(String(localized: "home.addManually"), systemImage: AppIcons.plus)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Ingredients Section

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(
                title: String(localized: "home.ingredients.title"),
                actionTitle: String(localized: "home.addMore")
            ) {
                showAddIngredient = true
            }

            FlowLayout(spacing: AppTheme.Spacing.xs) {
                ForEach(viewModel.scannedIngredients) { ingredient in
                    IngredientChip(ingredient: ingredient) {
                        withAnimation(AppTheme.Animation.quick) {
                            viewModel.removeIngredient(ingredient)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Cuisine selector
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(String(localized: "home.cuisine.title"))
                    .font(AppTheme.Typography.headline)
                    .padding(.horizontal, AppTheme.Spacing.md)

                CuisineSelector(selected: $viewModel.selectedCuisine)
            }

            // Servings selector
            HStack {
                Text(String(localized: "home.servings.title"))
                    .font(AppTheme.Typography.headline)

                Spacer()

                ServingsStepper(value: $viewModel.servings)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateRecipes()
            }
        } label: {
            HStack {
                Image(systemName: AppIcons.wand)
                Text(String(localized: "home.generate"))
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, AppTheme.Spacing.md)
        .disabled(viewModel.scannedIngredients.isEmpty || viewModel.isGenerating)
    }

    // MARK: - Recent Recipes Section

    private var recentRecipesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(title: String(localized: "home.recent.title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.recentRecipes.prefix(5)) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeCard(recipe: recipe)
                                .frame(width: 180)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

// MARK: - Add Ingredient Sheet

struct AddIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (Ingredient) -> Void

    @State private var ingredientName = ""
    @State private var selectedCategory: IngredientCategory = .other

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Text input
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(String(localized: "ingredient.name"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)

                    TextField(String(localized: "ingredient.name.placeholder"), text: $ingredientName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                }

                // Category picker
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(String(localized: "ingredient.category"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)

                    Picker(String(localized: "ingredient.category"), selection: $selectedCategory) {
                        ForEach(IngredientCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.defaultIcon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Quick presets
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(String(localized: "ingredient.presets"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: AppTheme.Spacing.xs) {
                        ForEach(Ingredient.presets) { preset in
                            Button {
                                addIngredient(preset)
                            } label: {
                                Text(preset.name)
                                    .font(AppTheme.Typography.caption)
                            }
                            .buttonStyle(ChipButtonStyle())
                        }
                    }
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle(String(localized: "ingredient.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.add")) {
                        if !ingredientName.isEmpty {
                            let ingredient = Ingredient(
                                name: ingredientName,
                                category: selectedCategory
                            )
                            addIngredient(ingredient)
                        }
                    }
                    .disabled(ingredientName.isEmpty)
                }
            }
        }
    }

    private func addIngredient(_ ingredient: Ingredient) {
        onAdd(ingredient)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let settingsStorage = UserSettingsStorage()
    let subscriptionManager = SubscriptionManager(settingsStorage: settingsStorage)
    let viewModel = HomeViewModel(subscriptionManager: subscriptionManager)

    return HomeView(viewModel: viewModel)
}
