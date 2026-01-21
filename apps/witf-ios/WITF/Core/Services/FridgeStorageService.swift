// WITF? - What's In That Fridge?
// Core/Services/FridgeStorageService.swift

import Foundation

// MARK: - Protocol

/// Protocol for storing and retrieving fridge/pantry data
/// Implement this protocol to swap between local storage and cloud backends
protocol FridgeStorageServiceProtocol {
    /// Loads all stored ingredients
    func loadIngredients() async throws -> [Ingredient]

    /// Saves ingredients to storage
    func saveIngredients(_ ingredients: [Ingredient]) async throws

    /// Adds a single ingredient
    func addIngredient(_ ingredient: Ingredient) async throws

    /// Updates an existing ingredient
    func updateIngredient(_ ingredient: Ingredient) async throws

    /// Removes an ingredient by ID
    func removeIngredient(id: UUID) async throws

    /// Clears all ingredients
    func clearAll() async throws
}

/// Protocol for recipe storage (favorites, history)
protocol RecipeStorageServiceProtocol {
    /// Loads saved/favorited recipes
    func loadSavedRecipes() async throws -> [Recipe]

    /// Saves a recipe to favorites
    func saveRecipe(_ recipe: Recipe) async throws

    /// Removes a recipe from favorites
    func removeRecipe(id: UUID) async throws

    /// Loads recipe history (recently generated/viewed)
    func loadRecipeHistory() async throws -> [Recipe]

    /// Adds a recipe to history
    func addToHistory(_ recipe: Recipe) async throws
}

// MARK: - Storage Error

enum StorageError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case saveFailed(String)
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode data"
        case .decodingFailed: return "Failed to decode data"
        case .fileNotFound: return "Storage file not found"
        case .saveFailed(let reason): return "Save failed: \(reason)"
        case .loadFailed(let reason): return "Load failed: \(reason)"
        }
    }
}

// MARK: - Local Storage Keys

private enum StorageKeys {
    static let ingredients = "witf_ingredients"
    static let savedRecipes = "witf_saved_recipes"
    static let recipeHistory = "witf_recipe_history"
    static let userSettings = "witf_user_settings"
    static let userSubscription = "witf_user_subscription"
}

// MARK: - Local Fridge Storage Implementation

/// Local storage implementation using UserDefaults and file system
/// TODO: Replace with cloud sync (Firebase/AWS) for production
@Observable
class LocalFridgeStorageService: FridgeStorageServiceProtocol {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard

    // In-memory cache
    private(set) var cachedIngredients: [Ingredient] = []

    init() {
        // Load cached data on init
        Task {
            cachedIngredients = (try? await loadIngredients()) ?? []
        }
    }

    func loadIngredients() async throws -> [Ingredient] {
        guard let data = userDefaults.data(forKey: StorageKeys.ingredients) else {
            return []
        }

        do {
            let ingredients = try decoder.decode([Ingredient].self, from: data)
            cachedIngredients = ingredients
            return ingredients
        } catch {
            throw StorageError.decodingFailed
        }
    }

    func saveIngredients(_ ingredients: [Ingredient]) async throws {
        do {
            let data = try encoder.encode(ingredients)
            userDefaults.set(data, forKey: StorageKeys.ingredients)
            cachedIngredients = ingredients
        } catch {
            throw StorageError.encodingFailed
        }
    }

    func addIngredient(_ ingredient: Ingredient) async throws {
        var ingredients = try await loadIngredients()
        ingredients.append(ingredient)
        try await saveIngredients(ingredients)
    }

    func updateIngredient(_ ingredient: Ingredient) async throws {
        var ingredients = try await loadIngredients()
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index] = ingredient
            try await saveIngredients(ingredients)
        }
    }

    func removeIngredient(id: UUID) async throws {
        var ingredients = try await loadIngredients()
        ingredients.removeAll { $0.id == id }
        try await saveIngredients(ingredients)
    }

    func clearAll() async throws {
        userDefaults.removeObject(forKey: StorageKeys.ingredients)
        cachedIngredients = []
    }
}

// MARK: - Local Recipe Storage Implementation

@Observable
class LocalRecipeStorageService: RecipeStorageServiceProtocol {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    private let maxHistoryItems = 50

    // In-memory cache
    private(set) var cachedSavedRecipes: [Recipe] = []
    private(set) var cachedHistory: [Recipe] = []

    init() {
        // Load cached data on init
        Task {
            cachedSavedRecipes = (try? await loadSavedRecipes()) ?? []
            cachedHistory = (try? await loadRecipeHistory()) ?? []
        }
    }

    func loadSavedRecipes() async throws -> [Recipe] {
        guard let data = userDefaults.data(forKey: StorageKeys.savedRecipes) else {
            return []
        }

        do {
            let recipes = try decoder.decode([Recipe].self, from: data)
            cachedSavedRecipes = recipes
            return recipes
        } catch {
            throw StorageError.decodingFailed
        }
    }

    func saveRecipe(_ recipe: Recipe) async throws {
        var recipes = try await loadSavedRecipes()

        // Check if already saved
        if recipes.contains(where: { $0.id == recipe.id }) {
            return
        }

        var savedRecipe = recipe
        savedRecipe.isFavorite = true
        recipes.insert(savedRecipe, at: 0)

        do {
            let data = try encoder.encode(recipes)
            userDefaults.set(data, forKey: StorageKeys.savedRecipes)
            cachedSavedRecipes = recipes
        } catch {
            throw StorageError.encodingFailed
        }
    }

    func removeRecipe(id: UUID) async throws {
        var recipes = try await loadSavedRecipes()
        recipes.removeAll { $0.id == id }

        do {
            let data = try encoder.encode(recipes)
            userDefaults.set(data, forKey: StorageKeys.savedRecipes)
            cachedSavedRecipes = recipes
        } catch {
            throw StorageError.encodingFailed
        }
    }

    func loadRecipeHistory() async throws -> [Recipe] {
        guard let data = userDefaults.data(forKey: StorageKeys.recipeHistory) else {
            return []
        }

        do {
            let recipes = try decoder.decode([Recipe].self, from: data)
            cachedHistory = recipes
            return recipes
        } catch {
            throw StorageError.decodingFailed
        }
    }

    func addToHistory(_ recipe: Recipe) async throws {
        var history = try await loadRecipeHistory()

        // Remove if already in history to avoid duplicates
        history.removeAll { $0.id == recipe.id }

        // Add to front
        history.insert(recipe, at: 0)

        // Trim to max size
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }

        do {
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: StorageKeys.recipeHistory)
            cachedHistory = history
        } catch {
            throw StorageError.encodingFailed
        }
    }
}

// MARK: - User Settings Storage

@Observable
class UserSettingsStorage {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard

    var settings: UserSettings {
        didSet {
            save()
        }
    }

    var subscription: UserSubscription {
        didSet {
            saveSubscription()
        }
    }

    init() {
        // Load settings
        if let data = userDefaults.data(forKey: StorageKeys.userSettings),
           let loaded = try? decoder.decode(UserSettings.self, from: data) {
            self.settings = loaded
        } else {
            self.settings = .default
        }

        // Load subscription
        if let data = userDefaults.data(forKey: StorageKeys.userSubscription),
           let loaded = try? decoder.decode(UserSubscription.self, from: data) {
            self.subscription = loaded
        } else {
            self.subscription = .free
        }

        // Reset monthly counter if needed
        subscription.resetIfNeeded()
    }

    func save() {
        if let data = try? encoder.encode(settings) {
            userDefaults.set(data, forKey: StorageKeys.userSettings)
        }
    }

    func saveSubscription() {
        if let data = try? encoder.encode(subscription) {
            userDefaults.set(data, forKey: StorageKeys.userSubscription)
        }
    }

    func resetAll() {
        settings = .default
        subscription = .free
        userDefaults.removeObject(forKey: StorageKeys.userSettings)
        userDefaults.removeObject(forKey: StorageKeys.userSubscription)
    }
}

// MARK: - Cloud Storage Stub

/// Stub for cloud-based storage (Firebase/AWS)
/// TODO: Implement with actual cloud backend
class CloudFridgeStorageService: FridgeStorageServiceProtocol {

    // TODO: Add Firebase/AWS configuration
    // private let firestore: Firestore
    // private let authService: AuthService

    func loadIngredients() async throws -> [Ingredient] {
        // TODO: Implement Firestore/DynamoDB fetch
        // Fall back to local for now
        let local = LocalFridgeStorageService()
        return try await local.loadIngredients()
    }

    func saveIngredients(_ ingredients: [Ingredient]) async throws {
        // TODO: Implement cloud save with sync
        let local = LocalFridgeStorageService()
        try await local.saveIngredients(ingredients)
    }

    func addIngredient(_ ingredient: Ingredient) async throws {
        let local = LocalFridgeStorageService()
        try await local.addIngredient(ingredient)
    }

    func updateIngredient(_ ingredient: Ingredient) async throws {
        let local = LocalFridgeStorageService()
        try await local.updateIngredient(ingredient)
    }

    func removeIngredient(id: UUID) async throws {
        let local = LocalFridgeStorageService()
        try await local.removeIngredient(id: id)
    }

    func clearAll() async throws {
        let local = LocalFridgeStorageService()
        try await local.clearAll()
    }
}

// MARK: - Service Factory

enum StorageServiceFactory {

    enum StorageType {
        case local
        case cloud
    }

    static func createFridgeStorage(type: StorageType = .local) -> FridgeStorageServiceProtocol {
        switch type {
        case .local:
            return LocalFridgeStorageService()
        case .cloud:
            return CloudFridgeStorageService()
        }
    }

    static func createRecipeStorage() -> RecipeStorageServiceProtocol {
        return LocalRecipeStorageService()
    }
}
