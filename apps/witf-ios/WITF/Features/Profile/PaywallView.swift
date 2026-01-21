// WITF? - What's In That Fridge?
// Features/Profile/PaywallView.swift

import SwiftUI
import StoreKit

// MARK: - Paywall View

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedProduct: MockProductInfo?
    @State private var isLoading = false
    @State private var purchaseSuccess = false

    // Using mock products for development
    // TODO: Replace with real StoreKit products when available
    private let products = MockProductInfo.allProducts

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header
                    headerSection

                    // Features
                    featuresSection

                    // Products
                    productsSection

                    // Purchase button
                    purchaseButton

                    // Restore & Terms
                    footerSection
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.background(colorScheme).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: AppIcons.close)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .overlay {
                if isLoading {
                    LoadingView(message: String(localized: "purchase.processing"))
                }
            }
            .alert(String(localized: "purchase.success.title"), isPresented: $purchaseSuccess) {
                Button(String(localized: "common.ok")) {
                    dismiss()
                }
            } message: {
                Text(String(localized: "purchase.success.message"))
            }
            .onAppear {
                selectedProduct = products.first { $0.tier == .premiumYearly }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: AppIcons.crown)
                    .font(.system(size: 50))
                    .foregroundStyle(AppTheme.primaryGradient)
            }

            Text(String(localized: "paywall.title"))
                .font(AppTheme.Typography.title1)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall.subtitle"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            ForEach(premiumFeatures) { feature in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: feature.icon)
                        .foregroundColor(AppTheme.primaryFallback)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(AppTheme.Typography.headline)

                        Text(feature.description)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

    // MARK: - Products Section

    private var productsSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(products) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    isBestValue: product.tier == .premiumYearly
                ) {
                    withAnimation(AppTheme.Animation.quick) {
                        selectedProduct = product
                    }
                }
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            purchaseSelectedProduct()
        } label: {
            HStack {
                Text(String(localized: "paywall.subscribe"))
                if let product = selectedProduct {
                    Text("- \(product.displayPrice)")
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selectedProduct == nil || isLoading)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Button(String(localized: "subscription.restore")) {
                // TODO: Implement restore with real StoreKit
            }
            .font(AppTheme.Typography.subheadline)
            .foregroundColor(.secondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Link(String(localized: "paywall.terms"), destination: URL(string: "https://witf.app/terms")!)
                Text("•")
                Link(String(localized: "paywall.privacy"), destination: URL(string: "https://witf.app/privacy")!)
            }
            .font(AppTheme.Typography.caption)
            .foregroundColor(.secondary)

            Text(String(localized: "paywall.disclaimer"))
                .font(AppTheme.Typography.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.md)
    }

    // MARK: - Premium Features

    private var premiumFeatures: [PremiumFeature] {
        [
            PremiumFeature(
                icon: "infinity",
                title: String(localized: "feature.unlimited.generations"),
                description: String(localized: "feature.unlimited.generations.desc")
            ),
            PremiumFeature(
                icon: "globe",
                title: String(localized: "feature.all.cuisines"),
                description: String(localized: "feature.all.cuisines.desc")
            ),
            PremiumFeature(
                icon: "wand.and.stars",
                title: String(localized: "feature.smart.suggestions"),
                description: String(localized: "feature.smart.suggestions.desc")
            ),
            PremiumFeature(
                icon: "chart.bar.fill",
                title: String(localized: "feature.nutrition.details"),
                description: String(localized: "feature.nutrition.details.desc")
            )
        ]
    }

    // MARK: - Purchase

    private func purchaseSelectedProduct() {
        guard selectedProduct != nil else { return }

        isLoading = true

        // Simulate purchase for development
        // TODO: Replace with real StoreKit purchase
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                isLoading = false
                purchaseSuccess = true
            }
        }
    }
}

// MARK: - Premium Feature

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Product Card

struct ProductCard: View {
    let product: MockProductInfo
    let isSelected: Bool
    var isBestValue: Bool = false
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    HStack {
                        Text(product.displayName)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)

                        if isBestValue {
                            Text(String(localized: "paywall.best.value"))
                                .font(AppTheme.Typography.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }

                    Text(product.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(isSelected ? AppTheme.primaryFallback : .primary)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.card(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? AppTheme.primaryFallback : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
