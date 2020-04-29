//
//  SecondViewController.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/21/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var adressLabel: UILabel!
    
    @IBOutlet weak var placeNameField: UITextField!
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var chosenImage: UIImageView!
    
    var arrImageViews: [UIImageView] = []
    var intStars = 5
    var intRate: Int = 0
    var address: String="";
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        adressLabel.text = address
        setStarStack()
    }
    
    @IBAction func chooseImage(_ sender: Any) {
      //  showImagePickerController()
    }
    func setStarStack(){
        starStackView.axis = NSLayoutConstraint.Axis.horizontal
        starStackView.distribution = .fillEqually
        starStackView.alignment = .fill
        starStackView.spacing = 20
        starStackView.tag = 5007
        for i in 0..<intStars{
            let imageView=UIImageView()
            if(i==0){
                imageView.tag = 5009
            }
            imageView.image = UIImage(named:"icon-star-empty.png")
            starStackView.addArrangedSubview(imageView)
            arrImageViews.append(imageView)
        }
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        placeNameField.resignFirstResponder()
        dateField.resignFirstResponder()
        descriptionField.resignFirstResponder()
        handleTouchAtLocation(withTouches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        handleTouchAtLocation(withTouches: touches)
    }
    
    func handleTouchAtLocation(withTouches touches:Set<UITouch>){
        let touchLocation = touches.first
        let location = touchLocation?.location(in:starStackView)
        if(touchLocation?.view?.tag == 5007){
            var intRating:Int = 0
            arrImageViews.forEach({ (imageView) in
                if ((location?.x)! > imageView.frame.origin.x){
                    let i = arrImageViews.firstIndex(of:imageView)
                    intRating = i! + 1;
                    intRate=Int(intRating)
                    imageView.image = UIImage(named:"icon-star-filled.png")
                }
                else{
                    if(imageView.tag != 5009){
                        imageView.image=UIImage(named:"icon-star-empty.png")
                    }
                }
            })
        }
        print(String(intRate))
    }

   

}
extension SecondViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerControllerActionSheet(){
        
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated:true, completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            chosenImage.image = editedImage
            
        } else  if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            chosenImage.image = originalImage
            
        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

