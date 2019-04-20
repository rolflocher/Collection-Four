//
//  NotesViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/24/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet var notesTextView: UITextView!
    
    @IBAction func getButton(_ sender: Any) {
        getNotes()
    }
    
    @IBAction func writeButton(_ sender: Any) {
        updateNotes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesTextView.isEditable = false
        self.mayI()
        //self.getNotes()
        // Do any additional setup after loading the view.
    }
    
    var isOccupied = true
    var isFirstTime = true
    
    func mayI () {
        let url = URL(string: "http://127.0.0.1:8000/notes/mayI")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.notesTextView.isEditable = true
                    }
                    self.isOccupied = false
                    print("trying to start edit mode")
                    self.getNotes()
                    self.editing()
                    
                }
                else {
                    print("someone is already editing")
                    self.isOccupied = true
                    
                    if self.isFirstTime {
                        DispatchQueue.global(qos: .background).async {
                            self.getNotesUntilLeave()
                        }
                        DispatchQueue.global(qos: .background).async {
                            self.checkIfOccupied()
                        }
                        
                        let alert = UIAlertController(title: "Notification", message: "Someone is already editing", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                        self.notesTextView.isEditable = false
                        self.isFirstTime = false
                    }
                }
            }
            
        })
        task.resume()
    }
    var windowOK = false
    
    func checkWindow() {
//        DispatchQueue.global(qos: .background).async {
//            sleep(1)
        print("checking window")
        DispatchQueue.main.async {
            self.windowOK = self.viewIfLoaded?.window != nil
            
            }
    }
    
    func editing () {
        self.checkWindow()
        sleep(1)
        print("got to editing")
        while(self.windowOK) {
            let url = URL(string: "http://127.0.0.1:8000/notes/here")!
            let request = URLRequest(url:url)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            })
            task.resume()
            print("youre editing")
            sleep(5)
            self.updateNotes()
            self.checkWindow()
            
        }
    }
    
    func getNotesUntilLeave() {
        self.checkWindow()
        sleep(1)
        while(self.windowOK && self.isOccupied == true) {
            sleep(1)
            print("getting notes")
            self.getNotes()
            self.checkWindow()
            
        }
    }
    
    func checkIfOccupied () {
        self.checkWindow()
        sleep(1)
        while(self.windowOK && self.isOccupied == true) {
            print("checking if still occupied")
            sleep(10)
            self.mayI()
            self.checkWindow()
        }
    }
    
    func getNotes() {
        let url = URL(string: "http://127.0.0.1:8000/notes/")!
        let request = URLRequest(url:url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            do{
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    print("fail")
                    return
                }
                var message : String = ""
                for x in 0..<jsonArray.count {
                    let format1 = jsonArray[x]["fields"] as! [String:Any]
                    message += format1["note_text"] as! String + "\n\n"
                }
                //print(message)
                let formatFinal = message.replacingOccurrences(of: "+", with: " ")
                let formatFinal2 = formatFinal.replacingOccurrences(of: "%0A", with: "\n")
                DispatchQueue.main.async (execute: { () -> Void in
                    self.notesTextView!.text = formatFinal2
                })
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    func updateNotes() {
        
        DispatchQueue.main.async {
            let format = self.notesTextView.text as! String
            let format1 = format.replacingOccurrences(of: " ", with: "+")
            let format2 = format1.replacingOccurrences(of: "\n", with: "%0A")
            print(format2)
            let url = URL(string: "http://127.0.0.1:8000/notes/1/\(format2)/update")!
            let request = URLRequest(url:url)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            })
            task.resume()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}
