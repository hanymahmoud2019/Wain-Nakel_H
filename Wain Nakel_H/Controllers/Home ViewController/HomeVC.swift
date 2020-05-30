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
    var resturantImages: [String] = []
    
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

            print(resturant?.name ?? "")

            let resturantCoordinates = CLLocationCoordinate2D(latitude: Double((resturant?.lat as NSString? ?? "").doubleValue), longitude: Double((resturant?.lon as NSString? ?? "").doubleValue))
            
            self.titleView_HightConstraints.constant = 160
            
            self.resturantImages = resturant?.image ?? []
            self.lblResturantName.text = resturant?.name ?? ""
            self.lblCategory.text = resturant?.cat ?? ""
            self.lblRate.text = (resturant?.rating ?? "") + "/" + Global.resturantRate
            self.updateRegion(currentLocation: resturantCoordinates)
            
            let annotation = MKPointAnnotation()
            annotation.title = resturant?.name
            annotation.coordinate = resturantCoordinates
            self.map.addAnnotation(annotation)
            self.selectedResturantCoordinates = resturantCoordinates
            
            self.listenForReachability()
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Update Region value on map
    func updateRegion(currentLocation: CLLocationCoordinate2D){
        
        let center = currentLocation
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setVisibleMapRect(self.map.visibleMapRect, edgePadding: UIEdgeInsets(top: 40.0, left: 20.0, bottom: 20, right: 20.0), animated: true)
        self.map.setRegion(region, animated: true)
        
    }
    
    func openResturantLocationInGoogleMap(resturantCoordinates: CLLocationCoordinate2D){
        
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
        
        self.openResturantLocationInGoogleMap(resturantCoordinates: view.annotation!.coordinate)
        
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
