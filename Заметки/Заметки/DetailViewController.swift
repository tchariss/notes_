//
//  DetailViewController.swift
//  Заметки
//
//  Created by Виктория Шеховцова on 3/9/22.
//

import UIKit

class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = .white

        createTextView()
        addNavigationBar()
    }
    
    func configure(with infoNotes: InfoNotes) {
        currentNote = infoNotes
        title = currentNote?.nameNotes
    }
    
// MARK: - Create TextView and adjust Keyboard
    private func createTextView() {
        textView = UITextView(frame: view.bounds)
        
        let text = userDefault.string(forKey: "\(String(describing: currentNote!.nameNotes))")
        
        if text != "" {
            textView.text = text
            textView.textColor = .black
        } else {
            textView.text = "Введите текст"
            textView.textColor = .gray
        }
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.font = UIFont.systemFont(ofSize: 17)
        // Cmd + K -> Вызвать клавиатуру
        
        view.addSubview(textView)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        if textView.text! == "Введите текст", textView.textColor == .gray {
            textView.text = ""
        }
        textView.textColor = .black
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            // Если клавиуатура прячется, возвращаем все на свое место
            textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            // Если клавиатура появляется, сдвигаем курсор и контент
            textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 16)
        }
        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
// MARK: - Create NavigationBar
    private func addNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(touchDone(_:)))
    }
    
    @objc func touchDone(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()

        let nameNotes: String = currentNote!.nameNotes

        userDefault.set(textView.text, forKey: "\(nameNotes)")
        userDefault.synchronize()

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private var currentNote: InfoNotes?
    private var textView = UITextView() // Введенный текст
    private let userDefault = UserDefaults.standard
}

