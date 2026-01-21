// WITF? - What's In That Fridge?
// Features/MyFridge/MyFridgeView.swift

import SwiftUI

// MARK: - My Fridge View

struct MyFridgeView: View {
    @Bindable var viewModel: MyFridgeViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showAddIngredient = false
    @State private var showEditIngredient = false
    @State private var selectedIngredient: Ingredient?
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: String(localized: "fridge.loading"))
                } else if viewModel.ingredients.isEmpty {
                    emptyState
                } else {
                    ingredientsList
                }
            }
            .background(AppTheme.background(colorScheme).ignoresSafeArea())
            .navigationTitle(String(localized: "fridge.title"))
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                prompt: String(localized: "fridge.search.placeholder")
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAddIngredient = true
                        } label: {
                            Label(String(localized: "fridge.add"), systemImage: AppIcons.plus)
                        }

                        if !viewModel.ingredients.isEmpty {
                            Divider()

                            Button(role: .destructive) {
                                showClearConfirmation = true
                            } label: {
                                Label(String(localized: "fridge.clear.all"), systemImage: AppIcons.delete)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .task {
                await viewModel.loadIngredients()
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientView(viewModel: viewModel)
            }
            .sheet(item: $selectedIngredient) { ingredient in
                EditIngredientView(ingredient: ingredient, viewModel: viewModel)
            }
            .confirmationDialog(
                String(localized: "fridge.clear.confirmation.title"),
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "fridge.clear.all"), role: .destructive) {
                    Task {
                        await viewModel.clearAllIngredients()
                    }
                }
                Button(String(localized: "common.cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "fridge.clear.confirmation.message"))
            }
            .alert(
                String(localized: "error.title"),
                isPresented: .constant(viewModel.errorMessage != nil)
            ) {
                Button(String(localized: "common.ok")) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: AppIcons.fridge,
            title: String(localized: "fridge.empty.title"),
            message: String(localized: "fridge.empty.message"),
            actionTitle: String(localized: "fridge.add.first")
        ) {
            showAddIngredient = true
        }
    }

    // MARK: - Ingredients List

    private var ingredientsList: some View {
        List {
            // Quick presets section
            Section {
                quickPresetsRow
            } header: {
                Text(String(localized: "fridge.quickadd"))
            }

            // Grouped by category
            ForEach(viewModel.activeCategories) { category in
                Section {
                    ForEach(viewModel.groupedIngredients[category] ?? []) { ingredient in
                        ingredientRow(ingredient)
                    }
                    .onDelete { indexSet in
                        deleteIngredients(in: category, at: indexSet)
                    }
                } header: {
                    HStack {
                        Image(systemName: category.defaultIcon)
                            .foregroundColor(category.color)
                        Text(category.displayName)
                        Spacer()
                        Text("\(viewModel.count(for: category))")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Quick Presets Row

    private var quickPresetsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                ForEach(Ingredient.presets.prefix(8)) { preset in
                    Button {
                        Task {
                            await viewModel.addPresets([preset])
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            Image(systemName: preset.iconName)
                                .font(.system(size: 12))
                            Text(preset.name)
                                .font(AppTheme.Typography.caption)
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.primaryFallback.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.ingredients.contains { $0.name.lowercased() == preset.name.lowercased() })
                }
            }
            .padding(.vertical, AppTheme.Spacing.xxs)
        }
    }

    // MARK: - Ingredient Row

    private func ingredientRow(_ ingredient: Ingredient) -> some View {
        HStack {
            Image(systemName: ingredient.iconName)
                .foregroundColor(ingredient.category.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(AppTheme.Typography.body)

                if let quantity = ingredient.quantity, let unit = ingredient.unit {
                    Text("\(Int(quantity)) \(unit.abbreviation)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if ingredient.isScanned {
                Image(systemName: AppIcons.camera)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedIngredient = ingredient
        }
    }

    // MARK: - Helper Methods

    private func deleteIngredients(in category: IngredientCategory, at indexSet: IndexSet) {
        guard let ingredients = viewModel.groupedIngredients[category] else { return }
        let toDelete = indexSet.map { ingredients[$0] }

        Task {
            await viewModel.removeIngredients(toDelete)
        }
    }
}

// MARK: - Add Ingredient View

struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MyFridgeViewModel

    @State private var name = ""
    @State private var category: IngredientCategory = .other
    @State private var quantity: String = ""
    @State private var unit: MeasurementUnit = .pieces

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "ingredient.name"), text: $name)
                        .textInputAutocapitalization(.words)

                    Picker(String(localized: "ingredient.category"), selection: $category) {
                        ForEach(IngredientCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.defaultIcon)
                                .tag(cat)
                        }
                    }
                }

                Section {
                    TextField(String(localized: "ingredient.quantity"), text: $quantity)
                        .keyboardType(.decimalPad)

                    Picker(String(localized: "ingredient.unit"), selection: $unit) {
                        ForEach(MeasurementUnit.allCases) { u in
                            Text(u.displayName).tag(u)
                        }
                    }
                } header: {
                    Text(String(localized: "ingredient.quantity.optional"))
                }

                // Presets
                Section {
                    ForEach(Ingredient.presets) { preset in
                        Button {
                            addPreset(preset)
                        } label: {
                            HStack {
                                Image(systemName: preset.iconName)
                                    .foregroundColor(preset.category.color)
                                Text(preset.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: AppIcons.plus)
                                    .foregroundColor(AppTheme.primaryFallback)
                            }
                        }
                        .disabled(viewModel.ingredients.contains { $0.name.lowercased() == preset.name.lowercased() })
                    }
                } header: {
                    Text(String(localized: "ingredient.presets"))
                }
            }
            .navigationTitle(String(localized: "ingredient.add.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.add")) {
                        addIngredient()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(
            name: name,
            category: category,
            quantity: Double(quantity),
            unit: quantity.isEmpty ? nil : unit
        )

        Task {
            await viewModel.addIngredient(ingredient)
            dismiss()
        }
    }

    private func addPreset(_ preset: Ingredient) {
        Task {
            await viewModel.addPresets([preset])
            dismiss()
        }
    }
}

// MARK: - Edit Ingredient View

struct EditIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    let ingredient: Ingredient
    @Bindable var viewModel: MyFridgeViewModel

    @State private var name: String
    @State private var category: IngredientCategory
    @State private var quantity: String
    @State private var unit: MeasurementUnit

    init(ingredient: Ingredient, viewModel: MyFridgeViewModel) {
        self.ingredient = ingredient
        self.viewModel = viewModel
        _name = State(initialValue: ingredient.name)
        _category = State(initialValue: ingredient.category)
        _quantity = State(initialValue: ingredient.quantity.map { String(Int($0)) } ?? "")
        _unit = State(initialValue: ingredient.unit ?? .pieces)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "ingredient.name"), text: $name)
                        .textInputAutocapitalization(.words)

                    Picker(String(localized: "ingredient.category"), selection: $category) {
                        ForEach(IngredientCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.defaultIcon)
                                .tag(cat)
                        }
                    }
                }

                Section {
                    TextField(String(localized: "ingredient.quantity"), text: $quantity)
                        .keyboardType(.decimalPad)

                    Picker(String(localized: "ingredient.unit"), selection: $unit) {
                        ForEach(MeasurementUnit.allCases) { u in
                            Text(u.displayName).tag(u)
                        }
                    }
                } header: {
                    Text(String(localized: "ingredient.quantity.optional"))
                }

                Section {
                    Button(role: .destructive) {
                        deleteIngredient()
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "ingredient.delete"))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "ingredient.edit.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.save")) {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        var updated = ingredient
        updated.name = name
        updated.category = category
        updated.quantity = Double(quantity)
        updated.unit = quantity.isEmpty ? nil : unit

        Task {
            await viewModel.updateIngredient(updated)
            dismiss()
        }
    }

    private func deleteIngredient() {
        Task {
            await viewModel.removeIngredient(ingredient)
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    MyFridgeView(viewModel: MyFridgeViewModel())
}
