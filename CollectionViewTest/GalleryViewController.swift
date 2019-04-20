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
import Cloudinary

class GalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    
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
    
    var GlobalImages = [UIImage]()
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
                let imageData:Data = image.jpegData(compressionQuality: 1)! as Data
                let config = CLDConfiguration(cloudName: "andreabucket", apiKey: "579189372131841")
                let cloudinary = CLDCloudinary(configuration: config)
                var url = String()
                //cloudinary.createUrl().
                //cloudinary.createManagementApi().
                
                cloudinary.createUploader().upload(data: imageData, uploadPreset: "r2o7mvsx", progress: { (progress0) in
                    self.progressView.setProgress(Float(progress0.fractionCompleted), animated: true)
                }) { result, error in
                    url = result!.url!
                    print (result?.tags)
                    self.progressView.setProgress(0.0, animated: false)
                    cloudinary.createDownloader().fetchImage(url, { (progress1) in
                        self.progressView.setProgress(Float(progress1.fractionCompleted), animated: true)
                    }, completionHandler: { (image, error) in
                        
                        self.GlobalImages.append(image!)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.progressView.setProgress(0.0, animated: false)
                        }
                        
                    })
                    
                }
                
                
//                DispatchQueue.main.async {
//                    self.GalleryImageView.image = UIImage(data:imageData)
//                }
//                let backToString = String(data: imageData, encoding: .ascii)
//                print(backToString!)
//                let strBase64 = imageData.base64EncodedString()
//                let format4 = strBase64.data(using: .utf8)
//                print(strBase64)
//                print("stop\n\n\n")
//                print(format4 as Any)
//                print("stop12\n\n\n")
                //let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters) as String
                //let temp1 = (strBase64).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                //let temp1 = "testfromSwift"
                let temp = "http://res.cloudinary.com/andreabucket/image/list/logos.json"
                
                print(temp.count)
                let url0 = URL(string: temp)!
                var request = URLRequest(url:url0)
                request.httpMethod = "POST"
                request.httpBody = imageData
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                    print(response)
                self.getCount()
                })
                task.resume()
//
            }
            dismiss(animated: true, completion: nil)
        }
    }
        //checkPhotoPermission {
        //if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            //imagePicker.delegate = self //as UIImagePickerControllerDelegate & UINavigationControllerDelegate
             //as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            
            //self.imagePicker.allowsEditing = false
            //self.imagePicker.modalPresentationStyle = .popover
            //let ppc = self.imagePicker.popoverPresentationController
            //ppc?.barButtonItem = sender as? UIBarButtonItem
            //self.present(self.imagePicker, animated: true, completion: nil)
        //}
        //}
    
    
//    func checkPhotoPermission(hanler: @escaping () -> Void) {
//        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
//        switch photoAuthorizationStatus {
//        case .authorized:
//            // Access is already granted by user
//            hanler()
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization { (newStatus) in
//                if newStatus == PHAuthorizationStatus.authorized {
//                    // Access is granted by user
//                    hanler()
//                }
//            }
//        default:
//            print("Error: no access to photo album.")
//        }
//    }
    
//    @objc internal func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let image = info[UIImagePickerControllerEditedImage] as? UIImage
//        print(image as Any)
//
//
//
//        DispatchQueue.main.async{
//            print("we made it")
//            self.GalleryImageView.image = image
//        }
//
//        self.dismiss(animated: true, completion: { () -> Void in
//
//        })
//    }
    
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
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
            self.getAll()
//                let jsonResponse = try JSONSerialization.jsonObject(with:
//                    dataResponse, options: [])
//                print(jsonResponse)

                
//            } catch let parsingError {
//                print("5Error", parsingError)
//            }

        })
        task.resume()
            
    }
    
    func getAll() {
        
//        for x in GlobalPkArray {
//            self.getImages(pk:x)
//        }
        self.pkIndex = 0
        if self.GlobalPkArray.count > 0 {
            self.getImages(pk: self.GlobalPkArray.first!)
        }
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
        
    }
    
    var pkIndex = 0
    
    func getImages(pk:Int) {
        let url = URL(string: "http://127.0.0.1:8000/images/\(pk)/imageGet")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
//            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Responsekugkugkgk Error")
                        return }
            print(dataResponse)
//                let jsonResponse = try JSONSerialization.jsonObject(with:
//                    dataResponse, options: [])
//                print(jsonResponse)
//                //let temp = try 1
//                //print(dataResponse)
////                let backToString = String(data: dataResponse, encoding: .utf8)!
////                print(backToString)
//
//
//                guard let format1 = jsonResponse as? [[String:Any]] else {
//                    print("fail")
//                    return
//                }
//                let format2 = format1[0]["fields"] as! [String:Any]
//                let format3 = format2["photo"] as! String
//
//
//
//                let format4 = format3.data(using: .utf8)
//
//                print(format4)
//
//
//                //var message : String = ""
////                for x in 0..<jsonArray.count {
////                    let format1 = jsonArray[x]["fields"] as! [String:Any]
////                    message += format1["note_text"] as! String + "\n\n"
////                }
//                print(format2)
//                print(format3)
                //print(format4)
//            let dataDecoded : Data? = Data(base64Encoded: backToString, options: .ignoreUnknownCharacters)
//            print(dataDecoded)
                //let formatFinal = message.replacingOccurrences(of: "+", with: " ")
                //let formatFinal2 = formatFinal.replacingOccurrences(of: "%0A", with: "\n")
//                let format1 = jsonArray[0]["fields"] as! [String:Any]
//                let message = format1["photo"] as! String
//                let format4: Data = format3.data(using: .ascii)!
//                let format5: Data = format3.data(using: .utf8)!
//                let format6: Data = format3.data(using: .utf16)!
//                print(format4)
//                print(format5)
//                print(format6)
                 //body += String(data: mediaPath, encoding: .utf8)!
                
                
                
                //THIS ONE
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
//            print(self.GlobalImages.count)
//            if self.GlobalImages.count == self.GlobalPkArray.count {
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//            else {
//                print("wtf man")
//                sleep(1)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//
//            }
//                DispatchQueue.main.async (execute: { () -> Void in
//                    print(dataResponse)
//                    print("^this")
//                    self.GalleryImageView!.image = UIImage(data:dataResponse)!
//                })
            
                
                
                
//                let dataDecoded : Data = Data(base64Encoded: jsonResponse, options: .ignoreUnknownCharacters)!
//                let decodedimage = UIImage(data: dataDecoded)
//                DispatchQueue.main.async {
//                    self.GalleryImageView.image = UIImage(data:format4!)!
//                }
                
                
//                DispatchQueue.main.async (execute: { () -> Void in
//                    self.GalleryImageView.image = formatFinal2
//                })
                
//            } catch let parsingError {
//                print("5Error", parsingError)
//            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.secondaryReturn.isHidden = true
        self.uploadButton.isHidden = false
        self.saveButton.isHidden = true
        self.getCount()
        self.progressView.setProgress(0.0, animated: true)
        
        collectionView.dataSource=self
        collectionView.delegate=self
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
        //self.getImages()
        
//        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
//            switch status{
//            case .denied:
//                break
//            case .authorized:
//                break
//            default:
//                break
//            }
//        })

        // Do any additional setup after loading the view.
        
        //self.loadGallery()
        
        
        
    } //https://imgur.com/a/0jAaDyj
    
//    func loadGallery() {
//        let reqUrl = URL(string: "https://api.imgur.com/3/image/fjYPXKK")
//        let request = NSMutableURLRequest(url: reqUrl!)
//        let clientId = "845b92ab5e0878a"
//        request.httpMethod = "GET"
//        request.addValue("Client-ID " + clientId, forHTTPHeaderField: "Authorization")
//        print(request as Any)
//
//        let semaphore = DispatchSemaphore.init(value: 0)
//        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
//            guard let data = data, error == nil else {
//                print("!! oops: \(String(describing: error))")
//                exit(1)
//            }
//
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("!! unexpected response: \(String(describing: response))")
//                exit(1)
//            }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data)
//                // lol idgaf
//                let link = (((json as! [String: Any])["data"] as! [String: Any])["link"]! as! String).replacingOccurrences(of: "http://", with: "https://")
//
//                print(link)
//                print(json as Any)
//
//            } catch let error as NSError {
//                print("!! oops: \(error)")
//                exit(1)
//            }
//
//            semaphore.signal()
//        }
//
//        task.resume()
//        semaphore.wait()
//
//        //let data = NSBitmapImageRep.representationOfImageReps(in: img.representations, using: NSPNGFileType, properties: [:])!
//
//        //let image =
//        //let bodyString = "grant_type=refresh_token&client_secret=\(IMGUR_SECRET)&client_id=\(CLIENT_ID)&refresh_token=\(refreshKey)"
//        //request.httpBody = bodyString.data(using: .utf8)
//
//
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if GlobalImages.count == GlobalPkArray.count {
//            return GlobalPkArray.count
//        }
//        else {
//            return GlobalImages.count//0
//        }
        return GlobalImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as! CollectionViewCell1
//        if GlobalImages.count != 0 && GlobalImages.count == GlobalPkArray.count{
//            print(indexPath.item)
//            print(GlobalImages.count)
//            print("full stop")
//            cell.cellImageView.image = GlobalImages[indexPath.item]
//        }
//        else {
//            cell.cellImageView.image = nil
//        }
        cell.cellImageView.image = GlobalImages[indexPath.row]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        //cell.frame.size.height = CGFloat(spacing)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath)
        //cell?.layer.borderColor = UIColor.gray.cgColor
        //cell?.layer.borderWidth = 2
//        if( indexPath == [0,0]) {
//            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "Cloudview") as UIViewController
//            self.present(vc, animated: true, completion: nil)
//        }
        
        self.GalleryImageView.image = self.GlobalImages[indexPath.row]
        
        
        self.collectionView.isHidden = true
        self.primaryReturn.isHidden = true
        self.secondaryReturn.isHidden = false
        self.GalleryImageView.isHidden = false
        self.uploadButton.isHidden = true
        self.saveButton.isHidden = false
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
