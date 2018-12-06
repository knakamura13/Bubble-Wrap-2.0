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
    var categoryList = CATEGORIES_LIST
    //var tapGesture = UITapGestureRecognizer()
    
    // Set the searchVC controller inorder to access it, when filters need to be set
    var searchVC:SearchVC!

    // Outlets
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var minTxtFld: UITextField!
    @IBOutlet weak var maxTxtFld: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var FilterView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the category of all to the category list in filters
        categoryList.insert("All", at: 1)
        
        // Setting the categor picker to be ready
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        // Turn off the filter
        filterOn = false
        
        // Tap Gessuter set when user tap outside of filters
        //tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.b))
        //infosView.isUserInteractionEnabled = true
        //infosView.addGestureRecognizer(tapGesture)
        //view.addSubview(infosView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     * Preform Checks for the filter to work
     */
    @IBAction func setBtn(_ sender: Any) {
        /* Check price is not lower than 0*/
        guard let priceMin = Int(minTxtFld.text!) else {
            let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have a Min price.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if priceMin < 0{
            let alert = UIAlertController(title: "Check Price!", message: "You can not have a min price lower than 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        /* Check price is not higher than $99,999*/
        guard let priceMax = Int(maxTxtFld.text!) else {
            let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have a Max price.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if priceMax > 99999{
            let alert = UIAlertController(title: "Check Price!", message: "You can not have a max price higher than $99,999.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        /* Check min price is not higher than max price*/
        if priceMin > priceMax{
            let alert = UIAlertController(title: "Check Prices!", message: "You Min price can not be bigger than your Max price.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        /* Check the max price is not equal to the min price*/
        if priceMin == priceMax{
            let alert = UIAlertController(title: "Check Prices!", message: "You Min price can be the same as your Max price.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if categoryChoosen == categoryList[0] || categoryChoosen == "" {
            let alert = UIAlertController(title: "Check Category!", message: "You have to choose a category! You can also choose all", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // Set the variables necessary to pass to SearchVC for the filter search
        searchVC.catChoosen = categoryChoosen
        searchVC.minPrice = Int(minTxtFld.text!)!
        searchVC.maxPrice = Int(maxTxtFld.text!)!
        filterOn = true
        searchVC.viewDidLoad()
        self.dismiss(animated: true, completion: nil)
    }
    
    // Cancel button
    @IBAction func cancelBtn(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    // Detect if there is a tap outside the filters view.
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != FilterView {
        self.dismiss(animated: true, completion: nil)
        }
    }
    
}

/*Set the content for the picker view*/
extension FiltersVC: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryChoosen = categoryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row]
    }
}
