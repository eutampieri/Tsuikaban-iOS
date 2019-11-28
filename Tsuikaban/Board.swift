//
//  Models.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 26/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import Foundation
import SpriteKit

public enum Block: Equatable {
    case Door
    case Wall
    case Block(SKColor, Int)
    case Empty
}

public enum Direction {
    case Up
    case Right
    case Down
    case Left
}

public class Board {
    private var _size: (Int, Int)
    private var _board: [[Block]]
    private var _playerPosition: (Int, Int)
    private var _playerHasWon = false
    private var snapshots: [((Int, Int), [[Block]])] = []
    
    convenience init(levelFilePath: String) {
        let levelData: String
        do {
            levelData = try String(contentsOfFile: levelFilePath, encoding: .utf8)
        } catch {
            //levelData = "0 0\n0 0\
            levelData = """
            6 10
            ##########
            #.....##D#
            #........#
            #.....####
            #.....####
            ##########
            1 1
            9
            2 2 255 0 0 1
            3 2 255 0 0 2
            4 2 255 0 0 3
            4 3 0 255 255 3
            3 3 0 255 255 2
            2 3 0 255 255 1
            6 2 0 255 255 -2
            7 2 255 0 0 -4
            8 2 0 255 255 -4
            """
        }
        self.init(levelText: levelData)
    }
    
    init(levelText: String) {
        let rows = levelText.components(separatedBy: "\n")
        // Initialize the size
        let sizeArray = rows[0].components(separatedBy: " ").map{Int($0)!}
        _size = (sizeArray[0], sizeArray[1])
        // Inizialize the board
        _board = []
        for i in 0..<_size.0 {
            let row: [Block] = Array(rows[i+1]).map {
                let block: Block
                switch $0 {
                case "#":
                    block = Block.Wall
                case "D":
                    block = Block.Door
                default:
                    block = Block.Empty
                }
                return block
            }
            _board.append(row)
        }
        // Set the player position
        let playerPosArray = rows[_size.0 + 1].components(separatedBy: " ").map{Int($0)!}
        _playerPosition = (playerPosArray[0], playerPosArray[1])
        // Fill the blocks
        let numberOfBlocks = Int(rows[_size.0 + 2])!
        for i in 0..<numberOfBlocks {
            let blockData = rows[i + _size.0 + 3].components(separatedBy: " ").map{Int($0)!}
            _board[blockData[1]][blockData[0]] = Block.Block(
                SKColor(
                    red: CGFloat(Float(blockData[2])/255.0),
                    green: CGFloat(Float(blockData[3])/255.0),
                    blue: CGFloat(Float(blockData[4])/255.0),
                    alpha: 1
                ),
                blockData[5]
            )
        }
    }
    public var playerPosition: (Int, Int){
        get { return self._playerPosition }
    }
    public var playerHasWon: Bool {
        get { return self._playerHasWon }
    }
    public var size: (Int, Int){
        get { return self._size }
    }
    public var blocks: [[Block]]{
        get { return self._board }
    }
    private func tryMove(coord: (Int, Int), to: Direction) -> Bool {
        var finalPosition: (Int, Int) = coord
        switch to {
        case .Up:
            finalPosition.0 -= 1
        case .Right:
            finalPosition.1 += 1
        case .Down:
            finalPosition.0 += 1
        case .Left:
            finalPosition.1 -= 1
        }
        if finalPosition.0 < 0 || finalPosition.1 < 0 || finalPosition.0 >= self.size.0 || finalPosition.1 >= self.size.1 {
            return false
        }
        // If we're trying to move the player or a block
        let moveBlock = coord != self._playerPosition
        switch self._board[finalPosition.0][finalPosition.1] {
        case .Empty:
            if moveBlock {
                let old = self._board[coord.0][coord.1]
                self._board[coord.0][coord.1] = self._board[finalPosition.0][finalPosition.1]
                self._board[finalPosition.0][finalPosition.1] = old
            }
            return true;
        case .Wall:
            return false;
        case .Door:
            // If we're trying to move a block over a door then forbid it!
            self._playerHasWon = !moveBlock
            return !moveBlock
        case .Block(let colour, let value):
            if moveBlock{
                // If we're moving a block check if we can add it
                switch self._board[coord.0][coord.1] {
                case .Block(let currentColour, let currentValue):
                    if colour == currentColour {
                        self._board[coord.0][coord.1] = .Empty
                        if value + currentValue == 0 {
                            // If the two blocks cancel each other
                            self._board[finalPosition.0][finalPosition.1] = .Empty
                        } else {
                            // Sum the blocks
                            self._board[finalPosition.0][finalPosition.1] = .Block(colour, value + currentValue)
                        }
                        return true
                    }
                default:
                    break
                }
            }
            let canMove = self.tryMove(coord: finalPosition, to: to)
            if canMove && moveBlock {
                let old = self._board[coord.0][coord.1]
                self._board[coord.0][coord.1] = self._board[finalPosition.0][finalPosition.1]
                self._board[finalPosition.0][finalPosition.1] = old
            }
            return canMove
        /*default:
            #warning("This switch should be exhaustive!")
            return false;*/
        }
    }
    public func move(_ direction: Direction) {
        let snapshot = (self.playerPosition, self._board)
        if !self.tryMove(coord: self.playerPosition, to: direction) {
            return
        }
        if snapshot.1 != self._board {
            // Save the snapshot
            self.snapshots.append(snapshot)
        }
        switch direction {
        case .Up:
            self._playerPosition.0 -= 1
        case .Right:
            self._playerPosition.1 += 1
        case .Down:
            self._playerPosition.0 += 1
        case .Left:
            self._playerPosition.1 -= 1
        }
    }
    public func undo() {
        if self.snapshots.count == 0 {
            return
        }
        let snapshot = self.snapshots.popLast()!
        self._playerPosition = snapshot.0
        self._board = snapshot.1
    }
    public func clear() {
        self._board = []
        self.snapshots = []
    }
}
