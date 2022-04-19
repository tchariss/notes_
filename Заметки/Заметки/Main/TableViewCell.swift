//
//  TableViewCell.swift
//  Заметки
//
//  Created by Tchariss on 3/9/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(label)
        setConstraints()
    }
    
    func setLabelText(name: String?) {
        if let name = name {
            label.text = name
        }
    }

    private func setConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
