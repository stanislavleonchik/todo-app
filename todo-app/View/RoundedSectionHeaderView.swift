import UIKit

class RoundedSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "RoundedSectionHeaderView"
    
    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
