import UIKit

class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupLabel()
    }

    private func setupLabel() {
        let label = UILabel()
        label.text = "Test SnapshotTestingHEIC"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 64)
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
