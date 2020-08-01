//
//  ViewController.swift
//  ARPortal
//
//  Created by Jérémy Perez on 31/07/2020.
//  Copyright © 2020 Jérémy Perez. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var planeDetectedLabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSCNScene()
    }
    
    // MARK: - Helpers
    func configureSCNScene() {
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureReconizer)
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScnene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScnene?.rootNode.childNode(withName: "Portal", recursively: false)
        
        let transform = hitTestResult.worldTransform
        let planeXPosition = transform.columns.3.x
        let planeYPosition = transform.columns.3.y
        let planeZPosition = transform.columns.3.z
        
        portalNode?.position = SCNVector3(planeXPosition, planeYPosition, planeZPosition)
        self.sceneView.scene.rootNode.addChildNode(portalNode!)
        
        self.addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode!, imageName: "bottom")
        
        self.addWalls(nodeName: "backWall", portalNode: portalNode!, imageName: "back")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode!, imageName: "sideA")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode!, imageName: "sideB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode!, imageName: "sideDoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode!, imageName: "sideDoorB")
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
        
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        child?.renderingOrder = 200
    }
    
    // MARK: - Selectors
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            
        }
    }
    
    // MARK: - SCNSceneRenderer
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.planeDetectedLabel.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetectedLabel.isHidden = true
        }
    }

}

