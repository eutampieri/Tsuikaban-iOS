//
//  GameViewController.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 26/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    public var level: Level? = nil
    private var scene: SKScene? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            self.scene = SKScene(fileNamed: "GameScene")
            // Load the SKScene from 'GameScene.sks'
            if let scene = self.scene{
                // Set the scale mode to scale to fit the window
                scene.size = UIScreen.main.bounds.size
                scene.scaleMode = .aspectFit
                // Present the scene
                view.presentScene(scene)
                (scene as! GameScene).initBoard(level: self.level!, vc: self)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    #if os(iOS)
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let scene = self.scene{
            scene.size = UIScreen.main.bounds.size
            scene.scaleMode = .aspectFit
            (scene as! GameScene).renderBoard()
        }
    }
    #endif
}
