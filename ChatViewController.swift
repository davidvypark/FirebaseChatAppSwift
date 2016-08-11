//
//  ChatViewController.swift
//  FirebaseChatAppSwift
//
//  Created by David Park on 8/10/16.
//  Copyright © 2016 DavidVYPark. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
	
	var messages = [JSQMessage]()
	
	var messageRef = FIRDatabase.database().reference().child("messages")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.senderId = "1"
		self.senderDisplayName = "David"
		
		
//		messageRef.childByAutoId().setValue("first message")
//		messageRef.childByAutoId().setValue("second message")
		
//		messageRef.observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot) in
//			
//			print("test")
//			if let dict = snapshot.value as? String {
//				print(dict)
//			}
//		}
	
		observeMessages()
	}
	
	func observeMessages() {
		messageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
			if let dict = snapshot.value as? [String: AnyObject] {
				let mediaType = dict["MediaType"] as! String
				let senderId = dict["senderId"] as! String
				let senderName = dict["senderName"] as! String
				
				switch mediaType {
				case "TEXT":
					let text = dict["text"] as! String
					self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
					
				case "PHOTO":
					let fileUrl = dict["fileUrl"] as! String
					let url = NSURL(string: fileUrl)
					let data = NSData(contentsOfURL: url!)
					let picture = UIImage(data: data!)
					let photo = JSQPhotoMediaItem(image: picture)
					self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
					
				case "VIDEO":
					let fileUrl = dict["fileUrl"] as! String
					let video = NSURL(string: fileUrl)
					let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
					self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
					
				default:
					print("Unknown Data Type")
				}

				self.collectionView.reloadData()
			}
		})
	}

	override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
		
//		messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//		collectionView.reloadData()
//		print(messages)
		
		let newMessage = messageRef.childByAutoId()
		let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
		
		newMessage.setValue(messageData)
		

	}
	
	override func didPressAccessoryButton(sender: UIButton!) {
		print("did print accessory button")
		
		let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.ActionSheet)
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert: UIAlertAction) in
			
		}
		
		let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in
			self.getMediaFrom(kUTTypeImage)
		}
		
		let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in
			self.getMediaFrom(kUTTypeMovie)
			
		}
		sheet.addAction(photoLibrary)
		sheet.addAction(videoLibrary)
		sheet.addAction(cancel)
		self.presentViewController(sheet, animated: true, completion: nil)

		
		
//		let imagePicker = UIImagePickerController()
//		imagePicker.delegate = self
//		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	func getMediaFrom(type: CFString) {
		print(type)
		let mediaPicker = UIImagePickerController()
		mediaPicker.delegate = self
		mediaPicker.mediaTypes = [type as String]
		self.presentViewController(mediaPicker, animated: true, completion: nil)
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
		return messages[indexPath.item]
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.blackColor())
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		print(messages.count)
		return messages.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

		return cell
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
		print("Tapped")
		print("didtapmessegeBubbleAtIndexPath: \(indexPath.item)")
		let message = messages[indexPath.item]
		if message.isMediaMessage {
			if let mediaItem = message.media as? JSQVideoMediaItem {
				let player = AVPlayer(URL: mediaItem.fileURL)
				let playerViewController = AVPlayerViewController()
				playerViewController.player = player
				self.presentViewController(playerViewController, animated: true, completion: nil)
			}

		}
	}
	
	@IBAction func logOutButtonTapped(sender: AnyObject) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LogInViewController
		
		//get the app delegate
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		//set navigation controller as root view controller
		appDelegate.window?.rootViewController = loginVC
	}
	
	func sendMedia(picture: UIImage?, video: NSURL?) {
		print(picture)
		print(FIRStorage.storage().reference())
		if let picture = picture {
			let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
			print(filePath)
			let data = UIImageJPEGRepresentation(picture, 1)					//might have to compress this down
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpg"
			FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
				if error != nil {
					print(error?.localizedDescription)
					return
				}
				
				let fileUrl = metadata!.downloadURLs![0].absoluteString
				
				let newMessage = self.messageRef.childByAutoId()
				let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
				newMessage.setValue(messageData)
			}
			
		} else if let video = video {
			let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
			print(filePath)
			let data = NSData(contentsOfURL: video)
			let metadata = FIRStorageMetadata()
			metadata.contentType = "video/mp4"
			FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
				if error != nil {
					print(error?.localizedDescription)
					return
				}
				
				let fileUrl = metadata!.downloadURLs![0].absoluteString
				
				let newMessage = self.messageRef.childByAutoId()
				let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
				newMessage.setValue(messageData)
			}

			
		}
		

		
	}




}



extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		print("Did finish picking")
		
		//get the image
		print(info)
		if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
			let photo = JSQPhotoMediaItem(image: picture)
			messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
			sendMedia(picture, video: nil)
		} else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
			let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
			messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
			sendMedia(nil, video: video)
		}
		
		
		self.dismissViewControllerAnimated(true, completion: nil)
		collectionView.reloadData()
		
		
	}
}
