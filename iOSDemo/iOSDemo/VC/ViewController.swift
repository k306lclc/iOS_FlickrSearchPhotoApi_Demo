//
//  ViewController.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/13.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.tag = 0
            searchTextField.delegate = self
            searchTextField.placeholder = "欲搜尋內容"
        }
    }
    
    @IBOutlet weak var perPageTextField: UITextField!{
        didSet{
            perPageTextField.tag = 1
            perPageTextField.delegate = self
            perPageTextField.placeholder = "每頁呈現數量"
        }
    }
    @IBOutlet weak var apiTextField: UITextField!{
        didSet{
            apiTextField.tag = 2
            apiTextField.delegate = self
            apiTextField.text = "859b051eae75a311a96a2f04c7e71118"
            apiTextField.placeholder = "搜尋無資料時更換ApiKey"
        }
    }
    @IBOutlet weak var searchButton: UIButton!{
        didSet{
            searchButton.tag = 3
            searchButton.setTitle("搜尋", for: .normal)
            searchButton.isEnabled = false
            searchButton.setTitleColor(UIColor.white, for: .normal)
            searchButton.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func clickSearchButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "FeaturedVC") as? FeaturedVC else {
            print("get ViewController error")
            return
        }
        
        let text = searchTextField.text ?? ""
        let perPage = perPageTextField.text ?? ""
        let apiKey = apiTextField.text ?? ""
        
        vc.searchText = text
        vc.perPage = perPage
        vc.apiKey = apiKey
        vc.viewWillAppear(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
            if textField.tag == 1 || textField.tag == 2{
                clickSearchButton("")
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(searchTextField.text != "" && perPageTextField.text != ""){
            searchButton.isEnabled = true
            searchButton.backgroundColor = UIColor.init(red: 0/255, green: 123/255, blue: 255/255, alpha: 1.0)
        }else{
            searchButton.isEnabled = false
            searchButton.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 1.0)
        }
    }
}
