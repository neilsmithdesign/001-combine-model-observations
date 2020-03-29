import UIKit
import Combine

final class ViewController: UITableViewController {
    
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        configureSubscriptions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Strong reference for subscriptions associated with published properties of the model
    private var subscriptions: Set<AnyCancellable> = .init()

    private let model: Model

    private lazy var addButton: UIBarButtonItem = .init(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addItem)
    )
    
    private let cellReuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        navigationItem.title = "Items"
        navigationItem.rightBarButtonItem = addButton
    }

}


// MARK: - User interactions
extension ViewController {
    
    /// Create
    @objc private func addItem() {
        let row = Int.random(in: 0...model.items.count)
        model.insert(item: Int.random(in: 0...100), at: IndexPath(row: row, section: 0))
    }
    
    /// Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        model.delete(itemAt: indexPath)
    }
    
}


// MARK: - Model observations (Combine)
private extension ViewController {
    
    /// 1: Configure subscriptions upon initialization.
    /// Keep a strong reference to the return value (AnyCancellable)
    /// using the store(in:) method.
    func configureSubscriptions() {
        model.onChange.sink { [weak self] change in
            self?.handle(change)
        }.store(in: &subscriptions)
    }
    
    
    /// 2: Handle the value from the model received via Combine's sink method
    func handle(_ change: Model.Change) {
        switch change {
        case let .deletedAt(indexPaths):
            tableView.performBatchUpdates({
                self.tableView.deleteRows(at: indexPaths, with: .automatic)
            })
        case let .insertedAt(indexPaths):
            tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            })
        }
    }
    
}


// MARK: - Model observations (NotificationCenter)
private extension ViewController {
    
    
    /// 1: Configure notifications on initialization of ViewController
    func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onReceive(_:)),
            name: .myModelDidChange,
            object: nil
        )
    }
    
    
    /// 2: Handle the receieved notification
    @objc func onReceive(_ notification: Notification) {
        guard
            notification.name == .myModelDidChange,
            let info = notification.userInfo,
            let change = info[Model.Change.userInfoKey] as? Model.Change else {
                return
        }
        self.handle(change)
    }
        
}


// MARK: - Table View DataSource
extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = "\(model.items[indexPath.row])"
        return cell
    }
    
}

