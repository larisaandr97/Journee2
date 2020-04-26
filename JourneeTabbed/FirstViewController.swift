//
//  FirstViewController.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/21/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Firebase
import FirebaseDatabase


class FirstViewController: UIViewController ,GMSMapViewDelegate{
    @IBOutlet weak var mapView: GMSMapView!
    private let locationManager=CLLocationManager();
    var ref: DatabaseReference!
    private var infoWindow = MapMarkerWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        ref=Database.database().reference()
        self.infoWindow = loadNiB()
        loadMarkersFromDB()
    
    }
    
    
    func loadNiB() -> MapMarkerWindow {
        let infoWindow = MapMarkerWindow.instanceFromNib() as! MapMarkerWindow
        return infoWindow
    }
    
    
   func loadMarkersFromDB() {
            let spots = ref.child("spots")
            spots.observe(.childAdded, with: { (snapshot) in
                if snapshot.value as? [String : AnyObject] != nil {
                    self.mapView.clear()
                    guard let spot = snapshot.value as? [String : AnyObject] else {
                        return
                    }
                    // Get coordinate values from DB
                    let latitude = spot["latitude"]
                    let longitude = spot["longitude"]
                    //print(latitude)
                    //print(longitude)
                    DispatchQueue.main.async(execute: {
                        let marker = GMSMarker()
                        // Assign custom image for each marker
                       /* let markerImage = self.resizeImage(image: UIImage.init(named: "icons-marker-30")!, newWidth: 30).withRenderingMode(.alwaysTemplate)*/
                        let markerImage = UIImage(named:"icons-marker-48");//!.withRenderingMode(.alwaysTemplate)
                        let markerView = UIImageView(image: markerImage)
                        // Customize color of marker here:
                        //markerView.tintColor = UIColor.green
                        marker.iconView = markerView
                        marker.position = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        marker.map = self.mapView
                        // *IMPORTANT* Assign all the spots data to the marker's userData property
                        marker.userData = spot
                    })
                }
            }, withCancel: nil)
        }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData : NSDictionary?
        if let data = marker.userData! as? NSDictionary {
            markerData = data
        }
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.spotData = markerData
        infoWindow.delegate = self.infoWindow.delegate
        // Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.borderColor = UIColor(named: "19E698")?.cgColor
        infoWindow.addVisitButton.layer.cornerRadius = infoWindow.addVisitButton.frame.height / 2
            
       // let address = markerData!["address"]!
        let name = markerData!["name"]!
        let dateVisited = markerData!["date"]!
        print(name as? String)
        print(dateVisited as? String)
       // infoWindow.addressLabel.text = address as? String
        infoWindow.placeNameLabel.text=name as? String
        infoWindow.dateVisitedLabel.text=dateVisited as? String
       
        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 82
        self.view.addSubview(infoWindow)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - 82
        }
    }
        
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
  
}
// MARK: - CLLocationManagerDelegate
//1
extension FirstViewController: CLLocationManagerDelegate {
  // 2
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // 3
    guard status == .authorizedWhenInUse else {
      return
    }
    // 4
    locationManager.startUpdatingLocation()
      
    //5
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  // 6
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
      
    // 7
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
    // 8
    locationManager.stopUpdatingLocation()
  }
}


