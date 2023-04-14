import UIKit
import RecoilSwift

class CategoryViewController: UITableViewController {
    var selectedCategory: Book.Category?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset",
                                                            style: .plain,
                                                            target: self
                                                            , action: #selector(didTapResetButton))
        
        refresh()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Book.Category.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let category = Book.Category.allCases[indexPath.row]
        cell.textLabel?.text = category.rawValue
        cell.accessoryType = category == selectedCategory ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVal = Book.Category.allCases[indexPath.row]
        let updateCategory = recoil.useUpdate(BookList.selectedCategoryState)
        updateCategory(selectedVal)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapResetButton() {
        let updateCategory = recoil.useUpdate(BookList.selectedCategoryState)
        updateCategory(nil)
        navigationController?.popViewController(animated: true)
    }
}

extension CategoryViewController: RecoilUIScope {
    func refresh() {
        let selectedCategoryState = try? recoil.useThrowingValue(BookList.selectedCategoryState)
        self.selectedCategory = selectedCategoryState
        tableView.reloadData()
    }
}
