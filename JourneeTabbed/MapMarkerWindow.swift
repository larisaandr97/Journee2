//
//  MapMarkerWindow.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/25/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit


protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
    func shareVisit(data: NSDictionary)
    func getDirections(data: NSDictionary)
}

class MapMarkerWindow: UIView {
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var notVisitedLabel: UILabel!
    
    @IBOutlet weak var dateVisitedLabel: UILabel!
    
    @IBOutlet weak var addVisitButton: UIButton!
    
    @IBOutlet weak var rate: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var getDirectionsButton: UIButton!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
//    @IBAction func shareVisit(_ sender: Any) {
//          delegate?.shareVisit(data: spotData!)
//    }
    
    @IBAction func getDirections(_ sender: Any) {
        delegate?.getDirections(data: spotData!)
    }
    

    @IBAction func shareVisit(_ sender: Any) {
        delegate?.shareVisit(data: spotData!)
    }
}


