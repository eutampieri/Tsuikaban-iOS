//
//  Models.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 26/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import Foundation
import SpriteKit

public enum Block {
    case Door
    case Wall
    case Block(SKColor, Int)
    case Empty
}

public class Board {
    private var _size: (Int, Int)
    private var _board: [[Block]]
    private var _playerPosition: (Int, Int)
    
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
    public var size: (Int, Int){
        get { return self._size }
    }
    public var blocks: [[Block]]{
        get { return self._board }
    }
    public func dumpBoard() {
        var dump = ""
        for col in _board{
            for cell in col {
                switch cell {
                case .Door:
                    dump += "D"
                case .Empty:
                    dump += "."
                case .Wall:
                    dump += "#"
                case .Block(_, _):
                    dump += "B"
                }
            }
            dump += "\n"
        }
        print(dump)
    }
}
