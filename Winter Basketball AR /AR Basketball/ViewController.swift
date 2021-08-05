//
//  ViewController.swift
//  Winter Basketball AR
//
//  Created by Vladislav Vitsenets on 8/02/21.
//  Copyright © 2021 Vladislav Vitsenets. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var addHoopButton: UIButton!
    
    var currentNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGesture()
    }
    
    func registerGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        sceneView.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(gestureRegocnizer: UIGestureRecognizer) {
        // Can access the sceneView
        guard let sceneView = gestureRegocnizer.view as? ARSCNView else {
            return
        }
        
        // Access the center point of the sceneView
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        // transform matrix - orientation and location of the camera - place ball here
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41 ,y: cameraTransform.m42, z:cameraTransform.m43)
        // The camera's orientation is reversed
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31 ,y: -cameraTransform.m32, z: -cameraTransform.m33 )
        // x1 + x2, y1 + y2, z1 + z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
    
        // Create Basketball geometry
        let ball = SCNSphere(radius: 0.15)
        // Create the ball material
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [ballMaterial]
        
        // Create the ball node to position the ball
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        // Create the physics shape and body
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        // Add physicsBody to the ball node in order to add force
        ballNode.physicsBody = physicsBody
        
        let forceVector : Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: cameraOrientation.y * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
        
        // Add ballNode to scene
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    // Load basketball hoop
    func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else {
            return
        }
        
        backboardNode.position = SCNVector3(x: 0, y: -0.5, z: -3)
        
        // Adding backboard interaction so the ball doesn't pass through
        // concavePolyhedron takes into concideration the entire 3D obj, including the hole of the hoop
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        // add physics body to the backboard node
        backboardNode.physicsBody = physicsBody
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        currentNode = backboardNode
    }
    
    func horizontalAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        
        // Place both action in a sequence
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        // Run the action
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    func roundAction(node: SCNNode) {
        // Actions
        let upLeft = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0), duration: 2)
        
        // Sequence
        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func startRoundAction(_ sender: Any) {
        roundAction(node: currentNode)
    }
    
    @IBAction func stopAction(_ sender: Any) {
        currentNode.removeAllActions()
    }
    
    @IBAction func startHorizontalAction(_ sender: Any) {
        horizontalAction(node: currentNode)
    }
    
    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopButton.isHidden = true
    }
    
}
