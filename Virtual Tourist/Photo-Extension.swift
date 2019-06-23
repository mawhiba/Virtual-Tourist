//
//  Photo-Extension.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 15/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension Photo {
    
    func set(img: UIImage) {
        self.img = img.pngData()
    }
    
    func getImg() -> UIImage? {
        return (img == nil) ? nil : UIImage(data: img!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
