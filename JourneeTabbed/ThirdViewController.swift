//
//  ThirdViewController.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/22/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit



class ThirdViewController: UIViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    
  
        override func viewDidLoad() {
            super.viewDidLoad()
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 120,height: 120)
            collectionView.collectionViewLayout=layout
            collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self

            // Do any additional setup after loading the view.
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
       {
           if segue.destination is SecondViewController
           {
               let vc = segue.destination as? SecondViewController
               /*vc?.address = infoWindow.addressLabel.text! as String
               vc?.currentIndex = self.count + 1
               vc?.ref = self.ref
               vc?.lat = self.lat
               vc?.long = self.long*/
           }
       }
    
   

        // make a cell for each cell index path
       /* func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            // get a reference to our storyboard cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell

          //  // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.myLabel.text = self.items[indexPath.item]
            cell.myLabel.text = String(indexPath.item)
            cell.
            cell.backgroundColor = UIColor.cyan // make cell more visible in our example project

            return cell
        }*/

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ThirdViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        print("Am apasat pe cel de-al " + String(indexPath.row))
      //  print("You tapped me")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    
}
extension ThirdViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    
  /*  @objc func editVisit(sender: sender){
        print("Am intrat in functie!!!")
       // performSegue(withIdentifier: "secondView", sender: self)
        performSegue(withIdentifier: "addVisit", sender: sender);
        
    }*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
       // cell.delegate = self
        //cell.configure()
        //cell.addTarget(self,action:#selector(editVisit(sender:cell)), for: .touchUpInside)
       
        cell.addressLabel.text="Adresa mea"
        return cell
    }
}


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


