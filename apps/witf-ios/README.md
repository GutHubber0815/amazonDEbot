# WITF? - What's In That Fridge?

**Turn your fridge into dinner.**

An iOS app that helps users reduce food waste by scanning their fridge/pantry contents and generating suitable meal recipes with AI-powered ingredient detection.

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Features

### Core Functionality
- **Fridge Scanning**: Take photos of your fridge/pantry for AI-powered ingredient detection
- **Manual Ingredient Management**: Add, edit, and organize ingredients by category
- **Smart Recipe Generation**: Get recipe suggestions based on available ingredients
- **Portion Scaling**: Adjust recipes for 1-6 servings with automatic ingredient scaling
- **Multi-Cuisine Support**: German, Italian, Mediterranean, Asian, and more

### User Experience
- **Beautiful UI**: Modern SwiftUI design with pastel colors, rounded cards, and smooth animations
- **Dark Mode**: Full light and dark theme support
- **Localization**: English, German, French, Spanish, Italian
- **Accessibility**: VoiceOver support, Dynamic Type compatibility

### Monetization
- **Freemium Model**: 5 free recipe generations per month
- **Premium Subscriptions**: Monthly, yearly, and lifetime options
- **StoreKit 2 Integration**: Ready for App Store deployment

---

## Project Structure

```
WITF/
├── WITFApp.swift                    # Main app entry point
├── Core/
│   ├── Models/
│   │   ├── Ingredient.swift         # Ingredient data model
│   │   ├── Recipe.swift             # Recipe data model
│   │   ├── CuisinePreference.swift  # Cuisine types
│   │   ├── Subscription.swift       # Subscription tiers
│   │   └── UserSettings.swift       # App settings & state
│   ├── Services/
│   │   ├── IngredientRecognitionService.swift  # Image → Ingredients
│   │   ├── RecipeGeneratorService.swift        # Ingredients → Recipes
│   │   ├── FridgeStorageService.swift          # Local data persistence
│   │   └── SubscriptionManager.swift           # StoreKit 2 IAP
│   └── Theme/
│       └── AppTheme.swift           # Design system & styling
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # 3-page onboarding flow
│   ├── Home/
│   │   ├── HomeView.swift           # Main scan & generate UI
│   │   └── HomeViewModel.swift
│   ├── Recipes/
│   │   ├── RecipesView.swift        # Recipe list & favorites
│   │   ├── RecipeDetailView.swift   # Full recipe display
│   │   └── RecipesViewModel.swift
│   ├── MyFridge/
│   │   ├── MyFridgeView.swift       # Ingredient management
│   │   └── MyFridgeViewModel.swift
│   ├── Profile/
│   │   ├── ProfileView.swift        # Settings & preferences
│   │   ├── ProfileViewModel.swift
│   │   └── PaywallView.swift        # Subscription paywall
│   └── Shared/
│       └── Components.swift         # Reusable UI components
└── Resources/
    └── Localization/
        ├── en.lproj/Localizable.strings
        ├── de.lproj/Localizable.strings
        ├── fr.lproj/Localizable.strings
        ├── es.lproj/Localizable.strings
        └── it.lproj/Localizable.strings
```

---

## Getting Started

### Prerequisites

- **Xcode 16.0+** (or Xcode 15 with iOS 17 SDK)
- **iOS 17.0+** deployment target
- **macOS Sonoma** or later recommended

### Setup Instructions

1. **Create New Xcode Project**
   ```
   File → New → Project → iOS → App
   Product Name: WITF
   Interface: SwiftUI
   Language: Swift
   ```

2. **Copy Source Files**
   - Copy all files from `WITF/` folder into your Xcode project
   - Maintain the folder structure for organization

3. **Configure Project Settings**
   - Set deployment target to iOS 17.0
   - Add camera usage description to Info.plist:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>WITF needs camera access to scan your fridge contents</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>WITF needs photo library access to select fridge photos</string>
     ```

4. **Add Localizations**
   - In Project Settings → Info → Localizations
   - Add: German (de), French (fr), Spanish (es), Italian (it)
   - Import the Localizable.strings files for each language

5. **Run the App**
   - Select iOS Simulator or device
   - Build and run (⌘R)

---

## Integration Points

### Adding Real CoreML Model

Replace the mock ingredient recognition with a real CoreML model:

```swift
// In IngredientRecognitionService.swift

class CoreMLIngredientRecognitionService: IngredientRecognitionServiceProtocol {
    private var model: VNCoreMLModel?

    init() {
        // 1. Add your .mlmodel file to the project
        guard let modelURL = Bundle.main.url(
            forResource: "FoodClassifier",  // Your model name
            withExtension: "mlmodelc"
        ),
        let mlModel = try? MLModel(contentsOf: modelURL),
        let visionModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to load CoreML model")
        }
        self.model = visionModel
    }

    func recognizeIngredients(from image: UIImage) async throws -> [DetectedIngredient] {
        guard let cgImage = image.cgImage, let model = model else {
            throw RecognitionError.invalidImage
        }

        let request = VNCoreMLRequest(model: model)
        let handler = VNImageRequestHandler(cgImage: cgImage)

        try handler.perform([request])

        // Parse VNClassificationObservation results
        // Map to DetectedIngredient objects
        // Return results
    }
}
```

### Adding LLM Recipe Generation

Replace mock recipes with an AI/LLM API:

```swift
// In RecipeGeneratorService.swift

class LLMRecipeGeneratorService: RecipeGeneratorServiceProtocol {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    func generateRecipes(
        ingredients: [Ingredient],
        cuisine: CuisinePreference?,
        servings: Int,
        limit: Int
    ) async throws -> [Recipe] {
        let prompt = buildPrompt(ingredients: ingredients, cuisine: cuisine, servings: servings)

        // Make API request to GPT-4 or Claude
        // Parse structured JSON response
        // Convert to Recipe objects
    }

    private func buildPrompt(/* ... */) -> String {
        """
        Generate \(limit) recipes using these ingredients: \(ingredients.map(\.name).joined(separator: ", "))
        Cuisine preference: \(cuisine?.displayName ?? "any")
        Servings: \(servings)

        Return as JSON with structure: { recipes: [{ title, ingredients, steps, ... }] }
        """
    }
}
```

### Real StoreKit Products

Configure real App Store Connect products:

1. **Create Products in App Store Connect**
   - `com.witf.premium.monthly` - Auto-renewable subscription
   - `com.witf.premium.yearly` - Auto-renewable subscription
   - `com.witf.premium.lifetime` - Non-consumable

2. **Update SubscriptionManager**
   ```swift
   // Set useMockPurchases to false
   SubscriptionManager(settingsStorage: settingsStorage, useMockPurchases: false)
   ```

3. **Configure StoreKit Testing**
   - Create StoreKit Configuration file for testing
   - Or use sandbox testing with App Store Connect

### Cloud Backend Integration

Add Firebase or AWS for data sync:

```swift
// In FridgeStorageService.swift

class FirebaseFridgeStorageService: FridgeStorageServiceProtocol {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    func loadIngredients() async throws -> [Ingredient] {
        guard let userId = auth.currentUser?.uid else {
            throw StorageError.notAuthenticated
        }

        let snapshot = try await db
            .collection("users")
            .document(userId)
            .collection("ingredients")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Ingredient.self)
        }
    }

    // Implement other methods...
}
```

---

## Architecture

### MVVM Pattern

```
View (SwiftUI) ←→ ViewModel (@Observable) ←→ Service (Protocol)
                                              ↓
                                         Storage/API
```

### Key Design Decisions

1. **Protocol-Based Services**: All services implement protocols for easy testing and swapping implementations
2. **Observable ViewModels**: Using Swift's new `@Observable` macro for reactive state management
3. **Dependency Injection**: Services injected into view models for flexibility
4. **Local-First Storage**: UserDefaults with JSON encoding; prepared for cloud sync

---

## Design System

### Colors
- **Primary**: Teal/Mint (#33C7B8)
- **Secondary**: Soft Blue (#6699E6)
- **Accent**: Warm Orange (#FF9966)

### Typography
- Uses system fonts with `.rounded` design
- Supports Dynamic Type for accessibility

### Components
- `IngredientChip`: Compact ingredient display
- `RecipeCard`: Recipe preview card
- `CuisineSelector`: Horizontal cuisine picker
- `ServingsStepper`: Custom servings control
- `EmptyStateView`: Consistent empty state UI

---

## App Icon Concept

```
┌─────────────────┐
│    ┌─────┐      │
│    │ ❄️  │      │  Circular icon
│    │     │      │  Blue/Green gradient
│    │ 🍎  │      │  Minimalist fridge
│    │     │      │  "WITF?" initials
│    └─────┘      │
│     WITF?       │
└─────────────────┘
```

---

## Roadmap

### Version 1.0 (Current)
- [x] Fridge scanning with mock detection
- [x] Manual ingredient management
- [x] Recipe generation with mock database
- [x] Portion scaling
- [x] Multi-language support
- [x] Subscription framework

### Version 1.1
- [ ] Real CoreML food detection model
- [ ] Cloud sync with Firebase
- [ ] Recipe sharing
- [ ] Shopping list generation

### Version 2.0
- [ ] LLM-powered recipe generation
- [ ] Meal planning calendar
- [ ] Nutritional goals tracking
- [ ] Apple Watch companion app

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Acknowledgments

- SF Symbols for iconography
- SwiftUI for the modern UI framework
- StoreKit 2 for simplified in-app purchases

---

**Made with 🍳 by the WITF? Team**

*Turn your fridge into dinner.*
