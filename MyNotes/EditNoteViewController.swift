//
//  EditNoteViewController.swift
//  TouchIDDemo
//
//  Created by Rajeev Sharma on 2015-03-11.
//  Copyright (c) 2015 Rajeev. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate {
    func noteWasSaved()
}

class EditNoteViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tvNoteBody: UITextView!
    @IBOutlet weak var txtNoteTitle: UITextField!
    var delegate : EditNoteViewControllerDelegate?
    var indexOfEditedNote : Int!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtNoteTitle.becomeFirstResponder()
        txtNoteTitle.delegate = self
            self.tvNoteBody.alpha = 0.0
            self.txtNoteTitle.alpha = 0.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveNote(sender: AnyObject) {

        if (self.txtNoteTitle.text.isEmpty && self.tvNoteBody.text.isEmpty) {
            println("No title for the note was typed.")
            return
        }

        // Create a dictionary with the note data.
        var noteDic = ["title": self.txtNoteTitle.text, "note": self.tvNoteBody.text]
        
        // Declare a NSMutableArray object.
        var dataArray: NSMutableArray
        
        // If the notes data file exists then load its contents and add the new note data too, otherwise
        // just initialize the dataArray array and add the new note data.
        if appDelegate.checkIfDataFileExists() {
            // Load any existing notes.
            dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())!
        
            if indexOfEditedNote == nil {
            
            // Add the dictionary to the array.
                dataArray.addObject(noteDic)
            }
            
            else {
                // Replace the existing dictionary to the array.
                dataArray.replaceObjectAtIndex(indexOfEditedNote, withObject: noteDic)
            }
        }
        else{
            // Create a new mutable array and add the noteDict object to it.
            dataArray = NSMutableArray(object: noteDic)
        }
        
        // Save the array contents to file.
        dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
        
        delegate?.noteWasSaved()
        
        // Pop the view controller
        self.navigationController!.popViewControllerAnimated(true)
        
    }

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        // Resign the textfield from first responder.
        textField.resignFirstResponder()
        
        // Make the textview the first responder.
        tvNoteBody.becomeFirstResponder()
        
        return true
    }

    func editNote() {
        // Load all notes.
        var notesArray: NSArray = NSArray(contentsOfFile: appDelegate.getPathOfDataFile())!
        
        // Get the dictionary at the specified index.
        let noteDict : Dictionary = notesArray.objectAtIndex(indexOfEditedNote) as Dictionary<String, String>
        
        UIView .animateWithDuration(0.5, animations: { () -> Void in
            // Set the textfield text.
            self.txtNoteTitle.text = noteDict["title"]

            // Set the textview text.
            self.tvNoteBody.text = noteDict["note"]

        })
        
        
    }
    
     override func viewDidAppear(animated: Bool) {
        if (indexOfEditedNote != nil) {
            editNote()
        }
        UIView .animateWithDuration(0.3, animations: { () -> Void in
            self.txtNoteTitle.alpha = 1.0
            self.tvNoteBody.alpha = 1.0
        })
    }
    
}
