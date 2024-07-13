//
//  DisplayVideos_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 23/06/24.
//

import UIKit
import AVKit
import PhotosUI

class DisplayVideos_ViewController: UIViewController {

    var videoUrl_Catch:URL?
    
    @IBOutlet weak var videoContainerView: UIView!
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        guard let videoUrl = videoUrl_Catch else {
            print("video url not found for DisplayVideos_ViewController...")
            return
        }
        
        print("url is : ",videoUrl)
        
        playVideo(url: videoUrl)
    }
    
    
    
    func playVideo(url: URL) {
            player = AVPlayer(url: url)
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player
            
            guard let playerViewController = playerViewController else { return }
            
            // Set playerViewController's frame
            playerViewController.view.frame = videoContainerView.bounds
            
            // Add the playerViewController as a child view controller
            self.addChild(playerViewController)
            videoContainerView.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: self)
            
            // Start playing the video
            player?.play()
        }
    

    @IBAction func backTo_Video_ViewController(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
    @IBAction func restoreVideo(_ sender: Any) {
        
        guard let videoUrl = videoUrl_Catch else {
            print("video url not found for DisplayVideos_ViewController...")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
                   guard status == .authorized else {
                       print("Permission denied to save videos to photo library.")
                       return
                   }
                   
                   PHPhotoLibrary.shared().performChanges({
                       PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                   }, completionHandler: { success, error in
                       if success {
                           print("Video successfully restored to photo library.")
                           
                           // Remove the video from the document directory if needed
                           do {
                               try FileManager.default.removeItem(at: videoUrl)
                               print("Video removed from document directory.")
                           } catch {
                               print("Error removing video from document directory: \(error.localizedDescription)")
                           }
                           
                       } else {
                           print("Error restoring video to photo library: \(error?.localizedDescription ?? "Unknown error")")
                       }
                   })
               }
        
        showToast(message: "Video restored to the Photos Library successfully", font: .systemFont(ofSize: 12.0))
        delayNavigate(interval: 1) // function from ReuseCommonFunction_UiViewcontroller
        
    }
    
    
    @IBAction func videoSendTo_Cloud(_ sender: Any) {
        print("video send to cloud..")
    }
    
    
    
    @IBAction func deleteVideo(_ sender: Any) {
        guard let videoUrl = videoUrl_Catch else {
            print("video url not found for DisplayVideos_ViewController...")
            return
        }
        
        let alert = UIAlertController(title: "Alert", message: "IBy clicking 'OK', the selected video will be permanently deleted. They cannot be recovered. Are you sure you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in

            
            do {
                  try FileManager.default.removeItem(at: videoUrl)
                  print("Video deleted successfully from \(videoUrl.path)")
                }catch{
                  print("Error deleting video: \(error.localizedDescription)")
                }
            
                
                showToast(message: "Image deleted successfully", font: .systemFont(ofSize: 12.0))
                delayNavigate(interval: 1) // function from ReuseCommonFunction_UiViewcontroller
              
            }))
        present(alert, animated: true)
    }
    
                                      
                                
    
    @IBAction func shareVideo(_ sender: Any) {
        print("video share..")
    }
}
