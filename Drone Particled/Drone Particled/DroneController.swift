//
//  DroneController.swift
//  Drone Particled
//
//  Created by Rachit Prajapati on 07/10/21.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

class DroneController: UIViewController {
    
    fileprivate var scnView: SCNView!
    private var scene: SCNScene!
    fileprivate var baseNode: SCNNode!
    fileprivate var bottomViewConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!
    private var startValue = 0
    private var endValue = 100
    private var cameraNode: SCNNode!
    private var droneGeometry: SCNGeometry!
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Welcome"
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-BoldItalic", size: 30)
        label.textColor = .black
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
    
    private let initializeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "button"), for: .normal)
        button.setDimensions(width: 170, height: 100)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(initialize), for: .touchUpInside)
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
        label.textColor = .black
        return label
    }()
    
    
    private let status: UILabel = {
        let label = UILabel()
        label.text = "Flight time in 36 min"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    
    private lazy var  backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.image = UIImage(named: "design")
        return backgroundView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
    }
    
    
    @objc private func count(displayLink: CADisplayLink) {
        batteryPercentage.text = "\(startValue)%"
        startValue += 1
        if startValue == endValue {
            batteryPercentage.text = "\(endValue)%"
            displayLink.invalidate()
        }
    }
    
    
    @objc private func initialize() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            
            VoxelService.shared.explode(sceneView: scnView, scene: scene, baseNode: baseNode) {
                self.titleLabel.text = "Ready to fly"
            }
            cameraNode.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0.610, z: 1.85), duration: 10))
        }
        
        titleLabel.text = "Initializing"
        menu.alpha = 0
        
    }
    
    
    func setupScene() {
        scene = SCNScene(named: "Drone_dae.scn")
        scnView = SCNView()
        view.addSubview(scnView)
        scnView.anchor(left: view.leftAnchor, right: view.rightAnchor)
        heightConstraint = scnView.heightAnchor.constraint(equalToConstant: 350)
        scnView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height * 0.18)).isActive = true
        heightConstraint.isActive = true
        
        scnView.backgroundColor = .clear
        
        baseNode = scene?.rootNode.childNode(withName: "helicopter", recursively: true)!
        baseNode.scale = SCNVector3(2.5, 2.5, 2.5)
        
        scnView.scene?.rootNode.addChildNode(baseNode)
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true
        scnView.scene = scene
        //        baseNode.geometry!.firstMaterial?.fillMode = .lines
        
        cameraNode = scene?.rootNode.childNode(withName: "camera", recursively: false)!
        print("DBG: default \(cameraNode.position.x), \(cameraNode.position.y), \(cameraNode.position.z)")
        
        
        cameraNode.position =  SCNVector3(x: 0, y: 0.610, z: 0.67)
        
        scene!.rootNode.addChildNode(cameraNode)
    }
    
    
    
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        
        
        view.addSubview(menu)
        menu.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 16)
        
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
        
        
        view.addSubview(initializeButton)
        initializeButton.centerX(inView: backgroundView)
        initializeButton.anchor(bottom: droneIcon.topAnchor, paddingBottom: 0)
        initializeButton.setDimensions(width: view.frame.width * 0.45, height: view.frame.height * 0.15)
        
        
        view.addSubview(wifiImage)
        wifiImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 35).isActive = true
        wifiImage.anchor(bottom: initializeButton.topAnchor, paddingBottom: view.frame.height * 0.025)
        
        view.addSubview(wifiStats)
        wifiStats.anchor(left: wifiImage.rightAnchor, bottom: initializeButton.topAnchor, paddingLeft: 5, paddingBottom: view.frame.height * 0.025)
        
        view.addSubview(storageStats)
        storageStats.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40).isActive = true
        storageStats.anchor(bottom: initializeButton.topAnchor, paddingBottom: view.frame.height * 0.025)
        
        view.addSubview(storageImage)
        storageImage.anchor(bottom: initializeButton.topAnchor, right: storageStats.leftAnchor, paddingBottom: view.frame.height * 0.025, paddingRight: 7)
        
        view.addSubview(batteryLabel)
        batteryLabel.anchor(bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: view.frame.height * 0.36, paddingRight: 30)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(count))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .current, forMode: .default)
    }
    
}

