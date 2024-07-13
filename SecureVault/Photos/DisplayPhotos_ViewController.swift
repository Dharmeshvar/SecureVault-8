//
//  DisplayPhotos_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 30/04/24.
//

import UIKit
import PhotosUI
import Photos

class DisplayPhotos_ViewController: UIViewController {

    
    
    @IBOutlet weak var ImageView_Selected: UIImageView!
    
    var getimage = UIImage()
    var imageName:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageView_Selected.image = getimage
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func RestoreImage(_ sender: Any) {
        

        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let photosDirectory = documentsDirectory.appendingPathComponent("Photos")
            
            guard let imagename = imageName else { return  }
            let imageFileURL = photosDirectory.appendingPathComponent(imagename) // actual filename

            // Call the function to restore the image
            restoreImageToPhotoLibrary(imageURL: imageFileURL)
            showToast(message: "Image restored to the Photos Library successfully", font: .systemFont(ofSize: 12.0))
            delayNavigate(interval: 1) // function from ReuseCommonFunction_UiViewcontroller
          
        }

    }

    @IBAction func backNavItemBar(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func deletePhoto(_ sender: Any) {
        
        let alert = UIAlertController(title: "Alert", message: "IBy clicking 'OK', the selected photos will be permanently deleted. They cannot be recovered. Are you sure you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let photosDirectory = documentsDirectory.appendingPathComponent("Photos")
                
                guard let imagename = imageName else { return  }
                let imageFileURL = photosDirectory.appendingPathComponent(imagename) // actual filename

                do {
                    try FileManager.default.removeItem(at: imageFileURL)
                    print("Image deleted from document directory successfully")
                } catch {
                    print("Error deleting image from document directory: \(error.localizedDescription)")
                }

                
                showToast(message: "Image deleted successfully", font: .systemFont(ofSize: 12.0))
                delayNavigate(interval: 1) // function from ReuseCommonFunction_UiViewcontroller
              
            }
            print("OK button tapped.")
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func restoreImageToPhotoLibrary(imageURL: URL) {
        // Ensure the image fetching and PHPhotoLibrary operations are done sequentially
        DispatchQueue.main.async {
            // Fetch the image from the UIImageView on the main thread
            guard let image = self.ImageView_Selected.image else {
                print("Error: UIImageView does not contain an image")
                return
            }
            
            // Request authorization to access the photo library
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Error: Photo Library access is not authorized")
                    return
                }

                // Save the image to the photo library
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        print("Image restored to the photo library successfully")
                        
                        // Step 5: Delete the image from the document directory
                                       do {
                                           try FileManager.default.removeItem(at: imageURL)
                                           print("Image deleted from document directory successfully")
                                       } catch {
                                           print("Error deleting image from document directory: \(error.localizedDescription)")
                                       }
                        
                    } else {
                        print("Error restoring image to the photo library: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
           
        }
    }
    
    
}
