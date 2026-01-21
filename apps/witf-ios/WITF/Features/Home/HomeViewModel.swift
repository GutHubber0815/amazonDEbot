// WITF? - What's In That Fridge?
// Features/Home/HomeViewModel.swift

import Foundation
import SwiftUI
import PhotosUI

// MARK: - Home View Model

@Observable
class HomeViewModel {

    // MARK: - Properties

    /// Currently scanned/detected ingredients
    var scannedIngredients: [Ingredient] = []

    /// Recent recipes (history)
    var recentRecipes: [Recipe] = []

    /// Generated recipes from current scan
    var generatedRecipes: [Recipe] = []

    /// Selected cuisine preference
    var selectedCuisine: CuisinePreference = .international

    /// Number of servings
    var servings: Int = 2

    /// Loading states
    var isScanning = false
    var isGenerating = false

    /// Error state
    var errorMessage: String?

    /// Show recipe results
    var showRecipeResults = false

    /// Show paywall
    var showPaywall = false

    /// Selected photo item
    var selectedPhotoItem: PhotosPickerItem?

    /// Selected image for scanning
    var selectedImage: UIImage?

    // MARK: - Services

    private let recognitionService: IngredientRecognitionServiceProtocol
    private let recipeService: RecipeGeneratorServiceProtocol
    private let fridgeStorage: FridgeStorageServiceProtocol
    private let recipeStorage: RecipeStorageServiceProtocol
    private let subscriptionManager: SubscriptionManager

    // MARK: - Initialization

    init(
        recognitionService: IngredientRecognitionServiceProtocol = IngredientRecognitionServiceFactory.create(type: .mock),
        recipeService: RecipeGeneratorServiceProtocol = RecipeGeneratorServiceFactory.create(type: .mock),
        fridgeStorage: FridgeStorageServiceProtocol = StorageServiceFactory.createFridgeStorage(),
        recipeStorage: RecipeStorageServiceProtocol = StorageServiceFactory.createRecipeStorage(),
        subscriptionManager: SubscriptionManager
    ) {
        self.recognitionService = recognitionService
        self.recipeService = recipeService
        self.fridgeStorage = fridgeStorage
        self.recipeStorage = recipeStorage
        self.subscriptionManager = subscriptionManager
    }

    // MARK: - Public Methods

    /// Loads initial data
    @MainActor
    func loadData() async {
        do {
            recentRecipes = try await recipeStorage.loadRecipeHistory()
        } catch {
            print("Failed to load recipe history: \(error)")
        }
    }

    /// Processes a selected photo for ingredient recognition
    @MainActor
    func processSelectedPhoto() async {
        guard let photoItem = selectedPhotoItem else { return }

        isScanning = true
        errorMessage = nil

        do {
            // Load image data
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                await scanImage(uiImage)
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }

        isScanning = false
    }

    /// Scans an image for ingredients
    @MainActor
    func scanImage(_ image: UIImage) async {
        isScanning = true
        errorMessage = nil

        do {
            let detected = try await recognitionService.recognizeIngredients(from: image)
            scannedIngredients = detected.map { $0.toIngredient() }

            // Save to fridge storage
            for ingredient in scannedIngredients {
                try await fridgeStorage.addIngredient(ingredient)
            }
        } catch {
            errorMessage = "Scan failed: \(error.localizedDescription)"
        }

        isScanning = false
    }

    /// Generates recipes based on scanned ingredients
    @MainActor
    func generateRecipes() async {
        guard !scannedIngredients.isEmpty else {
            errorMessage = String(localized: "error.no.ingredients.selected")
            return
        }

        // Check subscription quota
        if !subscriptionManager.canGenerate {
            showPaywall = true
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            generatedRecipes = try await recipeService.generateRecipes(
                ingredients: scannedIngredients,
                cuisine: selectedCuisine,
                servings: servings,
                limit: 10
            )

            // Record generation for quota tracking
            subscriptionManager.recordGeneration()

            // Add to history
            for recipe in generatedRecipes.prefix(3) {
                try await recipeStorage.addToHistory(recipe)
            }

            showRecipeResults = true
        } catch {
            errorMessage = "Recipe generation failed: \(error.localizedDescription)"
        }

        isGenerating = false
    }

    /// Adds an ingredient manually
    func addIngredient(_ ingredient: Ingredient) {
        if !scannedIngredients.contains(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
            scannedIngredients.append(ingredient)
        }
    }

    /// Removes an ingredient
    func removeIngredient(_ ingredient: Ingredient) {
        scannedIngredients.removeAll { $0.id == ingredient.id }
    }

    /// Clears all scanned ingredients
    func clearIngredients() {
        scannedIngredients.removeAll()
        selectedImage = nil
        selectedPhotoItem = nil
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    /// Returns remaining generations text
    var remainingGenerationsText: String {
        if subscriptionManager.isPremium {
            return String(localized: "subscription.unlimited")
        }
        let remaining = subscriptionManager.remainingGenerations
        return String(localized: "subscription.remaining.\(remaining)")
    }
}
