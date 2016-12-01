//
//  AddController.swift
//  Savings Tracker
//
//  Created by Beecher Adams on 11/5/16.
//  Copyright © 2016 Beecher Adams. All rights reserved.
//

import UIKit

class AddController: UIViewController {
    @IBOutlet var nameTextField: UITextField!;
    @IBOutlet var goalTextField: UITextField!;
    
    @IBAction func doneClicked(sender: UIButton)
    {
        // create goal
        let goal = GoalClass()
        if(!(nameTextField.text?.isEmpty)! && !(goalTextField.text?.isEmpty)!)
        {
            goal.name = nameTextField.text!
            goal.amount = Float(goalTextField.text!)!
            NSNotificationCenter.defaultCenter().postNotificationName("addGoal", object: goal)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
