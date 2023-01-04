//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Semih Mac on 11.12.2022.
//

import UIKit
import CoreData
class DetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var itemPriceTxt: UITextField!
    @IBOutlet weak var itemNameTxt: UITextField!
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemSizeTxt: UITextField!
    
    var selectedName=""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedName != "" {
            saveButton.isHidden=true
            if let uuidString = selectedId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count>0{
                        for result in  results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String {
                                itemNameTxt.text=name
                            }
                            if let price = result.value(forKey: "price") as? Int {
                                itemPriceTxt.text=String(price)
                            }
                            if let size = result.value(forKey: "size") as? String {
                                itemSizeTxt.text=size
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                itemImage.image=image
                            }
                        }
                    }
                    
                }catch{
                    let error = error as NSError
                    fatalError(error.localizedDescription)
                }
            }
            
        }
        else{
            saveButton.isHidden=false
            saveButton.isEnabled=false
            itemPriceTxt.text=""
            itemNameTxt.text=""
            itemPriceTxt.text=""
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gesture)
        
        itemImage.isUserInteractionEnabled=true
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        itemImage.addGestureRecognizer(imageGesture)
    }
    @objc func closeKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func selectImage()  {
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .photoLibrary
        picker.allowsEditing=true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        saveButton.isEnabled=true
        itemImage.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }

    @IBAction func saveItem(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        let item = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        item.setValue(itemNameTxt.text, forKey: "name")
        item.setValue(itemSizeTxt.text, forKey: "size")
        
        if let itemprice = Int(itemPriceTxt.text!) {
            item.setValue(itemprice, forKey: "price")
        }
        item.setValue(UUID(), forKey: "id")
        if itemImage.image == nil {
            showAlert(title: "Error", message: "Please Select Image")
        }
        else{
            let imageData = itemImage.image!.jpegData(compressionQuality: 0.5)
            item.setValue(imageData, forKey: "image")
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                showAlert(title: "Error on Save", message: (nserror.localizedDescription))
            }
            NotificationCenter.default.post(name: NSNotification.Name("itemSaved"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func showAlert(title : String, message : String) {

            // create the alert
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    
}
