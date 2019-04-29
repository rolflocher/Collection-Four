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
import Firebase

class GalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    let db = Firestore.firestore()
    var currentID = ""
    var currentIndex = 0
    
    @IBOutlet var deleteButton: UIButton!
    
    @IBAction func deleteTapped(_ sender: Any) {
        
        db.collection("imageMetadata").document(currentID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
        GlobalImages.remove(at: currentIndex)
        self.globalNames.remove(at: self.currentIndex)
        
        UIView.animate(withDuration: 1, animations: {
            self.collectionView.cellForItem(at: IndexPath.init(row: self.currentIndex, section: 0))?.alpha = 0
        }) { (result) in
            self.collectionView.deleteItems(at: [IndexPath.init(row: self.currentIndex, section: 0)])
        }
        
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let imageRef = storageRef.child("images/\(currentID).jpg")
//        imageRef.delete { error in
//            if let error = error {
//                print(error)
//            } else {
//                print("deleted image \(self.currentID)")
//            }
//        }
        
//        let imagePath = documentsPath.appendingPathComponent(self.currentID)
//        guard fileManager.fileExists(atPath: imagePath.path) else {
//            print("Image does not exist at path: \(imagePath)")
//            return
//        }
//        do {
//            try fileManager.removeItem(at: imagePath)
//            print("\(self.currentID) was deleted.")
//        } catch let error as NSError {
//            print("Could not delete \(self.currentID): \(error)")
//        }
        
        hideFullImage()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.GalleryImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        hideFullImage()
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            print("saved?")
        }
    }
    
    func hideFullImage () {
        self.deleteButton.isHidden = true
        self.GalleryImageView.isHidden = true
        self.collectionView.isHidden = false
        self.primaryReturn.isHidden = false
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
        self.progressView.isHidden = false
    }
    
    @IBAction func returnButton(_ sender: Any) {
        hideFullImage()
    }
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var uploadButton: UIButton!
    
    @IBOutlet var secondaryReturn: UIButton!
    
    @IBOutlet var primaryReturn: UIButton!
    
    @IBOutlet weak var GalleryImageView: UIImageView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var progressView: UIProgressView!
    
    
    let imagePicker = UIImagePickerController()
    
    var GlobalImages = [UIImage]()
    var globalNames = [String]()
    
    @IBAction @objc internal func UploadButton(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    var isUploading = false
    var isDeleting = false
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.isUploading = true
            DispatchQueue.global(qos: .background).async {
                self.uploadImage(image: image)
            }
            self.GlobalImages.append(image)
            let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.collectionView.insertItems(at: [indexPath])
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    //let fileManager = FileManager.default
    //let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func downloadMult(idList: [String], count: Int) {
        
        if count == idList.count {
            self.globalNames = idList
            return
        }
        
        if !self.globalNames.isEmpty && self.globalNames.contains(idList[count]) {
            downloadMult(idList: idList, count: count+1)
            return
        }
        print("trying index \(count)")
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "thumbnails/\(idList[count]).jpg")
        
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)!
                print(Float(count))
                self.progressView.setProgress(Float((count+1)/idList.count), animated: true)
                
                self.GlobalImages.append(image)
                let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
                self.collectionView.insertItems(at: [indexPath])
                
                self.downloadMult(idList: idList, count: count+1)
            }
        }
    }
    
    func deleteOldRecords(id: String, index : Int) {
        
        GlobalImages.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath.init(row: index, section: 0)])
//        UIView.animate(withDuration: 1, animations: {
//            self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))?.alpha = 0
//        }) { (result) in
//            self.collectionView.deleteItems(at: [IndexPath.init(row: index, section: 0)])
//            self.isDeleting = false
//        }
        
    }
    
    var isFirstLoad = true
    
    func getAllImages() {
        
        db.collection("imageMetadata").order(by: "timestamp", descending: false).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.progressView.setProgress(0.0, animated: false)
            
            var IDList = [String]()
            for document in documents {
                if document.data()["thumbName"] != nil {
                    return
                }
                //print(document.data())
                if !(document.data()["finishedUploading"] as! Bool) {
                    return
                }
                IDList.append(document.documentID)
            }
            
            var count = self.globalNames.count-1
            for name in self.globalNames.reversed() {
                if !IDList.contains(name) {
                    self.deleteOldRecords(id: name, index: count)
                }
                count -= 1
            }
            
            self.globalNames.removeAll(where: {!IDList.contains($0)})
            
            self.downloadMult(idList: IDList, count: 0)
            
//            for document in IDList {
//                progress+=1
//                if self.globalNames.contains(document) {
//                    continue
//                }
//
                //let pathReference = storage.reference(withPath: "thumbnails/\(document).jpg")
                
//                if true {//self.isFirstLoad {
//
//                    pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            let image = UIImage(data: data!)!
//
//                            self.progressView.setProgress(progress/Float(querySnapshot!.documents.count), animated: true)
//
//                            //self.globalNames.append(document)
////                            if self.isDeleting {
////                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
////                                    self.GlobalImages.append(image)
////                                    let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
////                                    self.collectionView.insertItems(at: [indexPath])
////                                })
////                            }
//
//                            self.GlobalImages.append(image)
//                            let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
//                            self.collectionView.insertItems(at: [indexPath])
//
//                        }
//                    }
//                }
//                else {
//                    DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
//                        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                            if let error = error {
//                                print(error)
//                                self.getAllImages()
//                            } else {
//                                let image = UIImage(data: data!)!
//
//                                do {
//                                    let filePath = self.documentsPath.appendingPathComponent(document)
//                                    try data!.write(to: filePath)
//                                    print("\(document) was saved.")
//                                } catch let error as NSError {
//                                    print("\(document) could not be saved: \(error)")
//                                }
//
//                                self.progressView.setProgress(progress/Float(querySnapshot!.documents.count), animated: true)
//
//                                //self.globalNames.append(document)
//                                if self.isDeleting {
//                                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//                                        self.GlobalImages.append(image)
//                                        let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
//                                        self.collectionView.insertItems(at: [indexPath])
//                                    })
//                                }
//                                else {
//                                    self.GlobalImages.append(image)
//                                    let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
//                                    self.collectionView.insertItems(at: [indexPath])
//                                }
//                            }
//                        }
//                    })
//                }
//
            //}
//            self.isFirstLoad = false
            
            //UserDefaults.standard.setValue(self.globalNames, forKey: "imageNames")
        }
        
//
//        db.collection("imageMetadata").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//
//
//                self.progressView.setProgress(0.0, animated: true)
//                var progress : Float = 0
//
//                var IDList = [String]()
//                for document in querySnapshot!.documents {
//                    IDList.append(document.documentID)
//                }
//
//                var count = 0
//                var deletions = 0
//                for name in self.globalNames {
//
//                    if !IDList.contains(name) {
//
//                        self.deleteOldRecords(id: name, index: count, deletions: deletions)
//                        deletions += 1
//                    }
//                    count += 1
//                }
//
//                self.globalNames.removeAll(where: {!IDList.contains($0)})
//
//                let storage = Storage.storage()
//
//                for document in IDList {
//                    progress+=1
//                    if self.globalNames.contains(document) {
//                        continue
//                    }
//                    else {
//                        //self.globalNames.append(document)
//                    }
//
//                    let pathReference = storage.reference(withPath: "thumbnails/\(document).jpg")
//
//                    pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            let image = UIImage(data: data!)!
//
//                            do {
//                                let filePath = self.documentsPath.appendingPathComponent(document)
//
//                                try data!.write(to: filePath)
//
//                                print("\(document) was saved.")
//
//                            } catch let error as NSError {
//                                print("\(document) could not be saved: \(error)")
//
//                            }
//
//                            self.progressView.setProgress(progress/Float(querySnapshot!.documents.count), animated: true)
//
//                            //self.globalNames.append(document)
//                            if self.isDeleting {
//                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//                                    self.GlobalImages.append(image)
//                                    let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
//                                    self.collectionView.insertItems(at: [indexPath])
//                                })
//                            }
//                            else {
//                                self.GlobalImages.append(image)
//                                let indexPath = IndexPath.init(row: self.GlobalImages.count-1, section: 0)
//                                self.collectionView.insertItems(at: [indexPath])
//                            }
//
//
////                            if Int(progress) == querySnapshot!.documents.count {
////                                UserDefaults.standard.setValue(self.globalNames, forKey: "imageNames")
////                            }
//                        }
//                    }
//                }
//                self.globalNames = IDList
//                UserDefaults.standard.setValue(self.globalNames, forKey: "imageNames")
//            }
        
    }

    
    func uploadImage( image : UIImage ) {
        self.isFirstLoad = true
        var ref: DocumentReference? = nil
        ref = db.collection("imageMetadata").addDocument(data: [
            "timestamp" : Int(Date.timeIntervalSinceReferenceDate),
            "finishedUploading" : false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                //self.GlobalImages.removeLast()
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.globalNames.append(ref!.documentID)
                
                let storage = Storage.storage()
                let thumbRef = storage.reference().child("thumbnails/\(ref!.documentID).jpg")
                let thumb = image.jpegData(compressionQuality: 0.05)!
                let uploadTask1 = thumbRef.putData(thumb, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        print(error!)
                        return
                    }
                    self.db.collection("imageMetadata").document(ref!.documentID).setData([
                        "timestamp" : Int(Date.timeIntervalSinceReferenceDate),
                        "finishedUploading" : true
                        ])
                }
                self.progressView.setProgress(0.0, animated: false)
                uploadTask1.observe(.progress) { (snapshot) in
                    self.progressView.setProgress(Float(snapshot.progress!.fractionCompleted), animated: true)
                }
                uploadTask1.observe(.success, handler: { (snapshot) in
                    self.progressView.setProgress(1, animated: true)
                })
                uploadTask1.resume()
            }
        }
    }
    
//    func hasPreviousImages(){
//        UserDefaults.standard.setValue([], forKey: "imageNames")
//        if let nameArray = UserDefaults.standard.value(forKey: "imageNames") as? [String] {
//            self.globalNames = nameArray
//        }
//        var count = 0
//        for name in globalNames {
//            let imagePath = documentsPath.appendingPathComponent(name).path
//            guard fileManager.fileExists(atPath: imagePath) else {
//                print("Image does not exist at path: \(imagePath)")
//                return
//            }
//            if let imageData = UIImage(contentsOfFile: imagePath) {
//                self.GlobalImages.append(imageData)
//                if count == globalNames.count-1 {
//
//                }
//            } else {
//                print("UIImage could not be created.")
//            }
//            count += 1
//        }
//        self.collectionView.reloadData()
//
//        getAllImages()
//    }
    
    var numCells = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
        self.deleteButton.isHidden = true
        
        //UserDefaults.standard.setValue([], forKey: "imageNames")
        
        self.progressView.setProgress(0.0, animated: false)
        
        collectionView.dataSource=self
        collectionView.delegate=self
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
        
        getAllImages()
        //hasPreviousImages()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        cell.alpha = 0
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.GalleryImageView.image = self.GlobalImages[indexPath.row]
        self.currentID = self.globalNames[indexPath.row]
        self.currentIndex = indexPath.row
        self.collectionView.isHidden = true
        self.primaryReturn.isHidden = true
        self.secondaryReturn.isHidden = false
        self.GalleryImageView.isHidden = false
        self.uploadButton.isHidden = true
        self.saveButton.isHidden = false
        self.deleteButton.isHidden = false
        self.progressView.isHidden = true
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
