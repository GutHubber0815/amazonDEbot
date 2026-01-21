// WITF? - What's In That Fridge?
// Features/Recipes/RecipesView.swift

import SwiftUI

// MARK: - Recipes View (Tab)

struct RecipesView: View {
    @Bindable var viewModel: RecipesViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: String(localized: "recipes.loading"))
                } else if viewModel.filteredRecipes.isEmpty {
                    emptyState
                } else {
                    recipesGrid
                }
            }
            .background(AppTheme.background(colorScheme).ignoresSafeArea())
            .navigationTitle(String(localized: "recipes.title"))
            .searchable(
                text: $viewModel.searchText,
                prompt: String(localized: "recipes.search.placeholder")
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(RecipeFilter.allCases) { filter in
                            Button {
                                viewModel.selectedFilter = filter
                            } label: {
                                Label(filter.displayName, systemImage: filter.iconName)
                            }
                        }
                    } label: {
                        Label(viewModel.selectedFilter.displayName, systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                await viewModel.loadRecipes()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: AppIcons.recipes,
            title: emptyStateTitle,
            message: emptyStateMessage
        )
    }

    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .all:
            return String(localized: "recipes.empty.all.title")
        case .favorites:
            return String(localized: "recipes.empty.favorites.title")
        case .history:
            return String(localized: "recipes.empty.history.title")
        }
    }

    private var emptyStateMessage: String {
        switch viewModel.selectedFilter {
        case .all:
            return String(localized: "recipes.empty.all.message")
        case .favorites:
            return String(localized: "recipes.empty.favorites.message")
        case .history:
            return String(localized: "recipes.empty.history.message")
        }
    }

    // MARK: - Recipes Grid

    private var recipesGrid: some View {
        ScrollView {
            // Filter pills
            filterPills
                .padding(.top, AppTheme.Spacing.sm)

            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(
                            recipe: recipe,
                            isSaved: viewModel.isSaved(recipe),
                            onToggleFavorite: {
                                Task {
                                    await viewModel.toggleFavorite(recipe)
                                }
                            }
                        )
                    } label: {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Filter Pills

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                ForEach(RecipeFilter.allCases) { filter in
                    Button {
                        withAnimation(AppTheme.Animation.quick) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            Image(systemName: filter.iconName)
                                .font(.system(size: 12))
                            Text(filter.displayName)
                                .font(AppTheme.Typography.subheadline)
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(
                            viewModel.selectedFilter == filter
                                ? AppTheme.primaryFallback
                                : AppTheme.primaryFallback.opacity(0.1)
                        )
                        .foregroundColor(
                            viewModel.selectedFilter == filter
                                ? .white
                                : AppTheme.primaryFallback
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}

// MARK: - Recipe List View (for generated recipes)

struct RecipeListView: View {
    let recipes: [Recipe]
    var title: String = "Recipes"

    @Environment(\.colorScheme) private var colorScheme

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeCard(recipe: recipe, showMatchScore: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.background(colorScheme).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    RecipesView(viewModel: RecipesViewModel())
}
