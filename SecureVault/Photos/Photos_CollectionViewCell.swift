//
//  Photos_CollectionViewCell.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 27/04/24.
//

import UIKit

class Photos_CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photos_Cell_Image: UIImageView!
}

extension UICollectionViewCell {
    func addShadow( color: UIColor = .black, radius: CGFloat = 5, offset: CGSize = CGSize(width: 5, height: 6), opacity: Float = 0.1) {
        let cell = self
        cell.layer.shadowColor = color.cgColor
        cell.layer.shadowOffset = offset
        cell.layer.shadowRadius = radius
        cell.layer.shadowOpacity = opacity
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = false
    }
}
