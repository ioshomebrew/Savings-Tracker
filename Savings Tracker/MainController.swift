//
//  MainController.swift
//  Savings Tracker
//
//  Created by Beecher Adams on 11/5/16.
//  Copyright © 2016 Beecher Adams. All rights reserved.
//

import UIKit

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!;
    var goals : NSMutableArray = [];
    var savings : Float = 0.0;
    var income : Float = 0.0;
    
    func saveData()
    {
        // file manager instance
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let dataFile = dirPaths[0].URLByAppendingPathComponent("goals.txt").path
        
        // create new file
        filemgr.createFileAtPath(dataFile!, contents: nil, attributes: nil)
        let file: NSFileHandle? = NSFileHandle(forWritingAtPath: dataFile!)
        
        // start writing data
        for i in 0 ..< goals.count
        {
            let obj = goals[i] as! GoalClass
            let name = obj.name
            let amount = obj.amount
            
            let l1 = NSString.init(format: "%i", i)
            let l2 = NSString.init(format: "Name: %@", name)
            let l3 = NSString.init(format: "Amount: %.2f", amount)
            let lines = NSString.init(format: "%@\n%@\n%@\n", l1, l2, l3)
            
            if file != nil {
                // Set the data we want to write
                let data = lines.dataUsingEncoding(NSUTF8StringEncoding)
                
                // Write it to the file
                file?.writeData(data!)
            }
        }
        
        // Close the file
        file?.closeFile()
    }
    
    func loadData()
    {
        // file manager instance
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let dataFile = dirPaths[0].URLByAppendingPathComponent("goals.txt").path
        
        if filemgr.fileExistsAtPath(dataFile!){
            print("File exists")
        } else {
            print("File not found")
            return
        }
        
        // get data
        var inString = ""
        do {
            inString = try String(contentsOfFile: dataFile!)
        } catch let error as NSError {
            print("Failed reading from URL: \(dataFile), Error: " + error.localizedDescription)
        }
        
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        var lineArray = inString.componentsSeparatedByCharactersInSet(newlineChars).filter{!$0.isEmpty}
        let goalObj : GoalClass = GoalClass();
        
        // loop through file
        for i in 0 ..< lineArray.count
        {
            if(lineArray[i].containsString("Name: "))
            {
                let string = lineArray[i] as NSString
                goalObj.name = string.substringFromIndex(6)
            }
            else if(lineArray[i].containsString("Amount: "))
            {
                let string = lineArray[i] as NSString
                goalObj.amount = Float(string.substringFromIndex(8))!
                
                // add to main array
                goals.addObject(goalObj)
            }
        }
        
        // now for settings
        // file manager instance
        let dataFile2 = dirPaths[0].URLByAppendingPathComponent("settings.txt").path
        
        if filemgr.fileExistsAtPath(dataFile2!){
            print("File exists")
        } else {
            print("File not found")
            return
        }
        
        // get data
        do {
            inString = try String(contentsOfFile: dataFile2!)
        } catch let error as NSError {
            print("Failed reading from URL: \(dataFile2), Error: " + error.localizedDescription)
        }
        lineArray = inString.componentsSeparatedByCharactersInSet(newlineChars).filter{!$0.isEmpty}
        
        // loop through file
        for i in 0 ..< lineArray.count
        {
            if(lineArray[i].containsString("Income: "))
            {
                let string = lineArray[i] as NSString
                print("Income is: ", string.substringFromIndex(8))
                income = Float(string.substringFromIndex(8))!
                print("Income is: ", income)
            }
            else if(lineArray[i].containsString("Savings: "))
            {
                let string = lineArray[i] as NSString
                savings = Float(string.substringFromIndex(9))!
                print("Savings is: ", savings)
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            goals.removeObjectAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
            saveData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GoalViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GoalViewCell
        
        // set data
        let goal = goals.objectAtIndex(indexPath.row) as! GoalClass
        cell.nameLabel.text = goal.name as String
        cell.amountLabel.text = NSString(format: "%.2f", goal.amount) as String
        
        // set progress based on savings
        if(savings < goal.amount)
        {
            cell.progressView.progress = savings / goal.amount
            cell.percentLabel.text = NSString(format: "%.1f%%", (savings / goal.amount)*100) as String
            cell.timeLabel.text = NSString(format: "%.1f Months", (goal.amount - savings)/income) as String
        }
        else
        {
            cell.progressView.progress = 1.0
            cell.percentLabel.text = "100%"
            cell.timeLabel.text = "Goal Reached"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load file
        loadData()
        
        // register notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.goalRecieved), name: "addGoal", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.settingsChanged), name: "settingsChanged", object: nil)
    }
    
    @IBAction func addClicked(sender: UIButton)
    {
        let addViewController:AddController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("add") as! AddController
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    @IBAction func settingsClicked(sender: UIButton)
    {
        let addViewController:Settings = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("settings") as! Settings
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    func settingsChanged(notification: NSNotification)
    {
        print("Settings Changed")
        
        let newSettings = notification.object as! SettingsClass
        
        // update settings
        savings = newSettings.savings
        income = newSettings.income
        
        tableView.reloadData()
    }
    
    func goalRecieved(notification: NSNotification) {
        print("Object recieved")
        
        // get goalclass and add
        let goal = notification.object as! GoalClass
        
        print(goal.name)
        print(goal.amount)
        
        // add to array
        goals.addObject(goal)
        
        // save data
        saveData()
        
        self.tableView.reloadData()
    }
}
