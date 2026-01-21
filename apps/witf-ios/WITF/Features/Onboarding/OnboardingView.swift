// WITF? - What's In That Fridge?
// Features/Onboarding/OnboardingView.swift

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "refrigerator.fill",
            title: String(localized: "onboarding.page1.title"),
            subtitle: String(localized: "onboarding.page1.subtitle"),
            description: String(localized: "onboarding.page1.description"),
            color: AppTheme.primaryFallback
        ),
        OnboardingPage(
            icon: "camera.viewfinder",
            title: String(localized: "onboarding.page2.title"),
            subtitle: String(localized: "onboarding.page2.subtitle"),
            description: String(localized: "onboarding.page2.description"),
            color: AppTheme.secondaryFallback
        ),
        OnboardingPage(
            icon: "globe",
            title: String(localized: "onboarding.page3.title"),
            subtitle: String(localized: "onboarding.page3.subtitle"),
            description: String(localized: "onboarding.page3.description"),
            color: AppTheme.accentFallback
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    pages[currentPage].color.opacity(0.1),
                    AppTheme.background(.light)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(String(localized: "onboarding.skip")) {
                        completeOnboarding()
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Page indicator
                    HStack(spacing: AppTheme.Spacing.xs) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppTheme.primaryFallback : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                .animation(AppTheme.Animation.quick, value: currentPage)
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.sm)

                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(AppTheme.Animation.standard) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1
                             ? String(localized: "onboarding.next")
                             : String(localized: "onboarding.getStarted"))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
    }

    private func completeOnboarding() {
        withAnimation(AppTheme.Animation.smooth) {
            isComplete = true
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // Icon with animated background
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(page.color.opacity(0.25))
                    .frame(width: 140, height: 140)

                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }

            VStack(spacing: AppTheme.Spacing.md) {
                // Title
                Text(page.title)
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text(page.subtitle)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)

                // Description
                Text(page.description)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }

            Spacer()
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isComplete: .constant(false))
}
