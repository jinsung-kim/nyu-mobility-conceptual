//
//  ShareVideoController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseStorage
import JGProgressHUD

class ShareVideoController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var videoURL: URL!
    var saved: String!
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func uploadVideo() {
        spinner.show(in: view)
        let storageRef = Storage.storage().reference()
        let videoRef = storageRef.child(saved[0 ..< 36])
        _ = videoRef.putFile(from: videoURL!, metadata: nil, completion: {
            (metadata, error) in
            guard metadata != nil else {
                self.alertUserSaveError(message: "The video could not be saved to the database")
                return
            }
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            print("Video uploaded")
            self.successMessage()
        })
    }
    
    /**
        Sends a request to the device to save the video to the camera
        - Parameters:
            - completion: The completion handler that returns whether the video save contained an error
     */
    func requestAuthorization(completion: @escaping () -> Void) {
        // Needs to ask phone for permissions
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        // device has already given permission to save to the camera roll
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion()
        }
    }
    
    /**
        Given the url of the video, a request is created to the photo library to be added
        - Parameters:
            - outputURL: URL that is sent to be saved
            - completion: Handles possible failures with saving the URL
        - Returns: An error if applicable
     */
    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }
    
    @IBAction func shareVideoSubmitted(_ sender: Any) {
        saveVideoToAlbum(videoURL) { error in
            if (error != nil) {
                print("There was an error saving the video")
                self.alertUserSaveError()
            }
        }
        uploadVideo()
    }
    
    func alertUserSaveError(message: String = "The video could not be saved to the camera roll") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func successMessage(message: String = "The video has been uploaded successfully") {
        let alert = UIAlertController(title: "Successfully saved",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
