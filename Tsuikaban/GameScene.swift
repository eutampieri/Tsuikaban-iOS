//
//  GameScene.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 26/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import SpriteKit
import GameplayKit

extension CGSize {
    public static func -(lhs:CGSize,rhs:CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    public static func /(lhs: CGSize, rhs: Float) -> CGSize {
        return CGSize(width: lhs.width/CGFloat(rhs), height: lhs.height/CGFloat(rhs))
    }
}

extension CGPoint {
    public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    public static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    public static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs * (CGFloat(1)/rhs)
    }
    public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + (rhs*CGFloat(-1))
    }
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var board: Board! = nil
    private var boardSnapshots: [([[Block]], (Int, Int))] = []
    // When the drag began
    private var firstPoint: CGPoint! = nil
    
    public func initBoard(level: Level) {
        label?.text = level.name
        self.board = Board(levelFilePath: level.path)
        renderBoard()
    }
    func renderBoard(){
        self.removeAllChildren()
        let viewSize = self.size
        let squareWidth = min((viewSize.width / CGFloat(self.board!.size.1)), (viewSize.height / CGFloat(self.board!.size.0)))
        let blockSize = CGSize(width: squareWidth, height: squareWidth)
        let boardPixelSize: CGSize = CGSize(width: CGFloat(self.board!.size.1) * squareWidth, height: CGFloat(self.board!.size.0) * squareWidth)
        let offset = (viewSize - boardPixelSize) / 2.0
        let blocks = self.board!.blocks

        for j in 0..<blocks.count {
            for i in 0..<blocks[j].count {
                let nodePosition = CGPoint(
                    x: viewSize.width/CGFloat(-2.0) + (CGFloat(i)*squareWidth) + squareWidth/CGFloat(2.0) + offset.width,
                    y: viewSize.height/CGFloat(2.0) - (CGFloat(j)*squareWidth) - squareWidth/CGFloat(2.0) - offset.height
                )
                if (j, i) == self.board!.playerPosition {
                    let ground = SKSpriteNode(imageNamed: "ground");
                    ground.size = blockSize
                    ground.position = nodePosition
                    ground.zPosition = CGFloat(-100)
                    self.addChild(ground)
                    let node = SKSpriteNode(imageNamed: "player");
                    node.size = blockSize
                    node.position = nodePosition
                    self.addChild(node)
                } else {
                    switch blocks[j][i]{
                    case .Wall:
                        let node = SKSpriteNode(imageNamed: "wall");
                        node.size = blockSize
                        node.position = nodePosition
                        self.addChild(node)
                    case .Door:
                        let node = SKSpriteNode(imageNamed: "door");
                        node.size = blockSize
                        node.position = nodePosition
                        self.addChild(node)
                    case .Empty:
                        let node = SKSpriteNode(imageNamed: "ground");
                        node.size = blockSize
                        node.position = nodePosition
                        self.addChild(node)
                    case .Block(let colour, let content):
                        let label = SKLabelNode(text: String(content))
                        label.fontColor = SKColor(red: 0, green: 0, blue: 0, alpha: 1)
                        label.fontName = "Courier-Bold"
                        // Scale the font
                        label.fontSize = label.fontSize/75.0*squareWidth
                        label.position = nodePosition
                        label.verticalAlignmentMode = .center
                        label.zPosition = CGFloat(100)
                        let ground = SKSpriteNode(imageNamed: "ground");
                        ground.size = blockSize
                        ground.position = nodePosition
                        ground.zPosition = CGFloat(-100)
                        self.addChild(ground)
                        let node = SKSpriteNode(color: colour, size: blockSize)
                        node.texture = SKTexture(imageNamed: "cube")
                        node.colorBlendFactor = 0.8
                        node.position = nodePosition
                        self.addChild(node)
                        self.addChild(label)
                    }
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        
        if let label = self.label {
            label.alpha = 1
            //label.run(SKAction.fadeIn(withDuration: 0.0))
            //label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let numberOfTouches = CGFloat(touches.count)
        var average = CGPoint(x: 0.0, y: 0.0)
        
        for t in touches { average += t.location(in: self) }
        average = average / numberOfTouches
        self.firstPoint = average
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let numberOfTouches = CGFloat(touches.count)
        var average = CGPoint(x: 0.0, y: 0.0)
        
        for t in touches { average += t.location(in: self) }
        average = average / numberOfTouches
        let delta = average - self.firstPoint
        let direction: Direction
        if abs(delta.x) > 10 || abs(delta.y) > 10 {
            let alpha = atan2(delta.y, delta.x)
            switch alpha {
            case -0.3...0.3:
                direction = .Right
            case -1.8...(-1.2):
                direction = .Down
            case -3.2...(-2.9):
                direction = .Left
            case 2.9...3.2:
                direction = .Left
            case 1.3...1.7:
                direction = .Up
            default:
                return
            }
        } else {
            return
        }
        self.board.move(direction)
        self.renderBoard()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
