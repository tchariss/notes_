//
//  InfoNotes.swift
//  Заметки
//
//  Created by Tchariss on 19.04.2022.
//

import Foundation

// MARK: - Model
struct InfoNotes: Codable {
    let name: String
    var text: String? // Информация внутри заметки
    var date: String
}
