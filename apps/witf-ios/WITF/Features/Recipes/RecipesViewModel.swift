// WITF? - What's In That Fridge?
// Features/Recipes/RecipesViewModel.swift

import Foundation

// MARK: - Recipes View Model

@Observable
class RecipesViewModel {

    // MARK: - Properties

    /// Saved/favorited recipes
    var savedRecipes: [Recipe] = []

    /// Recipe history
    var historyRecipes: [Recipe] = []

    /// Selected filter
    var selectedFilter: RecipeFilter = .all

    /// Search text
    var searchText = ""

    /// Loading state
    var isLoading = false

    /// Error state
    var errorMessage: String?

    /// Filtered recipes based on current filter and search
    var filteredRecipes: [Recipe] {
        let baseRecipes: [Recipe]

        switch selectedFilter {
        case .all:
            baseRecipes = Array(Set(savedRecipes + historyRecipes))
        case .favorites:
            baseRecipes = savedRecipes
        case .history:
            baseRecipes = historyRecipes
        }

        if searchText.isEmpty {
            return baseRecipes
        }

        return baseRecipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(searchText) ||
            recipe.cuisine.displayName.localizedCaseInsensitiveContains(searchText) ||
            recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Services

    private let storageService: RecipeStorageServiceProtocol

    // MARK: - Initialization

    init(storageService: RecipeStorageServiceProtocol = StorageServiceFactory.createRecipeStorage()) {
        self.storageService = storageService
    }

    // MARK: - Public Methods

    /// Loads all recipes from storage
    @MainActor
    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        do {
            savedRecipes = try await storageService.loadSavedRecipes()
            historyRecipes = try await storageService.loadRecipeHistory()
        } catch {
            errorMessage = "Failed to load recipes: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Saves a recipe to favorites
    @MainActor
    func saveRecipe(_ recipe: Recipe) async {
        do {
            try await storageService.saveRecipe(recipe)
            if !savedRecipes.contains(where: { $0.id == recipe.id }) {
                var saved = recipe
                saved.isFavorite = true
                savedRecipes.insert(saved, at: 0)
            }
        } catch {
            errorMessage = "Failed to save recipe: \(error.localizedDescription)"
        }
    }

    /// Removes a recipe from favorites
    @MainActor
    func unsaveRecipe(_ recipe: Recipe) async {
        do {
            try await storageService.removeRecipe(id: recipe.id)
            savedRecipes.removeAll { $0.id == recipe.id }
        } catch {
            errorMessage = "Failed to remove recipe: \(error.localizedDescription)"
        }
    }

    /// Toggles favorite status
    @MainActor
    func toggleFavorite(_ recipe: Recipe) async {
        if savedRecipes.contains(where: { $0.id == recipe.id }) {
            await unsaveRecipe(recipe)
        } else {
            await saveRecipe(recipe)
        }
    }

    /// Checks if a recipe is saved
    func isSaved(_ recipe: Recipe) -> Bool {
        savedRecipes.contains { $0.id == recipe.id }
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Recipe Filter

enum RecipeFilter: String, CaseIterable, Identifiable {
    case all
    case favorites
    case history

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return String(localized: "recipes.filter.all")
        case .favorites: return String(localized: "recipes.filter.favorites")
        case .history: return String(localized: "recipes.filter.history")
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .favorites: return AppIcons.heart
        case .history: return AppIcons.clock
        }
    }
}
