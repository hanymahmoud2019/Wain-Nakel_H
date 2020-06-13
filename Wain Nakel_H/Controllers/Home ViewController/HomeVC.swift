//
//  HomeVC.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/27/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Toast_Swift
import Spring
import SwiftPhotoGallery
import Alamofire
import CoreData

class HomeVC: UIViewController {
    
    //MARK:- OutLets
    @IBOutlet weak var btnSuggest: SpringButton!
    @IBOutlet weak var btnSettings: SpringButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lblResturantName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    @IBOutlet weak var titleView_HightConstraints: NSLayoutConstraint!
    //******************************************

    
    //MARK:- Variables
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var firstLoadtFlag: Bool = true
    var selectedResturantCoordinates = CLLocationCoordinate2D()
    var selectedResturantID: String?
    var resturantImages: [String] = []
    var resturantsArray: [Resturant] = []
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    func listenForReachability() {
        self.reachabilityManager?.listener = { [weak self] status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                self?.lblResturantName.text = "ErrorText".localized
                self?.lblCategory.text = ""
                self?.lblRate.text = ""
                //self?.map.removeAnnotations(self?.map.annotations ?? [])
                //self?.updateRegion(currentLocation: self!.currentLocation)
                self?.view.makeToast("NoNetworkText".localized)
            case .reachable(_):
                print("internet")
            case .unknown:
                print("hany")
            }
        }

        self.reachabilityManager?.startListening()
    }
    
    //******************************************
    
    
    //MARK:- Actions
    @IBAction func btnSuggest_Click(_ sender: UIButton) {
        
        getNewResturantSuggestion()
    }
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        
        self.updateRegion(currentLocation: self.currentLocation)
    }
    
    
    @IBAction func btnGoogleMap_Click(_ sender: UIButton) {
        
        self.openResturantLocationInGoogleMap(resturantCoordinates: selectedResturantCoordinates)
    }
    
    
    @IBAction func btnImages_Click(_ sender: UIButton) {
        
        if resturantImages.count != 0 {
            
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)

            gallery.backgroundColor = UIColor.black
            gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
            gallery.currentPageIndicatorTintColor = UIColor.white
            gallery.hidePageControl = false

            present(gallery, animated: true, completion: nil)
        }
        else {
            
            self.view.makeToast("NoImagesText".localized)
        }
    }
    //******************************************
    
    
    //MARK:- Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLocationManager()
        
        // If the network is unreachable
        listenForReachability()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.animateButtons()
    }
    //******************************************
    

}

//MARK:- Functions
extension HomeVC {
    
    func setupView(){
        
        // To hide Navigation Controller Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //******************************************
        
        // Update UI
        btnSuggest.layer.cornerRadius = 8
        btnSuggest.clipsToBounds = true
        
        btnSettings.layer.cornerRadius = 8
        btnSettings.clipsToBounds = true
        
        titleView_HightConstraints.constant = 90
        //******************************************
        
        lblResturantName.text = ""
        lblCategory.text = ""
        lblRate.text = ""
        //******************************************
        
        map.delegate = self
        //******************************************
        // Localization
        lblCurrentLocation.text = "CurrentLocationText".localized
        btnSuggest.setTitle("SuggestText".localized, for: .normal)
    }
    
    func animateButtons(){
        
        btnSuggest.animation = Spring.AnimationPreset.SqueezeDown.rawValue
        btnSuggest.duration = 1.5
        btnSuggest.animate()
        
        btnSettings.animation = Spring.AnimationPreset.SqueezeDown.rawValue
        btnSettings.duration = 1.5
        btnSettings.animate()
    }
    
    func setupLocationManager(){
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getNewResturantSuggestion() {
        
        GetServices.generateResturant(long: String(currentLocation.longitude), lat: String(currentLocation.latitude))
        { (resturant, error) in

            self.loadSelectedResturant(resturant: resturant ?? Resturant())
            self.addAnnotationForResturantOnMap(resturant: resturant ?? Resturant())
            self.resturantsArray.append(resturant ?? Resturant())
            self.listenForReachability()
        }
    }
    
    func loadSelectedResturant(resturant: Resturant, withZoomIn: Bool = true) {
        
        let resturantCoordinates = CLLocationCoordinate2D(latitude: Double((resturant.lat as NSString? ?? "").doubleValue), longitude: Double((resturant.lon as NSString? ?? "").doubleValue))

        self.titleView_HightConstraints.constant = 160
        self.resturantImages = resturant.image ?? []
        self.lblResturantName.text = resturant.name ?? ""
        self.lblCategory.text = resturant.cat ?? ""
        self.lblRate.text = (resturant.rating ?? "") + "/" + Global.resturantRate
        
        if withZoomIn {
            
            self.updateRegion(currentLocation: resturantCoordinates)
        }
        
        self.selectedResturantID = resturant.id ?? ""
        self.selectedResturantCoordinates = resturantCoordinates
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addAnnotationForResturantOnMap(resturant: Resturant) {
        
        let resturantCoordinates = CLLocationCoordinate2D(latitude: Double((resturant.lat as NSString? ?? "").doubleValue), longitude: Double((resturant.lon as NSString? ?? "").doubleValue))
        
        // ResturantPointAnnotation id a custom class for MKPointAnnotation class to add a proparty -> ResturantID
        let annotation = ResturantPointAnnotation()
        annotation.title = resturant.name
        annotation.ResturantID = resturant.id
        annotation.coordinate = resturantCoordinates
        
        self.map.addAnnotation(annotation)
        self.selectedResturantCoordinates = resturantCoordinates
    }
    
    // Update Region value on map
    func updateRegion(currentLocation: CLLocationCoordinate2D){
        
        let center = currentLocation
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setVisibleMapRect(self.map.visibleMapRect, edgePadding: UIEdgeInsets(top: 40.0, left: 20.0, bottom: 20, right: 20.0), animated: true)
        self.map.setRegion(region, animated: true)
        
    }
    
    func openResturantLocationInGoogleMap(resturantCoordinates: CLLocationCoordinate2D){
        
        if resturantCoordinates.latitude != currentLocation.latitude && resturantCoordinates.longitude != currentLocation.longitude {
        
            let numLat = NSNumber(value: (resturantCoordinates.latitude) as Double)
            let stLat:String = numLat.stringValue
            
            let numLong = NSNumber(value: (resturantCoordinates.longitude) as Double)
            let stLong:String = numLong.stringValue
            
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(stLat),\(stLong)&zoom=14&views=traffic&q=\(stLat),\(stLong)")!, options: [:], completionHandler: nil)
                
            } else {
                
                self.view.makeToast("OpenGoogleMapText".localized)
            }
        }
    }
    
    func applyStateRestoration(resturants: [Resturant]) {
        
        self.firstLoadtFlag = false
        
        for resturant in resturants {
            
            self.addAnnotationForResturantOnMap(resturant: resturant)
            
            if selectedResturantID == resturant.id {
                
                self.loadSelectedResturant(resturant: resturant)
            }
        }
    }
}

//MARK:- CLLocationManagerDelegate Delegate Methods
extension HomeVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.currentLocation = locValue
        
        if self.firstLoadtFlag {
            
            self.updateRegion(currentLocation: locValue)
            self.getNewResturantSuggestion()
        }
        
        self.firstLoadtFlag = false
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: map)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
}

//MARK:- MKMapViewDelegate Delgate Methods
extension HomeVC : MKMapViewDelegate{
    
    // open Resturant location on google map if installed
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let pointAnnotation = view.annotation as? ResturantPointAnnotation
        let selectedResturant = self.resturantsArray.first(where: {$0.id == pointAnnotation?.ResturantID ?? ""})
        self.loadSelectedResturant(resturant: selectedResturant ?? Resturant(), withZoomIn: false)
        //self.openResturantLocationInGoogleMap(resturantCoordinates: view.annotation!.coordinate)
        
    }
    
    
    // Add Image to map annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

//        let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//
//        if annotation.coordinate.latitude != currentLocation.latitude && annotation.coordinate.longitude != currentLocation.longitude {
//
//            pin.image = #imageLiteral(resourceName: "locationpin")
//            return pin
//        }
//        else {
//
//            return nil
//        }
        return nil
    }
}

//MARK:- SwiftPhotoGalleryDataSource Methods
extension HomeVC: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return resturantImages.count
    }

    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        
        var img = UIImage()
        // convertToURL => i extend String by adding this method in global file
        let url = resturantImages[forIndex].convertToURL()
        if let data = try? Data(contentsOf: url!)
        {
            img = UIImage(data: data)!
        }
        return img
    }

    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK:- State Restoration
//UIStateRestoring Delegate Methods
extension HomeVC {
    
    /*
        - This method to encode ID of the selected resturant
        - Delete all data saved in Restaurant entity in core data
        - save new suggested resturants in Restaurant entity in core data
    */
    override func encodeRestorableState(with coder: NSCoder) {
        
        if let selectedResturantID = self.selectedResturantID {
            
            if self.resturantsArray.count != 0 {
                
                self.deleteAllResturantsFromCoreData()
                self.saveResturantsInCoreData(resturantArray: self.resturantsArray)
            }
            
            coder.encode(selectedResturantID, forKey: Global.selectedResturantID)
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    
    /*
        - This method to decode saved ID of the selected Resturant
        - Get all data saved in Restaurant entity in core data
    */
    override func decodeRestorableState(with coder: NSCoder) {
    
        self.getResturantsFromCoreData()
        self.selectedResturantID = coder.decodeObject(forKey: Global.selectedResturantID) as? String ?? ""
        self.applyStateRestoration(resturants: self.resturantsArray)
    }
}


//MARK:- Core Data
extension HomeVC {
    
    func saveResturantsInCoreData(resturantArray: [Resturant]) {
        
        for resturant in resturantArray {
            
            // 1
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2
            let entity = NSEntityDescription.entity(forEntityName: CoreDataEntities.Resturant.rawValue, in: managedContext)!
            let _Resturant = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // 3
            // Resturant_Entity is enum defined in separated file "Global" in AppFiles
            _Resturant.setValue(resturant.id, forKeyPath: Resturant_Entity.ID.rawValue)
            _Resturant.setValue(resturant.name, forKeyPath: Resturant_Entity.Name.rawValue)
            _Resturant.setValue(resturant.cat, forKeyPath: Resturant_Entity.Category.rawValue)
            _Resturant.setValue(resturant.catID, forKeyPath: Resturant_Entity.CategoryID.rawValue)
            _Resturant.setValue(resturant.lat, forKeyPath: Resturant_Entity.Latitude.rawValue)
            _Resturant.setValue(resturant.lon, forKeyPath: Resturant_Entity.Longitude.rawValue)
            _Resturant.setValue(resturant.ulat, forKeyPath: Resturant_Entity.ULatitude.rawValue)
            _Resturant.setValue(resturant.ulon, forKeyPath: Resturant_Entity.ULongitude.rawValue)
            _Resturant.setValue(resturant.rating, forKeyPath: Resturant_Entity.Rating.rawValue)
            _Resturant.setValue(resturant.link, forKeyPath: Resturant_Entity.Link.rawValue)
            _Resturant.setValue(resturant.openResturant, forKeyPath: Resturant_Entity.OpenResturant.rawValue)
            _Resturant.setValue(resturant.error, forKeyPath: Resturant_Entity.Error.rawValue)
            _Resturant.setValue(resturant.image, forKeyPath: Resturant_Entity.Images.rawValue)
            
            // 4
            do {
                
              try managedContext.save()
            } catch let error as NSError {
                
              print("Could not save. \(error), \(error.userInfo)")
                self.view.makeToast("ErrorSave".localized)
            }
        }
    }
    
    
    func getResturantsFromCoreData() {
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.Resturant.rawValue)
        
        //3
        do {
            
            var fetchedResturants: [NSManagedObject] = []
            fetchedResturants = try managedContext.fetch(fetchRequest)
            self.resturantsArray.removeAll()
            
            for item in fetchedResturants {
                
                // Resturant_Entity is enum defined in separated file "Global" in AppFiles
                var resturantObject = Resturant()
                resturantObject.id = item.value(forKeyPath: Resturant_Entity.ID.rawValue) as? String
                resturantObject.name = item.value(forKeyPath: Resturant_Entity.Name.rawValue) as? String
                resturantObject.cat = item.value(forKeyPath: Resturant_Entity.Category.rawValue) as? String
                resturantObject.catID = item.value(forKeyPath: Resturant_Entity.CategoryID.rawValue) as? String
                resturantObject.lat = item.value(forKeyPath: Resturant_Entity.Latitude.rawValue) as? String
                resturantObject.lon = item.value(forKeyPath: Resturant_Entity.Longitude.rawValue) as? String
                resturantObject.ulat = item.value(forKeyPath: Resturant_Entity.ULatitude.rawValue) as? String
                resturantObject.ulon = item.value(forKeyPath: Resturant_Entity.ULongitude.rawValue) as? String
                resturantObject.rating = item.value(forKeyPath: Resturant_Entity.Rating.rawValue) as? String
                resturantObject.link = item.value(forKeyPath: Resturant_Entity.Link.rawValue) as? String
                resturantObject.openResturant = item.value(forKeyPath: Resturant_Entity.OpenResturant.rawValue) as? String
                resturantObject.error = item.value(forKeyPath: Resturant_Entity.Error.rawValue) as? String
                resturantObject.image = item.value(forKeyPath: Resturant_Entity.Images.rawValue) as? [String]
                
                self.resturantsArray.append(resturantObject)
                print(resturantObject)
            }
            
        } catch let error as NSError {
          
            print("Could not fetch. \(error), \(error.userInfo)")
            self.view.makeToast("ErrorFetch".localized)
        }
    }
    
    
    func deleteAllResturantsFromCoreData() {
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntities.Resturant.rawValue)
        let fetchRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        //3
        do {
            
            let result = try managedContext.execute(fetchRequest)
            print(result)
        
        } catch let error as NSError {
          
            print("Could not fetch. \(error), \(error.userInfo)")
            self.view.makeToast("ErrorDelete".localized)
        }
    }
    
}
