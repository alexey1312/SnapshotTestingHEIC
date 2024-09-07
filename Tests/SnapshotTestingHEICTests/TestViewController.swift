#if os(iOS) || os(tvOS)
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
        label.textAlignment = .center
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.view.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
}
#endif
