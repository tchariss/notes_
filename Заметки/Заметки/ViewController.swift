//
//  ViewController.swift
//  Заметки
//
//  Created by Виктория Шеховцова on 3/9/22.
//

import UIKit

struct InfoNotes {
    var textNotes: String? // Информация внутри заметки
    let nameNotes: String
    
    init(nameNotes: String, textNotes: String?) {
        self.nameNotes = nameNotes
        self.textNotes = textNotes
    }
}

class ViewController: UIViewController {
    lazy var tableView = UITableView.init(frame: .zero, style: .insetGrouped)
    lazy var dataSource: [InfoNotes] = [
        InfoNotes(nameNotes: "Новая заметка", textNotes: "1 - Купить маме цветы\n 2 - запустить стиральную машину \n\n 3 - Сделать задание на swiftbook\n")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "myCell")
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        checkNewNotes()
        setupTableView()
        addNavigationBar()
    }
    
    // MARK: - Create NavigationBar
    private func addNavigationBar() {
        self.navigationItem.title = "Все заметки"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Создать", style: .done, target: self, action: #selector((createNote(_:))))
    }
    
    private func checkNewNotes() {
        
//      //   Clear userDefault :
//        let dictionary = userDefault.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            userDefault.removeObject(forKey: key)
//        }
        
        guard let strings = userDefault.object(forKey: "myKey") as? [String] else {
            userDefault.set("1 - Купить маме цветы\n 2 - запустить стиральную машину \n\n 3 - Сделать задание на swiftbook\n", forKey: "Новая заметка")
            return
        }
        
        for string in strings {
            arrayNotesName.append(string)
            dataSource.append(InfoNotes(nameNotes: string, textNotes: userDefault.string(forKey: string)))
        }
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
            self.dataSource.append(InfoNotes(nameNotes: name, textNotes: nil))

            arrayNotesName.append("\(name)")
            userDefault.set("", forKey: "\(name)")
            userDefault.set(arrayNotesName, forKey: "myKey")
            
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
    
    private var arrayNotesName: [String] = []
    private let userDefault = UserDefaults.standard // хранилище данных UserDefaults
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Количество секций / разделов
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Сколько ячеек в секции
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создание ячейки
        let item = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! TableViewCell
        cell.configure(with: item)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = dataSource[indexPath.row] // Выбранная ячейка
        
        let newController = DetailViewController()
        newController.configure(with: item)
        
        self.navigationController?.pushViewController(newController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.tableView.beginUpdates()
            let removeItem = self.dataSource.remove(at: indexPath.row)
            
            if let index = arrayNotesName.firstIndex(where: { $0 == removeItem.nameNotes }) {
                arrayNotesName.remove(at: index)
            }
            
            userDefault.removeObject(forKey: removeItem.nameNotes)
            userDefault.set(arrayNotesName, forKey: "myKey")
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
}
