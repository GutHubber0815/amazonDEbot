// WITF? - What's In That Fridge?
// Core/Theme/AppTheme.swift

import SwiftUI

// MARK: - App Theme

/// Central theme configuration for the WITF app
/// Style: Clean, modern, slightly playful with pastel blue/green palette
enum AppTheme {

    // MARK: - Brand Colors

    /// Primary brand color - Fresh teal/mint
    static let primary = Color("PrimaryColor", bundle: nil)
    static let primaryFallback = Color(red: 0.2, green: 0.78, blue: 0.72) // #33C7B8

    /// Secondary brand color - Soft blue
    static let secondary = Color("SecondaryColor", bundle: nil)
    static let secondaryFallback = Color(red: 0.4, green: 0.6, blue: 0.9) // #6699E6

    /// Accent color - Warm orange for CTAs
    static let accent = Color("AccentColor", bundle: nil)
    static let accentFallback = Color(red: 1.0, green: 0.6, blue: 0.4) // #FF9966

    // MARK: - Semantic Colors

    /// Background colors
    static let backgroundPrimary = Color("BackgroundPrimary", bundle: nil)
    static let backgroundSecondary = Color("BackgroundSecondary", bundle: nil)

    /// Card background
    static let cardBackground = Color("CardBackground", bundle: nil)

    /// Text colors
    static let textPrimary = Color("TextPrimary", bundle: nil)
    static let textSecondary = Color("TextSecondary", bundle: nil)
    static let textTertiary = Color("TextTertiary", bundle: nil)

    // MARK: - Adaptive Colors (Light/Dark Mode)

    /// Primary color that adapts to color scheme
    static func primaryColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.3, green: 0.85, blue: 0.78)
            : Color(red: 0.2, green: 0.72, blue: 0.65)
    }

    /// Background that adapts to color scheme
    static func background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.1, green: 0.1, blue: 0.12)
            : Color(red: 0.97, green: 0.98, blue: 0.99)
    }

    /// Card background that adapts to color scheme
    static func card(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.15, green: 0.15, blue: 0.18)
            : Color.white
    }

    // MARK: - Gradients

    /// Main brand gradient
    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.78, blue: 0.72),
            Color(red: 0.4, green: 0.6, blue: 0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Accent gradient for CTAs
    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.6, blue: 0.4),
            Color(red: 1.0, green: 0.45, blue: 0.45)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Soft pastel gradient for backgrounds
    static let softGradient = LinearGradient(
        colors: [
            Color(red: 0.9, green: 0.95, blue: 1.0),
            Color(red: 0.95, green: 1.0, blue: 0.98)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 100
    }

    // MARK: - Shadows

    enum Shadow {
        static let small = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 4,
            x: 0,
            y: 2
        )

        static let medium = ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )

        static let large = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions

extension View {
    /// Applies the app's card style
    func cardStyle(colorScheme: ColorScheme = .light) -> some View {
        self
            .background(AppTheme.card(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .shadow(
                color: AppTheme.Shadow.medium.color,
                radius: AppTheme.Shadow.medium.radius,
                x: AppTheme.Shadow.medium.x,
                y: AppTheme.Shadow.medium.y
            )
    }

    /// Applies the app's primary button style
    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    /// Applies the app's secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.primaryFallback)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.primaryFallback.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    /// Applies a soft shadow
    func softShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: AppTheme.Shadow.small.x,
            y: AppTheme.Shadow.small.y
        )
    }

    /// Applies a medium shadow
    func mediumShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.medium.color,
            radius: AppTheme.Shadow.medium.radius,
            x: AppTheme.Shadow.medium.x,
            y: AppTheme.Shadow.medium.y
        )
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                isEnabled
                    ? AppTheme.primaryGradient
                    : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.primaryFallback)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.primaryFallback.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

struct ChipButtonStyle: ButtonStyle {
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.subheadline)
            .foregroundColor(isSelected ? .white : AppTheme.primaryFallback)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(isSelected ? AppTheme.primaryFallback : AppTheme.primaryFallback.opacity(0.12))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - SF Symbols

/// Centralized SF Symbol names used throughout the app
enum AppIcons {
    // Navigation
    static let home = "house.fill"
    static let recipes = "book.fill"
    static let fridge = "refrigerator.fill"
    static let profile = "person.fill"

    // Actions
    static let camera = "camera.fill"
    static let photo = "photo.fill"
    static let plus = "plus"
    static let minus = "minus"
    static let edit = "pencil"
    static let delete = "trash.fill"
    static let share = "square.and.arrow.up"
    static let close = "xmark"
    static let checkmark = "checkmark"
    static let search = "magnifyingglass"

    // Content
    static let star = "star.fill"
    static let starEmpty = "star"
    static let heart = "heart.fill"
    static let heartEmpty = "heart"
    static let clock = "clock.fill"
    static let flame = "flame.fill"
    static let person = "person.fill"
    static let personMultiple = "person.2.fill"

    // Categories
    static let leaf = "leaf.fill"
    static let carrot = "carrot.fill"
    static let drop = "drop.fill"
    static let fork = "fork.knife"
    static let fish = "fish.fill"

    // Settings
    static let globe = "globe"
    static let gear = "gearshape.fill"
    static let crown = "crown.fill"
    static let chevronRight = "chevron.right"
    static let chevronDown = "chevron.down"

    // Misc
    static let sparkles = "sparkles"
    static let wand = "wand.and.stars"
    static let info = "info.circle.fill"
    static let warning = "exclamationmark.triangle.fill"
}

// MARK: - Logo Comment

/*
 WITF? App Icon Concept:
 -------------------------
 Shape: Circular with rounded edges
 Background: Gradient from teal (#33C7B8) to soft blue (#6699E6)

 Icon Design Option 1 - Minimalist Fridge:
 - Simple fridge outline in white
 - Question mark integrated into fridge door
 - Clean, modern lines

 Icon Design Option 2 - Plate with Ingredients:
 - Circular plate outline
 - Abstract food items arranged aesthetically
 - "WITF?" text subtly incorporated

 Icon Design Option 3 - Combined:
 - Fridge door opening to reveal a plate/dish
 - Magical sparkles suggesting AI/discovery
 - "WITF?" initials in a modern, rounded font

 Launch Screen:
 - Centered app icon/logo
 - Gradient background matching brand colors
 - Tagline: "Turn your fridge into dinner."
 - Subtle animation: sparkle/shimmer effect
 */
