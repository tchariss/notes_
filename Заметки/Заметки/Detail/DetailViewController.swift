//
//  DetailViewController.swift
//  Заметки
//
//  Created by Tchariss on 3/9/22.
//

import UIKit
import UniformTypeIdentifiers

class DetailViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = .white
        
        createTextView()
        setDate()
        addNavigationBar()
    }
    
    func setTitleNavigationBar(index: Int, text: String?) {
        if let text = text {
            title = text
        }
        self.index = index
    }
    
// MARK: - Create TextView and adjust Keyboard
    private func createTextView() {
        textView = UITextView(frame: view.bounds)
        
        guard let index = index else { return }
        let text = manager.dataSource[index].text
        changeDate.text = manager.dataSource[index].date
        
        if text == "" || text == nil {
            textView.text = "Введите текст"
            textView.textColor = .gray
        } else {
            textView.text = text
            textView.textColor = .black
        }
        
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.font = UIFont.systemFont(ofSize: 17)
        
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
        textView.font = UIFont.systemFont(ofSize: 17)
    }
    
    func setDate() {
        textView.addSubview(changeDate)
        changeDate.topAnchor.constraint(equalTo: textView.topAnchor, constant: -16).isActive = true
        changeDate.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
// MARK: - Create NavigationBar
    private func addNavigationBar() {
        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(touchDone(_:)))
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPhoto))
        navigationItem.rightBarButtonItems = [done, buttonAdd]
    }
    
    @objc func touchDone(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()

        manager.updateNote(text: textView.text, index: index)
        manager.setData()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    func setImage() {
        guard let image = selectImage.image else { return }
        let aspectRatio = image.size.height / image.size.width
        let newImage = selectImage.image?.resizeImageTo(size: CGSize(width: view.bounds.width - 32, height: (view.bounds.width - 32) * aspectRatio))
        let attachment = NSTextAttachment()
        attachment.image = newImage
        let imageString = NSAttributedString(attachment: attachment)
        textView.textStorage.insert(imageString, at: textView.text.count)
    }
    
    private var index: Int?
    private var textView = UITextView() // Введенный текст
    private let manager = DataManager.manager
    private var selectImage = UIImageView()
    private let picker = UIImagePickerController()
    private var changeDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

}

// MARK: - UIImagePickerControllerDelegate
extension DetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Пользователь выбрал изображение
        if let image = info[.originalImage] as? UIImage {
            selectImage.image = image
            setImage()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func importPhoto() {
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - Resize image
extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizeImage
    }
}
