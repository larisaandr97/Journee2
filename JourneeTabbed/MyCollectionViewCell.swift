//
//  MyCollectionViewCell.swift
//  JourneeTabbed
//
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
    
    var image: String = ""
    var descript: String = ""
    
    
    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func editVisit(_ sender: Any) {
        delegate?.collectionViewCell(self)
    }
    
    static func nib()-> UINib{
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
}


