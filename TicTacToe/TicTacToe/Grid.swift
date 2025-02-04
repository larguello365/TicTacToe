//
//  Grid.swift
//  TicTacToe
//
//  Created by Lester Arguello on 2/3/25.
//

import Foundation

enum Piece {
    case x
    case o
}

enum EndGame {
    case XVictor
    case OVictor
    case Draw
}

class Grid {
    var board: [[Piece?]]
    var startSquarePos = (0, 0)
    var endSquarePos = (0, 0)
    
    init() {
        board = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    }
    
    func isPieceOccupied(xPos: Int, yPos: Int) -> Bool {
        return board[xPos][yPos] != nil
    }
    
    func gameOver() -> EndGame? {
        // Check rows
        for row in 0..<board.count {
            if board[row][0] == board[row][1] && board[row][1] == board[row][2] && board[row][0] != nil {
                
                startSquarePos = (row, 0)
                endSquarePos = (row, 2)
                
                if board[row][0] == .x {
                    return .XVictor
                } else {
                    return .OVictor
                }
            }
        }
        
        // Check columns
        for col in 0..<board[0].count {
            if board[0][col] == board[1][col] && board[1][col] == board[2][col] && board[0][col] != nil {
                
                startSquarePos = (0, col)
                endSquarePos = (2, col)
                
                if board[0][col] == .x {
                    return .XVictor
                } else {
                    return .OVictor
                }
            }
        }
        
        // Check diagonals
        if board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != nil {
            
            startSquarePos = (0,0)
            endSquarePos = (2,2)
            
            if board[0][0] == .x {
                return .XVictor
            } else {
                return .OVictor
            }
        }
        
        if board[2][0] == board[1][1] && board[1][1] == board[0][2] && board[2][0] != nil {
            
            startSquarePos = (2, 0)
            endSquarePos = (0, 2)
            
            if board[2][0] == .x {
                return .XVictor
            } else {
                return .OVictor
            }
        }
        
        // Check for draw
        if !board.contains(where: { $0.contains(nil) }) {
            return .Draw
        }
        
        return nil
    }
}
