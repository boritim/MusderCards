//
//  SettingsCell.swift
//  MusderCards
//
//  Created by Borisov Timofey on 15/07/21.
//  Copyright © 2021 Borisov Timofey. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    class SettingsTextField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }
        
        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: 44)
        }
    }
    
    let textField: UITextField = {
        let tf = SettingsTextField()
        tf.placeholder = "Введите имя"
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
