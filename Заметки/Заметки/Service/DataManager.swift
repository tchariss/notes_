//
//  DataManager.swift
//  Заметки
//
//  Created by Tchariss on 19.04.2022.
//

import Foundation

class DataManager {
    
    static let manager = DataManager()
    
    private(set) var dataSource = [InfoNotes]()
    let key = "myKey"
    private let userDefault = UserDefaults.standard // хранилище данных UserDefaults
    
    func addNote(text: String?, name: String) {
        let newNote = InfoNotes(name: name, text: text, date: getFormattedDate())
        dataSource.append(newNote)
    }
    
    func updateNote(text: String, index: Int?) {
        if let index = index {
            dataSource[index].text = text
            dataSource[index].date = getFormattedDate()
        }
    }
    
    func setData() {
        if let json = try? JSONEncoder().encode(dataSource) {
            userDefault.set(json, forKey: key)
        }
    }
    
    func getData() {
        guard let data = userDefault.object(forKey: key) as? Data else { return }
        if let data = try? JSONDecoder().decode([InfoNotes].self, from: data) {
            dataSource = data
        }
    }
    
    func deleteData(index: Int) {
        dataSource.remove(at: index)
    }
    
    // Date formatting
    func getFormattedDate() -> String {
        let time = NSDate()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "d MMMM yyyy г. в HH:mm"
        return dateformat.string(from: time as Date)
    }
}
