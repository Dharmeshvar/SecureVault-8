//
//  CloudFile_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 21/04/24.
//

import UIKit

class CloudFile_ViewController: UIViewController {
    
    // round background(white) uiview
    @IBOutlet weak var CloudFile_ViewController_UiView: UIView!
    
    // bottom tabbar stack view
    @IBOutlet weak var cloud_bottomTabBarHStackView: UIStackView!
    
    // lockfile stack outlets
    @IBOutlet weak var lockFileStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CloudFile_ViewController_UiView.clipsToBounds = true
        CloudFile_ViewController_UiView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        CloudFile_ViewController_UiView.layer.cornerRadius = 15

        cloud_bottomTabBarHStackView.clipsToBounds = true
        cloud_bottomTabBarHStackView.layer.cornerRadius = cloud_bottomTabBarHStackView.frame.size.height / 2

        let lockFile_Tap = UITapGestureRecognizer(target: self, action: #selector(backViewTap))
        lockFileStack.addGestureRecognizer(lockFile_Tap)
        
    }
    
    @objc func backViewTap(){
        dismiss(animated: true, completion: nil)
     }

   
}
