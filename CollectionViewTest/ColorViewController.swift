//
//  ColorViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/2/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit


class ColorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var colorView1: UIImageView!
    
    @IBOutlet weak var colorView2: UIImageView!
    
    @IBOutlet weak var colorView3: UIImageView!
    
    @IBOutlet weak var colorView4: UIImageView!
    
    @IBOutlet weak var colorView5: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let color1 = defaults.array(forKey: "color1")  as? [CGFloat] {
            self.colorView1.backgroundColor = UIColor(red: color1[0], green: color1[1], blue: color1[2] , alpha: 0.9)
        }
        else {
            self.colorView1.backgroundColor = UIColor.color1
        }
        if let color2 = defaults.array(forKey: "color2")  as? [CGFloat] {
            self.colorView2.backgroundColor = UIColor(red: color2[0], green: color2[1], blue: color2[2] , alpha: 0.9)
        }
        else {
            self.colorView2.backgroundColor = UIColor.color2
        }
        if let color3 = defaults.array(forKey: "color3")  as? [CGFloat] {
            self.colorView3.backgroundColor = UIColor(red: color3[0], green: color3[1], blue: color3[2] , alpha: 0.9)
        }
        else {
            self.colorView3.backgroundColor = UIColor.color3
        }
        if let color4 = defaults.array(forKey: "color4")  as? [CGFloat] {
            self.colorView4.backgroundColor = UIColor(red: color4[0], green: color4[1], blue: color4[2] , alpha: 0.9)
        }
        else {
            self.colorView4.backgroundColor = UIColor.color4
        }
        if let color5 = defaults.array(forKey: "color5")  as? [CGFloat] {
            self.colorView5.backgroundColor = UIColor(red: color5[0], green: color5[1], blue: color5[2] , alpha: 0.9)
        }
        else {
            self.colorView5.backgroundColor = UIColor.color5
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectButtonPress(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func captureButtonPress(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera;
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
    
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            DispatchQueue.main.async{
                //self.colorView1.image = image //// color is 0, 1, or 2
                
                self.colorView1.backgroundColor = image.averageColor1(alpha: 1, color: 2)
                
                self.colorView2.backgroundColor = image.averageColor2(alpha: 1, color: 2)
                self.colorView3.backgroundColor = image.averageColor3(alpha: 1, color: 2)
                self.colorView4.backgroundColor = image.averageColor4(alpha: 1, color: 2)
                self.colorView5.backgroundColor = image.averageColor5(alpha: 1, color: 2)
            }
            dismiss(animated: true, completion: nil)
        }
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

extension UIImage {
    
    func averageColor(alpha : CGFloat) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel / 6
        
        var red = 0
        var green = 0
        var blue  = 0
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                red    += Int(rowPtr[0])
                green  += Int(rowPtr[1])
                blue   += Int(rowPtr[2])
                rowPtr += Int(stride)
            }
        }
        
        
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(imageWidth) * CGFloat(imageHeight))
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
    
    
    func averageColor1(alpha : CGFloat, color : Int) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel
        
        var red : Double = 0
        var green : Double = 0
        var blue  : Double = 0
        var pixelCount : Double = 0
        
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                if ( Int(rowPtr[color]) <= 51 ) {
                    red    += Double(rowPtr[0])
                    green  += Double(rowPtr[1])
                    blue   += Double(rowPtr[2])
                    pixelCount += 1
                }
                rowPtr += Int(stride)
            }
        }
        let defaults = UserDefaults.standard
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(pixelCount))
        let test : Array = [f * CGFloat(red), f * CGFloat(green), f * CGFloat(blue)]
        defaults.set(test, forKey: "color1")
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
    
    func averageColor2(alpha : CGFloat, color : Int) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel // 6
        
        var red : Double = 0
        var green : Double = 0
        var blue : Double  = 0
        var pixelCount : Double = 0
        
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                if ( Int(rowPtr[color]) > 51 && Int(rowPtr[color]) <= 102 ) {
                    red    += Double(rowPtr[0])
                    green  += Double(rowPtr[1])
                    blue   += Double(rowPtr[2])
                    pixelCount += 1
                    //print(Int(rowPtr[0]))
                }
                rowPtr += Int(stride)
            }
        }
        let defaults = UserDefaults.standard
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(pixelCount))
        print(f)
        print(f * CGFloat(red))
        let test : Array = [f * CGFloat(red), f * CGFloat(green), f * CGFloat(blue)]
        defaults.set(test, forKey: "color2")
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
    
    
    func averageColor3(alpha : CGFloat, color : Int) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel
        
        var red = 0
        var green = 0
        var blue  = 0
        var pixelCount = 0
        
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                if ( Int(rowPtr[color]) > 102 && Int(rowPtr[color]) <= 153 ) {
                    red    += Int(rowPtr[0])
                    green  += Int(rowPtr[1])
                    blue   += Int(rowPtr[2])
                    pixelCount += 1
                }
                rowPtr += Int(stride)
            }
        }
        let defaults = UserDefaults.standard
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(pixelCount))
        let test : Array = [f * CGFloat(red), f * CGFloat(green), f * CGFloat(blue)]
        defaults.set(test, forKey: "color3")
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
    
    func averageColor4(alpha : CGFloat, color : Int) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel
        
        var red = 0
        var green = 0
        var blue  = 0
        var pixelCount = 0
        
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                if ( Int(rowPtr[color]) > 153 && Int(rowPtr[color]) <= 204 ) {
                    red    += Int(rowPtr[0])
                    green  += Int(rowPtr[1])
                    blue   += Int(rowPtr[2])
                    pixelCount += 1
                }
                rowPtr += Int(stride)
            }
        }
        let defaults = UserDefaults.standard
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(pixelCount))
        let test : Array = [f * CGFloat(red), f * CGFloat(green), f * CGFloat(blue)]
        defaults.set(test, forKey: "color4")
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
    
    func averageColor5(alpha : CGFloat, color : Int) -> UIColor {
        
        let rawImageRef : CGImage = self.cgImage!
        let  data : CFData = rawImageRef.dataProvider!.data!
        let rawPixelData  =  CFDataGetBytePtr(data);
        
        let imageHeight = rawImageRef.height
        let imageWidth  = rawImageRef.width
        let bytesPerRow = rawImageRef.bytesPerRow
        let stride = rawImageRef.bitsPerPixel
        
        var red = 0
        var green = 0
        var blue  = 0
        var pixelCount = 0
        
        
        for row in 0...imageHeight {
            var rowPtr = rawPixelData! + bytesPerRow * row
            for _ in 0...imageWidth {
                if ( Int(rowPtr[color]) > 204 ) {
                    red    += Int(rowPtr[0])
                    green  += Int(rowPtr[1])
                    blue   += Int(rowPtr[2])
                    pixelCount += 1
                }
                rowPtr += Int(stride)
            }
        }
        let defaults = UserDefaults.standard
        let  f : CGFloat = 1.0 / (255.0 * CGFloat(pixelCount))
        let test : Array = [f * CGFloat(red), f * CGFloat(green), f * CGFloat(blue)]
        defaults.set(test, forKey: "color5")
        return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
    }
}



extension UIColor {
    
    class var color1: UIColor {
        let color1 = 0xfbecec
        return UIColor.rgb(fromHex: color1)
    }
    class var color2: UIColor {
        let color2 = 0xebddf6
        return UIColor.rgb(fromHex: color2)
    }
    class var color3: UIColor {
        let color3 = 0xdad3f2
        return UIColor.rgb(fromHex: color3)
    }
    class var color4: UIColor {
        let color4 = 0xd6e4f9
        return UIColor.rgb(fromHex: color4)
    }
    class var color5: UIColor {
        let color5 = 0xd9fcff
        return UIColor.rgb(fromHex: color5)
    }
    
    class func rgb(fromHex: Int) -> UIColor {
        
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
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
