//
//  GameScene.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 26/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import SpriteKit

extension CGSize {
    public static func -(lhs:CGSize,rhs:CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    public static func *(lhs: CGSize, rhs: Float) -> CGSize {
        return CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
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
    private var board: Board! = nil
    private var ignoreGesture = false
    private weak var parentVC: GameViewController! = nil
    // When the drag began
    private var firstPoint: CGPoint! = nil
    
    public func initBoard(level: Level, vc: GameViewController) {
        label?.text = level.name
        self.board = Board(levelFilePath: level.path)
        self.parentVC = vc
        renderBoard()
    }
    func renderBoard(){
        self.removeAllChildren()
        if self.board == nil {
            return
        }
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
                let ground = SKSpriteNode(imageNamed: "ground");
                ground.size = blockSize
                ground.position = nodePosition
                ground.zPosition = CGFloat(-100)
                self.addChild(ground)
                if (j, i) == self.board!.playerPosition {
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
                        break
                    case .Block(let colour, let content):
                        let label = SKLabelNode(text: String(content))
                        label.fontColor = {() -> SKColor in
                            let brightness: CGFloat = {
                                let c: [CGFloat] = colour.cgColor.components ?? [0.0, 0.0, 0.0]
                                return c[0]*CGFloat(0.299) + c[1]*CGFloat(0.587) + c[2]*CGFloat(0.114)
                            }()
                            return brightness > 0.5 ? .black : .white
                        }()
                        label.fontName = "Courier-Bold"
                        // Scale the font
                        label.fontSize = label.fontSize/80.0*squareWidth
                        label.position = nodePosition
                        label.verticalAlignmentMode = .bottom
                        label.zPosition = CGFloat(100)
                        let node = SKShapeNode(rect: CGRect(origin: CGPoint(x: -squareWidth*0.45, y: -squareWidth*0.45), size: blockSize*0.9), cornerRadius: squareWidth*0.15)
                        node.fillColor = colour
                        node.strokeColor = label.fontColor!
                        node.position = nodePosition
                        let eyes = SKSpriteNode(imageNamed: "eyes")
                        eyes.size = blockSize
                        eyes.position = nodePosition
                        eyes.zPosition = 20
                        self.addChild(node)
                        self.addChild(label)
                        self.addChild(eyes)
                    }
                }
            }
        }
    }
    func exit() {
        self.removeAllChildren()
        self.board=nil
        self.renderBoard()
        self.parentVC.performSegue(withIdentifier: "backToLvlLst", sender: self)
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        
        if let label = self.label {
            label.alpha = 1
            //label.run(SKAction.fadeIn(withDuration: 0.0))
            //label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let numberOfTouches = CGFloat(touches.count)
        var average = CGPoint(x: 0.0, y: 0.0)
        
        for t in touches { average += t.location(in: self) }
        average = average / numberOfTouches
        self.firstPoint = average
        let activeCornerSize = min(self.size.width, self.size.height)*0.1
        let demo = self.size
        if average.x < self.size.width/(-2.0) + activeCornerSize && average.y > self.size.width/(2.0) - activeCornerSize {
            // Upper left active corner, undo
            self.ignoreGesture = true
            self.board.undo()
            self.renderBoard()
        } else if average.x > self.size.width/(2.0) - activeCornerSize && average.y > self.size.width/(2.0) - activeCornerSize {
            // Upper right active corner
            self.exit()
            self.ignoreGesture = true
            
        }
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.ignoreGesture {
            self.ignoreGesture = false
            return;
        }
        let numberOfTouches = CGFloat(touches.count)
        var average = CGPoint(x: 0.0, y: 0.0)
        
        for t in touches { average += t.location(in: self) }
        average = average / numberOfTouches
        let delta = average - self.firstPoint
        let direction: Direction
        if abs(delta.x) > 10 || abs(delta.y) > 10 {
            let tolerance = CGFloat.pi/6.0
            let alpha = atan2(delta.y, delta.x)
            switch alpha {
            case -tolerance...tolerance:
                direction = .Right
            case (-1*CGFloat.pi/2.0)-tolerance...(-1*CGFloat.pi/2.0)+tolerance:
                direction = .Down
            case CGFloat.pi-tolerance...CGFloat.pi:
                direction = .Left
            case -CGFloat.pi ... -CGFloat.pi+tolerance:
                direction = .Left
            case (CGFloat.pi/2.0)-tolerance...(CGFloat.pi/2.0)+tolerance:
                direction = .Up
            default:
                return
            }
        } else {
            return
        }
        self.board.move(direction)
        self.renderBoard()
        if self.board.playerHasWon {
            let level = Int((self.label?.text)!.replacingOccurrences(of: "Level ", with: "")) ?? 0
            UserDefaults.standard.set(max(UserDefaults.standard.integer(forKey: "lastLevel"), level+1), forKey: "lastLevel")
            (self.parentVC.presentingViewController as! LevelsViewController).enableLevel(level: level+1)
            self.exit()
            //#warning("Level won logic is not implemented yet")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
