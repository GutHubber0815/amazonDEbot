// WITF? - What's In That Fridge?
// Features/MyFridge/MyFridgeViewModel.swift

import Foundation

// MARK: - My Fridge View Model

@Observable
class MyFridgeViewModel {

    // MARK: - Properties

    /// All ingredients in the fridge
    var ingredients: [Ingredient] = []

    /// Ingredients grouped by category
    var groupedIngredients: [IngredientCategory: [Ingredient]] {
        Dictionary(grouping: ingredients) { $0.category }
    }

    /// Categories that have ingredients
    var activeCategories: [IngredientCategory] {
        groupedIngredients.keys.sorted { $0.rawValue < $1.rawValue }
    }

    /// Search text
    var searchText = ""

    /// Filtered ingredients based on search
    var filteredIngredients: [Ingredient] {
        if searchText.isEmpty {
            return ingredients
        }
        return ingredients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Loading state
    var isLoading = false

    /// Error state
    var errorMessage: String?

    /// Ingredient being edited
    var editingIngredient: Ingredient?

    // MARK: - Services

    private let storageService: FridgeStorageServiceProtocol

    // MARK: - Initialization

    init(storageService: FridgeStorageServiceProtocol = StorageServiceFactory.createFridgeStorage()) {
        self.storageService = storageService
    }

    // MARK: - Public Methods

    /// Loads all ingredients from storage
    @MainActor
    func loadIngredients() async {
        isLoading = true
        errorMessage = nil

        do {
            ingredients = try await storageService.loadIngredients()
        } catch {
            errorMessage = "Failed to load ingredients: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Adds a new ingredient
    @MainActor
    func addIngredient(_ ingredient: Ingredient) async {
        do {
            try await storageService.addIngredient(ingredient)
            ingredients.append(ingredient)
        } catch {
            errorMessage = "Failed to add ingredient: \(error.localizedDescription)"
        }
    }

    /// Updates an existing ingredient
    @MainActor
    func updateIngredient(_ ingredient: Ingredient) async {
        do {
            try await storageService.updateIngredient(ingredient)
            if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                ingredients[index] = ingredient
            }
        } catch {
            errorMessage = "Failed to update ingredient: \(error.localizedDescription)"
        }
    }

    /// Removes an ingredient
    @MainActor
    func removeIngredient(_ ingredient: Ingredient) async {
        do {
            try await storageService.removeIngredient(id: ingredient.id)
            ingredients.removeAll { $0.id == ingredient.id }
        } catch {
            errorMessage = "Failed to remove ingredient: \(error.localizedDescription)"
        }
    }

    /// Removes multiple ingredients
    @MainActor
    func removeIngredients(_ ingredientsToRemove: [Ingredient]) async {
        for ingredient in ingredientsToRemove {
            await removeIngredient(ingredient)
        }
    }

    /// Clears all ingredients
    @MainActor
    func clearAllIngredients() async {
        do {
            try await storageService.clearAll()
            ingredients.removeAll()
        } catch {
            errorMessage = "Failed to clear ingredients: \(error.localizedDescription)"
        }
    }

    /// Adds multiple preset ingredients
    @MainActor
    func addPresets(_ presets: [Ingredient]) async {
        for preset in presets {
            let newIngredient = Ingredient(
                name: preset.name,
                category: preset.category,
                iconName: preset.iconName
            )

            // Check if already exists
            if !ingredients.contains(where: { $0.name.lowercased() == newIngredient.name.lowercased() }) {
                await addIngredient(newIngredient)
            }
        }
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    /// Gets count for a category
    func count(for category: IngredientCategory) -> Int {
        groupedIngredients[category]?.count ?? 0
    }
}
