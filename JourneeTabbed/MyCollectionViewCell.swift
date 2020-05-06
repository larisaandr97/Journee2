//
//  MyCollectionViewCell.swift
//  JourneeTabbed
//
//  Created by user169887 on 5/5/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: class {
    // Declare a delegate function holding a reference to `UICollectionViewCell` instance
    func collectionViewCell(_ cell: UICollectionViewCell)
}

class MyCollectionViewCell: UICollectionViewCell {

    weak var delegate: CollectionViewCellDelegate?
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func editVisit(_ sender: Any) {
        delegate?.collectionViewCell(self)
       // print(s)
    }
    
    static func nib()-> UINib{
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    
}


