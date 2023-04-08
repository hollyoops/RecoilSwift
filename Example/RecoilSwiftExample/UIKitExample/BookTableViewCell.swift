import UIKit

class BookTableViewCell: UITableViewCell {
    static let reuseIdentifier = "BookTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    let quarterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
    
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(quarterLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),

            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            categoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            quarterLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            quarterLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            quarterLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            quarterLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryLabel.trailingAnchor, constant: 8)
        ])
    }

    func configure(with book: Book) {
        nameLabel.text = book.name
        categoryLabel.text = "Category: \(book.category.rawValue)"
        quarterLabel.text = "Date: \(book.publishDate.rawValue)"
    }
}
