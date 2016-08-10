//
//  ChatViewController.swift
//  FirebaseChatAppSwift
//
//  Created by David Park on 8/10/16.
//  Copyright © 2016 DavidVYPark. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
	
	var messeges = [JSQMessage]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.senderId = "1"
		self.senderDisplayName = "David"
	}

	override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
		print("didpresssendbutton")
		print("\(text)")
		print(senderId)
		print(senderDisplayName)
		messeges.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
		collectionView.reloadData()
		print(messeges)
	}
	
	override func didPressAccessoryButton(sender: UIButton!) {
		print("did print accessory button")
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
		return messeges[indexPath.item]
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.blackColor())
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		print(messeges.count)
		return messeges.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

		return cell
	}
	
	@IBAction func logOutButtonTapped(sender: AnyObject) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LogInViewController
		
		//get the app delegate
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		//set navigation controller as root view controller
		appDelegate.window?.rootViewController = loginVC
	}
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		print("Did finish picking")
		
		//get the image
		print(info)
		let picture = info[UIImagePickerControllerOriginalImage] as? UIImage
		let photo = JSQPhotoMediaItem(image: picture)
		
		messeges.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
		self.dismissViewControllerAnimated(true, completion: nil)
		collectionView.reloadData()
		
		
	}
}
