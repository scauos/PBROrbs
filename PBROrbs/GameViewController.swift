//
//  GameViewController.swift
//  PBROrbs
//
//  Created by Avihay Assouline on 23/07/2016.
//  Copyright © 2016 MediumBlog. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scnCameraNode: SCNNode!
    var scnCamera: SCNCamera!
    

    let materialPrefixes : [String] = ["bamboo-wood-semigloss",
                                       "oakfloor2",
                                       "scuffed-plastic",
                                       "rustediron-streaks",
                                       "gold-scuffed",
                                       "greasy-metal-pan1",
                                       "harshbricks"];
    
    
    
    @IBOutlet weak var scnView: SCNView!
    @IBAction func wantsHDRButtonTapped(_ sender: UISwitch) {
        print(scnCamera)
        scnCamera.wantsHDR = sender.isOn
    }
    @IBAction func wantsExposureAdaptationTapped(_ sender: UISwitch) {
        scnCamera.wantsExposureAdaptation = sender.isOn
    }
    
    
    @IBAction func firstSlider(_ sender: UISlider) {
        scnCamera.exposureOffset = CGFloat(sender.value)
    }
    @IBAction func secondSlider(_ sender: UISlider) {
        scnCamera.averageGray = CGFloat(sender.value)
    }
    
    @IBAction func thirdSlider(_ sender: UISlider) {
        scnCamera.whitePoint = CGFloat(sender.value)
    }
    
    @IBAction func forthSlider(_ sender: UISlider) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "sphere.obj")!
        print("1")
        
        
        // select the sphere node - As we know we only loaded one object
        // we select the first item on the children list
        let sphereNode = scene.rootNode.childNodes[0]
        
        // create and add a camera to the scene
        scnCameraNode = SCNNode()
        scnCamera = SCNCamera()
        scnCameraNode.camera = scnCamera
        scene.rootNode.addChildNode(scnCameraNode)
        
        // place the camera
        scnCameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let material = sphereNode.geometry?.firstMaterial
        
        // Declare that you intend to work in PBR shading mode
        // Note that this requires iOS 10 and up
        material?.lightingModel = SCNMaterial.LightingModel.physicallyBased
        
        // Setup the material maps for your object
        let materialFilePrefix = materialPrefixes[5]
        material?.diffuse.contents = UIImage(named: "\(materialFilePrefix)-albedo.png")
        
        material?.roughness.contents = UIImage(named: "\(materialFilePrefix)-roughness.png")
        material?.metalness.contents = UIImage(named: "\(materialFilePrefix)-metal.png")
        material?.normal.contents = UIImage(named: "\(materialFilePrefix)-normal.png")
        
        let sphereNode2 = sphereNode.clone()
        sphereNode2.position = SCNVector3(x: 0, y: 0, z: -20)
        scene.rootNode.addChildNode(sphereNode2)
        print("2")
        
        //add a liteNode
        let liteNode = SCNNode()
        liteNode.light = SCNLight()
        
        liteNode.light?.iesProfileURL = URL(fileReferenceLiteralResourceName: "LF6N_1_42TRT_F6LS73.ies")
        
        liteNode.light?.type = .IES
        
        scene.rootNode.addChildNode(liteNode)
        print("3")
        
        liteNode.position = SCNVector3(x: 10, y: 10, z: 30)
        
        
        
        // Setup background - This will be the beautiful blurred background
        // that assist the user understand the 3D envirnoment
        let bg = UIImage(named: "sphericalBlurred.png")
        scene.background.contents = bg;
        
        // Setup Image Based Lighting (IBL) map
        let env = UIImage(named: "interior_hdri_29_20150416_1169368110.jpg")
//        scene.lightingEnvironment.contents = env
//        scene.lightingEnvironment.intensity = 2.0
        print("4")
        
        SCNTransaction.begin()
        scene.rootNode.addChildNode(addGeometrySphere())
        SCNTransaction.commit()
        
        scnView.scene = scene
        
        // Notallows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        
        /* 
         * The following was not a part of my blog post but are pretty easy to understand:
         * To make the Orb cool, we'll add rotation animation to it
         */
        sphereNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 1, duration: 10)))
        sphereNode2.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 1, duration: 10)))
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func addGeometrySphere() -> SCNNode {
        let sphere = SCNSphere(radius: 3)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphere.firstMaterial?.specular.contents = UIColor.white
        sphere.firstMaterial?.specular.intensity = 1.0
        sphere.firstMaterial?.shininess = 0.1
        sphere.firstMaterial?.reflective.contents = UIImage(named: "envmap.jpg")
        sphere.firstMaterial?.fresnelExponent = 2

        
        let node = SCNNode()
        node.geometry = sphere
        node.position = SCNVector3(x: -12, y: 3, z: 0)
        node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -(Float)(M_PI_4))
        node.geometry!.firstMaterial?.lightingModel = .lambert
        let surfaceModifier = Bundle.main.path(forResource: "sm_surf", ofType: "shader")
        node.geometry!.shaderModifiers = [SCNShaderModifierEntryPoint.surface: surfaceModifier!]
        
        return node
    }
    

}
