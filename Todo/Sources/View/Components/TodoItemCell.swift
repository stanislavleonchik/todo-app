import UIKit
import FileCacheUnit

class TodoItemCell: UITableViewCell {
    static let reuseIdentifier = "TodoItemCell"
    
    private let categoryDot = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1
        
        categoryDot.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryDot)
        
        NSLayoutConstraint.activate([
            categoryDot.widthAnchor.constraint(equalToConstant: 10),
            categoryDot.heightAnchor.constraint(equalToConstant: 10),
            categoryDot.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryDot.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func configure(with item: Todoitem, isTop: Bool, isBottom: Bool) {
        textLabel?.text = item.text
        textLabel?.textColor = item.isDone ? .gray : .black
        textLabel?.attributedText = item.isDone ? NSAttributedString(string: item.text, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]) : NSAttributedString(string: item.text, attributes: [:])
        
        categoryDot.backgroundColor = UIColor(hex: item.category.color ?? "05FF00FF")
        categoryDot.layer.cornerRadius = 5
        
        if isTop && isBottom {
            contentView.layer.cornerRadius = 10
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isTop {
            contentView.layer.cornerRadius = 10
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isBottom {
            contentView.layer.cornerRadius = 10
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            contentView.layer.cornerRadius = 0
        }
    }
}
