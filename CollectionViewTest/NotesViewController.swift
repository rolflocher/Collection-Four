//
//  NotesViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/24/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var notesTextView: UITextView!
    
    let db = Firestore.firestore()
    
    var cursorPos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        db.collection("notes").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.notesTextView.text = documents[0]["content"] as? String
            if let newPosition = self.notesTextView.position(from: self.notesTextView.beginningOfDocument, offset: self.cursorPos) {
                
                self.notesTextView.selectedTextRange = self.notesTextView.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let selectedRange = notesTextView.selectedTextRange {
            
            cursorPos = notesTextView.offset(from: notesTextView.beginningOfDocument, to: selectedRange.start)
        }
        db.collection("notes").document("text").setData([
            "content" : textView.text ?? ""
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
}
