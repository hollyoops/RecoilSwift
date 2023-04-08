import UIKit
import RecoilSwift

class BooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var books: [Book] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let errorLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isHidden = true
            return label
    }()

    private let emptyDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Books"
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        refresh()
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(tableView)
        self.view.addSubview(loadingSpinner)
        self.view.addSubview(emptyDataLabel)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingSpinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            emptyDataLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapFilterButton))
        navigationItem.title = "Book Catalogue(UIKit)"
    }
    
    @objc func didTapFilterButton() {
        let categoryViewController = CategoryViewController()
        navigationController?.pushViewController(categoryViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.reuseIdentifier, for: indexPath) as! BookTableViewCell
        cell.configure(with: books[indexPath.row])
        return cell
    }
}

extension BooksViewController: RecoilUIScope {
    func refresh() {
        let booksLoader = ctx.useRecoilValueLoadable(BookList.currentBooks)
        
        if let error = booksLoader.errors.first {
            loadingSpinner.stopAnimating()
            tableView.isHidden = true
            emptyDataLabel.isHidden = true
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
        } else if let books = booksLoader.data {
            loadingSpinner.stopAnimating()
            
            if books.isEmpty {
                tableView.isHidden = true
                emptyDataLabel.isHidden = false
            } else {
                tableView.isHidden = false
                emptyDataLabel.isHidden = true
                self.books = books
                tableView.reloadData()
            }
        } else {
            tableView.isHidden = true
            emptyDataLabel.isHidden = true
            loadingSpinner.startAnimating()
        }
    }
}
