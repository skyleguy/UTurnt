//
//  FirstControllerViewController.swift
//  UTurn
//
//  Created by Stephen Kyle Lobsinger on 11/10/16.
//  Copyright © 2016 Stephen Kyle Lobsinger. All rights reserved.
//

import UIKit

class FirstControllerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    @IBOutlet weak var lockIn: UIButton!
    @IBOutlet weak var travelType: UIPickerView!
    @IBOutlet weak var numMinutes: UITextField!
    @IBOutlet weak var theSwitch: UISwitch!
    
    private let travelOptions = ["driving", "bicycling", "walking"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let row = travelType.selectedRow(inComponent: 0)
        let selected = travelOptions[row]
        let numberMinutes = (Int(numMinutes.text!)!)
        let switchCheck = theSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(selected, forKey: "drivingMethod")
        defaults.set(numberMinutes, forKey: "numMinutes")
        defaults.set(switchCheck, forKey: "switchPosition")
        //print("Travel type selected is \(selected)")
        //print("Number of minutes to travel is \(numberMinutes)")
        //print("The switch is set to the \(switchCheck) position")
    }
    
    @IBAction func textFieldDoneEditing( sender: UITextField)
    {
        sender.resignFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return travelOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return travelOptions[row]
    }
    
}
