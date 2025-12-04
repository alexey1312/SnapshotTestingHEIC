//
//  SwiftUIView.swift
//
//
//  Created by Emanuel Cunha on 19/05/2023.
//

#if os(iOS) || os(tvOS)
    import SwiftUI

    struct SwiftUIView: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with gradient
                    ZStack(alignment: .bottomTrailing) {
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.45, blue: 0.95),
                                Color(red: 0.55, green: 0.35, blue: 0.85),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 200)

                        // Decorative circles
                        ForEach(0 ..< 3, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: CGFloat(80 + index * 40), height: CGFloat(80 + index * 40))
                                .offset(x: CGFloat(-20 + index * 30), y: CGFloat(-60 + index * 15))
                        }
                    }

                    // Profile section
                    VStack(spacing: 12) {
                        // Avatar
                        ZStack(alignment: .bottomTrailing) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)

                                Circle()
                                    .fill(Color(red: 0.35, green: 0.45, blue: 0.95))
                                    .frame(width: 108, height: 108)

                                Text("JD")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            // Online indicator
                            Circle()
                                .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .offset(x: -4, y: -4)
                        }
                        .offset(y: -60)

                        // Name with verified badge
                        HStack(spacing: 8) {
                            Text("John Doe")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.35, green: 0.45, blue: 0.95))
                                    .frame(width: 20, height: 20)

                                Text("✓")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(y: -50)

                        Text("@johndoe")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            .offset(y: -48)

                        Text("iOS Developer | Swift Enthusiast | Open Source Contributor")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .offset(y: -40)
                    }

                    // Stats section
                    HStack(spacing: 0) {
                        StatItem(value: "1,234", label: "Followers")
                        Divider().frame(height: 40)
                        StatItem(value: "567", label: "Following")
                        Divider().frame(height: 40)
                        StatItem(value: "89", label: "Projects")
                        Divider().frame(height: 40)
                        StatItem(value: "4.9", label: "Rating")
                    }
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .offset(y: -30)

                    // Action buttons
                    HStack(spacing: 12) {
                        ActionButton(title: "Follow", isPrimary: true)
                        ActionButton(title: "Message", isPrimary: false)
                    }
                    .padding(.horizontal, 20)
                    .offset(y: -10)

                    // Featured Work section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Featured Work")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FeatureCard(
                                    title: "Swift Package",
                                    subtitle: "Open Source",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.4)
                                )
                                FeatureCard(
                                    title: "iOS App",
                                    subtitle: "App Store",
                                    color: Color(red: 0.4, green: 0.8, blue: 0.7)
                                )
                                FeatureCard(
                                    title: "Framework",
                                    subtitle: "CocoaPods",
                                    color: Color(red: 0.6, green: 0.5, blue: 0.9)
                                )
                                FeatureCard(
                                    title: "CLI Tool",
                                    subtitle: "Homebrew",
                                    color: Color(red: 0.95, green: 0.75, blue: 0.3)
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 12)

                    // Recent Activity section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                        VStack(spacing: 0) {
                            ActivityRow(
                                action: "Pushed to main",
                                target: "SnapshotTestingHEIC",
                                time: "2h ago",
                                color: Color(red: 0.2, green: 0.8, blue: 0.4),
                                showDivider: true
                            )
                            ActivityRow(
                                action: "Opened PR #42",
                                target: "swift-composable-architecture",
                                time: "5h ago",
                                color: Color(red: 0.35, green: 0.45, blue: 0.95),
                                showDivider: true
                            )
                            ActivityRow(
                                action: "Starred repository",
                                target: "Alamofire/Alamofire",
                                time: "1d ago",
                                color: Color(red: 0.95, green: 0.75, blue: 0.3),
                                showDivider: true
                            )
                            ActivityRow(
                                action: "Released v2.0.0",
                                target: "MyAwesomeLib",
                                time: "3d ago",
                                color: Color(red: 0.9, green: 0.4, blue: 0.5),
                                showDivider: false
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        }
    }

    // MARK: - Supporting Views

    struct StatItem: View {
        let value: String
        let label: String

        var body: some View {
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct ActionButton: View {
        let title: String
        let isPrimary: Bool

        var body: some View {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isPrimary ? .white : Color(red: 0.35, green: 0.45, blue: 0.95))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isPrimary ? Color(red: 0.35, green: 0.45, blue: 0.95) : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.35, green: 0.45, blue: 0.95), lineWidth: isPrimary ? 0 : 2)
                )
        }
    }

    struct FeatureCard: View {
        let title: String
        let subtitle: String
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .padding(.top, 16)
                    .padding(.leading, 16)

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.leading, 16)
                .padding(.bottom, 16)
            }
            .frame(width: 140, height: 160)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    struct ActivityRow: View {
        let action: String
        let target: String
        let time: String
        let color: Color
        let showDivider: Bool

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(action)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text(target)
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    }

                    Spacer()

                    Text(time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                }
                .padding(.horizontal, 16)
                .frame(height: 64)

                if showDivider {
                    Rectangle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                        .frame(height: 1)
                        .padding(.leading, 40)
                }
            }
        }
    }

    struct SwiftUIView_Previews: PreviewProvider {
        static var previews: some View {
            SwiftUIView()
        }
    }
#endif
