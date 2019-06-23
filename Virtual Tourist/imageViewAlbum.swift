//
//  imageViewAlbum.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 19/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class imageViewAlbum : UIImageView {
    
    func loadFrom(photo:Photo) {
        URLSession.shared.dataTask(with: photo.imgURL!) { (data, response, error) in
//            cell.loadingIndicator.stopAnimating()
            guard error == nil else {
//                self.alert(title: "Error", message: "\(error?.localizedDescription)")
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                photo.img = data
                self.image = photo.getImg()
                try? DataController.shared.viewContext.save()
            } else {
//                self.alert(title: "Error", message: "Data is nil")
                print("Error: data is nil")
            }
        }
    }
    
}
