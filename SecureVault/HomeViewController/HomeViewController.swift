//
//  HomeViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 19/04/24.
//

import UIKit

class HomeViewController: UIViewController {

    // round background(white) uiview
    @IBOutlet weak var homeViewController_UiView: UIView!
    
    // bottom tabbar stack view
    @IBOutlet weak var bottomTabBarHStackView: UIStackView!
    
    // cloudfile stack outlets
    @IBOutlet weak var cloudFileStack: UIStackView!
  
    // collection view
    @IBOutlet weak var home_CollectionView: UICollectionView!
    
    // define arrays for collectionView
    private let lockFile_Image_Array:[String] = ["photos","videos","audio","documents"]
    private let lockFile_Name_Array:[String] = ["Photos","Videos","Audio","Documents"]
    private let lockFile_Count_Array:[String] = ["01","02","03","04"]
    private let lockFile_Cell_bgColor:[String] = ["E6E4FD","C2D9DA","EEDFDF","D6EFFA"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewController_UiView.clipsToBounds = true
        homeViewController_UiView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        homeViewController_UiView.layer.cornerRadius = 15

        bottomTabBarHStackView.clipsToBounds = true
        bottomTabBarHStackView.layer.cornerRadius = bottomTabBarHStackView.frame.size.height / 2
 
        let cloudFile_Tap = UITapGestureRecognizer(target: self, action: #selector(nextViewTap))
        cloudFileStack.addGestureRecognizer(cloudFile_Tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func nextViewTap(){
        guard  let cloudVC = storyboard?.instantiateViewController(withIdentifier: "CloudFile_ViewController") as? CloudFile_ViewController else {
            return
        }
        cloudVC.modalTransitionStyle = .crossDissolve
        cloudVC.modalPresentationStyle = .fullScreen
        present(cloudVC, animated: true, completion: nil)
     }

}


extension HomeViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let lockFile_Cell = (home_CollectionView.dequeueReusableCell(withReuseIdentifier: "lockFileCell", for: indexPath) as? HomeLockFile_CollectionViewCell) else { return
            UICollectionViewCell()
        }
        
        lockFile_Cell.layer.backgroundColor = UIColor(hex: lockFile_Cell_bgColor[indexPath.row])?.cgColor
        lockFile_Cell.layer.cornerRadius = 20
        
        lockFile_Cell.lockFileCell_Image.image = UIImage(named: lockFile_Image_Array[indexPath.row])
        lockFile_Cell.lockFileCell_Label1.text = lockFile_Name_Array[indexPath.row]
        lockFile_Cell.lockFileCell_Label2.text = lockFile_Count_Array[indexPath.row]
        
        return lockFile_Cell
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if (indexPath.row == 0){
            guard let photos_Controller = storyboard?.instantiateViewController(withIdentifier: "Photos_ViewController") as? Photos_ViewController else { return  }
            navigationController?.pushViewController(photos_Controller, animated: true)
             
        }
        else if (indexPath.row == 1){
            guard let videos_Controller = storyboard?.instantiateViewController(withIdentifier: "Videos_ViewController") as? Videos_ViewController else { return  }
            navigationController?.pushViewController(videos_Controller, animated: true)
             
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (home_CollectionView.frame.size.width / 2) - 10, height: home_CollectionView.frame.size.width / 2)
    }
}

