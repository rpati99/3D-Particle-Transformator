//
//  VoxelService.swift
//  Drone Particled
//
//  Created by Rachit Prajapati on 09/10/21.
//

import ModelIO
import SceneKit

class VoxelService {
    
    static let shared = VoxelService()
    private var voxelNode: SCNNode?
    private var SCALE_FACTOR: CGFloat = 0.0275
    private var dronePositions: [SCNVector3]!
    
    
    private func rnd() -> SCNFloat {
        return 0.01 * SCNFloat(0.1) * ((SCNFloat(arc4random()) / SCNFloat(RAND_MAX)) - 0.5)
    }
    
    private func voxelize(scene: SCNScene, sceneView: SCNView, baseNode: SCNNode) {
        dronePositions = [SCNVector3]()
        
        let tempScene = SCNScene()
        tempScene.rootNode.addChildNode(baseNode)
        let asset = MDLAsset(scnScene: tempScene)
        let voxelArray = MDLVoxelArray(asset: asset, divisions: 13, patchRadius: 0.0)
        
        if let voxelData = voxelArray.voxelIndices() {
            
            //Create voxel parent node and add to scene
            voxelNode?.removeFromParentNode()
            voxelNode = SCNNode()
            sceneView.scene?.rootNode.addChildNode(voxelNode!)
            
            //Creation of voxel node from geometry
            let particle = SCNBox(width: 2.0 * SCALE_FACTOR, height: 2.0 * SCALE_FACTOR, length: 2.0 * SCALE_FACTOR, chamferRadius: 0.0)
            
            
            
            voxelData.withUnsafeBytes { voxelBytes in
                let voxels = voxelBytes.bindMemory(to: MDLVoxelIndex.self).baseAddress!
                let count = voxelData.count / MemoryLayout<MDLVoxelIndex>.size
                
                for i in 0..<count {
                    let position = voxelArray.spatialLocation(ofIndex: voxels[i])
                    let voxelDataNode = SCNNode(geometry: (particle.copy() as! SCNGeometry))
                    voxelDataNode.position = SCNVector3Make(SCNFloat(position.x) + rnd(), SCNFloat(position.y), SCNFloat(position.z) + rnd())
                    dronePositions.append(voxelDataNode.position)
                    voxelNode!.addChildNode(voxelDataNode)
                }//end for loop
            }//end voxel data
            
        }//end voxel array
        
    }
    
    func explode(sceneView: SCNView, scene: SCNScene, baseNode: SCNNode, completion: @escaping () -> Void) {
         voxelize(scene: scene, sceneView: sceneView, baseNode: baseNode)
        let particle: SCNGeometry
        particle = SCNBox(width: 2.0 * SCALE_FACTOR, height: 2.0 * SCALE_FACTOR, length: 2.0 * SCALE_FACTOR, chamferRadius: 0.0)
        
        // For each voxel node, apply a physics force
        voxelNode?.enumerateChildNodes{child, stop in
            child.physicsBody = SCNPhysicsBody.dynamic()
            child.physicsBody!.isAffectedByGravity = false
            child.physicsBody!.physicsShape = SCNPhysicsShape(geometry: particle, options: nil)
            child.position = SCNVector3(rnd(), 0.5 + rnd(), rnd())
            child.physicsField = SCNPhysicsField.vortex()
            child.physicsField?.strength = 0.007
            
        }
        
        let gravityNode = SCNNode()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
              let radialGravityField = SCNPhysicsField.radialGravity()
            
              gravityNode.physicsField = radialGravityField
                gravityNode.position = SCNVector3Make(0, 0.5, 0)
            radialGravityField.strength = 1.3
            scene.rootNode.addChildNode(gravityNode)

        }

        var i : Int  = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.3) { [self] in
            voxelNode?.enumerateChildNodes({ child, stop in

                
                child.physicsBody?.isAffectedByGravity = false
                let action = SCNAction.move(to: SCNVector3(x: dronePositions[i].x, y: dronePositions[i].y, z: dronePositions[i].z), duration: 1.5)
                child.runAction(action)
                i += 1

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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                baseNode.geometry!.firstMaterial?.fillMode = .fill
            }
            
               completion()
            
        }

    }
    
    
}
