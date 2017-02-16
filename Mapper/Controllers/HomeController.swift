//
//  HomeController.swift
//  Mapper
//
//  Created by Huy Pham on 2/16/17.
//  Copyright © 2017 Huy Pham. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
  
  let model = Model(dictionary: ["ID": "ID from Super class of Model"])
  
  let textView = UITextView()
  let nameField = UITextField()
  let idField = UITextField()
  
  override func loadView() {
    super.loadView()
    
    self.view.backgroundColor = .white
    
    // Init view
    self.nameField.frame = CGRect(x: 10, y: 45, width: self.view.bounds.width - 20, height: 25)
    self.nameField.placeholder = "Name"
    self.nameField.font = UIFont(name: "HelveticaNeue", size: 14)
    self.nameField.addTarget(self, action: #selector(HomeController.ChangeName), for: .editingChanged)
    
    self.idField.frame = CGRect(x: 10, y: 85, width: self.view.bounds.width - 20, height: 25)
    self.idField.placeholder = "ObjectID"
    self.idField.font = UIFont(name: "HelveticaNeue", size: 14)
    self.idField.addTarget(self, action: #selector(HomeController.ChangeID), for: .editingChanged)
    
    self.textView.frame = CGRect(x: 10, y: 130, width: self.view.bounds.width - 20, height: 200)
    self.textView.backgroundColor = .lightGray
    self.textView.isEditable = false
    self.textView.layer.cornerRadius = 3
    
    self.textView.text = "Edit two text fields above and see how it works"
    
    self.view.addSubview(self.textView)
    self.view.addSubview(self.nameField)
    self.view.addSubview(self.idField)
    
    // Setup reaction
    self.model.property("Name", target: self, selector: #selector(HomeController.UpdateTextView), on: .onChange)
    self.model.property("ObjectID", target: self, selector: #selector(HomeController.UpdateTextView), on: .onChange)
  }
  
  func ChangeName() {
    self.model.name = self.nameField.text
  }
  
  func ChangeID() {
    self.model.objectID = self.idField.text
  }
  
  func UpdateTextView() {
    Dispatcher.delay(0) {
      self.textView.text = "model.toDictionary():\n \(self.model.toDictionary() as! [String: AnyObject])"
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    self.nameField.endEditing(true)
    self.idField.endEditing(true)
  }
}

class Dispatcher {
  class func delay(_ delayTime: Double, handler: @escaping (() -> Void)) {
    let delayTimeDispatch = DispatchTime.now() + Double(CLongLong(delayTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTimeDispatch) {
      handler()
    }
  }
}
