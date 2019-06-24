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
    var _photo: Photo?
    let imageCache = NSCache<AnyObject, AnyObject>()
    func loadFrom(photo: Photo) {
//        URLSession.shared.dataTask(with: photo.imgURL!) { (data, response, error) in
////            cell.loadingIndicator.stopAnimating()
//            guard error == nil else {
////                self.alert(title: "Error", message: "\(error?.localizedDescription)")
//                print("Error: \(error)")
//                return
//            }
//
//            if let data = data {
//                photo.img = data
//                self.image = photo.getImg()
//                try? DataController.shared.viewContext.save()
//            } else {
////                self.alert(title: "Error", message: "Data is nil")
//                print("Error: data is nil")
//            }
//        }
        
        
        if _photo != nil {
            guard _photo?.creationDate != photo.creationDate else {return}
        }
        
        self.image = nil
        _photo = photo
        
        if let img = _photo?.getImg() {
            self.image = img
            return
        }
        
        ai.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            guard let imgData = try? Data(contentsOf: photo.imgURL!) else {return}
            
            DispatchQueue.main.async {
                self.ai.stopAnimating()
                photo.img = imgData
                self.image = photo.getImg()
                try? DataController.shared.viewContext.save()
            }
        }
    }
    
    lazy var ai: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.color = .black
        ai.hidesWhenStopped = true
        
        addSubview(ai)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        ai.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        return ai
        
    }()
    
}
