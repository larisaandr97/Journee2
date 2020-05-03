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
    var markerAdded = GMSMarker()
    var saved = false
    lazy var count : Int = 0
    var lat: Double=0
    var long: Double=0
    //var delegate: MapMarkerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
       ref=Database.database().reference()
      print(String(count))
        loadMarkersFromDB()
        self.infoWindow = loadNiB()
        mapView.delegate=self
      /*  if saved == true {
            showToast(message: "Saved!", font: UIFont(name: "Times New Roman", size: 19.0)!)
            print("Salvat!")
        }
        saved = false*/
       
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SecondViewController
        {
            let vc = segue.destination as? SecondViewController
            vc?.address = infoWindow.addressLabel.text! as String
            vc?.currentIndex = self.count + 1
            vc?.ref = self.ref
            vc?.lat = self.lat
            vc?.long = self.long
        }
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
                    let latitude = spot["latitude"] as! Double
                    let longitude = spot["longitude"] as! Double
                    /*print("Latitude: " + (latitude as! String))
                    print("Longitude: " + (longitude as! String))*/
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
                        self.count+=1
                    })
                }
            }, withCancel: nil)
        }
    
    @objc func addVisit(sender: UIButton){
        print("Am intrat in functie!!!")
       // performSegue(withIdentifier: "secondView", sender: self)
        performSegue(withIdentifier: "addVisit", sender: sender);
        
    }

    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        var hasData = true
        var markerData : NSDictionary?
        if marker.userData == nil {
            print("NU AM DATE")
           // return false
            hasData = false
        }
        if hasData==true{
        if let data = marker.userData! as? NSDictionary {
            markerData = data
            }
        }
       
        //print("Am ajuns aici!")
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        // Pass the spot data to the info window, and set its delegate to self
        if hasData==true{
            infoWindow.spotData = markerData
            
        }
      //  infoWindow.setDelegate(self, mapDelegate: self)
       // infoWindow.delegate = self as? MapMarkerDelegate
        
        // Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.borderColor = UIColor(named: "19E698")?.cgColor
        infoWindow.addVisitButton.layer.cornerRadius = infoWindow.addVisitButton.frame.height / 2
            
       // let address = markerData!["address"]!
        if hasData==true
        {
            let name = markerData!["name"]!
            let dateVisited = markerData!["date"]!
            let rate = markerData!["rate"]!
            infoWindow.placeNameLabel.text=name as? String
            infoWindow.dateVisitedLabel.text=dateVisited as? String
            infoWindow.rate.text = (rate as! String) + "/5"
            infoWindow.notVisitedLabel.isHidden = true;
            infoWindow.addVisitButton.isHidden = true
            
            //inca nu merge
            if(markerData?["image"] != nil){
            let image = UIImage(contentsOfFile: markerData?["image"] as! String)
            print(markerData?["image"] as! String)
            infoWindow.imageView.image=image
            }
            let geocoder = GMSGeocoder()
                let position = CLLocationCoordinate2DMake(markerData!["latitude"] as! CLLocationDegrees,markerData!["longitude"] as! CLLocationDegrees)
                
            
            geocoder.reverseGeocodeCoordinate(position) { response, error in
                if (response?.firstResult()) != nil {
               var currentAdress = response?.firstResult()?.thoroughfare! as! String
                self.infoWindow.addressLabel.text=currentAdress
                print("Adresa: " + currentAdress)
                }
            }
        }
        else
        {
            let geocoder = GMSGeocoder()
            let position = CLLocationCoordinate2DMake(marker.position.latitude as! CLLocationDegrees,marker.position.longitude as! CLLocationDegrees)
            self.lat = marker.position.latitude
            self.long = marker.position.longitude
            geocoder.reverseGeocodeCoordinate(position) { response, error in
                if (response?.firstResult()) != nil
                {
                   var currentAdress = response?.firstResult()?.thoroughfare! as! String
                    self.infoWindow.addressLabel.text=currentAdress
                    print("Adresa: " + currentAdress)
                }
            }
            infoWindow.placeNameLabel.text="";
            infoWindow.dateVisitedLabel.text="";
            infoWindow.addVisitButton.addTarget(self,action:#selector(addVisit(sender:)), for: .touchUpInside)
        }
        //infoWindow.addressLabel.text=currentAdress as! String
        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 82
        self.view.addSubview(infoWindow)
        print("Info window added")
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
    
       func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
            // Custom logic here
        print("LONG PRESS")
            
            markerAdded.position = coordinate
         let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(markerAdded.position) { response, error in
            if (response?.firstResult()) != nil {
                self.markerAdded.title=response?.firstResult()?.thoroughfare! as! String
              
                  }
              }
           // marker.title = "I added this with a long tap"
            markerAdded.snippet = ""
            markerAdded.map = mapView
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


extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    //UIApplication.shared.keyWindow?.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
