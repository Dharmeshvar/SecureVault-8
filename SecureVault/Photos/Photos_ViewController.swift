//
//  Photos_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 27/04/24.
//

import UIKit
import PhotosUI

class Photos_ViewController: UIViewController{
    
// Mark :- Custom outels and variables
    var fetchImage_Array:[URL] = []
    
    @IBOutlet weak var DashLine_View: UIView!
    
    
// Mark :-  Collection View outlets
    @IBOutlet weak var Photos_CollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // getAllImages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false

        setNavigation_BackButton(titleName: "  PHOTOS")
        setcollectionViewCornor()
        Photos_CollectionView.reloadData()
       
    }
    
    
    
    func  setcollectionViewCornor(){
        Photos_CollectionView.layer.cornerRadius = 20
        Photos_CollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}


// Mark :- CollectionView data Source Methods
extension Photos_ViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchImage_Array = []
        if let imageFileURLs = fetchImagesFromDirectory() {
            fetchImage_Array.append(contentsOf: imageFileURLs)
            //print("Images added successfully to fetchImage array")
            // Now you can use fetchImage array
            if !fetchImage_Array.isEmpty{
                DashLine_View.isHidden = true
            }
            else{
                DashLine_View.isHidden = false
            }
            
        } else {
            print("No images found or an error occurred")
        }
        
       
        return fetchImage_Array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let PhotoCell = Photos_CollectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as? Photos_CollectionViewCell else { return UICollectionViewCell() }
        
        PhotoCell.photos_Cell_Image.image = UIImage(contentsOfFile: fetchImage_Array[indexPath.row].path)
        PhotoCell.layer.cornerRadius = 15
        
        PhotoCell.photos_Cell_Image.layer.cornerRadius = 15
      
        PhotoCell.addShadow()
        return PhotoCell
    }
    
    // set collection view header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Photos_CollectionViewHeaderCell", for: indexPath) as? Photos_CollectionViewHeaderCell else{ return  UICollectionReusableView()}
            // Configure header view here
            headerView.headerLabel.text = "Photos (\(fetchImage_Array.count))"
            return headerView
        }
        return UICollectionReusableView()
    }
}


// Mark :- CollectionView Delegate Methods
extension Photos_ViewController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let displayPhotoVC = storyboard?.instantiateViewController(identifier: "DisplayPhotos_ViewController") as? DisplayPhotos_ViewController else{ return }
        
        guard let image = UIImage(contentsOfFile: fetchImage_Array[indexPath.row].path()) else { return }
        displayPhotoVC.getimage = image
        displayPhotoVC.imageName = fetchImage_Array[indexPath.row].lastPathComponent
        navigationController?.pushViewController(displayPhotoVC, animated: true)
        
    }
    
    // Mark :- CollectionView flow Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ( Photos_CollectionView.frame.size.width / 3.5)
        return CGSize(width:width , height: width)
    }
}


// Mark :- Pick One Image By Import Button click
extension Photos_ViewController: PHPickerViewControllerDelegate{
    
    @IBAction func importPhotos(_ sender: Any) {
        
        
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 6
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        
        present(phPickerVC, animated: true, completion: nil)
        
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Array to store local identifiers of assets to delete
        var assetIdentifiersToDelete = [String]()
        
        // Check and request permission to delete photos
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission denied to delete photos.")
                return
            }
            
            // Add images on array for displaying on collection view
            results.forEach { result in
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    guard let image = reading as? UIImage, error == nil else { return }
                    guard let imageData = image.pngData() else {return }
                    
                    // Get the original filename (or any other metadata)
                    if let assetIdentifier = result.assetIdentifier {
                        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                        
                        guard let originalFilename = asset?.value(forKey: "filename") as? String else { return }
                        //print("Original Filename: \(originalFilename )")
                        
                        self.saveImageDocumentDirectory(originalFilename: originalFilename, imageData: imageData)
                        
                    }
                    
                }
                
                // Get the local identifier of the asset
                if let assetIdentifier = result.assetIdentifier {
                    assetIdentifiersToDelete.append(assetIdentifier)
                }
                
            }
            
            // Delete all selected assets from the photo library after processing all images
            if !results.isEmpty{
                PHPhotoLibrary.shared().performChanges({
                    let assetsToDelete = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiersToDelete, options: nil)
                    PHAssetChangeRequest.deleteAssets(assetsToDelete)
                }, completionHandler: { success, error in
                    if success {
                        print("Selected assets deleted successfully.")
                        DispatchQueue.main.async { [self] in
                            
                            // alert for delete images inside the recent delelte folder
                            getUserAlert(title: "Confirmation Alert", message: "The selected photos will be hidden from public view and moved to the 'Recently Deleted' folder.To permanently delete them:Open the Photos app, go to the 'Recently Deleted' album, select photos, and delete them permanently.Photos will remain securely stored in your Secure Vault app and will only be accessible to you.Proceed with deletion?")
                            
                            // reload colloection view after deleted images from library
                            Photos_CollectionView.reloadData()
                        }
                    } else {
                        print("Error deleting selected assets: \(error?.localizedDescription ?? "Unknown error")")
                    }
                })
            }
        }
    }
}
   
 
// Mark :- Documentdirectory operations like create directory and fetch image from directory
extension Photos_ViewController{
    
    func saveImageDocumentDirectory(originalFilename: String, imageData: Data) {
        // Get the Document Directory URL
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access document directory")
            return
        }
        
        // Create the "Photos" folder URL
        let photosDirectory = documentsDirectory.appendingPathComponent("Photos")
        
        // Create the "Photos" folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating Photos folder: \(error.localizedDescription)")
                return
            }
        }
        
        // Create the file URL for the image
        let destinationURL = photosDirectory.appendingPathComponent(originalFilename ,conformingTo: .png)
        
        // Save the image data to the file URL
        do {
            try imageData.write(to: destinationURL)
            print("Image saved successfully at \(destinationURL.path)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
        //print(fileURL)
    }

    
    // fetch images from document directory
    
    func fetchImagesFromDirectory() -> [URL]? {
        // Get the Document Directory URL
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access document directory")
            return nil
        }
        
        // Get the "Photos" directory URL
        let photosDirectory = documentsDirectory.appendingPathComponent("Photos")
        
        do {
            // Get the contents of the "Photos" directory
            let fileURLs = try FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            // Filter the contents to include only image files
            let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
            let imageFileURLs = fileURLs.filter { fileURL in
                return imageExtensions.contains(fileURL.pathExtension.lowercased())
            }
            
            return imageFileURLs
        } catch {
            print("Error fetching image files: \(error.localizedDescription)")
            return nil
        }
    }
}


//==================================================================


// Mark :- fetch all Images
/*
extension Photos_ViewController{
    func getAllImages(){
        let allphotos = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
        allphotos.enumerateObjects { asset, _, _ in
            
            let requestOption = PHImageRequestOptions()
            requestOption.isSynchronous = true
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: requestOption) { [weak self] (imageData, _) in
                if let image = imageData{
                    self?.fetchImage_Array.append(image)
                    DispatchQueue.main.async { [weak self] in
                        self?.Photos_CollectionView.reloadData()
                    }
                }
                else{
                    print("image fetch error.....")
                }
            }
            
        }
    }
}
*/
