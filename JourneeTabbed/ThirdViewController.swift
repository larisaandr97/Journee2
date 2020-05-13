//
//  ThirdViewController.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/22/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ThirdViewController: UIViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    var ref: DatabaseReference! = Database.database().reference()
    var count : Int = 0
    var firstController = FirstViewController()
    var spotsArray: [DataSnapshot]! = []
    var clickedCell: MyCollectionViewCell = MyCollectionViewCell()
    var clickedCellIndex: Int = 0
    
        override func viewDidLoad() {
            super.viewDidLoad()
            print("Am intrat")
            collectionView.reloadData()
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: 120,height: 120)
            collectionView.collectionViewLayout=layout
            
            let spots = ref.child("spots")
            spots.observe(.value, with: { (snapshot: DataSnapshot!) in
                print("Count: " + String(snapshot.childrenCount))
                self.count = Int(snapshot.childrenCount)
                self.collectionView.reloadData()
            })
            
            spots.observe(.childChanged, with: { (snapshot: DataSnapshot!) in
                print("Child changed in third view controller")
                self.collectionView.reloadData()
                       })
           
            getData()
            
            collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            
         
        }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Third view appeared")
        super.viewWillAppear(animated) // No need for semicolon
        self.collectionView.reloadData()
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
       {
           if segue.destination is SecondViewController
           {
               let vc = segue.destination as? SecondViewController
                vc?.clickedCell = self.clickedCell
                vc?.clicked = true
                vc?.indexClickedCell = self.clickedCellIndex
                vc?.ref=self.ref           }
        
       }
    
    func getRandomColor() -> UIColor {
         //Generate between 0 to 1
         let red:CGFloat = CGFloat(drand48())
         let green:CGFloat = CGFloat(drand48())
         let blue:CGFloat = CGFloat(drand48())

         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    
    func getData()
    {
         let spots = ref.child("spots")
        spots.observe(.childAdded, with: { (snapshot) in
               if snapshot.value as? [String : AnyObject] != nil {
                self.spotsArray.append(snapshot)
            }
        }, withCancel: nil)
    }
        
    }

// MARK:- UICollectionViewDelegate

extension ThirdViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         print("Am apasat pe cel de-al " + String(indexPath.row))
        self.clickedCell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        self.clickedCellIndex = indexPath.row
        performSegue(withIdentifier: "editVisit", sender: nil);
       // print(cell.placeNameLabel.text!)
    }
    
}

// MARK:- DataSource
extension ThirdViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    
  /*  @objc func editVisit(sender: sender){
        print("Am intrat in functie!!!")
       // performSegue(withIdentifier: "secondView", sender: self)
        performSegue(withIdentifier: "addVisit", sender: sender);
        
    }*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
       // cell.delegate = self
        //cell.addTarget(self,action:#selector(editVisit(sender:cell)), for: .touchUpInside)
        
        let spotSnapshot: DataSnapshot! = self.spotsArray[indexPath.row]
        let spot = spotSnapshot.value as! Dictionary<String,Any>
        cell.addressLabel.text = spot["adress"] as? String
        cell.placeNameLabel.text = spot["name"] as? String
        cell.ratingLabel.text = spot["rate"]! as! String  + "/5"
        cell.dateLabel.text = spot["date"] as? String
        cell.backgroundColor = getRandomColor()
        cell.descript = (spot["description"] as? String)!
        if(spot["image"] != nil){
            cell.image = (spot["image"] as? String)!
        }
       cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
       /* print("Name/address" + cell.placeNameLabel.text!  + " / " + cell.addressLabel.text!)
        print("Cell added")*/
        return cell
    }
}


// MARK: DelegateFlowLayout
extension ThirdViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 192)
    }
    
  /*  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}


