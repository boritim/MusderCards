//
//  Advertiser.swift
//  MusderCards
//
//  Created by Borisov Timofey on 14/07/21.
//  Copyright © 2021 Borisov Timofey. All rights reserved.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSMutableAttributedString(string: "\n\(brandName)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return CardViewModel(uid: "",imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
    }
}

