//
//  FiltersVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 11/25/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class FiltersVC: UIViewController {
    
    // Variables
    var createItemWasPressed: Bool!
    var categoryChoosen = ""

    // Outlets
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var minTxtFld: UITextField!
    @IBOutlet weak var maxTxtFld: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryPicker.dataSource = self
        categoryPicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func setBtn(_ sender: Any) {
        
         self.dismiss(animated: true, completion: nil)
    }
    
    
    
  


}

/*Set the content for the picker view*/
extension FiltersVC: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CATEGORIES_LIST.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryChoosen = CATEGORIES_LIST[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CATEGORIES_LIST[row]
    }
}
