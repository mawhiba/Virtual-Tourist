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
        return fetchResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionUIView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as? imgCell {
            let photo = fetchResultController.object(at: indexPath)
            cell.imgView.loadFrom(photo: photo)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img =  fetchResultController.object(at: indexPath)
        DataController.shared.viewContext.delete(img)
        try? DataController.shared.viewContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
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
        
        Flicker_API.photosURL(with: pin.coordinate, pageNo: pageNo) { (urls, error, errMsg) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                
                if (error == nil) && (errMsg == nil) {
                    if urls != nil {
                        
                        self.noImageLabel.isHidden = !urls!.isEmpty
                        
                        for url in urls! {
                            let img = Photo(context: DataController.shared.viewContext)
                            img.imgURL = url
                            img.pin = self.pin
                        }
                        try? DataController.shared.viewContext.save()
                        self.collectionUIView.reloadData()
                    } else {
                        self.noImageLabel.isHidden = false
                        return
                    }
                } else {
                    self.alert(title: "Error", message: error?.localizedDescription)
                }
            }
        }
        pageNo += 1
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewPhotos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionUIView.reloadData()
    }
    
    func updateUI(processing: Bool) {
        self.noImageLabel.isHidden = checkPhotoAvailability
        
        collectionUIView.isUserInteractionEnabled = !processing
        if processing {
            newCollectionBarButton.title = ""
            activityIndicatorUIView.startAnimating()
        } else {
            activityIndicatorUIView.stopAnimating()
            newCollectionBarButton.title = "New Collection"
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange didChangeanObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !deleteAll {
            collectionUIView.deleteItems(at: [indexPath])
            return
        }
        
        if type == .update {
            collectionUIView.reloadData()
        }
        
        if let indexPath = indexPath, type == .insert {
            collectionUIView.insertItems(at: [indexPath])
            return
        }
    }
    
    
}
