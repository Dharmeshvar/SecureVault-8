//
//  SetPassword_ViewController.swift
//  SecureVault
//
//  Created by Dharmeshwar Pattaiya on 08/04/24.
//

import UIKit

class SetPassword_ViewController: UIViewController {

    
    @IBOutlet weak var setPassUiview: UIView!
    
    @IBOutlet weak var setPass_CollectionView: UICollectionView!
    
    @IBOutlet weak var circleBtnOne: UIButton!
    @IBOutlet weak var circleBtnTwo: UIButton!
    @IBOutlet weak var circleBtnThree: UIButton!
    @IBOutlet weak var circleBtnFour: UIButton!
    
    @IBOutlet weak var setPasswordLabel: UILabel!
    
    @IBOutlet weak var pinCodeLabel: UILabel!
    
    let numberFristSection = ["1","2","3","4","5","6","7","8","9"]
    let numberSecondSection = ["0"]
    var digitCount = [String]()
    var navigateHomeTimer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setPassUiview.clipsToBounds = true
        setPassUiview.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        setPassUiview.layer.cornerRadius = 15
        
        setPass_CollectionView.dataSource = self
        setPass_CollectionView.delegate = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        navigateHomeTimer = true
        clearAll()
        digitCount.removeAll()
    }
    
    func fillCircle(){
        switch digitCount.count {
        case 1:
            circleBtnOne.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        case 2:
            circleBtnTwo.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        case 3:
            circleBtnThree.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        case 4:
            circleBtnFour.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        default:
            print("invalid")
        }
    }
    
    
    @IBAction func clearButton(_ sender: Any) {
        switch digitCount.count {
            case 1:
                circleBtnOne.setImage(UIImage(systemName: "circle"), for: .normal)
            case 2:
                circleBtnTwo.setImage(UIImage(systemName: "circle"), for: .normal)
            case 3:
                circleBtnThree.setImage(UIImage(systemName: "circle"), for: .normal)
            case 4:
               circleBtnFour.setImage(UIImage(systemName: "circle"), for: .normal)
            default:
                print("invalid")
        }
        digitCount.popLast()
    }
    
   func clearAll(){
       circleBtnOne.setImage(UIImage(systemName: "circle"), for: .normal)
       circleBtnTwo.setImage(UIImage(systemName: "circle"), for: .normal)
       circleBtnThree.setImage(UIImage(systemName: "circle"), for: .normal)
       circleBtnFour.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    func alertUser(message:String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

// Mark :- DataSourceMethod

extension SetPassword_ViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return numberFristSection.count
        }else{
            return numberSecondSection.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = setPass_CollectionView.dequeueReusableCell(withReuseIdentifier: "setPassCell", for: indexPath) as! SetPassword_CollectionViewCell
      
        if indexPath.section == 0 {
                cell.setPass_Label.text = numberFristSection[indexPath.row]
        }
        else{
                cell.setPass_Label.text = numberSecondSection[indexPath.row]
        }
        cell.layer.cornerRadius = cell.frame.size.height / 2
        return cell
    }
}

// Mark :- delegate methods

extension SetPassword_ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) && digitCount.count != 5 {
           digitCount.append(numberFristSection[indexPath.row])
            fillCircle()
            
          
        }
        else if digitCount.count != 5 {
           digitCount.append(numberFristSection[indexPath.row])
            fillCircle()

        }
        else{
            alertUser(message: "enter valid password")
        }
        
        
        
        guard  digitCount.count == 4 else { return  }
       
        if navigateHomeTimer{
            var timer = Timer()
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(navigateHome), userInfo: nil, repeats: false)
        }else{
            navigateHomeTimer = false
        }
        

    }
    @objc func navigateHome(){
                var confirmDigitCount = [String]()
        
                guard let retrievedArray = UserDefaults.standard.array(forKey: "passwordKey") as? [String], !retrievedArray.isEmpty  else {
                      confirmDigitCount = digitCount
                      UserDefaults.standard.setValue(confirmDigitCount, forKey: "passwordKey")
        
                      clearAll()
                      digitCount.removeAll()
                      setPasswordLabel.text = "Confirm Password"
                      pinCodeLabel.text = "Confirm Your Pin Code"
                    return
                }
        
                if retrievedArray == digitCount{
                    UserDefaults.standard.setValue(digitCount, forKey: "passwordKey")
                    digitCount.removeAll()
                    // Mark :- navigate to another screen
                    guard let vc = storyboard?.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else{ return }
                    print("vc........")
                    navigationController?.pushViewController(vc, animated: true)
                }else{
                    alertUser(message: "Enter Wrong Password")
                    clearAll()
                    digitCount.removeAll()
                }
    }
    
}

// Mark :- flow layout

extension SetPassword_ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/4, height: setPass_CollectionView.frame.size.height / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("section : ",section)
        var lastCellCenter:UIEdgeInsets!
        if section == 1{
            lastCellCenter = UIEdgeInsets(top: 10, left: (setPass_CollectionView.frame.size.width / 2)/2, bottom: 0, right: (setPass_CollectionView.frame.size.width / 2)/2)
        }
        else{
            lastCellCenter = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
       return lastCellCenter
        
    }
    
}
