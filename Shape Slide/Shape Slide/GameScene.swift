//
//  GameScene.swift
//  Shape Slide
//
//  Created by 90307332 on 3/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit
import GameplayKit
import StoreKit

enum PanelState {
    case PUZZLE
    case LEVELS
    case OPTIONS
}

class GameScene: SKScene {
    
    private var scale: Double?
    private var puzzle: Puzzle?
    private var level = 0
    
    var restartButton: SKShapeNode?
    let levelNum = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    var firstLevelOnLevelsPanel = 0
    var settingsPanel: SKNode!
    var levelsPanel: SKNode!
    
    var viewController: UIViewController!
    
    override func didMove(to view: SKView) {
        self.level = DataStore.getLevel()
        self.backgroundColor = ColorPallete.BACKGROUND
        
        let layout = Levels.getLayout(num: level)
        self.scale = Double(view.frame.width) /  Double(layout.count) * 0.5 // figure out how to scale
        self.puzzle = Puzzle(layout: layout, scale: scale!)
        self.addChild(puzzle!)

        self.settingsPanel = initSettingsPanel()
        self.levelsPanel = initLevelsPanel(firstLevel: firstLevelOnLevelsPanel)
        setupSwipeDetector()
        
        //debug()
        
        // -- -- --  -- - - -- - -- - ---- --- -- --- -- -- -- --- --- -- -- - -- -- -- -- -- - - -- -- - -- - -- - - //
        
        // bad code
        
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.fontSize = 75
        title.text = "Shape Slide"
        title.fontColor = ColorPallete.TEXT
        title.position = CGPoint(x: 0, y: Double(layout[0].count) * scale! / 2 + 135)
        addChild(title)
        
        levelNum.fontSize = 50
        levelNum.text = "Level \(level)"
        levelNum.fontColor = ColorPallete.PUZZLE_BACK
        levelNum.position = CGPoint(x: 0, y: Double(layout[0].count) * scale! / 2 + 10)
        addChild(levelNum)
        
        restartButton = SKShapeNode(rectOf: CGSize(width: scale!, height: scale!), cornerRadius: 25)
        //restartButton?.lineWidth = 20
        restartButton?.fillColor = ColorPallete.PUZZLE_BACK
        restartButton?.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        restartButton?.position = CGPoint(x: 0, y: -300)
        restartButton?.name = "Restart"
        
        let restartIcon = SKSpriteNode(imageNamed: "restart")
        restartIcon.name = "Restart"
        restartIcon.scale(to: CGSize(width: 50, height: 50))
        restartIcon.zRotation = CGFloat(Double.pi)
        restartButton?.addChild(restartIcon)
        
        addChild(restartButton!)
        
        // ---- ---- -- --- -- -- -- ---- ----- ---- ----- ------- ------ ----- ----- ----- //
        
        let settings = SKSpriteNode(imageNamed: "settings.png")
        settings.position = CGPoint(x: view.frame.width/2-50, y: view.frame.height/2-50)
        settings.scale(to: CGSize(width: 30, height: 30))
        settings.name = "Settings"
        addChild(settings)
        
        let levels = SKSpriteNode(imageNamed: "menu")
        levels.scale(to: CGSize(width: 35, height: 35))
        levels.name = "Levels"
        levels.position = CGPoint(x: view.frame.width/2-50, y: view.frame.height/2-90)
        addChild(levels)
    }
    
    private func setupSwipeDetector() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(swipe:)))
            swipeRight.direction = direction
            view!.addGestureRecognizer(swipeRight)
        }
    }
    
    @objc func onSwipe(swipe: UISwipeGestureRecognizer) {
        if panelState == PanelState.PUZZLE {
            swipeActionForPuzzleState(swipe: swipe)
        }
    }
    
    func swipeActionForPuzzleState(swipe: UISwipeGestureRecognizer) {
        if panelState != PanelState.PUZZLE || dragStartLoc == nil {
            return
        }
        
        let endLoc: (Int, Int)
        switch swipe.direction {
        case UISwipeGestureRecognizer.Direction.left:
            endLoc = puzzle!.calcEndTile(start: dragStartLoc!, dir: (-1, 0))
            break
        case UISwipeGestureRecognizer.Direction.right:
            endLoc = puzzle!.calcEndTile(start: dragStartLoc!, dir: (1, 0))
            break
        case UISwipeGestureRecognizer.Direction.up:
            endLoc = puzzle!.calcEndTile(start: dragStartLoc!, dir: (0, 1))
            break
        case UISwipeGestureRecognizer.Direction.down:
            endLoc = puzzle!.calcEndTile(start: dragStartLoc!, dir: (0, -1))
            break
        default:
            return
        }

        puzzle?.moveTile(start: dragStartLoc!, end: endLoc)
        dragStartLoc = nil
        
        if puzzle!.solved() {
            //nextLevelButton.text = "Next Level"
            let nextLevelButton = puzzle!.getFinalSprite()!
            
            let wait = SKAction.wait(forDuration: 0.3)
            
            let move = SKAction.move(to: CGPoint(x: (restartButton?.frame.width)!/2+10, y: -300), duration: 0.2)
            let rotate = SKAction.rotate(byAngle: CGFloat(2*Double.pi), duration: 0.2)
            let scale = SKAction.scale(by: 2, duration: 0.2)
            let moveRotateScale = SKAction.group([move, rotate, scale])
            
            let moveRestart = SKAction.run {
                self.restartButton?.run(SKAction.moveTo(x: -(self.restartButton?.frame.width)!/2-10, duration: 0.2))
            }
            let group = SKAction.group([moveRestart, moveRotateScale])
            
            let addLabel = SKAction.run {
                self.nextButton = SKShapeNode(rectOf: CGSize(width: self.scale!, height: self.scale!), cornerRadius: 25)
                self.nextButton?.fillColor = nextLevelButton.fillColor
                self.nextButton?.strokeColor = nextLevelButton.strokeColor
                self.nextButton?.position = CGPoint(x: -(self.restartButton?.position.x)!, y: -300)
                //next.name = "NextLevel"
                
                let nextlevelIcon = SKSpriteNode(imageNamed: "next")
                nextlevelIcon.name = "NextLevel"
                nextlevelIcon.scale(to: CGSize(width: 60, height: 60))
                self.nextButton?.addChild(nextlevelIcon)
                
                self.addChild(self.nextButton!)
                nextLevelButton.removeFromParent()
            }
            
            let sequence = SKAction.sequence([wait, group, addLabel])
            nextLevelButton.run(sequence)
        }
    }
    
    
    
    
    
    
    private var dragStartLoc: (Int, Int)?
    private var nextButton: SKShapeNode?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLoc = (touches.first?.location(in: puzzle!))!
        dragStartLoc = puzzle!.tilePositionFromScreen(x: Double(touchLoc.x), y: Double(touchLoc.y))
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "NextLevel" {
                nextLevel()
                restartButton?.run(SKAction.moveTo(x: 0, duration: 0.2))
                nextButton?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1), SKAction.removeFromParent()]))
                break
            }else if touchedNode.name == "Restart" {
                if panelState != PanelState.PUZZLE {
                    break
                }
                
                level -= 1
                nextLevel()
                restartButton?.run(SKAction.moveTo(x: 0, duration: 0.2))
                nextButton?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1), SKAction.removeFromParent()]))
                break
            }else if touchedNode.name == "Settings" {
                setPanelState(state: panelState == PanelState.OPTIONS ? PanelState.PUZZLE : PanelState.OPTIONS)
                break
            }else if touchedNode.name == "Levels" {
                if panelState != PanelState.LEVELS {
                    firstLevelOnLevelsPanel = level / 16 * 16 // fancy code
                    levelsPanel = initLevelsPanel(firstLevel: firstLevelOnLevelsPanel)
                }
                setPanelState(state: panelState == PanelState.LEVELS ? PanelState.PUZZLE : PanelState.LEVELS)
                break
            }else if touchedNode.name == "ResetProgress" {
                setPanelState(state: PanelState.PUZZLE)
                level = -1
                nextLevel()
                restartButton?.run(SKAction.moveTo(x: 0, duration: 0.2))
                nextButton?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1), SKAction.removeFromParent()]))
                break
            }else if touchedNode.name == "Rate" {
                // Replace appId with my app id
                if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)

                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                break
            }else if touchedNode.name == "Theme" {
                print("pressed theme")
                break
            }else if touchedNode.name == "PrevLevelSlide" {
                if firstLevelOnLevelsPanel == 0 {
                    break
                }
                
                firstLevelOnLevelsPanel -= 16
                levelsPanel.removeFromParent()
                levelsPanel = initLevelsPanel(firstLevel: firstLevelOnLevelsPanel)
                addChild(levelsPanel)
                
                break
            }else if touchedNode.name == "NextLevelSlide" {
                if firstLevelOnLevelsPanel+16 > Levels.amount() {
                    break
                }
                
                firstLevelOnLevelsPanel += 16
                levelsPanel.removeFromParent()
                levelsPanel = initLevelsPanel(firstLevel: firstLevelOnLevelsPanel)
                addChild(levelsPanel)
                
                break
            }
            
            
            
            // LEVEL SELECT
            if panelState == PanelState.LEVELS && touchedNode.name != nil {
                let levelNum = Int(touchedNode.name!)
                if levelNum != nil {
                    setPanelState(state: PanelState.PUZZLE)
                    level = levelNum!-1
                    nextLevel()
                    restartButton?.run(SKAction.moveTo(x: 0, duration: 0.2))
                    nextButton?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1), SKAction.removeFromParent()]))
                    break
                }
            }
        }
        
        
        // DEBUG BUTTONS (will be removed)
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "Next" {
                if level+1 != Levels.amount() {
                    nextLevel()
                }
                break
            }else if touchedNode.name == "Back" {
                if level - 1 >= 0 {
                    level = level-2
                    nextLevel()
                }
                break
            }
        }
    }
    
    func nextLevel() {
        level += 1
        levelNum.text = "Level \(level)"
        puzzle?.removeFromParent()
        
        if level >= Levels.amount() {
            levelNum.text = "No More Levels"
            return
        }
        
        let layout = Levels.getLayout(num: level)
        puzzle = Puzzle(layout: layout, scale: scale!)
        addChild(puzzle!)
        
        DataStore.setLevel(level: level)
    }
    
    private func initLevelsPanel(firstLevel: Int) -> SKNode {
        let panel = SKShapeNode(rectOf: CGSize(width: Double(4)*scale!, height: Double(4)*scale!), cornerRadius: 25)
        panel.fillColor = ColorPallete.PUZZLE_BACK
        panel.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let seed: UInt64 = UInt64(firstLevel*69) // use a seed so that levels don't change icons
        let source = GKMersenneTwisterRandomSource(seed: seed)
        let rng = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 3)
        
        var levelLayout = [[Int]]()
        for _ in 0 ..< 4 {
            var row = [Int]()
            for _ in 0 ..< 4 {
                row.append(rng.nextInt())
            }
            
            levelLayout.append(row)
        }
        
        let levelSprites = Puzzle(layout: levelLayout, scale: scale!).getSpriteGrid()
        var levelCounter = firstLevel
        
        for dy in 0 ..< 4 {
            let y = 3-dy
            for x in 0 ..< 4 {
                if levelSprites[x][y] != nil {
                    let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                    levelLabel.position.y = -7
                    levelLabel.name = String(levelCounter)
                    levelLabel.text = String(levelCounter)
                    levelLabel.fontSize = 20
                    levelLabel.color = .white
                    
                    levelSprites[x][y]?.removeFromParent()
                    levelSprites[x][y]?.name = String(levelCounter)
                    levelSprites[x][y]?.addChild(levelLabel)
                    panel.addChild(levelSprites[x][y]!)
                    
                    levelCounter += 1
                    if levelCounter == Levels.amount() {
                        break
                    }
                }
            }
            
            if levelCounter == Levels.amount() {
                break
            }
        }
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let prevLevelSlide = SKShapeNode(rectOf: CGSize(width: scale!, height: scale!), cornerRadius: 25)
        prevLevelSlide.fillColor = ColorPallete.PUZZLE_BACK
        prevLevelSlide.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        prevLevelSlide.position = CGPoint(x: -(prevLevelSlide.frame.width)/2-10, y: -300)
        prevLevelSlide.name = "PrevLevelSlide"
        
        let prevLevelSlideIcon = SKSpriteNode(imageNamed: "next")
        prevLevelSlideIcon.name = "PrevLevelSlide"
        prevLevelSlideIcon.scale(to: CGSize(width: 50, height: 50))
        prevLevelSlideIcon.zRotation = CGFloat(Double.pi)
        prevLevelSlide.addChild(prevLevelSlideIcon)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let nextLevelSlide = SKShapeNode(rectOf: CGSize(width: scale!, height: scale!), cornerRadius: 25)
        nextLevelSlide.fillColor = ColorPallete.PUZZLE_BACK
        nextLevelSlide.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        nextLevelSlide.position = CGPoint(x: (nextLevelSlide.frame.width)/2+10, y: -300)
        nextLevelSlide.name = "NextLevelSlide"
        
        let nextLevelSlideIcon = SKSpriteNode(imageNamed: "next")
        nextLevelSlideIcon.name = "NextLevelSlide"
        nextLevelSlideIcon.scale(to: CGSize(width: 50, height: 50))
        nextLevelSlide.addChild(nextLevelSlideIcon)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        panel.addChild(prevLevelSlide)
        panel.addChild(nextLevelSlide)
        return panel
    }

    private func initSettingsPanel() -> SKNode {
        let panel = SKShapeNode(rectOf: CGSize(width: Double(4)*scale!, height: Double(4)*scale!), cornerRadius: 25)
        panel.fillColor = ColorPallete.PUZZLE_BACK
        panel.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let theme = SKShapeNode(rectOf: CGSize(width: 300, height: 150), cornerRadius: 15)
        theme.position.y = 75
        theme.name = "Theme"
        theme.fillColor = ColorPallete.BACKGROUND
        theme.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        let themeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        themeLabel.position.y = 35
        themeLabel.text = "Theme"
        themeLabel.color = .white
        theme.addChild(themeLabel)
        
        let squareOne = SKShapeNode(rectOf: CGSize(width: scale!/2, height: scale!/2), cornerRadius: 10)
        squareOne.position = CGPoint(x: -scale!, y: -25)
        squareOne.fillColor = ColorPallete.SQUARE_ONE
        squareOne.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
        theme.addChild(squareOne)
        
        let triangle = SKShapeNode(path: puzzle!.roundedPolygonPath(size: scale!/2.5, lineWidth: 5, sides: 3, cornerRadius: 10))
        triangle.position = CGPoint(x: -scale!/3, y: -25)
        triangle.fillColor = ColorPallete.TRIANGLE
        triangle.strokeColor = ColorPallete.TRIANGLE.darker(by: 50)
        theme.addChild(triangle)
        
        let squareTwo = SKShapeNode(rectOf: CGSize(width: scale!/2, height: scale!/2), cornerRadius: 10)
        squareTwo.position = CGPoint(x: scale!/3, y: -25)
        squareTwo.fillColor = ColorPallete.SQUARE_TWO
        squareTwo.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
        theme.addChild(squareTwo)
        
        let circle = SKShapeNode(circleOfRadius: CGFloat(scale!/4))
        circle.position = CGPoint(x: scale!, y: -25)
        circle.fillColor = ColorPallete.CIRCLE
        circle.strokeColor = ColorPallete.CIRCLE.darker(by: 50)
        theme.addChild(circle)
        
        for child in theme.children {
            child.name = theme.name
        }
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let rate = SKShapeNode(rectOf: CGSize(width: 300, height: 50), cornerRadius: 15)
        rate.position.y = -60
        rate.name = "Rate"
        rate.fillColor = ColorPallete.SQUARE_ONE
        rate.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
        
        let rateLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rateLabel.position.y = -10
        rateLabel.text = "Rate"
        rateLabel.name = "Rate"
        rate.addChild(rateLabel)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let resetProgress = SKShapeNode(rectOf: CGSize(width: 300, height: 50), cornerRadius: 15)
        resetProgress.position.y = -120
        resetProgress.name = "ResetProgress"
        resetProgress.fillColor = ColorPallete.SQUARE_TWO
        resetProgress.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
        
        let resetProgressLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resetProgressLabel.position.y = -10
        resetProgressLabel.text = "Reset Progress"
        resetProgressLabel.name = "ResetProgress"
        resetProgress.addChild(resetProgressLabel)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let exitSettings = SKShapeNode(rectOf: CGSize(width: scale!, height: scale!), cornerRadius: 25)
        exitSettings.fillColor = ColorPallete.PUZZLE_BACK
        exitSettings.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        exitSettings.position = CGPoint(x: 0, y: -300)
        exitSettings.name = "Settings"
        
        let exitSettingsIcon = SKSpriteNode(imageNamed: "exit")
        exitSettingsIcon.name = "Settings"
        exitSettingsIcon.scale(to: CGSize(width: 50, height: 50))
        exitSettings.addChild(exitSettingsIcon)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        panel.addChild(theme)
        panel.addChild(rate)
        panel.addChild(resetProgress)
        panel.addChild(exitSettings)
        return panel
    }
    
    private var panelState = PanelState.PUZZLE
    
    private func setPanelState(state: PanelState) {
        if panelState != state {
            panelState = state
            puzzle?.removeFromParent()
            levelsPanel.removeFromParent()
            settingsPanel.removeFromParent()
            restartButton?.removeFromParent()
            
            // todo: display different button options on the bottom for each state
            
            switch state {
            case .PUZZLE:
                levelNum.text = "Level \(level)"
                self.addChild(puzzle!)
                self.addChild(restartButton!)
                break
            case .LEVELS:
                levelNum.text = "Levels"
                self.addChild(levelsPanel)
                break
            case .OPTIONS:
                levelNum.text = "Options"
                self.addChild(settingsPanel)
                break
            }
        }
    }
    
    
    
    
    private func debug() {
        let backLevel = SKShapeNode(rectOf: CGSize(width: 100, height: 100), cornerRadius: 25)
        backLevel.position = CGPoint(x: -250, y: -400)
        backLevel.fillColor = .red
        backLevel.name = "Back"
        addChild(backLevel)
        
        let backDebugLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backDebugLabel.position = CGPoint(x: -250, y: -400)
        backDebugLabel.text = "Debug Back"
        backDebugLabel.name = "Back"
        backDebugLabel.fontSize = 15
        backDebugLabel.color = .white
        addChild(backDebugLabel)
        
        let nextLevel = SKShapeNode(rectOf: CGSize(width: 100, height: 100), cornerRadius:25)
        nextLevel.position = CGPoint(x: 250, y: -400)
        nextLevel.fillColor = .red
        nextLevel.name = "Next"
        addChild(nextLevel)
        
        let nextDebugLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nextDebugLabel.position = CGPoint(x: 250, y: -400)
        nextDebugLabel.text = "Debug Next"
        nextDebugLabel.name = "Next"
        nextDebugLabel.fontSize = 15
        nextDebugLabel.color = .white
        addChild(nextDebugLabel)
    }
}

