#if os(iOS) || os(tvOS)
import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        setupUI()
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Header with gradient
        let headerView = createHeaderView()
        contentView.addSubview(headerView)

        // Profile section
        let profileSection = createProfileSection()
        contentView.addSubview(profileSection)

        // Stats section
        let statsSection = createStatsSection()
        contentView.addSubview(statsSection)

        // Action buttons
        let actionButtons = createActionButtons()
        contentView.addSubview(actionButtons)

        // Feature cards
        let featureCards = createFeatureCards()
        contentView.addSubview(featureCards)

        // Recent activity
        let activitySection = createActivitySection()
        contentView.addSubview(activitySection)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),

            profileSection.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -60),
            profileSection.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            statsSection.topAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: 24),
            statsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            actionButtons.topAnchor.constraint(equalTo: statsSection.bottomAnchor, constant: 24),
            actionButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            featureCards.topAnchor.constraint(equalTo: actionButtons.bottomAnchor, constant: 32),
            featureCards.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featureCards.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            activitySection.topAnchor.constraint(equalTo: featureCards.bottomAnchor, constant: 32),
            activitySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activitySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activitySection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1400, height: 200)
        headerView.layer.addSublayer(gradientLayer)

        // Decorative circles
        for i in 0..<3 {
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            circle.layer.cornerRadius = CGFloat(40 + i * 20)
            headerView.addSubview(circle)

            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: CGFloat(80 + i * 40)),
                circle.heightAnchor.constraint(equalToConstant: CGFloat(80 + i * 40)),
                circle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: CGFloat(-20 + i * 30)),
                circle.topAnchor.constraint(equalTo: headerView.topAnchor, constant: CGFloat(20 + i * 15))
            ])
        }

        return headerView
    }

    private func createProfileSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Avatar
        let avatarContainer = UIView()
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.backgroundColor = .white
        avatarContainer.layer.cornerRadius = 60
        avatarContainer.layer.shadowColor = UIColor.black.cgColor
        avatarContainer.layer.shadowOpacity = 0.15
        avatarContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        avatarContainer.layer.shadowRadius = 12
        container.addSubview(avatarContainer)

        let avatarImageView = UIView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.backgroundColor = UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0)
        avatarImageView.layer.cornerRadius = 54
        avatarContainer.addSubview(avatarImageView)

        let initialsLabel = UILabel()
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.text = "JD"
        initialsLabel.font = .systemFont(ofSize: 36, weight: .bold)
        initialsLabel.textColor = .white
        avatarImageView.addSubview(initialsLabel)

        // Online indicator
        let onlineIndicator = UIView()
        onlineIndicator.translatesAutoresizingMaskIntoConstraints = false
        onlineIndicator.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        onlineIndicator.layer.cornerRadius = 10
        onlineIndicator.layer.borderWidth = 3
        onlineIndicator.layer.borderColor = UIColor.white.cgColor
        avatarContainer.addSubview(onlineIndicator)

        // Name
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "John Doe"
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        container.addSubview(nameLabel)

        // Username
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "@johndoe"
        usernameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        usernameLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        container.addSubview(usernameLabel)

        // Bio
        let bioLabel = UILabel()
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.text = "iOS Developer | Swift Enthusiast | Open Source Contributor"
        bioLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bioLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        container.addSubview(bioLabel)

        // Verified badge
        let verifiedBadge = UIView()
        verifiedBadge.translatesAutoresizingMaskIntoConstraints = false
        verifiedBadge.backgroundColor = UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0)
        verifiedBadge.layer.cornerRadius = 10
        container.addSubview(verifiedBadge)

        let checkLabel = UILabel()
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.text = "✓"
        checkLabel.font = .systemFont(ofSize: 12, weight: .bold)
        checkLabel.textColor = .white
        verifiedBadge.addSubview(checkLabel)

        NSLayoutConstraint.activate([
            avatarContainer.topAnchor.constraint(equalTo: container.topAnchor),
            avatarContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 120),
            avatarContainer.heightAnchor.constraint(equalToConstant: 120),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 108),
            avatarImageView.heightAnchor.constraint(equalToConstant: 108),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            onlineIndicator.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: -4),
            onlineIndicator.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: -4),
            onlineIndicator.widthAnchor.constraint(equalToConstant: 20),
            onlineIndicator.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: -15),

            verifiedBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            verifiedBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 20),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 20),

            checkLabel.centerXAnchor.constraint(equalTo: verifiedBadge.centerXAnchor),
            checkLabel.centerYAnchor.constraint(equalTo: verifiedBadge.centerYAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 12),
            bioLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bioLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            bioLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createStatsSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        container.addSubview(stackView)

        let stats = [
            ("1,234", "Followers"),
            ("567", "Following"),
            ("89", "Projects"),
            ("4.9", "Rating")
        ]

        for (index, stat) in stats.enumerated() {
            let statView = createStatItem(value: stat.0, label: stat.1)
            stackView.addArrangedSubview(statView)

            if index < stats.count - 1 {
                let divider = UIView()
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0)
                statView.addSubview(divider)
                NSLayoutConstraint.activate([
                    divider.trailingAnchor.constraint(equalTo: statView.trailingAnchor),
                    divider.centerYAnchor.constraint(equalTo: statView.centerYAnchor),
                    divider.widthAnchor.constraint(equalToConstant: 1),
                    divider.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }

    private func createStatItem(value: String, label: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        valueLabel.textAlignment = .center
        container.addSubview(valueLabel)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createActionButtons() -> UIView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually

        let followButton = createButton(title: "Follow", isPrimary: true)
        let messageButton = createButton(title: "Message", isPrimary: false)

        stackView.addArrangedSubview(followButton)
        stackView.addArrangedSubview(messageButton)

        NSLayoutConstraint.activate([
            followButton.heightAnchor.constraint(equalToConstant: 48),
            messageButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        return stackView
    }

    private func createButton(title: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12

        if isPrimary {
            button.backgroundColor = UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0)
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0), for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
        }

        return button
    }

    private func createFeatureCards() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Featured Work"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        container.addSubview(titleLabel)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        container.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        scrollView.addSubview(stackView)

        let cards = [
            ("Swift Package", "Open Source", UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)),
            ("iOS App", "App Store", UIColor(red: 0.4, green: 0.8, blue: 0.7, alpha: 1.0)),
            ("Framework", "CocoaPods", UIColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 1.0)),
            ("CLI Tool", "Homebrew", UIColor(red: 0.95, green: 0.75, blue: 0.3, alpha: 1.0))
        ]

        for card in cards {
            let cardView = createFeatureCard(title: card.0, subtitle: card.1, color: card.2)
            stackView.addArrangedSubview(cardView)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 160),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        return container
    }

    private func createFeatureCard(title: String, subtitle: String, color: UIColor) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = color
        card.layer.cornerRadius = 16
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOpacity = 0.4
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 12

        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        iconView.layer.cornerRadius = 20
        card.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        card.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 140),

            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),

            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func createActivitySection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Recent Activity"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        container.addSubview(titleLabel)

        let activitiesContainer = UIView()
        activitiesContainer.translatesAutoresizingMaskIntoConstraints = false
        activitiesContainer.backgroundColor = .white
        activitiesContainer.layer.cornerRadius = 16
        activitiesContainer.layer.shadowColor = UIColor.black.cgColor
        activitiesContainer.layer.shadowOpacity = 0.08
        activitiesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        activitiesContainer.layer.shadowRadius = 8
        container.addSubview(activitiesContainer)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        activitiesContainer.addSubview(stackView)

        let activities = [
            ("Pushed to main", "SnapshotTestingHEIC", "2h ago", UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)),
            ("Opened PR #42", "swift-composable-architecture", "5h ago", UIColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0)),
            ("Starred repository", "Alamofire/Alamofire", "1d ago", UIColor(red: 0.95, green: 0.75, blue: 0.3, alpha: 1.0)),
            ("Released v2.0.0", "MyAwesomeLib", "3d ago", UIColor(red: 0.9, green: 0.4, blue: 0.5, alpha: 1.0))
        ]

        for (index, activity) in activities.enumerated() {
            let activityRow = createActivityRow(
                action: activity.0,
                target: activity.1,
                time: activity.2,
                color: activity.3,
                showDivider: index < activities.count - 1
            )
            stackView.addArrangedSubview(activityRow)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            activitiesContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            activitiesContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            activitiesContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            activitiesContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: activitiesContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: activitiesContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: activitiesContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: activitiesContainer.bottomAnchor)
        ])

        return container
    }

    private func createActivityRow(action: String, target: String, time: String, color: UIColor, showDivider: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = color
        indicator.layer.cornerRadius = 5
        container.addSubview(indicator)

        let actionLabel = UILabel()
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.text = action
        actionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        actionLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        container.addSubview(actionLabel)

        let targetLabel = UILabel()
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        targetLabel.text = target
        targetLabel.font = .systemFont(ofSize: 13, weight: .regular)
        targetLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        container.addSubview(targetLabel)

        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        container.addSubview(timeLabel)

        if showDivider {
            let divider = UIView()
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0)
            container.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
                divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1)
            ])
        }

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 64),

            indicator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 10),
            indicator.heightAnchor.constraint(equalToConstant: 10),

            actionLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 12),
            actionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),

            targetLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 12),
            targetLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),

            timeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }
}
#endif
