//
//  GalleryViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/2/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import Foundation
import UIKit
import Photos
//import Cloudinary
import Firebase

class GalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    let db = Firestore.firestore()
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.GalleryImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        self.GalleryImageView.isHidden = true
        self.collectionView.isHidden = false
        self.primaryReturn.isHidden = false
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error)
        } else {
            print("saved?")
        }
    }
    
    @IBAction func returnButton(_ sender: Any) {
        self.GalleryImageView.isHidden = true
        self.collectionView.isHidden = false
        self.primaryReturn.isHidden = false
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
//        print(self.GlobalImages.count)
//        print(self.GlobalPkArray.count)
    }
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var uploadButton: UIButton!
    
    @IBOutlet var secondaryReturn: UIButton!
    
    @IBOutlet var primaryReturn: UIButton!
    
    @IBOutlet weak var GalleryImageView: UIImageView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var progressView: UIProgressView!
    
    
    let imagePicker = UIImagePickerController()
    
    var GlobalImages = [UIImage]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var globalNames = [String]()
    var GlobalPkArray = [Int]()
    
    @IBAction @objc internal func UploadButton(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
            
        {
            
            
            DispatchQueue.global(qos: .background).async {
                
                self.uploadImage(image: image)
//
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func getCount() {
        self.GlobalImages = []
        self.GlobalPkArray = []
        let url = URL(string: "http://127.0.0.1:8000/images/")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
//            do{
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Responsekugkugkgk Error")
                    return }
            let backToString = String(data: dataResponse, encoding: .utf8)!
//            print(backToString)
            let temp = backToString.split(separator: "/")
//            print(temp)
            self.GlobalPkArray = []
            for x in temp {
                self.GlobalPkArray.append(Int(x)!)
            }
            print(self.GlobalPkArray)
            self.getAll()
        })
        task.resume()
            
    }
    
    func getAll() {
        
        self.pkIndex = 0
        if self.GlobalPkArray.count > 0 {
            self.getImages(pk: self.GlobalPkArray.first!)
        }
    }
    
    var pkIndex = 0
    
    func getImages(pk:Int) {
        let url = URL(string: "http://127.0.0.1:8000/images/\(pk)/imageGet")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Responsekugkugkgk Error")
                        return }
            print(dataResponse)
            
            self.GlobalImages.append(UIImage(data:dataResponse)!)
            print(pk)
            print(self.GlobalPkArray)
            print(self.GlobalImages.count)
            if self.GlobalPkArray.last == pk {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    print("tried to reload")
                }
            }
            else {
                self.pkIndex += 1
                self.getImages(pk: self.GlobalPkArray[self.pkIndex])
            }
        })
        task.resume()
    }
    
    func getAllImages() {
        db.collection("imageMetadata").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let storage = Storage.storage()
                for document in querySnapshot!.documents {
                    
                    let pathReference = storage.reference(withPath: "images/\(document.documentID).jpg")
                    pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                            // Uh-oh, an error occurred!
                        } else {
                            // Data for "images/island.jpg" is returned
                            let image = UIImage(data: data!)!
                            if self.globalNames.contains(document.documentID) {
                                return
                            }
                            self.globalNames.append(document.documentID)
                            self.GlobalImages.append(image)
                        }
                    }
                    
                }
            }
        }
    }
    
    func uploadImage( image : UIImage ) {
        
        var ref: DocumentReference? = nil
        ref = db.collection("imageMetadata").addDocument(data: [
            "thumbName" : "test"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                let storage = Storage.storage()
                let storageRef = storage.reference().child("images/\(ref!.documentID).jpg")
                //print(image.pngData()!)
                let uploadTask = storageRef.putData(image.jpegData(compressionQuality: 0.1)!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print(error!)
                        return
                    }
                    print(metadata)
                    // Metadata contains file metadata such as size, content-type.
                    //let size = metadata.size
                    //print(size)
                    // You can also access to download URL after upload.
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        print(downloadURL)
                        //self.GlobalImages = []
                        self.getAllImages()
                    }
                }
                
                uploadTask.observe(.progress) { (snapshot) in
                    self.progressView.progress = Float(snapshot.progress!.fractionCompleted)
                }
                uploadTask.resume()
                
            }
        }
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
        
        getAllImages()
        
        //uploadImage(image: UIImage(named: "app1")!)
        
        
        //self.getCount()
        self.progressView.setProgress(0.0, animated: true)
        
        collectionView.dataSource=self
        collectionView.delegate=self
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return GlobalImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as! CollectionViewCell1

        cell.cellImageView.image = GlobalImages[indexPath.row]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        //cell.frame.size.height = CGFloat(spacing)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        self.GalleryImageView.image = self.GlobalImages[indexPath.row]
        
        self.collectionView.isHidden = true
        self.primaryReturn.isHidden = true
        self.secondaryReturn.isHidden = false
        self.GalleryImageView.isHidden = false
        self.uploadButton.isHidden = true
        self.saveButton.isHidden = false
        }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
