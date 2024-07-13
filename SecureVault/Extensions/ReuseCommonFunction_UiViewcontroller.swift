//
//  ReuseCommonFunction_UiViewcontroller.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 23/06/24.
//

import Foundation
import UIKit

extension UIViewController{
    
    func setNavigation_BackButton(titleName:String){
        let backButton = UIButton()
        backButton.setTitle(titleName, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        
        backButton.contentHorizontalAlignment = .right
        let backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
        
        // Add target and action for back button
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    // Action function for back button tap event
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // for back delayed timer
    
    func delayNavigate(interval:TimeInterval){
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(backToPhotoViewController), userInfo: nil, repeats: false)
    }
    
    @objc func backToPhotoViewController(){
        navigationController?.popViewController(animated: true)
    }
}
