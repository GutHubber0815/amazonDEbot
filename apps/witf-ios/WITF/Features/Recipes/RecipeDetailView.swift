// WITF? - What's In That Fridge?
// Features/Recipes/RecipeDetailView.swift

import SwiftUI

// MARK: - Recipe Detail View

struct RecipeDetailView: View {
    let recipe: Recipe
    var isSaved: Bool = false
    var onToggleFavorite: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var servings: Int
    @State private var showShareSheet = false

    private var scaledRecipe: Recipe {
        recipe.scaled(to: servings)
    }

    init(recipe: Recipe, isSaved: Bool = false, onToggleFavorite: (() -> Void)? = nil) {
        self.recipe = recipe
        self.isSaved = isSaved
        self.onToggleFavorite = onToggleFavorite
        _servings = State(initialValue: recipe.servings)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero image
                heroSection

                VStack(spacing: AppTheme.Spacing.lg) {
                    // Title and metadata
                    titleSection

                    Divider()

                    // Servings control
                    servingsSection

                    Divider()

                    // Ingredients
                    ingredientsSection

                    Divider()

                    // Instructions
                    instructionsSection

                    // Nutrition
                    if let nutrition = scaledRecipe.nutrition {
                        Divider()
                        nutritionSection(nutrition)
                    }

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(AppTheme.Spacing.md)
            }
        }
        .background(AppTheme.background(colorScheme).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // Favorite button
                    Button {
                        onToggleFavorite?()
                    } label: {
                        Image(systemName: isSaved ? AppIcons.heart : AppIcons.heartEmpty)
                            .foregroundColor(isSaved ? .red : .primary)
                    }

                    // Share button
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: AppIcons.share)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Image placeholder
            Rectangle()
                .fill(AppTheme.primaryGradient.opacity(0.3))
                .frame(height: 250)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primaryFallback.opacity(0.5))
                }

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Cuisine badge
            HStack {
                Text(recipe.cuisine.flagEmoji)
                    .font(.system(size: 24))
                Text(recipe.cuisine.displayName)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(recipe.title)
                .font(AppTheme.Typography.title1)
                .foregroundColor(.primary)

            if let subtitle = recipe.subtitle {
                Text(subtitle)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.secondary)
            }

            // Metadata row
            HStack(spacing: AppTheme.Spacing.lg) {
                // Total time
                Label {
                    Text("\(recipe.totalTime) min")
                        .font(AppTheme.Typography.subheadline)
                } icon: {
                    Image(systemName: AppIcons.clock)
                        .foregroundColor(AppTheme.primaryFallback)
                }

                // Difficulty
                Label {
                    Text(recipe.difficulty.displayName)
                        .font(AppTheme.Typography.subheadline)
                } icon: {
                    Image(systemName: recipe.difficulty.iconName)
                        .foregroundColor(recipe.difficulty.color)
                }

                Spacer()
            }

            // Tags
            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Servings Section

    private var servingsSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(String(localized: "recipe.servings"))
                    .font(AppTheme.Typography.headline)
                Text(String(localized: "recipe.servings.adjust"))
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            ServingsStepper(value: $servings)
        }
    }

    // MARK: - Ingredients Section

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(AppTheme.primaryFallback)
                Text(String(localized: "recipe.ingredients"))
                    .font(AppTheme.Typography.title3)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(scaledRecipe.ingredients) { ingredient in
                    HStack(alignment: .top) {
                        Circle()
                            .fill(AppTheme.primaryFallback)
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(ingredient.displayQuantity)
                                    .font(AppTheme.Typography.body)
                                    .fontWeight(.medium)

                                Text(ingredient.name)
                                    .font(AppTheme.Typography.body)

                                if ingredient.isOptional {
                                    Text("(" + String(localized: "recipe.optional") + ")")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            if let notes = ingredient.notes {
                                Text(notes)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Instructions Section

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "list.number")
                    .foregroundColor(AppTheme.primaryFallback)
                Text(String(localized: "recipe.instructions"))
                    .font(AppTheme.Typography.title3)
            }

            VStack(spacing: AppTheme.Spacing.md) {
                ForEach(recipe.steps) { step in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        // Step number
                        Text("\(step.stepNumber)")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(AppTheme.primaryFallback)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                            Text(step.instruction)
                                .font(AppTheme.Typography.body)

                            if let duration = step.duration {
                                Label("\(duration) min", systemImage: AppIcons.clock)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }

                            if let tip = step.tip {
                                HStack(alignment: .top, spacing: AppTheme.Spacing.xxs) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(tip)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.orange)
                                }
                                .padding(AppTheme.Spacing.xs)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Nutrition Section

    private func nutritionSection(_ nutrition: NutritionInfo) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppTheme.primaryFallback)
                Text(String(localized: "recipe.nutrition"))
                    .font(AppTheme.Typography.title3)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                NutritionBadge(
                    label: String(localized: "nutrition.calories"),
                    value: "\(nutrition.calories)",
                    unit: "kcal"
                )

                NutritionBadge(
                    label: String(localized: "nutrition.protein"),
                    value: String(format: "%.0f", nutrition.protein),
                    unit: "g"
                )

                NutritionBadge(
                    label: String(localized: "nutrition.carbs"),
                    value: String(format: "%.0f", nutrition.carbohydrates),
                    unit: "g"
                )

                NutritionBadge(
                    label: String(localized: "nutrition.fat"),
                    value: String(format: "%.0f", nutrition.fat),
                    unit: "g"
                )
            }

            Text(String(localized: "recipe.nutrition.note"))
                .font(AppTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Share Text

    private var shareText: String {
        """
        \(recipe.title)
        \(recipe.subtitle ?? "")

        \(String(localized: "recipe.servings")): \(servings)

        \(String(localized: "recipe.ingredients")):
        \(scaledRecipe.ingredients.map { "• \($0.displayQuantity) \($0.name)" }.joined(separator: "\n"))

        \(String(localized: "recipe.instructions")):
        \(recipe.steps.map { "\($0.stepNumber). \($0.instruction)" }.joined(separator: "\n"))

        Generated with WITF? - What's In That Fridge?
        """
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe.sampleRecipes[0], isSaved: true)
    }
}
