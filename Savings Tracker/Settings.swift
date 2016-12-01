//
//  Settings.swift
//  Savings Tracker
//
//  Created by Beecher Adams on 11/5/16.
//  Copyright © 2016 Beecher Adams. All rights reserved.
//

import UIKit

class Settings: UIViewController {
    @IBOutlet var monthlyIncomeTextField: UITextField!;
    @IBOutlet var savingsTextField: UITextField!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    @IBAction func doneClicked(sender: UIButton)
    {
        // save data
        saveData()
        
        // send data back
        let newSettings = SettingsClass()
        if(!(monthlyIncomeTextField.text?.isEmpty)! && !(savingsTextField.text?.isEmpty)!)
        {
            newSettings.income = Float(monthlyIncomeTextField.text!)!
            newSettings.savings = Float(savingsTextField.text!)!
            NSNotificationCenter.defaultCenter().postNotificationName("settingsChanged", object: newSettings)
        }
        
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func loadData() {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let dataFile2 = dirPaths[0].URLByAppendingPathComponent("settings.txt").path
        
        if filemgr.fileExistsAtPath(dataFile2!){
            print("File exists")
        } else {
            print("File not found")
            return
        }
        
        // get data
        var inString = ""
        do {
            inString = try String(contentsOfFile: dataFile2!)
        } catch let error as NSError {
            print("Failed reading from URL: \(dataFile2), Error: " + error.localizedDescription)
        }
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        let lineArray = inString.componentsSeparatedByCharactersInSet(newlineChars).filter{!$0.isEmpty}
        
        // loop through file
        for i in 0 ..< lineArray.count
        {
            if(lineArray[i].containsString("Income: "))
            {
                let string = lineArray[i] as NSString
                self.monthlyIncomeTextField.text = string.substringFromIndex(8)
            }
            else if(lineArray[i].containsString("Savings: "))
            {
                let string = lineArray[i] as NSString
                self.savingsTextField.text = string.substringFromIndex(9)
            }
        }

    }
    
    func saveData()
    {
        // file manager instance
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let dataFile = dirPaths[0].URLByAppendingPathComponent("settings.txt").path
        
        // create new file
        filemgr.createFileAtPath(dataFile!, contents: nil, attributes: nil)
        let file: NSFileHandle? = NSFileHandle(forWritingAtPath: dataFile!)
        
        // write data
        if(!((monthlyIncomeTextField.text?.isEmpty)!) && !((savingsTextField.text?.isEmpty)!))
        {
            let income = NSString.init(format: "Income: %.2f", Float(monthlyIncomeTextField.text!)!)
            let savings = NSString.init(format: "Savings: %.2f", Float(savingsTextField.text!)!)
            let lines = NSString.init(format: "%@\n%@\n", income, savings)
            
            if file != nil {
                // Set the data we want to write
                let data = lines.dataUsingEncoding(NSUTF8StringEncoding)
                
                // Write it to the file
                file?.writeData(data!)
            }
        }
    }
}
