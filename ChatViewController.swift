//
//  ChatViewController.swift
//  FirebaseChatAppSwift
//
//  Created by David Park on 8/10/16.
//  Copyright © 2016 DavidVYPark. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

	@IBAction func logOutButtonTapped(sender: AnyObject) {
		
		//create a main storyboard instance
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		//from main storyboard instantiate a navigation controller
		let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LogInViewController
		
		//get the app delegate
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		//set navigation controller as root view controller
		appDelegate.window?.rootViewController = loginVC
	}
}
