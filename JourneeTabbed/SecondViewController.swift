//
//  SecondViewController.swift
//  JourneeTabbed
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications
import GoogleSignIn
import FirebaseAuth
import CodableFirebase

class SecondViewController: UIViewController {
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var placeNameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var chosenImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var arrImageViews: [UIImageView] = []
    var intStars = 5
    var intRate: String=""
    var address: String=""
    var ref: DatabaseReference!
    var currentIndex : Int = 0
    var currentImagePath : String=""
    var lat: Double=0
    var long: Double=0
    
    var clickedCell: MyCollectionViewCell = MyCollectionViewCell()
    var clicked : Bool = false
    var indexClickedCell : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adressLabel.text = self.address
        setStarStack()
        if(clicked == true)
        {
            dateField.text = clickedCell.dateLabel.text
            adressLabel.text = clickedCell.addressLabel.text
            placeNameField.text = clickedCell.placeNameLabel.text
            descriptionField.text = clickedCell.descript
            titleLabel.text="Edit visit"
            editStarStack()
            let imageName = placeNameField.text?.replacingOccurrences(of: " ", with: "")
            self.chosenImage.image = getImage(imageName: imageName!)
        }
 
    }
    
    func getDirectoryPath() -> String {
          let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
          let documentsDirectory = paths[0]
          return documentsDirectory
      }
    
    // MARK: - Get Image
    func getImage(imageName : String)-> UIImage{
               let fileManager = FileManager.default
               let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
               if fileManager.fileExists(atPath: imagePath){
                   return UIImage(contentsOfFile: imagePath)!
               }else{
                   print("No Image available")
                   return UIImage.init(named: "placeholder.jpg")! // Return placeholder image here
               }
           }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FirstViewController
        {
            let vc = segue.destination as? FirstViewController
            vc?.saved = true
            vc?.count+=1
        }
    }
    
    // MARK: - Add Notification
    func addNotification(){
           let center = UNUserNotificationCenter.current()
                  center.requestAuthorization(options: [.alert, .sound, .badge]) {
                      (didAllow, error) in
                      if !didAllow {
                          print("User has declined notifications")
                      }
                  }
           
                  let content = UNMutableNotificationContent()
                  content.title = "New visit added!"
                  content.body = "Open to see more details"
                  
                  let date = Date().addingTimeInterval(10)
                  let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                  let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                  let idString = UUID().uuidString
                  let request = UNNotificationRequest(identifier: idString, content: content, trigger: trigger)
                  
                  center.add(request) { (error) in
                      // check errors
                  }
       }
   
    struct SpotModel : Codable {
        let uid: Int
        let name: String
        let date: String
        let address: String
        let description: String
        let rate: String
        let longitude: Double
        let latitude: Double
    }
    
    // MARK: - Save Visit
    @IBAction func saveVisit(_ sender: Any) {
        let name = placeNameField.text! as String
        let userUid =  Auth.auth().currentUser?.uid
        
        if(chosenImage.image != nil){
            saveImage(imageName: name.replacingOccurrences(of: " ", with: ""))
            
        }
    
        let spotObject = SpotModel(uid:currentIndex as Int, name:placeNameField.text! as String, date:dateField.text! as String, address:adressLabel.text! as String, description:descriptionField.text! as String, rate:intRate as String, longitude:long as Double, latitude:lat as Double)
        let data = try! FirebaseEncoder().encode(spotObject)
        
        if (clicked == false){
            Database.database().reference().child("users/\(userUid!)/spots/\(currentIndex)").setValue(data)
        }
        else{
           //Update spot
            Database.database().reference().child("users/\(userUid!)/spots/\(indexClickedCell+1)").updateChildValues(data as! [AnyHashable : Any])
            clicked = false
        }
        addNotification()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelVisit(_ sender: Any) {
          self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        showImagePickerController()
        //showChooseSourceTypeAlertController()
    }
    
    // MARK: - Create Star Stack
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
    
    func editStarStack(){
        let rating = Int (clickedCell.ratingLabel.text!.prefix(1)) ?? 0
        
        arrImageViews.forEach({ (imageView) in
            if (self.arrImageViews.firstIndex(of:imageView)! < rating ){
                 imageView.image = UIImage(named:"icon-star-filled.png")
        }
        else{
                imageView.image=UIImage(named:"icon-star-empty.png")
        }
        })
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
                    intRate=String(intRating)
                    imageView.image = UIImage(named:"icon-star-filled.png")
                }
                else{
                    if(imageView.tag != 5009){
                        imageView.image=UIImage(named:"icon-star-empty.png")
                    }
                }
            })
        }
    }

    // MARK: - Save image
   func saveImage(imageName: String){
      //create an instance of the FileManager
      let fileManager = FileManager.default
      //get the image path
      let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
    self.currentImagePath = imagePath
      //get the image we took with camera
      let image = chosenImage.image!
      //get the PNG data for this image
    let data = image.pngData()
      //store it in the document directory
    fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
   }

}
extension SecondViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   /* func showChooseSourceTypeAlertController() {
        let photoLibraryAction = UIAlertAction(title: "Choose a Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a New Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }*/
    
   // func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
    func showImagePickerController(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
      //  imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.chosenImage.image = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.chosenImage.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
      
        dismiss(animated: true, completion: nil)
    }
}

