//
//  ViewController.swift
//  TouchIDDemo
//
//  Created by Rajeev Sharma on 2015-03-11.
//  Copyright (c) 2015 Rajeev. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, EditNoteViewControllerDelegate {
    @IBOutlet weak var tblNotes: UITableView!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var dataArray: NSMutableArray = NSMutableArray()
    var noteIndexToEdit: Int!


    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        tblNotes.delegate = self
        tblNotes.dataSource = self

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idSegueEditNote" {
            var editNoteViewController : EditNoteViewController = segue.destinationViewController as EditNoteViewController
            editNoteViewController.delegate = self
        
            if noteIndexToEdit != nil {
                editNoteViewController.indexOfEditedNote = noteIndexToEdit
                
                noteIndexToEdit = nil
            }
        
        }
    }
    
     override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
    }

    func authenticateUser() {
        // Get the local authentication context.
        let context  = LAContext ()

        // Declare a NSError variable.
        var error : NSError?
        
        //Set the reason string that will appear on the authentication alert.
        var reasonString = "Authentication is required to access the notes."
    
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {

        [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
            
            if success {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.loadData()
                })
                
            }
            else {
                // If authentication failed then show a message to the console with a short description.
                // In case that the error is a user fallback, then show the password alert view.
                println(evalPolicyError?.localizedDescription)
                
                switch evalPolicyError!.code {
                    
                case LAError.SystemCancel.rawValue:
                    println("Authentication was cancelled by the system")
                    
                case LAError.UserCancel.rawValue:
                    println("Authentication was cancelled by the user")
                    
                case LAError.UserFallback.rawValue:
                    println("User selected to enter custom password")
                    self.showPasswordAlert()
                    
                default:
                    println("Authentication failed")
                    self.showPasswordAlert()
                }
            }
            
        })]
    }
            
        else {
                // If the security policy cannot be evaluated then show a short message depending on the error.
                switch error!.code{
                    
                case LAError.TouchIDNotEnrolled.rawValue:
                    println("TouchID is not enrolled")
                    
                case LAError.PasscodeNotSet.rawValue:
                    println("A passcode has not been set")
                    
                default:
                    // The LAError.TouchIDNotAvailable case.
                    println("TouchID not available")
                }
                
                // Optionally the error description can be displayed on the console.
                println(error?.localizedDescription)
                
                // Show the custom alert view to allow users to enter the password.
                self.showPasswordAlert()
            }
        }
    
    func showPasswordAlert() {
        var passwordAlert : UIAlertView = UIAlertView(title: "My Notes", message: "Please type your password", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        passwordAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if alertView.textFieldAtIndex(0)?.text == "" {
                loadData()
            } else {
                showPasswordAlert()
            }
        } else {
            showPasswordAlert()
        }
    }
    
    func loadData(){
        if appDelegate.checkIfDataFileExists() {
            self.dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())!
            self.tblNotes.reloadData()
        }
        else{
            println("File does not exist")
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCell") as UITableViewCell
        
        let currentNote = self.dataArray.objectAtIndex(indexPath.row) as Dictionary<String, String>
        cell.textLabel!.text = currentNote["title"]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        noteIndexToEdit = indexPath.row
        performSegueWithIdentifier("idSegueEditNote", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            // Delete the respective object from the dataArray array.
            dataArray.removeObjectAtIndex(indexPath.row)
            
            // Save the array to disk.
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
            
            // Reload the tableview.
            tblNotes.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }        
    }

    func noteWasSaved() {
        loadData()
    }
}


