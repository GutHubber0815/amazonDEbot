// WITF? - What's In That Fridge?
// Core/Services/RecipeGeneratorService.swift

import Foundation

// MARK: - Protocol

/// Protocol for recipe generation based on available ingredients
/// Implement this protocol to swap between mock, local database, or AI/LLM implementations
protocol RecipeGeneratorServiceProtocol {
    /// Generates recipes based on available ingredients
    /// - Parameters:
    ///   - ingredients: Available ingredients
    ///   - cuisine: Optional cuisine preference filter
    ///   - servings: Number of servings to scale recipes to
    ///   - limit: Maximum number of recipes to return
    /// - Returns: Array of matching recipes sorted by relevance
    func generateRecipes(
        ingredients: [Ingredient],
        cuisine: CuisinePreference?,
        servings: Int,
        limit: Int
    ) async throws -> [Recipe]
}

// MARK: - Recipe Generation Error

enum RecipeGenerationError: LocalizedError {
    case noIngredientsProvided
    case noMatchingRecipes
    case generationFailed(String)
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .noIngredientsProvided:
            return String(localized: "error.no.ingredients")
        case .noMatchingRecipes:
            return String(localized: "error.no.recipes")
        case .generationFailed(let reason):
            return String(localized: "error.generation.failed") + ": \(reason)"
        case .quotaExceeded:
            return String(localized: "error.quota.exceeded")
        }
    }
}

// MARK: - Mock Implementation

/// Mock implementation with a local recipe database
/// TODO: Replace with real LLM/AI recipe generation or remote API
@Observable
class MockRecipeGeneratorService: RecipeGeneratorServiceProtocol {

    var isGenerating = false
    var lastError: Error?

    /// Local recipe database for matching
    private let recipeDatabase: [Recipe]

    init() {
        self.recipeDatabase = Self.buildRecipeDatabase()
    }

    func generateRecipes(
        ingredients: [Ingredient],
        cuisine: CuisinePreference?,
        servings: Int,
        limit: Int = 10
    ) async throws -> [Recipe] {
        guard !ingredients.isEmpty else {
            throw RecipeGenerationError.noIngredientsProvided
        }

        isGenerating = true
        defer { isGenerating = false }

        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        let ingredientNames = Set(ingredients.map { $0.name.lowercased() })

        // Score and filter recipes
        var scoredRecipes = recipeDatabase.compactMap { recipe -> Recipe? in
            // Filter by cuisine if specified
            if let preferredCuisine = cuisine, preferredCuisine != .surprise {
                guard recipe.cuisine == preferredCuisine || recipe.cuisine == .international else {
                    return nil
                }
            }

            // Calculate match score
            let recipeIngredientNames = Set(recipe.ingredients.map { $0.name.lowercased() })
            let matchingIngredients = ingredientNames.intersection(recipeIngredientNames)
            let matchScore = Double(matchingIngredients.count) / Double(recipeIngredientNames.count)

            // Only include recipes with at least 30% ingredient match
            guard matchScore >= 0.3 else { return nil }

            var matchedRecipe = recipe
            matchedRecipe.matchScore = matchScore
            return matchedRecipe.scaled(to: servings)
        }

        // Sort by match score (descending)
        scoredRecipes.sort { ($0.matchScore ?? 0) > ($1.matchScore ?? 0) }

        let results = Array(scoredRecipes.prefix(limit))

        guard !results.isEmpty else {
            throw RecipeGenerationError.noMatchingRecipes
        }

        return results
    }

    // MARK: - Recipe Database

    /// Builds the local recipe database with region-typical recipes
    private static func buildRecipeDatabase() -> [Recipe] {
        var recipes: [Recipe] = []

        // German recipes
        recipes.append(contentsOf: germanRecipes())
        // Italian recipes
        recipes.append(contentsOf: italianRecipes())
        // Mediterranean recipes
        recipes.append(contentsOf: mediterraneanRecipes())
        // Asian recipes
        recipes.append(contentsOf: asianRecipes())
        // International simple recipes
        recipes.append(contentsOf: internationalRecipes())

        return recipes
    }

    private static func germanRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Kartoffelpuffer",
                subtitle: "German Potato Pancakes",
                cuisine: .german,
                ingredients: [
                    RecipeIngredient(name: "Potatoes", quantity: 500, unit: .grams),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Eggs", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Flour", quantity: 2, unit: .tablespoons),
                    RecipeIngredient(name: "Salt", quantity: 1, unit: .teaspoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Peel and grate potatoes. Squeeze out excess moisture."),
                    RecipeStep(stepNumber: 2, instruction: "Finely dice onion and mix with potatoes."),
                    RecipeStep(stepNumber: 3, instruction: "Add egg, flour, and salt. Mix well."),
                    RecipeStep(stepNumber: 4, instruction: "Heat oil in a pan. Form small pancakes and fry until golden.", duration: 8),
                    RecipeStep(stepNumber: 5, instruction: "Serve with applesauce or sour cream.")
                ],
                cookingTime: 25,
                prepTime: 15,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 280, protein: 6, carbohydrates: 42, fat: 10, fiber: 3, sodium: 380),
                tags: ["german", "vegetarian", "side dish"]
            ),
            Recipe(
                title: "Spätzle mit Käse",
                subtitle: "Cheese Spätzle",
                cuisine: .german,
                ingredients: [
                    RecipeIngredient(name: "Flour", quantity: 300, unit: .grams),
                    RecipeIngredient(name: "Eggs", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Milk", quantity: 100, unit: .milliliters),
                    RecipeIngredient(name: "Cheese", quantity: 200, unit: .grams),
                    RecipeIngredient(name: "Onion", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Butter", quantity: 50, unit: .grams)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Mix flour, eggs, milk, and salt into a thick batter."),
                    RecipeStep(stepNumber: 2, instruction: "Push batter through a spätzle press into boiling salted water.", duration: 5),
                    RecipeStep(stepNumber: 3, instruction: "Fry onions in butter until golden brown."),
                    RecipeStep(stepNumber: 4, instruction: "Layer spätzle with grated cheese. Top with fried onions.")
                ],
                cookingTime: 20,
                prepTime: 15,
                difficulty: .medium,
                servings: 4,
                nutrition: NutritionInfo(calories: 520, protein: 22, carbohydrates: 58, fat: 24, fiber: 2, sodium: 420),
                tags: ["german", "comfort food", "vegetarian"]
            ),
            Recipe(
                title: "Schnitzel",
                subtitle: "Classic Breaded Cutlet",
                cuisine: .german,
                ingredients: [
                    RecipeIngredient(name: "Pork Cutlets", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Eggs", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Flour", quantity: 100, unit: .grams),
                    RecipeIngredient(name: "Breadcrumbs", quantity: 150, unit: .grams),
                    RecipeIngredient(name: "Lemon", quantity: 1, unit: .pieces)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Pound cutlets thin. Season with salt and pepper."),
                    RecipeStep(stepNumber: 2, instruction: "Set up breading station: flour, beaten eggs, breadcrumbs."),
                    RecipeStep(stepNumber: 3, instruction: "Coat cutlets in flour, then egg, then breadcrumbs."),
                    RecipeStep(stepNumber: 4, instruction: "Fry in hot oil until golden brown, about 3-4 minutes per side.", duration: 8),
                    RecipeStep(stepNumber: 5, instruction: "Drain on paper towels. Serve with lemon wedges.")
                ],
                cookingTime: 15,
                prepTime: 15,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 450, protein: 35, carbohydrates: 28, fat: 22, fiber: 1, sodium: 520),
                tags: ["german", "classic", "meat"]
            )
        ]
    }

    private static func italianRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Pasta Aglio e Olio",
                subtitle: "Garlic and Oil Pasta",
                cuisine: .italian,
                ingredients: [
                    RecipeIngredient(name: "Spaghetti", quantity: 400, unit: .grams),
                    RecipeIngredient(name: "Garlic", quantity: 6, unit: .pieces),
                    RecipeIngredient(name: "Olive Oil", quantity: 100, unit: .milliliters),
                    RecipeIngredient(name: "Chili Flakes", quantity: 1, unit: .teaspoons, isOptional: true),
                    RecipeIngredient(name: "Parsley", quantity: 1, unit: .bunches)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Cook spaghetti in salted water until al dente.", duration: 10),
                    RecipeStep(stepNumber: 2, instruction: "Slice garlic thinly. Heat olive oil over low heat."),
                    RecipeStep(stepNumber: 3, instruction: "Add garlic and chili flakes. Cook until garlic is golden.", duration: 3, tip: "Don't let garlic burn!"),
                    RecipeStep(stepNumber: 4, instruction: "Add pasta with some cooking water. Toss to combine."),
                    RecipeStep(stepNumber: 5, instruction: "Garnish with fresh parsley and serve immediately.")
                ],
                cookingTime: 15,
                prepTime: 5,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 420, protein: 12, carbohydrates: 65, fat: 14, fiber: 3, sodium: 280),
                tags: ["italian", "quick", "vegetarian", "pasta"]
            ),
            Recipe(
                title: "Caprese Salad",
                subtitle: "Fresh Tomato and Mozzarella",
                cuisine: .italian,
                ingredients: [
                    RecipeIngredient(name: "Tomatoes", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Mozzarella", quantity: 250, unit: .grams),
                    RecipeIngredient(name: "Basil", quantity: 1, unit: .bunches),
                    RecipeIngredient(name: "Olive Oil", quantity: 3, unit: .tablespoons),
                    RecipeIngredient(name: "Balsamic Vinegar", quantity: 1, unit: .tablespoons, isOptional: true)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Slice tomatoes and mozzarella into thick rounds."),
                    RecipeStep(stepNumber: 2, instruction: "Arrange alternating on a plate."),
                    RecipeStep(stepNumber: 3, instruction: "Tuck fresh basil leaves between slices."),
                    RecipeStep(stepNumber: 4, instruction: "Drizzle with olive oil and balsamic. Season with salt and pepper.")
                ],
                cookingTime: 0,
                prepTime: 10,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 280, protein: 14, carbohydrates: 8, fat: 22, fiber: 2, sodium: 320),
                tags: ["italian", "salad", "vegetarian", "no-cook"]
            ),
            Recipe(
                title: "Risotto ai Funghi",
                subtitle: "Mushroom Risotto",
                cuisine: .italian,
                ingredients: [
                    RecipeIngredient(name: "Arborio Rice", quantity: 300, unit: .grams),
                    RecipeIngredient(name: "Mushrooms", quantity: 300, unit: .grams),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Chicken Broth", quantity: 1, unit: .liters),
                    RecipeIngredient(name: "Parmesan", quantity: 80, unit: .grams),
                    RecipeIngredient(name: "Butter", quantity: 50, unit: .grams),
                    RecipeIngredient(name: "White Wine", quantity: 100, unit: .milliliters)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Clean and slice mushrooms. Sauté in butter until golden.", duration: 5),
                    RecipeStep(stepNumber: 2, instruction: "In another pan, sauté diced onion until translucent."),
                    RecipeStep(stepNumber: 3, instruction: "Add rice and toast for 2 minutes."),
                    RecipeStep(stepNumber: 4, instruction: "Add wine and stir until absorbed."),
                    RecipeStep(stepNumber: 5, instruction: "Add warm broth one ladle at a time, stirring frequently.", duration: 18),
                    RecipeStep(stepNumber: 6, instruction: "Fold in mushrooms, parmesan, and butter. Rest 2 minutes.")
                ],
                cookingTime: 30,
                prepTime: 15,
                difficulty: .medium,
                servings: 4,
                nutrition: NutritionInfo(calories: 480, protein: 14, carbohydrates: 62, fat: 18, fiber: 3, sodium: 580),
                tags: ["italian", "risotto", "vegetarian"]
            )
        ]
    }

    private static func mediterraneanRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Greek Salad",
                subtitle: "Horiatiki",
                cuisine: .mediterranean,
                ingredients: [
                    RecipeIngredient(name: "Tomatoes", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Cucumber", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Red Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Feta Cheese", quantity: 200, unit: .grams),
                    RecipeIngredient(name: "Olives", quantity: 100, unit: .grams),
                    RecipeIngredient(name: "Olive Oil", quantity: 4, unit: .tablespoons),
                    RecipeIngredient(name: "Oregano", quantity: 1, unit: .teaspoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Cut tomatoes into wedges, cucumber into half-moons."),
                    RecipeStep(stepNumber: 2, instruction: "Slice red onion into thin rings."),
                    RecipeStep(stepNumber: 3, instruction: "Arrange vegetables on a plate. Add olives."),
                    RecipeStep(stepNumber: 4, instruction: "Place feta block on top. Drizzle with olive oil."),
                    RecipeStep(stepNumber: 5, instruction: "Sprinkle with oregano and serve with crusty bread.")
                ],
                cookingTime: 0,
                prepTime: 15,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 320, protein: 10, carbohydrates: 12, fat: 26, fiber: 3, sodium: 680),
                tags: ["mediterranean", "greek", "salad", "vegetarian"]
            ),
            Recipe(
                title: "Shakshuka",
                subtitle: "Eggs in Tomato Sauce",
                cuisine: .mediterranean,
                ingredients: [
                    RecipeIngredient(name: "Eggs", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Tomatoes", quantity: 400, unit: .grams, notes: "canned or fresh"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Bell Pepper", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Garlic", quantity: 3, unit: .pieces),
                    RecipeIngredient(name: "Cumin", quantity: 1, unit: .teaspoons),
                    RecipeIngredient(name: "Paprika", quantity: 1, unit: .teaspoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Dice onion and bell pepper. Mince garlic."),
                    RecipeStep(stepNumber: 2, instruction: "Sauté vegetables until soft. Add spices.", duration: 8),
                    RecipeStep(stepNumber: 3, instruction: "Add tomatoes and simmer for 10 minutes.", duration: 10),
                    RecipeStep(stepNumber: 4, instruction: "Make 4 wells in the sauce. Crack an egg into each."),
                    RecipeStep(stepNumber: 5, instruction: "Cover and cook until eggs are set to your liking.", duration: 5, tip: "Serve with crusty bread for dipping!")
                ],
                cookingTime: 25,
                prepTime: 10,
                difficulty: .easy,
                servings: 2,
                nutrition: NutritionInfo(calories: 280, protein: 16, carbohydrates: 18, fat: 16, fiber: 4, sodium: 420),
                tags: ["mediterranean", "breakfast", "vegetarian"]
            ),
            Recipe(
                title: "Falafel",
                subtitle: "Crispy Chickpea Fritters",
                cuisine: .mediterranean,
                ingredients: [
                    RecipeIngredient(name: "Chickpeas", quantity: 400, unit: .grams, notes: "dried, soaked overnight"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Garlic", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Parsley", quantity: 1, unit: .bunches),
                    RecipeIngredient(name: "Cumin", quantity: 2, unit: .teaspoons),
                    RecipeIngredient(name: "Coriander", quantity: 1, unit: .teaspoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Drain soaked chickpeas. Do not use canned for this recipe."),
                    RecipeStep(stepNumber: 2, instruction: "Blend all ingredients in a food processor until coarse."),
                    RecipeStep(stepNumber: 3, instruction: "Refrigerate mixture for 1 hour.", duration: 60),
                    RecipeStep(stepNumber: 4, instruction: "Form into small patties or balls."),
                    RecipeStep(stepNumber: 5, instruction: "Deep fry until golden brown, about 3-4 minutes.", duration: 4),
                    RecipeStep(stepNumber: 6, instruction: "Serve in pita with tahini, vegetables, and pickles.")
                ],
                cookingTime: 15,
                prepTime: 75,
                difficulty: .medium,
                servings: 4,
                nutrition: NutritionInfo(calories: 340, protein: 14, carbohydrates: 42, fat: 14, fiber: 10, sodium: 380),
                tags: ["mediterranean", "vegan", "street food"]
            )
        ]
    }

    private static func asianRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Fried Rice",
                subtitle: "Quick Wok Classic",
                cuisine: .asian,
                ingredients: [
                    RecipeIngredient(name: "Rice", quantity: 400, unit: .grams, notes: "day-old, cold"),
                    RecipeIngredient(name: "Eggs", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Carrots", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Peas", quantity: 100, unit: .grams),
                    RecipeIngredient(name: "Green Onions", quantity: 3, unit: .pieces),
                    RecipeIngredient(name: "Soy Sauce", quantity: 2, unit: .tablespoons),
                    RecipeIngredient(name: "Sesame Oil", quantity: 1, unit: .tablespoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Beat eggs and scramble in hot wok. Set aside."),
                    RecipeStep(stepNumber: 2, instruction: "Stir-fry diced carrots and peas until tender.", duration: 3),
                    RecipeStep(stepNumber: 3, instruction: "Add cold rice and break up any clumps."),
                    RecipeStep(stepNumber: 4, instruction: "Add soy sauce and toss to coat evenly."),
                    RecipeStep(stepNumber: 5, instruction: "Return eggs to wok. Add green onions and sesame oil."),
                    RecipeStep(stepNumber: 6, instruction: "Toss everything together and serve hot.")
                ],
                cookingTime: 10,
                prepTime: 10,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 320, protein: 10, carbohydrates: 52, fat: 8, fiber: 3, sodium: 620),
                tags: ["asian", "chinese", "quick", "rice"]
            ),
            Recipe(
                title: "Miso Soup",
                subtitle: "Japanese Comfort",
                cuisine: .asian,
                ingredients: [
                    RecipeIngredient(name: "Miso Paste", quantity: 3, unit: .tablespoons),
                    RecipeIngredient(name: "Tofu", quantity: 150, unit: .grams),
                    RecipeIngredient(name: "Wakame Seaweed", quantity: 2, unit: .tablespoons),
                    RecipeIngredient(name: "Green Onions", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Dashi Stock", quantity: 800, unit: .milliliters)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Heat dashi stock in a pot. Do not boil."),
                    RecipeStep(stepNumber: 2, instruction: "Rehydrate wakame in water for 5 minutes.", duration: 5),
                    RecipeStep(stepNumber: 3, instruction: "Cut tofu into small cubes."),
                    RecipeStep(stepNumber: 4, instruction: "Dissolve miso paste in a ladle of warm dashi."),
                    RecipeStep(stepNumber: 5, instruction: "Add miso mixture, tofu, and wakame to pot.", tip: "Never boil miso soup - it destroys the flavor!"),
                    RecipeStep(stepNumber: 6, instruction: "Ladle into bowls and garnish with sliced green onions.")
                ],
                cookingTime: 10,
                prepTime: 10,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 80, protein: 6, carbohydrates: 6, fat: 4, fiber: 1, sodium: 720),
                tags: ["asian", "japanese", "soup", "vegan"]
            ),
            Recipe(
                title: "Pad Thai",
                subtitle: "Thai Noodle Stir-Fry",
                cuisine: .asian,
                ingredients: [
                    RecipeIngredient(name: "Rice Noodles", quantity: 250, unit: .grams),
                    RecipeIngredient(name: "Shrimp", quantity: 200, unit: .grams, isOptional: true),
                    RecipeIngredient(name: "Eggs", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Bean Sprouts", quantity: 150, unit: .grams),
                    RecipeIngredient(name: "Peanuts", quantity: 50, unit: .grams),
                    RecipeIngredient(name: "Lime", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Fish Sauce", quantity: 2, unit: .tablespoons),
                    RecipeIngredient(name: "Tamarind Paste", quantity: 2, unit: .tablespoons),
                    RecipeIngredient(name: "Brown Sugar", quantity: 2, unit: .tablespoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Soak rice noodles in warm water until pliable.", duration: 15),
                    RecipeStep(stepNumber: 2, instruction: "Mix fish sauce, tamarind, and sugar for the sauce."),
                    RecipeStep(stepNumber: 3, instruction: "Stir-fry shrimp until pink. Set aside.", duration: 3),
                    RecipeStep(stepNumber: 4, instruction: "Scramble eggs in wok. Add drained noodles."),
                    RecipeStep(stepNumber: 5, instruction: "Add sauce and toss until noodles are coated.", duration: 3),
                    RecipeStep(stepNumber: 6, instruction: "Return shrimp, add bean sprouts. Top with crushed peanuts and lime.")
                ],
                cookingTime: 15,
                prepTime: 20,
                difficulty: .medium,
                servings: 4,
                nutrition: NutritionInfo(calories: 420, protein: 18, carbohydrates: 58, fat: 14, fiber: 3, sodium: 890),
                tags: ["asian", "thai", "noodles"]
            )
        ]
    }

    private static func internationalRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Classic Omelette",
                subtitle: "Simple and Versatile",
                cuisine: .international,
                ingredients: [
                    RecipeIngredient(name: "Eggs", quantity: 3, unit: .pieces),
                    RecipeIngredient(name: "Butter", quantity: 15, unit: .grams),
                    RecipeIngredient(name: "Cheese", quantity: 30, unit: .grams, isOptional: true),
                    RecipeIngredient(name: "Chives", quantity: 1, unit: .tablespoons, isOptional: true)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Beat eggs with a fork. Season with salt and pepper."),
                    RecipeStep(stepNumber: 2, instruction: "Melt butter in a non-stick pan over medium heat."),
                    RecipeStep(stepNumber: 3, instruction: "Pour in eggs. Let set slightly, then gently push edges to center.", duration: 2),
                    RecipeStep(stepNumber: 4, instruction: "When almost set, add cheese if using."),
                    RecipeStep(stepNumber: 5, instruction: "Fold omelette and slide onto plate. Garnish with chives.")
                ],
                cookingTime: 5,
                prepTime: 3,
                difficulty: .easy,
                servings: 1,
                nutrition: NutritionInfo(calories: 320, protein: 20, carbohydrates: 2, fat: 26, fiber: 0, sodium: 380),
                tags: ["breakfast", "quick", "vegetarian"]
            ),
            Recipe(
                title: "Pasta Primavera",
                subtitle: "Spring Vegetable Pasta",
                cuisine: .international,
                ingredients: [
                    RecipeIngredient(name: "Pasta", quantity: 400, unit: .grams),
                    RecipeIngredient(name: "Zucchini", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Bell Pepper", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Cherry Tomatoes", quantity: 200, unit: .grams),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Olive Oil", quantity: 3, unit: .tablespoons),
                    RecipeIngredient(name: "Parmesan", quantity: 50, unit: .grams)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Cook pasta according to package directions. Reserve 1 cup pasta water.", duration: 10),
                    RecipeStep(stepNumber: 2, instruction: "Dice all vegetables into bite-sized pieces."),
                    RecipeStep(stepNumber: 3, instruction: "Sauté garlic in olive oil. Add vegetables and cook until tender.", duration: 8),
                    RecipeStep(stepNumber: 4, instruction: "Add drained pasta and a splash of pasta water."),
                    RecipeStep(stepNumber: 5, instruction: "Toss with parmesan and serve immediately.")
                ],
                cookingTime: 15,
                prepTime: 15,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 380, protein: 14, carbohydrates: 62, fat: 10, fiber: 5, sodium: 320),
                tags: ["vegetarian", "pasta", "healthy"]
            ),
            Recipe(
                title: "Chicken Quesadilla",
                subtitle: "Cheesy Mexican-Style",
                cuisine: .international,
                ingredients: [
                    RecipeIngredient(name: "Flour Tortillas", quantity: 4, unit: .pieces),
                    RecipeIngredient(name: "Chicken Breast", quantity: 300, unit: .grams),
                    RecipeIngredient(name: "Cheese", quantity: 200, unit: .grams),
                    RecipeIngredient(name: "Bell Pepper", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Cumin", quantity: 1, unit: .teaspoons)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Season chicken with cumin, salt, and pepper. Cook and slice.", duration: 12),
                    RecipeStep(stepNumber: 2, instruction: "Sauté sliced peppers and onions until soft.", duration: 5),
                    RecipeStep(stepNumber: 3, instruction: "Place tortilla in dry pan. Add cheese, chicken, and vegetables."),
                    RecipeStep(stepNumber: 4, instruction: "Fold tortilla in half. Cook until golden on both sides.", duration: 4),
                    RecipeStep(stepNumber: 5, instruction: "Cut into wedges. Serve with salsa and sour cream.")
                ],
                cookingTime: 20,
                prepTime: 10,
                difficulty: .easy,
                servings: 4,
                nutrition: NutritionInfo(calories: 420, protein: 28, carbohydrates: 32, fat: 22, fiber: 2, sodium: 680),
                tags: ["mexican-style", "quick", "comfort food"]
            ),
            Recipe(
                title: "Vegetable Soup",
                subtitle: "Hearty and Healthy",
                cuisine: .international,
                ingredients: [
                    RecipeIngredient(name: "Carrots", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Potatoes", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                    RecipeIngredient(name: "Celery", quantity: 2, unit: .pieces),
                    RecipeIngredient(name: "Vegetable Broth", quantity: 1.5, unit: .liters),
                    RecipeIngredient(name: "Tomatoes", quantity: 200, unit: .grams, notes: "canned"),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: .pieces)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, instruction: "Dice all vegetables into similar-sized pieces."),
                    RecipeStep(stepNumber: 2, instruction: "Sauté onion and garlic in a large pot.", duration: 5),
                    RecipeStep(stepNumber: 3, instruction: "Add remaining vegetables and broth. Bring to a boil."),
                    RecipeStep(stepNumber: 4, instruction: "Reduce heat and simmer until vegetables are tender.", duration: 25),
                    RecipeStep(stepNumber: 5, instruction: "Season with salt, pepper, and herbs. Serve with crusty bread.")
                ],
                cookingTime: 35,
                prepTime: 15,
                difficulty: .easy,
                servings: 6,
                nutrition: NutritionInfo(calories: 120, protein: 4, carbohydrates: 24, fat: 2, fiber: 5, sodium: 480),
                tags: ["soup", "vegan", "healthy", "comfort food"]
            )
        ]
    }
}

// MARK: - LLM Implementation Stub

/// Stub for LLM-based recipe generation (e.g., OpenAI, Anthropic)
/// TODO: Implement with actual LLM API
class LLMRecipeGeneratorService: RecipeGeneratorServiceProtocol {

    // TODO: Add API configuration
    // private let apiKey: String
    // private let endpoint: URL

    func generateRecipes(
        ingredients: [Ingredient],
        cuisine: CuisinePreference?,
        servings: Int,
        limit: Int
    ) async throws -> [Recipe] {
        // TODO: Implement LLM API call
        // 1. Build prompt with ingredient list and preferences
        // 2. Call LLM API (e.g., OpenAI GPT-4, Claude)
        // 3. Parse structured response into Recipe objects

        // For now, fall back to mock
        let mockService = MockRecipeGeneratorService()
        return try await mockService.generateRecipes(
            ingredients: ingredients,
            cuisine: cuisine,
            servings: servings,
            limit: limit
        )
    }
}

// MARK: - Service Factory

/// Factory for creating recipe generator service instances
enum RecipeGeneratorServiceFactory {

    enum ServiceType {
        case mock
        case llm
    }

    static func create(type: ServiceType = .mock) -> RecipeGeneratorServiceProtocol {
        switch type {
        case .mock:
            return MockRecipeGeneratorService()
        case .llm:
            return LLMRecipeGeneratorService()
        }
    }
}
