//
//  CloudViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/1/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit

class CloudViewController: UIViewController {

    @IBOutlet weak var CloudImageView: UIImageView!
    
    
    @IBAction func saveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.CloudImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error)
        } else {
            print("saved?")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CloudImageView.backgroundColor = UIColor.black
        let session = URLSession(configuration: .default)
        
        let catPictureURL = URL(string: "https://picsum.photos/375/667/?random")!
        
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async{
                            
//                            UIView.animate(withDuration: 2, delay: 0.0, options: [], animations: {
//                                self.CloudImageView.image = image
//                            }, completion: nil)
                            UIView.transition(with: self.CloudImageView,
                                              duration:0.5,
                                              options: .transitionCrossDissolve,
                                              animations: { self.CloudImageView.image = image },
                                              completion: nil)
                            
                            //self.CloudImageView.image = image
                            
                            
                            
                        }
                        
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
