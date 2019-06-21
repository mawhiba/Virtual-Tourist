//
//  PhotoCollectionVC.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 15/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoCollectionVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
   
    @IBOutlet var collectionUIView: UICollectionView!
    @IBOutlet var noImageLabel: UILabel!
    @IBOutlet var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorUIView: UIActivityIndicatorView!
    
    var fetchResultController : NSFetchedResultsController<Photo>!
    var pin : Pin!
    var pageNo = 1
    var deleteAll = false
    var checkPhotoAvailability : Bool {
        return (fetchResultController.fetchedObjects?.count ?? 0 ) != 0
    }

//    if (fetchResultController.fetchedObjects?.count) != 0 {
//        checkPhotoAvailability = true
//    } else {
//        checkPhotoAvailability = false
//    }
    
    func viewPhotos() {
        let fetchRequest: NSFetchRequest<Photo>
        fetchRequest = Photo.fetchRequest()
        //Retrive only the photos associated with this pin
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            if checkPhotoAvailability {
                updateUI(processing: false)
            }
            else {
                newCollection(self)
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
    
    @IBAction func newCollection(_ sender: Any) {
        updateUI(processing: true)
        
        if checkPhotoAvailability {
            deleteAll = true
            for img in fetchResultController.fetchedObjects! {
                DataController.shared.viewContext.delete(img)
            }
            try? DataController.shared.viewContext.save()
            deleteAll = false
        }
        
        Flicker_API.photosURL(with: pin.coordinate, pageNo: pageNo) { (url, error, errMsg) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeanObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !deleteAll {
            collectionUIView.deleteItems(at: [indexPath])
            return
        }
//        if let indexPath = indexPath, type == .insert {
//            collectionUIView.insertItems(at: [indexPath])
//            return
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMapAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    
}
