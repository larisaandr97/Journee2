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
    lazy var ref: DatabaseReference! = Database.database().reference()
    private var infoWindow = MapMarkerWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var markerAdded = GMSMarker()
    var saved = false
    lazy var count : Int = 0
    var lat: Double=0
    var long: Double=0
    var hasImage: Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spots = ref.child("spots")
        spots.observe(.childChanged, with: { (snapshot: DataSnapshot!) in
                      print("Child changed")
          
                             })
                 
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    
        loadMarkersFromDB()
        self.infoWindow = loadNiB()
        mapView.delegate=self
        
      /*  if saved == true {
            showToast(message: "Saved!", font: UIFont(name: "Times New Roman", size: 19.0)!)
            print("Salvat!")
        }
        saved = false*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
            print("First view appeared")
            super.viewWillAppear(animated) // No need for semicolon
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
        if segue.destination is ThirdViewController
        {
            let vc = segue.destination as? ThirdViewController
            vc?.ref = self.ref
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
                    let latitude = spot["latitude"]
                    let longitude = spot["longitude"]
                
                    DispatchQueue.main.async(execute: {
                        let marker = GMSMarker()
                        // Assign custom image for each marker
                        let markerImage = UIImage(named:"icons-marker-48");//!.withRenderingMode(.alwaysTemplate)
                        let markerView = UIImageView(image: markerImage)
                    
                        marker.iconView = markerView
                        marker.position = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees , longitude: longitude as! CLLocationDegrees )
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
    
    @objc func shareVisit(sender: UIButton){
        print("Share!")
        let shareText = infoWindow.addressLabel.text
      /*  let lati = (infoWindow.spotData!["latitude"] as? String)!
        let longi = (infoWindow.spotData!["longitude"] as? String)!
        let firsthalf = "comgooglemaps://?center=" + lati + "," + longi
        let generalLink = firsthalf + "&zoom=14&views=traffic"
        guard let url = URL(string: generalLink)
        else { return }*/
        /*    let image = UIImage(named: ".png")
            else { return }*/
       
        if(hasImage == true){
             let  imageToShare = infoWindow.imageView.image
            let shareContent: [Any] = [shareText!, imageToShare!]
            let activityController = UIActivityViewController(activityItems: shareContent,
                                                          applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
            
        else{
            let shareContent: [Any] = [shareText!]
            let activityController = UIActivityViewController(activityItems: shareContent,
                                                                     applicationActivities: nil)
            if (UIDevice.current.userInterfaceIdiom == .phone) {
                    self.present(activityController, animated: true, completion: nil)
                       }        }
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(imageName : String)-> UIImage{
            let fileManager = FileManager.default
            let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
            if fileManager.fileExists(atPath: imagePath){
                hasImage = true
                return UIImage(contentsOfFile: imagePath)!
            }else{
                hasImage = false
                print("No Image available")
                return UIImage.init(named: "placeholder.jpg")! // Return placeholder image here
            }
        }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        var hasData = true
        var markerData : NSDictionary?
        if marker.userData == nil {
           // print("NU AM DATE")
            hasData = false
        }
        if hasData==true{
        if let data = marker.userData! as? NSDictionary {
            markerData = data
            }
        }
       
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
            
        if hasData==true
        {
            let name = markerData!["name"]!
            let dateVisited = markerData!["date"]!
            let rate = markerData!["rate"]!
            infoWindow.placeNameLabel.text=name as? String
            infoWindow.dateVisitedLabel.text=dateVisited as? String
            infoWindow.rate.text = (rate as! String) + "/5"
            infoWindow.notVisitedLabel.isHidden = true
            infoWindow.addVisitButton.isHidden = true
           
            // Afisare imagine
            //print("Directory: " + getDirectoryPath())
            let imageName = infoWindow.placeNameLabel.text?.replacingOccurrences(of: " ", with: "")
            infoWindow.imageView.image=getImage(imageName: imageName!)
            
            let geocoder = GMSGeocoder()
            let position = CLLocationCoordinate2DMake(markerData!["latitude"] as! CLLocationDegrees,markerData!["longitude"] as! CLLocationDegrees)
                
            // cautare adresa dupa coordonate
            geocoder.reverseGeocodeCoordinate(position) { response, error in
                if (response?.firstResult()) != nil {
                    let currentAdress = response?.firstResult()?.thoroughfare!
                self.infoWindow.addressLabel.text=currentAdress
                }
            }
            
            infoWindow.shareButton.addTarget(self,action:#selector(shareVisit(sender:)), for: .touchUpInside)
        }
            
        else //Nu exista in baza de date inca
        {
            let geocoder = GMSGeocoder()
            let position = CLLocationCoordinate2DMake(marker.position.latitude ,marker.position.longitude )
            self.lat = marker.position.latitude
            self.long = marker.position.longitude
            geocoder.reverseGeocodeCoordinate(position) { response, error in
                if (response?.firstResult()) != nil
                {
                    let currentAdress = response?.firstResult()?.thoroughfare!
                    self.infoWindow.addressLabel.text=currentAdress
                    print("Adresa: " + currentAdress!)
                }
            }
            infoWindow.placeNameLabel.text="";
            infoWindow.dateVisitedLabel.text="";
            infoWindow.rate.text="";
            infoWindow.shareButton.isHidden = true
            infoWindow.addVisitButton.addTarget(self,action:#selector(addVisit(sender:)), for: .touchUpInside)
        }
        
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
         
        markerAdded.position = coordinate

        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(markerAdded.position) { response, error in
            if (response?.firstResult()) != nil {
                self.markerAdded.title=(response?.firstResult()?.thoroughfare! as! String)
              
                  }
              }
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
