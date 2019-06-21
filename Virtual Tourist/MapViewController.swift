//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 15/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var mapUIView: MKMapView!
    var fetchResultController : NSFetchedResultsController<Pin>!
    
    //    var vContext: NSManagedObjectContext {
    //        return DataController.shared.viewContext
    //    }
    
    
    func loadPins() {
        let fetchRequest : NSFetchRequest<Pin>
        fetchRequest = Pin.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            addMapAnnotations()
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addMapAnnotations() {
        let annotaions = MKPointAnnotation()
        
        guard let pins = fetchResultController.fetchedObjects else {return}

        for pin in pins {
            if mapUIView.annotations.contains(where: { pin.compare(to: $0.coordinate)}) {continue}
            //don't forget to try another way
            annotaions.coordinate = pin.coordinate
            mapUIView.addAnnotation(annotaions)
        }
    }
    
    func  mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchResultController.fetchedObjects?.filter { $0.compare(to: view.annotation!.coordinate)}.first!
        performSegue(withIdentifier: "goToPhotoAlbum", sender: pin)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        addMapAnnotations()
    }
    
    
    @IBAction func longPressGesture(sender: UIGestureRecognizer) {
        if sender.state == .began {
            let locationOnMap =  sender.location(in: mapUIView)
            let coordinate = mapUIView.convert(locationOnMap, toCoordinateFrom: mapUIView)
            let pin = Pin(context: DataController.shared.viewContext)
            pin.coordinate = coordinate
            try? DataController.shared.viewContext.save()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMapAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoAlbum" {
            let photoCollection = segue.destination as! PhotoCollectionVC
            photoCollection.pin = sender as? Pin
        }
    }
    
    
}


