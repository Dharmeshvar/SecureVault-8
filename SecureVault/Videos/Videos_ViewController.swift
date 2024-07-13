//
//  Videos_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 17/06/24.
//

import UIKit
import PhotosUI
import AVKit
class Videos_ViewController: UIViewController {

    @IBOutlet weak var Video_CollectionView: UICollectionView!
    @IBOutlet weak var DashLine_VideoView: UIView!
    var fetchvideos_Array: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
        setNavigation_BackButton(titleName: "  VIDEOS")
        setcollectionViewCornor()
        Video_CollectionView.reloadData()
        
    }
    
    func  setcollectionViewCornor(){
        Video_CollectionView.layer.cornerRadius = 20
        Video_CollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

// collection view data source methods
extension Videos_ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        fetchvideos_Array = []
        if let videosFileURLs = fetchVideosFromDirectory() {
            fetchvideos_Array.append(contentsOf: videosFileURLs)
            if !fetchvideos_Array.isEmpty{
                DashLine_VideoView.isHidden = true
            }
            else{
                DashLine_VideoView.isHidden = false
            }
            
        } else {
            print("No videos found or an error occurred")
        }
        
        return fetchvideos_Array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let videoCell = Video_CollectionView.dequeueReusableCell(withReuseIdentifier: "VideosCell", for: indexPath) as? Videos_CollectionViewCell else{return UICollectionViewCell() }
        
        videoCell.layer.cornerRadius = 15
        videoCell.videoThumbnilImage.layer.cornerRadius = 15
        videoCell.videoPlayBtnBackGround_View.layer.cornerRadius = 15
        videoCell.addShadow()
        
        generateThumbnail(url: fetchvideos_Array[indexPath.row]) { thumbnail in
            guard let thumbnail = thumbnail else { return }
            videoCell.videoThumbnilImage?.image = thumbnail
        }
        return videoCell
    }
    
    // set collection view header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let videos_HeaderView = Video_CollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Videos_CollectionViewHeaderCell", for: indexPath) as? Videos_CollectionViewHeaderCell else{ return  UICollectionReusableView()}
            // Configure header view here
            videos_HeaderView.videosHeader_Label.text = "Videos (\(fetchvideos_Array.count))"
            return videos_HeaderView
        }
        return UICollectionReusableView()
    }
}

//  collection view delegate methods
extension Videos_ViewController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let VideoDisplayVC = storyboard?.instantiateViewController(withIdentifier: "DisplayVideos_ViewController") as? DisplayVideos_ViewController else { return }
        
        VideoDisplayVC.videoUrl_Catch = fetchvideos_Array[indexPath.row
        ]
        navigationController?.pushViewController(VideoDisplayVC, animated: true)
        print("selected cell numver is : ",indexPath.row + 1)
    }
    
    // Mark :- CollectionView flow Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ( Video_CollectionView.frame.size.width / 3.5)
        return CGSize(width:width , height: width)
    }
    
}

extension Videos_ViewController: PHPickerViewControllerDelegate{
    
    @IBAction func importVideos(_ sender: Any){
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 6
        phPickerConfig.filter = PHPickerFilter.videos
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true, completion: nil)
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var assetIdentifiersToDelete = [String]()
        let dispatchGroup = DispatchGroup()
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission denied to delete videos.")
                return
            }
            
            results.forEach { result in
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    dispatchGroup.enter()
                    // Process video
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        guard let videoURL = url, error == nil else {
                            dispatchGroup.leave()
                            return
                        }
                        
                        // Get the original filename
                        if let assetIdentifier = result.assetIdentifier {
                            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                            guard let originalFilename = asset?.value(forKey: "filename") as? String else {
                                dispatchGroup.leave()
                                return
                            }
                            
                            // Copy video to the document directory
                            self.saveVideoDocumentDirectory(originalFilename: originalFilename, videoURL: videoURL)
                            
                            assetIdentifiersToDelete.append(assetIdentifier)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if !assetIdentifiersToDelete.isEmpty {
                    PHPhotoLibrary.shared().performChanges({
                        let assetsToDelete = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiersToDelete, options: nil)
                        PHAssetChangeRequest.deleteAssets(assetsToDelete)
                    }, completionHandler: { success, error in
                        if success {
                            print("Selected assets deleted successfully.")
                            DispatchQueue.main.async { [self] in
                                getUserAlert(title: "Confirmation Alert", message: "The selected videos will be hidden from public view and moved to the 'Recently Deleted' folder. To permanently delete them, open the Photos app, go to the 'Recently Deleted' album, select videos, and delete them permanently.")
                                Video_CollectionView.reloadData()
                            }
                        } else {
                            print("Error deleting selected assets: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    })
                }
            }
        }
    }
}

// Mark :- Document directory operations like create directory and fetch video from directory
extension Videos_ViewController {
    
    func saveVideoDocumentDirectory(originalFilename: String, videoURL: URL) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access document directory")
            return
        }
        
        let videosDirectory = documentsDirectory.appendingPathComponent("Videos")
        
        if !FileManager.default.fileExists(atPath: videosDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating Videos folder: \(error.localizedDescription)")
                return
            }
        }
        
        let destinationURL = videosDirectory.appendingPathComponent(originalFilename)
        
        do {
            try FileManager.default.copyItem(at: videoURL, to: destinationURL)
            print("Video saved successfully at \(destinationURL.path)")
        } catch {
            print("Error saving video: \(error.localizedDescription)")
        }
    }
    
    // Fetch videos from document directory
    func fetchVideosFromDirectory() -> [URL]? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access document directory")
            return nil
        }
        
        let videosDirectory = documentsDirectory.appendingPathComponent("Videos")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: videosDirectory, includingPropertiesForKeys: nil)
            
            let videoExtensions = ["mp4", "mov", "m4v"]
            let videoFileURLs = fileURLs.filter { fileURL in
                return videoExtensions.contains(fileURL.pathExtension.lowercased())
            }
            
            return videoFileURLs
        } catch {
            print("Error fetching video files: \(error.localizedDescription)")
            return nil
        }
    }
}




    
