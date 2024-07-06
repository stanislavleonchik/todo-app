import UIKit

class DateCell: UICollectionViewCell {
    private let label = UILabel()
    var item: Todoitem?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with text: String, isSelected: Bool, item: Todoitem?) {
        label.text = text
        self.item = item
        contentView.backgroundColor = isSelected ? .blue : .white
        label.textColor = isSelected ? .white : .black
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
}
