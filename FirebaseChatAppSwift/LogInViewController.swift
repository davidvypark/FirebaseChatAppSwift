//
//  LogInViewController.swift
//  FirebaseChatAppSwift
//
//  Created by David Park on 8/10/16.
//  Copyright © 2016 DavidVYPark. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
	
	override func viewDidLoad() {
		GIDSignIn.sharedInstance().clientID = "468674851696-k0gesktr0a3fg2a4dh2f7o37nc33gm4a.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		print(FIRAuth.auth()?.currentUser)
		//check if user is already authenticated
		// we can use a splash view that forks to either login or main screen
		FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
			if user != nil {
				print(user)
				Helper.helper.switchToNavigationViewController()
			} else {
				print("Unauthorized")
			}
		})
	}

	@IBAction func anonymouslyLoginTapped(sender: AnyObject) {
		Helper.helper.anonymouslyLogin()
	}
	
	@IBAction func facebookLoginTapped(sender: AnyObject) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.window?.rootViewController = naviVC
		
	}
	
	@IBAction func googleLoginTapped(sender: AnyObject) {
		
		GIDSignIn.sharedInstance().signIn()
		
	}

	func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
		
		if error != nil {							//If there is a loging error for some reason
			print(error!.localizedDescription)
			return
		}
		print(user.authentication)
		Helper.helper.loginWithGoogle(user.authentication)
	}
	
	
}
