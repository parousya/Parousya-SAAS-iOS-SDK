//
//  ViewController.swift
//  iOS Example
//
//  Created by Xuan Jie Chew on 09/08/2019.
//  Copyright (c) 2019 Parousya. All rights reserved.
//

import UIKit
import ParousyaSAASSDK

class ViewController: UIViewController {
	
	@IBOutlet private var appKeyLabel : UILabel!
	@IBOutlet private var userIdTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		self.title = "Parousya SAAS"
		self.appKeyLabel.text = "App Key: \(ParousyaSAASSampleClientConstants.appKey)"
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let userDefaults = UserDefaults.standard
		if let userId = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userIdKey),
			let _ = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userTypeKey) {
				self.userIdTextField.text = "\(userId)"
				self.performSegue(withIdentifier: "startObserving", sender: nil)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func hostButtonClicked(_ sender: UIButton) {
		self.startParousyaSDK(withPersonType: .host)
	}
	
	@IBAction func customerButtonClicked(_ sender: UIButton) {
		self.startParousyaSDK(withPersonType: .customer)
	}
	
	func startParousyaSDK(withPersonType personType: PRSPersonType) {
		guard let userId = self.userIdTextField.text, userId.count > 0 else {
			let alertController = UIAlertController(title: "Error", message: "Please enter a valid user id.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
			self.userIdTextField.becomeFirstResponder()
			return
		}
		
		self.userIdTextField.resignFirstResponder()
		
		ParousyaSAASSDK.start(appKey: ParousyaSAASSampleClientConstants.appKey, appSecret: ParousyaSAASSampleClientConstants.appSecret, personGenericId: userId, personType: personType, isDebug: true, onSuccess: {
			
			let userDefaults = UserDefaults.standard
			userDefaults.set(userId, forKey: ParousyaSAASSampleClientConstants.userIdKey)
			userDefaults.set(personType.rawValue, forKey: ParousyaSAASSampleClientConstants.userTypeKey)
			userDefaults.synchronize()
			
			self.performSegue(withIdentifier: "startObserving", sender: nil)
		}) { error in
			
		}
	}
}

