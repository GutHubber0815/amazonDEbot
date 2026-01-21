// WITF? - What's In That Fridge?
// Features/Shared/Components.swift

import SwiftUI

// MARK: - Ingredient Chip

/// Displays an ingredient as a compact chip with icon and label
struct IngredientChip: View {
    let ingredient: Ingredient
    var onRemove: (() -> Void)?
    var isRemovable: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: ingredient.iconName)
                .font(.system(size: 14))
                .foregroundColor(ingredient.category.color)

            Text(ingredient.name)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            if isRemovable, let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: AppIcons.close)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(ingredient.category.color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Recipe Card

/// Displays a recipe summary as a card
struct RecipeCard: View {
    let recipe: Recipe
    var showMatchScore: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.primaryGradient.opacity(0.3))
                    .frame(height: 120)

                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primaryFallback)

                // Cuisine badge
                VStack {
                    HStack {
                        Spacer()
                        Text(recipe.cuisine.flagEmoji)
                            .font(.system(size: 20))
                            .padding(AppTheme.Spacing.xs)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(AppTheme.Spacing.xs)

                // Match score badge
                if showMatchScore, let score = recipe.matchScore {
                    VStack {
                        HStack {
                            Text("\(Int(score * 100))% match")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 4)
                                .background(AppTheme.primaryFallback)
                                .clipShape(Capsule())
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.xs)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(recipe.title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let subtitle = recipe.subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: AppTheme.Spacing.md) {
                    // Time
                    Label("\(recipe.totalTime) min", systemImage: AppIcons.clock)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)

                    // Difficulty
                    Label(recipe.difficulty.displayName, systemImage: recipe.difficulty.iconName)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(recipe.difficulty.color)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .background(AppTheme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .softShadow()
    }
}

// MARK: - Cuisine Selector

/// Horizontal scrolling cuisine preference selector
struct CuisineSelector: View {
    @Binding var selected: CuisinePreference

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(CuisinePreference.mainCuisines) { cuisine in
                    CuisineButton(
                        cuisine: cuisine,
                        isSelected: selected == cuisine
                    ) {
                        withAnimation(AppTheme.Animation.quick) {
                            selected = cuisine
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}

struct CuisineButton: View {
    let cuisine: CuisinePreference
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text(cuisine.flagEmoji)
                    .font(.system(size: 28))

                Text(cuisine.displayName)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(width: 72)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.primaryFallback : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Servings Stepper

/// Custom stepper for selecting number of servings
struct ServingsStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...6

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button {
                if value > range.lowerBound {
                    value -= 1
                }
            } label: {
                Image(systemName: AppIcons.minus)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(value > range.lowerBound ? AppTheme.primaryFallback : .gray)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primaryFallback.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(value <= range.lowerBound)

            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: AppIcons.person)
                    .foregroundColor(AppTheme.primaryFallback)
                Text("\(value)")
                    .font(AppTheme.Typography.title2)
                    .monospacedDigit()
            }
            .frame(minWidth: 60)

            Button {
                if value < range.upperBound {
                    value += 1
                }
            } label: {
                Image(systemName: AppIcons.plus)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(value < range.upperBound ? AppTheme.primaryFallback : .gray)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primaryFallback.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(value >= range.upperBound)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Servings: \(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value < range.upperBound { value += 1 }
            case .decrement:
                if value > range.lowerBound { value -= 1 }
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Loading View

/// Full-screen loading indicator
struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppTheme.primaryFallback)

            Text(message)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.1))
    }
}

// MARK: - Empty State View

/// Displays when there's no content to show
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primaryFallback.opacity(0.6))

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(.primary)

                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, AppTheme.Spacing.xxl)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - Section Header

/// Styled section header with optional action button
struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.title3)
                .foregroundColor(.primary)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.primaryFallback)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Nutrition Badge

/// Displays a single nutrition value
struct NutritionBadge: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            Text(value)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.primaryFallback)

            Text(unit)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(.secondary)

            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 60)
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.primaryFallback.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
    }
}

// MARK: - Preview Provider

#Preview("Components") {
    ScrollView {
        VStack(spacing: 24) {
            // Ingredient Chips
            Section {
                FlowLayout(spacing: 8) {
                    ForEach(Ingredient.sampleIngredients.prefix(5)) { ingredient in
                        IngredientChip(ingredient: ingredient)
                    }
                }
            } header: {
                Text("Ingredient Chips").font(.headline)
            }

            Divider()

            // Recipe Card
            Section {
                RecipeCard(recipe: Recipe.sampleRecipes[0], showMatchScore: true)
                    .frame(width: 200)
            } header: {
                Text("Recipe Card").font(.headline)
            }

            Divider()

            // Servings Stepper
            Section {
                ServingsStepper(value: .constant(2))
            } header: {
                Text("Servings Stepper").font(.headline)
            }

            Divider()

            // Empty State
            Section {
                EmptyStateView(
                    icon: "refrigerator",
                    title: "Your fridge is empty",
                    message: "Add ingredients to get recipe suggestions",
                    actionTitle: "Add Ingredients"
                ) {}
            } header: {
                Text("Empty State").font(.headline)
            }
        }
        .padding()
    }
}

// MARK: - Flow Layout

/// A layout that arranges views in a flowing manner (like tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
