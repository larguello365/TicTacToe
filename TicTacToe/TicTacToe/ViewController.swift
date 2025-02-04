//
//  ViewController.swift
//  TicTacToe
//
//  Created by Lester Arguello on 2/1/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var Square0: UIView!
    @IBOutlet var Square1: UIView!
    @IBOutlet var Square2: UIView!
    @IBOutlet var Square3: UIView!
    @IBOutlet var Square4: UIView!
    @IBOutlet var Square5: UIView!
    @IBOutlet var Square6: UIView!
    @IBOutlet var Square7: UIView!
    @IBOutlet var Square8: UIView!
    @IBOutlet var XPiece: UILabel!
    @IBOutlet var OPiece: UILabel!
    @IBOutlet var InfoButton: UIButton!
    @IBOutlet var Hint: InfoView!
    @IBOutlet var HintText: UILabel!
    @IBOutlet var DismissButton: UIButton!
    @IBOutlet var gridView: GridView!
    var grid: Grid = Grid()
    var isXTurn: Bool = true
    var gameEnded: Bool = false
    var squares: [[UIView]] = []
    var xPiecePos: CGPoint!
    var oPiecePos: CGPoint!
    let overlayView = UIView()
    var winningLineLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        squares = [[Square0, Square1, Square2],
                  [Square3, Square4, Square5],
                  [Square6, Square7, Square8]]
        
        xPiecePos = self.XPiece.center
        oPiecePos = self.OPiece.center
        XPiece.alpha = 0.5
        OPiece.alpha = 0.5
        
        UIView.animate(withDuration: 2.0) {
            self.XPiece.alpha = 1
        }
        XPiece.isUserInteractionEnabled = true
        OPiece.isUserInteractionEnabled = false
        let panGestureX = UIPanGestureRecognizer(target: self,
                                                action: #selector(ViewController.handlePan(recognizer:)))
        let panGestureO = UIPanGestureRecognizer(target: self,
                                                action: #selector(ViewController.handlePan(recognizer:)))
        XPiece.addGestureRecognizer(panGestureX)
        OPiece.addGestureRecognizer(panGestureO)
        self.Hint.center = CGPoint(x: self.view.center.x, y: -100)
        InfoButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        DismissButton.addTarget(self, action: #selector(dismissInfo), for: .touchUpInside)
        
        overlayView.frame = self.view.frame
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
        view.sendSubviewToBack(self.overlayView)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        var xPos: Int = 0
        var yPos: Int = 0
        
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, in: self.view)
        
        if recognizer.state == .ended {
            // Check if the view intersets one of the squares
            var intersection: UIView? = nil
            var squareCenter: CGPoint = CGPoint(x: 0, y: 0)
            for i in 0..<squares.count {
                for j in 0..<squares[0].count {
                    if let piece = recognizer.view, squares[i][j].frame.intersects(piece.frame) {
                        intersection = squares[i][j]
                        squareCenter = squares[i][j].center
                        xPos = i
                        yPos = j
                        break
                    }
                    if intersection != nil {
                        break
                    }
                }
            }
            
            // Check if intersection exists
            if intersection != nil {
                // Check if space is occupied
                if grid.isPieceOccupied(xPos: xPos, yPos: yPos) {
                    bringPieceBack(piece: recognizer.view!)
                } else {
                   // If not lock the square in place
                    let piece = recognizer.view!
                    lockPieceInPlace(piece: piece, pos: squareCenter)
                    piece.isUserInteractionEnabled = false
                    
                    // Switch to next player
                    if isXTurn {
                        grid.board[xPos][yPos] = .x
                        newXPiece()
                        isXTurn = false
                        UIView.animate(withDuration: 2.0) {
                            self.OPiece.alpha = 1
                        }
                        self.OPiece.isUserInteractionEnabled = true
                    } else {
                        grid.board[xPos][yPos] = .o
                        newOPiece()
                        isXTurn = true
                        UIView.animate(withDuration: 2.0) {
                            self.XPiece.alpha = 1
                        }
                        self.XPiece.isUserInteractionEnabled = true
                    }
                    
                    // Check if game has ended
                    if let gameEnd = grid.gameOver() {
                        // If so, show the right game text and disable all interactions
                        self.gameEnded = true
                        self.Hint.center = CGPoint(x: self.view.center.x, y: -100)
                        self.view.bringSubviewToFront(self.overlayView)
                        self.XPiece.isUserInteractionEnabled = false
                        self.XPiece.alpha = 0.5
                        self.OPiece.isUserInteractionEnabled = false
                        self.OPiece.alpha = 0.5
                        
                        if gameEnd != .Draw {
                            if gameEnd == .XVictor {
                                HintText.text = "Congratulations, X wins!"
                            } else {
                                HintText.text = "Congratulations, O wins!"
                            }
                            self.drawWinningLine()
                        } else {
                            HintText.text = "It's a tie!"
                            
                            self.view.bringSubviewToFront(self.Hint)
                            UIView.animate(withDuration: 0.5) {
                                self.Hint.center = self.view.center
                            }
                        }
                    }
                }
            } else {
                bringPieceBack(piece: recognizer.view!)
            }
        }
    }
    
    func drawWinningLine() {
        let startCenter = squares[grid.startSquarePos.0][grid.startSquarePos.1].center
        let endCenter = squares[grid.endSquarePos.0][grid.endSquarePos.1].center
        
        let path = UIBezierPath()
        path.move(to: startCenter)
        path.addLine(to: endCenter)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.orange.cgColor
        lineLayer.lineWidth = 10.0
        overlayView.layer.addSublayer(lineLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.delegate = self
        
        lineLayer.add(animation, forKey: "drawLine")
        self.winningLineLayer = lineLayer
    }
    
    @objc func showInfo() {
        HintText.text = "Get 3 in a row to win!"
        self.Hint.center = CGPoint(x: self.view.center.x, y: -100)
        self.view.bringSubviewToFront(self.Hint)
        
        UIView.animate(withDuration: 0.5) {
            self.Hint.center = self.view.center
        }
        
    }
    
    @objc func dismissInfo() {
        if gameEnded {
            
            self.view.sendSubviewToBack(self.overlayView)
            
            // Fade out all pieces
            UIView.animate(withDuration: 0.5, animations: {
                self.view.subviews.forEach { subview in
                    if let label = subview as? UILabel, (label.text == "X" || label.text == "O") {
                        label.alpha = 0
                    }
                }
            }) { _ in
                // Reset the game
                self.resetGame()
                UIView.animate(withDuration: 0.5) {
                    self.Hint.center = CGPoint(x: self.view.center.x, y: 1000)
                }
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.Hint.center = CGPoint(x: self.view.center.x, y: 1000)
            }
        }
       
    }
    
    func resetGame() {
        self.view.subviews.forEach { subview in
            if let label = subview as? UILabel, (label.text == "X" || label.text == "O") {
                label.removeFromSuperview()
            }
        }
            
        // Reset grid
        grid = Grid()
        isXTurn = true
        gameEnded = false
        
        // Restore original pieces
        newXPiece()
        newOPiece()
        
        // Enable interaction again
        XPiece.isUserInteractionEnabled = false
        OPiece.isUserInteractionEnabled = false
        XPiece.alpha = 0.5
        OPiece.alpha = 0.5
        UIView.animate(withDuration: 2.0) {
            self.XPiece.alpha = 1
        }
        self.XPiece.isUserInteractionEnabled = true
    }
    
    func bringPieceBack(piece: UIView) {
        if isXTurn {
            UIView.animate(withDuration:0.5) {
                piece.center = self.xPiecePos
            }
        } else {
            UIView.animate(withDuration:0.5) {
                piece.center = self.oPiecePos
            }
        }
    }
    
    func lockPieceInPlace(piece: UIView, pos: CGPoint) {
        UIView.animate(withDuration: 0.1) {
            piece.center = pos
        }
    }
    
    func newXPiece() {
        let newX = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        newX.text = "X"
        newX.textAlignment = .center
        newX.font = UIFont.systemFont(ofSize: 90, weight: .bold)
        newX.center = xPiecePos
        newX.alpha = 0.5
        newX.backgroundColor = .systemBlue
        newX.textColor = .systemBackground
        newX.isUserInteractionEnabled = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        newX.addGestureRecognizer(panGesture)
       
        self.view.addSubview(newX)
        self.XPiece = newX
    }
    
    func newOPiece() {
        let newO = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        newO.text = "O"
        newO.textAlignment = .center
        newO.font = UIFont.systemFont(ofSize: 90, weight: .bold)
        newO.center = oPiecePos
        newO.alpha = 0.5
        newO.backgroundColor = .systemRed
        newO.textColor = .systemBackground
        newO.isUserInteractionEnabled = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        newO.addGestureRecognizer(panGesture)
        
        self.view.addSubview(newO)
        self.OPiece = newO
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.winningLineLayer?.removeFromSuperlayer()
            self.winningLineLayer = nil
            
            self.view.bringSubviewToFront(self.Hint)
            UIView.animate(withDuration: 0.5) {
                self.Hint.center = self.view.center
            }
        }
    }
}

