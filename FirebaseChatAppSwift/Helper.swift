//
//  Helper.swift
//  
//
//  Created by David Park on 8/10/16.
//
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn

class Helper {
	static let helper = Helper()
	
	func anonymouslyLogin() {
		
		FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (anonymousUser: FIRUser?, error: NSError?) in
			if error == nil {
				print("UserId: \(anonymousUser!.uid)")
				
				self.switchToNavigationViewController()
				
			} else {
				print(error!.localizedDescription)
				return
			}
			
		})
		
	}
	
	func loginWithGoogle(authentication: GIDAuthentication) {
		
		let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
		
		FIRAuth.auth()?.signInWithCredential(credential, completion: { (user: FIRUser?, error: NSError?) in
			if error != nil {
				print(error!.localizedDescription)
				return
			} else {
				print(user?.email)
				print(user?.displayName)
				
				self.switchToNavigationViewController()
			}
		})
		
	}
	
	func switchToNavigationViewController() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.window?.rootViewController = naviVC
	}

	
	
}
