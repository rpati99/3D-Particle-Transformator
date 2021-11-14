//
//  VoxelService.swift
//  Drone Particled
//
//  Created by Rachit Prajapati on 09/10/21.
//

import ModelIO
import SceneKit

final class VoxelService {
    
    static let shared = VoxelService()
    private var voxelNode: SCNNode?
    private var SCALE_FACTOR: CGFloat = 0.0250
    private var voxeledParticlePositions: [SCNVector3]!
    
    //Explosion effect at start
    private func rndm() -> SCNFloat {
        return 0.01 * SCNFloat(0.1) * ((SCNFloat(arc4random()) / SCNFloat(RAND_MAX)) - 0.5)
    }
    
    //Voxel rendering logic
    private func voxelize(scene: SCNScene, sceneView: SCNView, baseNode: SCNNode) {
        voxeledParticlePositions = [SCNVector3]()
        
        let tempScene = SCNScene()
        tempScene.rootNode.addChildNode(baseNode)
        let asset = MDLAsset(scnScene: tempScene)
        let voxelArray = MDLVoxelArray(asset: asset, divisions: 13, patchRadius: 0.0)
        
        if let voxelData = voxelArray.voxelIndices() {
            
            voxelNode?.removeFromParentNode()
            voxelNode = SCNNode()
            sceneView.scene?.rootNode.addChildNode(voxelNode!)
            
            let particle = SCNBox(width: 0.05, height:0.05, length: 0.05, chamferRadius: 0.0)
            
            voxelData.withUnsafeBytes { voxelBytes in
                let voxels = voxelBytes.bindMemory(to: MDLVoxelIndex.self).baseAddress!
                let count = voxelData.count / MemoryLayout<MDLVoxelIndex>.size
                
                for i in 0..<count {
                    let position = voxelArray.spatialLocation(ofIndex: voxels[i])
                    let voxelDataNode = SCNNode(geometry: (particle.copy() as! SCNGeometry))
                    voxelDataNode.position = SCNVector3Make(SCNFloat(position.x) + rndm(), SCNFloat(position.y), SCNFloat(position.z) + rndm())
                    voxeledParticlePositions.append(voxelDataNode.position)
                    voxelNode!.addChildNode(voxelDataNode)
                }//end for loop
            }//end voxel data
        }//end voxel array
        
    }
    
    //
    func initiateTransform(sceneView: SCNView, scene: SCNScene, baseNode: SCNNode, completion: @escaping () -> Void) {
        
        //voxelizes the model aka divides model into 3D cubes.
        voxelize(scene: scene, sceneView: sceneView, baseNode: baseNode)
        
        //Configuring the shape while enumerating SCNodes aka voxels for movements.
        let particle: SCNGeometry
        particle = SCNBox(width: 0.05, height:0.05, length: 0.05, chamferRadius: 0.0)
        
        voxelNode?.enumerateChildNodes{child, stop in
            child.physicsBody = SCNPhysicsBody.dynamic()
            child.physicsBody!.isAffectedByGravity = false
            child.physicsBody!.physicsShape = SCNPhysicsShape(geometry: particle, options: nil)
            child.position = SCNVector3(rndm(), 0.5 + rndm(), rndm())
            child.physicsField = SCNPhysicsField.vortex()
            child.physicsField?.strength = 0.004
        }
        
        //To attract cubes at the center.
        let gravityNode = SCNNode()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.7) {
            let radialGravityField = SCNPhysicsField.radialGravity()
            
            gravityNode.physicsField = radialGravityField
            gravityNode.position = SCNVector3Make(0, 0.5, 0)
            radialGravityField.strength = 1.3
            scene.rootNode.addChildNode(gravityNode)
            
        }
        
        //index to iterate array of stored positions to place the particles back, resembling shape of 3d model.
        var iterationIndex : Int  = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.3) { [self] in
            voxelNode?.enumerateChildNodes({ child, stop in
                
                child.physicsBody?.isAffectedByGravity = false
                let action = SCNAction.move(to: SCNVector3(x: voxeledParticlePositions[iterationIndex].x, y: voxeledParticlePositions[iterationIndex].y, z: voxeledParticlePositions[iterationIndex].z),
                                            duration: 1.5)
                
                child.runAction(action)
                
                iterationIndex += 1
                
            })
            
            //Removing physics fields to make the 3d particles stationary.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                gravityNode.removeFromParentNode()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                voxelNode?.enumerateChildNodes({ child, stop in
                    child.physicsBody = SCNPhysicsBody.static()
                })
            }
            
        }
        
        //Removing the voxelized drone. To present 3d model.
        DispatchQueue.main.asyncAfter(deadline: .now() +  7.4) { [self] in
            voxelNode?.removeFromParentNode()
            scene.rootNode.addChildNode(baseNode)
            baseNode.geometry!.firstMaterial?.fillMode = .lines
            
            let leftRotor = baseNode.childNode(withName: "Rotor_L_2", recursively: false)!
            let leftRotorInitialPlacement = SCNAction.rotateBy(x: 0, y: 0, z: -2.1, duration: 0)
            leftRotor.runAction(leftRotorInitialPlacement)
            
            let rightRotor = baseNode.childNode(withName: "Rotor_R_2", recursively: false)!
            let rightRotorInitialPlacement = SCNAction.rotateBy(x: 0, y: 0, z: 2.1, duration: 0)
            rightRotor.runAction(rightRotorInitialPlacement)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                let leftRotorAnimation = SCNAction.rotateBy(x: 0, y: 0, z: 2.1, duration: 4)
                leftRotor.runAction(leftRotorAnimation)
                let rightRotorAnimation = SCNAction.rotateBy(x: 0, y: 0, z: -2.1, duration: 4)
                rightRotor.runAction(rightRotorAnimation)
            }
            
            //Presenting wireframe of 3d model.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                baseNode.geometry!.firstMaterial?.fillMode = .fill
            }
            
            //For calling logic on DroneController
            completion()
        }
    }
}
