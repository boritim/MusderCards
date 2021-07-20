//
//  Bindable.swift
//  MusderCards
//
//  Created by Borisov Timofey on 16/07/21.
//  Copyright © 2021 Borisov Timofey. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
