//
//  ViewController.swift
//  DJI Drone app
//
//  Created by Rachit Prajapati on 17/05/21.
//

import UIKit
import SceneKit



class ViewController: UIViewController {
    
    fileprivate var scnView: SCNView!
    fileprivate var baseNode: SCNNode!
    fileprivate var bottomViewConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!
    private var startValue = 0
    private var endValue = 96
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "DJI \n大疆创新"
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-BoldItalic", size: 30)
        label.textColor = .white
        return label
    }()

    
    private let menu: UIImageView = {
        let menu = UIImageView()
        menu.image = UIImage(named: "menu")
        menu.setDimensions(width: 30, height: 30)
        return menu
    }()
    
   
    private let batteryLabel: UILabel = {
        let label = UILabel()
        label.text = "Battery >"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    
    private let storageImage: UIImageView = {
        let storageImage = UIImageView()
        storageImage.image = UIImage(named: "storage")
        storageImage.setDimensions(width: 45, height: 45)
        return storageImage
    }()
    
    private let wifiImage: UIImageView = {
        let wifiImage = UIImageView()
        wifiImage.image = UIImage(named: "wifi")
        wifiImage.setDimensions(width: 45, height: 45)
        return wifiImage
    }()
    
    private let storageStats: UILabel = {
        let label = UILabel()
        label.text = "58 GB\nof 128 GB"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let wifiStats: UILabel = {
        let label = UILabel()
        label.text = "Connected:- \nStrong"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let flyButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "button"), for: .normal)
        button.setDimensions(width: 170, height: 100)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(removeViews), for: .touchUpInside)
        return button
    }()
    
    
    private let droneIcon: UIImageView = {
        let droneIcon = UIImageView()
        droneIcon.image = UIImage(named: "drone")
        droneIcon.setDimensions(width: 35, height: 35)
        return droneIcon
    }()
    
    private let droneLabel: UILabel = {
        let label = UILabel()
        label.text = "Drone"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let folderIcon: UIImageView = {
        let folderIcon = UIImageView()
        folderIcon.image = UIImage(named: "folder")
        folderIcon.setDimensions(width: 35, height: 35)
        return folderIcon
    }()
 
    private let userIcon: UIImageView = {
        let userIcon = UIImageView()
        userIcon.image = UIImage(named: "user")
        userIcon.setDimensions(width: 35, height: 35)
        return userIcon
    }()
    
    private let batteryPercentage: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textColor = .white
        return label
    }()

   
    private let status: UILabel = {
        let label = UILabel()
        label.text = "Flight time in 36 min"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    
    private let borders: UIImageView = {
        let border = UIImageView()
        border.image  = UIImage(named: "borders")
        return border
    }()
    
 
 
    
    private lazy var  backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.image = UIImage(named: "design")
        
        
        
        return backgroundView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDrone()
        animateBorders()
    }

    
    @objc private func count(displayLink: CADisplayLink) {
        batteryPercentage.text = "\(startValue)%"
        startValue += 1
        if startValue == endValue {
            batteryPercentage.text = "\(endValue)%"
            displayLink.invalidate()
        }
    }
    

    @objc func removeViews() {
        
        borders.removeFromSuperview()
      
        bottomViewConstraint.constant += 1000
        heightConstraint.constant += 350
        flyButton.layer.position.y += 1000
        wifiImage.layer.position.y += 1000
        wifiStats.layer.position.y += 1000
        storageImage.layer.position.y += 1000
        storageStats.layer.position.y += 1000
        droneIcon.layer.position.y += 1000
        droneLabel.layer.position.y += 1000
        folderIcon.layer.position.y += 1000
        userIcon.layer.position.y += 1000
        batteryLabel.layer.position.y += 1000
        UIView.animate(withDuration: 1.5) {
            self.view.layoutIfNeeded()
            self.flyButton.removeFromSuperview()
            self.wifiStats.removeFromSuperview()
            self.wifiImage.removeFromSuperview()
            self.storageStats.removeFromSuperview()
            self.storageImage.removeFromSuperview()
            self.droneIcon.removeFromSuperview()
            self.droneLabel.removeFromSuperview()
            self.folderIcon.removeFromSuperview()
            self.userIcon.removeFromSuperview()
            self.batteryLabel.removeFromSuperview()
        }
        let rotation1 = SCNAction.rotateBy(x: 2, y: 8, z: 2, duration: 3)
        baseNode.runAction(rotation1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let rotation2 = SCNAction.rotateBy(x: 1, y: 2, z: 1, duration: 1)
            self.baseNode.runAction(rotation2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 2.0) {
                self.scnView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                self.scnView.alpha = 0
                self.titleLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                self.titleLabel.alpha = 0
                self.menu.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                self.menu.alpha = 0
                self.view.backgroundColor = .black
            }
        }
        
    
        
    }
    
    
    func animateBorders() {
        UIView.animate(withDuration:  0.75) {
            self.borders.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.75) {
                self.borders.alpha = 0
            } completion: {  _ in
                UIView.animate(withDuration: 0.5) {
                    self.borders.alpha = 1
                } completion: { _ in
                    UIView.animate(withDuration: 0.5) {
                        self.borders.alpha = 0
                    } completion: { _ in
                        UIView.animate(withDuration: 0.5) {
                            self.borders.alpha = 1
                        } completion: { _ in
                            UIView.animate(withDuration: 0.5) {
                                self.borders.alpha = 0
                            } completion: { _  in
                                UIView.animate(withDuration: 0.5) {
                                    self.borders.alpha = 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func setupDrone() {
        let scene = SCNScene(named: "Controllable Drone Animation Test.dae")
        scnView = SCNView()
                view.addSubview(scnView)
        scnView.anchor(left: view.leftAnchor, right: view.rightAnchor)
        heightConstraint = scnView.heightAnchor.constraint(equalToConstant: 350)
        scnView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height * 0.18)).isActive = true
        heightConstraint.isActive = true
        scnView.backgroundColor = .clear
        
        
        baseNode = scene?.rootNode.childNode(withName: "helicopter", recursively: false)!

        scnView.scene?.rootNode.addChildNode(baseNode)
        
        scnView.scene = scene
        let leftRoter = baseNode.childNode(withName: "Rotor_L_2", recursively: false)!
        let anim1 = SCNAction.rotateBy(x: 0, y: 1.6, z: 0, duration: 0)
        leftRoter.runAction(anim1)
        
       

        let rightRoter = baseNode.childNode(withName: "Rotor_R_2", recursively: false)!
        let anim2 = SCNAction.rotateBy(x: 0, y: -1.6, z: 0, duration: 0)
        rightRoter.runAction(anim2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            let anim3 = SCNAction.rotateBy(x: 0, y: -1.6, z: 0, duration: 4)
            leftRoter.runAction(anim3)
            let anim4 = SCNAction.rotateBy(x: 0, y: 1.6, z: 0, duration: 4)
            rightRoter.runAction(anim4)
        }
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .darkGray
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)

        
        view.addSubview(menu)
        menu.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 16)
    
        view.addSubview(borders)
        borders.layer.shadowColor = UIColor.green.cgColor
        borders.alpha = 0
        borders.layer.shadowRadius = 2.0
        borders.layer.shadowOpacity = 1.0
        borders.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: -25, paddingRight: -25, height: (view.frame.height * 0.425) + 10)
        
        view.addSubview(backgroundView)
        bottomViewConstraint = backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomViewConstraint.isActive = true
        backgroundView.anchor(left: view.leftAnchor, right: view.rightAnchor, height: view.frame.height * 0.425)
        
        
        view.addSubview(status)
        status.adjustsFontSizeToFitWidth = true
        status.anchor(left: view.leftAnchor, bottom: backgroundView.topAnchor, paddingLeft: 16, paddingBottom: -20, width: (view.frame.width / 2) - 10)
        
        
        view.addSubview(batteryPercentage)
        batteryPercentage.adjustsFontSizeToFitWidth = true
        batteryPercentage.anchor(left: view.leftAnchor, bottom: status.topAnchor, paddingLeft: 16 , paddingBottom: -5, width: 80)

        
        view.addSubview(droneIcon)
        droneIcon.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 56, paddingBottom: 30)
        view.addSubview(droneLabel)
        droneLabel.anchor(top: droneIcon.bottomAnchor, left: view.leftAnchor, paddingTop: 2, paddingLeft: 53)
        view.addSubview(folderIcon)
        folderIcon.centerX(inView: view)
        folderIcon.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 30)
        
        view.addSubview(userIcon)
        userIcon.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 30, paddingRight: 53)
     
        
        view.addSubview(flyButton)
        flyButton.centerX(inView: backgroundView)
        flyButton.anchor(bottom: droneIcon.topAnchor, paddingBottom: 0)
        flyButton.setDimensions(width: view.frame.width * 0.45, height: view.frame.height * 0.15)
        
        

        

        view.addSubview(wifiImage)
        wifiImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 35).isActive = true
        wifiImage.anchor(bottom: flyButton.topAnchor, paddingBottom: view.frame.height * 0.025)
        
        view.addSubview(wifiStats)
        wifiStats.anchor(left: wifiImage.rightAnchor, bottom: flyButton.topAnchor, paddingLeft: 5, paddingBottom: view.frame.height * 0.025)

        view.addSubview(storageStats)
        storageStats.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40).isActive = true
        storageStats.anchor(bottom: flyButton.topAnchor, paddingBottom: view.frame.height * 0.025)

        view.addSubview(storageImage)
        storageImage.anchor(bottom: flyButton.topAnchor, right: storageStats.leftAnchor, paddingBottom: view.frame.height * 0.025, paddingRight: 7)
        
        view.addSubview(batteryLabel)
        batteryLabel.anchor(bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: view.frame.height * 0.36, paddingRight: 30)
  
        
        let displayLink = CADisplayLink(target: self, selector: #selector(count))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .current, forMode: .default)
        
        
        
    
    }
    
}

