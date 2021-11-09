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
    private var dronePositions: [SCNVector3]!
    
    
    private func rndm() -> SCNFloat {
        return 0.01 * SCNFloat(0.1) * ((SCNFloat(arc4random()) / SCNFloat(RAND_MAX)) - 0.5)
    }
    
    private func voxelize(scene: SCNScene, sceneView: SCNView, baseNode: SCNNode) {
        dronePositions = [SCNVector3]()
        
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
                    dronePositions.append(voxelDataNode.position)
                    voxelNode!.addChildNode(voxelDataNode)
                }//end for loop
            }//end voxel data
            
        }//end voxel array
        
    }
    
    func explode(sceneView: SCNView, scene: SCNScene, baseNode: SCNNode, completion: @escaping () -> Void) {
        voxelize(scene: scene, sceneView: sceneView, baseNode: baseNode)
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
        
        let gravityNode = SCNNode()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.7) {
            let radialGravityField = SCNPhysicsField.radialGravity()
            
            gravityNode.physicsField = radialGravityField
            gravityNode.position = SCNVector3Make(0, 0.5, 0)
            radialGravityField.strength = 1.3
            scene.rootNode.addChildNode(gravityNode)
            
        }
        
        var iterationIndex : Int  = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.3) { [self] in
            voxelNode?.enumerateChildNodes({ child, stop in
                
                child.physicsBody?.isAffectedByGravity = false
                let action = SCNAction.move(to: SCNVector3(x: dronePositions[iterationIndex].x, y: dronePositions[iterationIndex].y, z: dronePositions[iterationIndex].z),
                                                    duration: 1.5)
                
                child.runAction(action)
                
                iterationIndex += 1
                
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                gravityNode.removeFromParentNode()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                voxelNode?.enumerateChildNodes({ child, stop in
                    child.physicsBody = SCNPhysicsBody.static()
                })
            }
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  7.4) { [self] in
            voxelNode?.removeFromParentNode()
            scene.rootNode.addChildNode(baseNode)
            baseNode.geometry!.firstMaterial?.fillMode = .lines
            
            let leftRoter = baseNode.childNode(withName: "Rotor_L_2", recursively: false)!
            let anim1 = SCNAction.rotateBy(x: 0, y: 0, z: -2.1, duration: 0)
            leftRoter.runAction(anim1)
            
            
            
            let rightRoter = baseNode.childNode(withName: "Rotor_R_2", recursively: false)!
            let anim2 = SCNAction.rotateBy(x: 0, y: 0, z: 2.1, duration: 0)
            rightRoter.runAction(anim2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                let anim3 = SCNAction.rotateBy(x: 0, y: 0, z: 2.1, duration: 4)
                leftRoter.runAction(anim3)
                let anim4 = SCNAction.rotateBy(x: 0, y: 0, z: -2.1, duration: 4)
                rightRoter.runAction(anim4)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                baseNode.geometry!.firstMaterial?.fillMode = .fill
            }
            
            completion()
            
        }
        
    }
    
    
}
