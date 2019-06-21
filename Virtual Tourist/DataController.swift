//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 15/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let shared = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "VirtualTouristDataModel")
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
//    init(modelName: String) {
//        persistentContainer = NSPersistentContainer(name: modelName)
//    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
}
