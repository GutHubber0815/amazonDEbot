// WITF? - What's In That Fridge?
// Core/Models/Recipe.swift

import Foundation
import SwiftUI

/// Represents a cooking recipe with all necessary details
struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var subtitle: String?
    var cuisine: CuisinePreference
    var ingredients: [RecipeIngredient]
    var steps: [RecipeStep]
    var cookingTime: Int // in minutes
    var prepTime: Int // in minutes
    var difficulty: DifficultyLevel
    var servings: Int
    var imageURL: URL?
    var imageName: String? // For local/system images
    var nutrition: NutritionInfo?
    var tags: [String]
    var isFavorite: Bool
    var createdAt: Date
    var matchScore: Double? // How well it matches available ingredients (0-1)

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        cuisine: CuisinePreference = .international,
        ingredients: [RecipeIngredient] = [],
        steps: [RecipeStep] = [],
        cookingTime: Int = 30,
        prepTime: Int = 15,
        difficulty: DifficultyLevel = .medium,
        servings: Int = 2,
        imageURL: URL? = nil,
        imageName: String? = nil,
        nutrition: NutritionInfo? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        matchScore: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.cuisine = cuisine
        self.ingredients = ingredients
        self.steps = steps
        self.cookingTime = cookingTime
        self.prepTime = prepTime
        self.difficulty = difficulty
        self.servings = servings
        self.imageURL = imageURL
        self.imageName = imageName
        self.nutrition = nutrition
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.matchScore = matchScore
    }

    /// Total time including prep and cooking
    var totalTime: Int {
        prepTime + cookingTime
    }

    /// Returns recipe with scaled ingredients for different servings
    func scaled(to newServings: Int) -> Recipe {
        let scaleFactor = Double(newServings) / Double(servings)
        var scaledRecipe = self
        scaledRecipe.servings = newServings
        scaledRecipe.ingredients = ingredients.map { ingredient in
            var scaled = ingredient
            scaled.quantity = ingredient.quantity * scaleFactor
            return scaled
        }
        if var nutrition = scaledRecipe.nutrition {
            nutrition = nutrition.scaled(by: scaleFactor)
            scaledRecipe.nutrition = nutrition
        }
        return scaledRecipe
    }
}

// MARK: - Recipe Ingredient

struct RecipeIngredient: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: MeasurementUnit
    var isOptional: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: MeasurementUnit,
        isOptional: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isOptional = isOptional
        self.notes = notes
    }

    var displayQuantity: String {
        if quantity == floor(quantity) {
            return "\(Int(quantity)) \(unit.abbreviation)"
        }
        return String(format: "%.1f %@", quantity, unit.abbreviation)
    }
}

// MARK: - Recipe Step

struct RecipeStep: Identifiable, Codable, Hashable {
    let id: UUID
    var stepNumber: Int
    var instruction: String
    var duration: Int? // in minutes, optional
    var tip: String?

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        duration: Int? = nil,
        tip: String? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.duration = duration
        self.tip = tip
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return String(localized: "difficulty.easy")
        case .medium: return String(localized: "difficulty.medium")
        case .hard: return String(localized: "difficulty.hard")
        }
    }

    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var iconName: String {
        switch self {
        case .easy: return "star.fill"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star.circle.fill"
        }
    }
}

// MARK: - Nutrition Info

struct NutritionInfo: Codable, Hashable {
    var calories: Int
    var protein: Double // grams
    var carbohydrates: Double // grams
    var fat: Double // grams
    var fiber: Double? // grams
    var sodium: Double? // mg

    func scaled(by factor: Double) -> NutritionInfo {
        NutritionInfo(
            calories: Int(Double(calories) * factor),
            protein: protein * factor,
            carbohydrates: carbohydrates * factor,
            fat: fat * factor,
            fiber: fiber.map { $0 * factor },
            sodium: sodium.map { $0 * factor }
        )
    }
}

// MARK: - Sample Recipes

extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            title: "Spaghetti Carbonara",
            subtitle: "Classic Italian comfort food",
            cuisine: .italian,
            ingredients: [
                RecipeIngredient(name: "Spaghetti", quantity: 400, unit: .grams),
                RecipeIngredient(name: "Guanciale", quantity: 150, unit: .grams, notes: "or pancetta"),
                RecipeIngredient(name: "Eggs", quantity: 4, unit: .pieces),
                RecipeIngredient(name: "Pecorino Romano", quantity: 100, unit: .grams),
                RecipeIngredient(name: "Black Pepper", quantity: 1, unit: .teaspoons)
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Bring a large pot of salted water to boil. Cook spaghetti according to package directions.", duration: 10),
                RecipeStep(stepNumber: 2, instruction: "Cut guanciale into small cubes and cook in a large pan over medium heat until crispy.", duration: 8),
                RecipeStep(stepNumber: 3, instruction: "In a bowl, whisk together eggs, grated pecorino, and plenty of black pepper."),
                RecipeStep(stepNumber: 4, instruction: "Remove pan from heat. Add drained pasta and toss quickly."),
                RecipeStep(stepNumber: 5, instruction: "Add egg mixture and toss vigorously. The residual heat will cook the eggs into a creamy sauce.", tip: "Don't let it get too hot or the eggs will scramble!")
            ],
            cookingTime: 20,
            prepTime: 10,
            difficulty: .medium,
            servings: 4,
            imageName: "carbonara",
            nutrition: NutritionInfo(calories: 650, protein: 25, carbohydrates: 70, fat: 28, fiber: 3, sodium: 580),
            tags: ["pasta", "classic", "quick"]
        ),
        Recipe(
            title: "German Potato Salad",
            subtitle: "Warm Bavarian style",
            cuisine: .german,
            ingredients: [
                RecipeIngredient(name: "Waxy Potatoes", quantity: 1, unit: .kilograms),
                RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                RecipeIngredient(name: "Bacon", quantity: 150, unit: .grams),
                RecipeIngredient(name: "Vegetable Broth", quantity: 200, unit: .milliliters),
                RecipeIngredient(name: "White Wine Vinegar", quantity: 3, unit: .tablespoons),
                RecipeIngredient(name: "Mustard", quantity: 1, unit: .tablespoons)
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Boil potatoes in salted water until tender. Let cool slightly, then slice.", duration: 25),
                RecipeStep(stepNumber: 2, instruction: "Dice onion and bacon. Fry bacon until crispy, add onion and cook until soft.", duration: 8),
                RecipeStep(stepNumber: 3, instruction: "Add broth, vinegar, and mustard to the pan. Bring to a simmer."),
                RecipeStep(stepNumber: 4, instruction: "Pour warm dressing over sliced potatoes. Toss gently and let rest 10 minutes.", tip: "Best served warm!")
            ],
            cookingTime: 35,
            prepTime: 15,
            difficulty: .easy,
            servings: 4,
            imageName: "potato_salad",
            nutrition: NutritionInfo(calories: 380, protein: 12, carbohydrates: 45, fat: 16, fiber: 4, sodium: 720),
            tags: ["salad", "german", "side dish"]
        ),
        Recipe(
            title: "Chicken Stir-Fry",
            subtitle: "Quick Asian weeknight dinner",
            cuisine: .asian,
            ingredients: [
                RecipeIngredient(name: "Chicken Breast", quantity: 500, unit: .grams),
                RecipeIngredient(name: "Bell Peppers", quantity: 2, unit: .pieces),
                RecipeIngredient(name: "Broccoli", quantity: 200, unit: .grams),
                RecipeIngredient(name: "Soy Sauce", quantity: 3, unit: .tablespoons),
                RecipeIngredient(name: "Garlic", quantity: 3, unit: .pieces),
                RecipeIngredient(name: "Ginger", quantity: 1, unit: .tablespoons, notes: "freshly grated"),
                RecipeIngredient(name: "Sesame Oil", quantity: 1, unit: .tablespoons),
                RecipeIngredient(name: "Rice", quantity: 300, unit: .grams, notes: "for serving")
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Cut chicken into bite-sized pieces. Slice vegetables.", duration: 10),
                RecipeStep(stepNumber: 2, instruction: "Cook rice according to package instructions.", duration: 15),
                RecipeStep(stepNumber: 3, instruction: "Heat oil in a wok over high heat. Stir-fry chicken until golden.", duration: 5),
                RecipeStep(stepNumber: 4, instruction: "Add garlic and ginger, stir for 30 seconds."),
                RecipeStep(stepNumber: 5, instruction: "Add vegetables and stir-fry for 3-4 minutes until crisp-tender.", duration: 4),
                RecipeStep(stepNumber: 6, instruction: "Add soy sauce and sesame oil. Toss to combine. Serve over rice.")
            ],
            cookingTime: 15,
            prepTime: 15,
            difficulty: .easy,
            servings: 4,
            imageName: "stirfry",
            nutrition: NutritionInfo(calories: 450, protein: 35, carbohydrates: 55, fat: 12, fiber: 5, sodium: 890),
            tags: ["asian", "quick", "healthy"]
        ),
        Recipe(
            title: "Mediterranean Omelette",
            subtitle: "Fresh and healthy breakfast",
            cuisine: .mediterranean,
            ingredients: [
                RecipeIngredient(name: "Eggs", quantity: 3, unit: .pieces),
                RecipeIngredient(name: "Feta Cheese", quantity: 50, unit: .grams),
                RecipeIngredient(name: "Cherry Tomatoes", quantity: 6, unit: .pieces),
                RecipeIngredient(name: "Spinach", quantity: 30, unit: .grams),
                RecipeIngredient(name: "Olive Oil", quantity: 1, unit: .tablespoons),
                RecipeIngredient(name: "Oregano", quantity: 0.5, unit: .teaspoons)
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Whisk eggs with a pinch of salt and pepper."),
                RecipeStep(stepNumber: 2, instruction: "Heat olive oil in a non-stick pan over medium heat."),
                RecipeStep(stepNumber: 3, instruction: "Pour in eggs and let set slightly. Add spinach, tomatoes, and feta.", duration: 3),
                RecipeStep(stepNumber: 4, instruction: "Fold omelette and cook until eggs are set but still creamy.", duration: 2),
                RecipeStep(stepNumber: 5, instruction: "Slide onto plate and sprinkle with oregano.", tip: "Serve with crusty bread!")
            ],
            cookingTime: 8,
            prepTime: 5,
            difficulty: .easy,
            servings: 1,
            imageName: "omelette",
            nutrition: NutritionInfo(calories: 380, protein: 22, carbohydrates: 6, fat: 30, fiber: 2, sodium: 520),
            tags: ["breakfast", "vegetarian", "quick"]
        ),
        Recipe(
            title: "Classic Risotto",
            subtitle: "Creamy Italian rice dish",
            cuisine: .italian,
            ingredients: [
                RecipeIngredient(name: "Arborio Rice", quantity: 300, unit: .grams),
                RecipeIngredient(name: "Chicken Broth", quantity: 1, unit: .liters),
                RecipeIngredient(name: "White Wine", quantity: 150, unit: .milliliters),
                RecipeIngredient(name: "Onion", quantity: 1, unit: .pieces),
                RecipeIngredient(name: "Parmesan", quantity: 80, unit: .grams),
                RecipeIngredient(name: "Butter", quantity: 50, unit: .grams)
            ],
            steps: [
                RecipeStep(stepNumber: 1, instruction: "Heat broth in a saucepan and keep warm.", duration: 5),
                RecipeStep(stepNumber: 2, instruction: "Sauté diced onion in butter until translucent.", duration: 5),
                RecipeStep(stepNumber: 3, instruction: "Add rice and toast for 2 minutes, stirring constantly.", duration: 2),
                RecipeStep(stepNumber: 4, instruction: "Add wine and stir until absorbed."),
                RecipeStep(stepNumber: 5, instruction: "Add warm broth one ladle at a time, stirring frequently until absorbed before adding more.", duration: 18, tip: "Patience is key!"),
                RecipeStep(stepNumber: 6, instruction: "Remove from heat, stir in parmesan and remaining butter. Rest 2 minutes before serving.")
            ],
            cookingTime: 30,
            prepTime: 10,
            difficulty: .medium,
            servings: 4,
            imageName: "risotto",
            nutrition: NutritionInfo(calories: 520, protein: 15, carbohydrates: 65, fat: 22, fiber: 2, sodium: 680),
            tags: ["italian", "comfort food", "vegetarian"]
        )
    ]

    static let empty = Recipe(title: "", cuisine: .international)
}
