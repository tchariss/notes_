//
//  ViewController.swift
//  Заметки
//
//  Created by Tchariss on 3/9/22.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView = UITableView.init(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "myCell")
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        manager.getData()
        setupTableView()
        addNavigationBar()
    }
    
    // MARK: - Create NavigationBar
    private func addNavigationBar() {
        self.navigationItem.title = "Все заметки"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Создать", style: .done, target: self, action: #selector((createNote(_:))))
    }
    
    // MARK: - UIAlertController
    @objc private func createNote(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Новая заметка", message: nil, preferredStyle: .alert)
        alertController.addTextField { (text) in
            text.placeholder = "Введите имя для новой заметки"
            text.addTarget(self, action: #selector(self.alertChange(_ :)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        let continueAction = UIAlertAction(title: "Подтвердить", style: .default) { [self]
            (action) in
            guard let name = alertController.textFields?.first?.text else { return }
            
            manager.addNote(text: nil, name: name)
            manager.setData()
            tableView.reloadData()
        }

        continueAction.isEnabled = false
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        present(alertController, animated: true)
    }

    @objc private func alertChange(_ textField: UITextField) {
        let alert = self.presentedViewController as? UIAlertController
        let text = (alert!.textFields?.first)! as UITextField
        let action = alert!.actions.last! as UIAlertAction
        action.isEnabled = text.text!.count > 0
    }
    
    // MARK: - Setup constraints tableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private let userDefault = UserDefaults.standard // хранилище данных UserDefaults
    private let manager = DataManager.manager
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Количество секций / разделов
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Сколько ячеек в секции
        manager.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создание ячейки
        let item = manager.dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! TableViewCell
        cell.setLabelText(name: item.name)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = manager.dataSource[indexPath.row] // Выбранная ячейка
        
        let newController = DetailViewController()
        newController.setTitleNavigationBar(index: indexPath.row, text: item.text)
        
        self.navigationController?.pushViewController(newController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.beginUpdates()
            
            manager.deleteData(index: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
}
