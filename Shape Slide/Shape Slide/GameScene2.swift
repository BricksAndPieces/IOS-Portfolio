//
//  GameScene2.swift
//  Shape Slide
//
//  Created by 90307332 on 3/21/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit
import GameplayKit

/*
 TODO:
 - theme change
 - scaling
 - block levels that aren't unlocked yet
 */

// App ID of this app. Used for opening app store
let APP_ID = "appId"

enum GameState {
    case PUZZLE
    case LEVELS
    case OPTIONS
}

struct Button {
    // General Buttons
    static let LEVELS_BUTTON = "Levels"
    static let OPTIONS_BUTTON = "Options"
    
    // Puzzle Buttons
    static let RESTART = "Restart"
    static let NEXT_LEVEL = "NextLevel"
    
    // Levels Buttons
    static let NEXT_LEVELS_PAGE = "NextLevelsPage"
    static let PREV_LEVELS_PAGE = "PrevLevelsPage"
    
    // Options Buttons
    static let THEME_CHANGE = "ThemeChange"
    static let RATE_APP = "RateApp"
    static let RESET_PROGRESS = "ResetProgress"
    static let EXIT_BUTTON = "ExitOptions"
}

class GameScene2 : SKScene {
    
    private var currentLevel = 0
    private var gameState = GameState.LEVELS
    private var dragStartPoint: (Int, Int)?
    private var scale: Double!
    
    private var puzzlePanel: Puzzle!
    private var levelsPanel: SKNode!
    private var optionsPanel: SKNode!
    
    private var restartButton: SKShapeNode!
    private var nextLevelButton: SKShapeNode!
    private var nextLevelPage: SKShapeNode!
    private var prevLevelPage: SKShapeNode!
    private var exitSettingsButton: SKShapeNode!
    
    private let headerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    public var viewController: UIViewController!
    
    private var levelsPageFirst = 0
    
    // MARK: Did Move
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    override func didMove(to view: SKView) {
        self.currentLevel = DataStore.getLevel()
        self.backgroundColor = ColorPallete.BACKGROUND
        self.scale = Double(self.size.width) * (UIDevice.current.model == "iPad" ? 0.6 : 0.75)
        print(UIDevice.current.model)
        
        // Setup the panels
        self.puzzlePanel = initPuzzlePanel(level: currentLevel)
        self.levelsPanel = initLevelsPanel(startLevel: 0)
        self.optionsPanel = initOptionsPanel()
        
        // Init buttons
        self.restartButton = initDefaultButton(buttonName: Button.RESTART, imgName: "restart", rotation: Double.pi)
        self.nextLevelButton = initDefaultButton(buttonName: Button.NEXT_LEVEL, imgName: "next", rotation: 0)
        self.nextLevelPage = initDefaultButton(buttonName: Button.NEXT_LEVELS_PAGE, imgName: "next", rotation: 0)
        self.prevLevelPage = initDefaultButton(buttonName: Button.PREV_LEVELS_PAGE, imgName: "next", rotation: Double.pi)
        self.exitSettingsButton = initDefaultButton(buttonName: Button.EXIT_BUTTON, imgName: "exit", rotation: 0)
        
        // Set button locations
        //self.restartButton.position.x = -restartButton.frame.width/2 - 10
        self.nextLevelButton.position.x = nextLevelButton.frame.width/2 + 10
        self.nextLevelPage.position.x = nextLevelPage.frame.width/2 + 10
        self.prevLevelPage.position.x = -prevLevelPage.frame.width/2 - 10
        
        // Start with puzzle
        self.setGameState(state: .PUZZLE)
        self.initSwipeDetector()
        
        // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
        
        // Setup game title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.fontSize = 75
        title.text = "Shape Slide"
        title.fontColor = ColorPallete.TEXT
        title.position.y = CGFloat(scale / 2 + 135)
        addChild(title)
        
        // Setup header label
        headerLabel.position.y = CGFloat(scale/2+10)
        headerLabel.fontColor = ColorPallete.PUZZLE_BACK
        headerLabel.fontSize = 50
        addChild(headerLabel)
        
        let settings = SKSpriteNode(imageNamed: "settings.png")
        //settings.position = CGPoint(x: size.width/2*0.9-100, y: size.height/2*0.65)
        settings.scale(to: CGSize(width: 30, height: 30))
        settings.name = Button.OPTIONS_BUTTON
        addChild(settings)
        
        let levels = SKSpriteNode(imageNamed: "menu")
        levels.scale(to: CGSize(width: 35, height: 35))
        levels.name = Button.LEVELS_BUTTON
        //levels.position = CGPoint(x: size.width/2*0.9-100, y: size.height/2*0.65-40)
        addChild(levels)
        
        settings.position.y = restartButton.position.y - restartButton.frame.height/2 - 70
        settings.position.x = -25
        
        levels.position.y = settings.position.y
        levels.position.x = -settings.position.x
    }
    
    // MARK: Initializers
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func initSwipeDetector() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let swipeDetector = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(swipe:)))
            swipeDetector.direction = direction
            view?.addGestureRecognizer(swipeDetector)
        }
    }
    
    private func initDefaultButton(buttonName: String, imgName: String, rotation: Double) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: scale/4, height: scale/4), cornerRadius: 25)
        button.fillColor = ColorPallete.PUZZLE_BACK
        button.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        button.position.y = CGFloat(-scale/2 - 100)
        button.name = buttonName
        
        let icon = SKSpriteNode(imageNamed: imgName)
        icon.name = buttonName
        icon.scale(to: CGSize(width: 50, height: 50))
        icon.zRotation = CGFloat(rotation)
        button.addChild(icon)
        
        return button
    }
    
    private func initPuzzlePanel(level: Int) -> Puzzle {
        currentLevel = level
        let layout = Levels.getLayout(num: level)
        return Puzzle(layout: layout, scale: scale/Double(layout.count))
    }
    
    private func initLevelsPanel(startLevel: Int) -> SKNode {
        let panel = SKShapeNode(rectOf: CGSize(width: scale, height: scale), cornerRadius: 25)
        panel.fillColor = ColorPallete.PUZZLE_BACK
        panel.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let seed: UInt64 = UInt64(startLevel*69) // use a seed so that levels don't change icons
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
        
        let levelSprites = Puzzle(layout: levelLayout, scale: scale/4).getSpriteGrid()
        var levelCounter = startLevel
        
        for dy in 0 ..< 4 {
            let y = 3-dy
            for x in 0 ..< 4 {
                if levelSprites[x][y] != nil {
                    if levelCounter > DataStore.getLevel() {
                        let lock = SKSpriteNode(imageNamed: "lock")
                        lock.scale(to: CGSize(width: scale/15, height: scale/15))
                        levelSprites[x][y]?.removeFromParent()
                        levelSprites[x][y]?.addChild(lock)
                        panel.addChild(levelSprites[x][y]!)
                    }else {
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
                    }
                    
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
        
        return panel
    }
    
    private func initOptionsPanel() -> SKNode {
        let panel = SKShapeNode(rectOf: CGSize(width: scale, height: scale), cornerRadius: 25)
        panel.fillColor = ColorPallete.PUZZLE_BACK
        panel.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let theme = SKShapeNode(rectOf: CGSize(width: 300, height: 150), cornerRadius: 15)
        theme.position.y = 75
        theme.name = Button.THEME_CHANGE
        theme.fillColor = ColorPallete.BACKGROUND
        theme.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        
        let themeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        themeLabel.position.y = 35
        themeLabel.text = "Game Created by Ishan Shetty"
        themeLabel.fontSize = 18
        themeLabel.color = .white
        theme.addChild(themeLabel)
        
        let squareOne = SKShapeNode(rectOf: CGSize(width: scale/4/2, height: scale/4/2), cornerRadius: 10)
        squareOne.position = CGPoint(x: -scale/4, y: -25)
        squareOne.fillColor = ColorPallete.SQUARE_ONE
        squareOne.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
        theme.addChild(squareOne)
        
        let triangle = SKShapeNode(path: puzzlePanel.roundedPolygonPath(size: scale/4/2.5, lineWidth: 5, sides: 3, cornerRadius: 10))
        triangle.position = CGPoint(x: -scale/4/3, y: -25)
        triangle.fillColor = ColorPallete.TRIANGLE
        triangle.strokeColor = ColorPallete.TRIANGLE.darker(by: 50)
        theme.addChild(triangle)
        
        let squareTwo = SKShapeNode(rectOf: CGSize(width: scale/4/2, height: scale/4/2), cornerRadius: 10)
        squareTwo.position = CGPoint(x: scale/4/3, y: -25)
        squareTwo.fillColor = ColorPallete.SQUARE_TWO
        squareTwo.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
        theme.addChild(squareTwo)
        
        let circle = SKShapeNode(circleOfRadius: CGFloat(scale/4/4))
        circle.position = CGPoint(x: scale/4, y: -25)
        circle.fillColor = ColorPallete.CIRCLE
        circle.strokeColor = ColorPallete.CIRCLE.darker(by: 50)
        theme.addChild(circle)
        
        for child in theme.children {
            child.name = theme.name
        }
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let rate = SKShapeNode(rectOf: CGSize(width: 300, height: 50), cornerRadius: 15)
        rate.position.y = -60
        rate.name = Button.RATE_APP
        rate.fillColor = ColorPallete.SQUARE_ONE
        rate.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
        
        let rateLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rateLabel.position.y = -10
        rateLabel.text = "Rate"
        rateLabel.name = Button.RATE_APP
        rate.addChild(rateLabel)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        let resetProgress = SKShapeNode(rectOf: CGSize(width: 300, height: 50), cornerRadius: 15)
        resetProgress.position.y = -120
        resetProgress.name = Button.RESET_PROGRESS
        resetProgress.fillColor = ColorPallete.SQUARE_TWO
        resetProgress.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
        
        let resetProgressLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resetProgressLabel.position.y = -10
        resetProgressLabel.text = "Reset Progress"
        resetProgressLabel.name = Button.RESET_PROGRESS
        resetProgress.addChild(resetProgressLabel)
        
        // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
        
        panel.addChild(theme)
        panel.addChild(rate)
        panel.addChild(resetProgress)
        return panel
    }
    
    // MARK: User Input
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    var z = true;
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // temp code
        if z {
            // Popup to tell user of known bugs / to be changed features
            let msg = "This is a puzzle game called shape slide. The goal of the game is to end up with just one shape left. Swipe on the shapes to move them. The settings and level button are currently just slapped at the bottom of UI. Xcode is kinda dumb and I'm having trouble putting them in the corner so just ignore that"
            let controller = UIAlertController(title: "Beta Version", message: msg, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            viewController.present(controller, animated: true, completion: nil)
            z=false
        }
        
        // Calling functions when buttons are pressed
        let nodeName = atPoint((touches.first?.location(in: self))!).name
        switch nodeName {
        case Button.LEVELS_BUTTON:
            levelsButtonPressed()
            return
        case Button.OPTIONS_BUTTON:
            optionsButtonPressed()
            return
        case Button.RESTART:
            restartButtonPressed()
            return
        case Button.NEXT_LEVEL:
            nextLevelButtonPressed()
            return
        case Button.PREV_LEVELS_PAGE:
            prevLevelsPage()
            return
        case Button.NEXT_LEVELS_PAGE:
            nextLevelsPage()
            return
        case Button.THEME_CHANGE:
            // do something ---------------------------------------------------------
            return
        case Button.RATE_APP:
            rateApp()
            return
        case Button.RESET_PROGRESS:
            resetProgress()
            return
        case Button.EXIT_BUTTON:
            displayLevel(level: currentLevel)
            return
        default:
            if gameState == .LEVELS && nodeName != nil {
                let levelNum = Int(nodeName!)
                if levelNum != nil {
                    displayLevel(level: levelNum!)
                    return
                }
            }
        }
        
        // If no button was pressed, then treat the touch as begining of drag
        let touchLoc = (touches.first?.location(in: puzzlePanel))!
        dragStartPoint = puzzlePanel.tilePositionFromScreen(x: Double(touchLoc.x), y: Double(touchLoc.y))
    }
    
    @objc func onSwipe(swipe: UISwipeGestureRecognizer) {
        if gameState == .PUZZLE && dragStartPoint != nil && !puzzlePanel.solved() {
            let dirsRel = [(-1, 0), (1, 0), (0, 1), (0, -1)]
            let dirs: [UISwipeGestureRecognizer.Direction] = [.left, .right, .up, .down]
            
            var dragEndPoint: (Int, Int)? = nil
            for i in 0 ..< 4 {
                if swipe.direction == dirs[i] {
                    dragEndPoint = puzzlePanel.calcEndTile(start: dragStartPoint!, dir: dirsRel[i])
                    break
                }
            }
            
            // Neither start nor end should be nil -> otherwise yikes
            puzzlePanel.moveTile(start: dragStartPoint!, end: dragEndPoint!)
            dragStartPoint = nil
            
            if puzzlePanel.solved() {
                puzzleSolved()
            }
        }
    }
    
    // MARK: Game States
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func displayLevel(level: Int) {
        setGameState(state: .PUZZLE)
        puzzlePanel.removeFromParent()
        puzzlePanel = initPuzzlePanel(level: level)
        headerLabel.text = "Level \(level)"
        addChild(puzzlePanel)
    }
    
    private func displayLevels(firstLevel: Int) {
        levelsPageFirst =  firstLevel
        setGameState(state: .LEVELS)
        levelsPanel.removeFromParent()
        levelsPanel = initLevelsPanel(startLevel: firstLevel)
        addChild(levelsPanel)
    }
    
    private func displayOptions() {
        setGameState(state: .OPTIONS)
    }

    private func setGameState(state: GameState) {
        if gameState != state {
            gameState = state
            
            // Remove panels from scene
            puzzlePanel.removeFromParent()
            levelsPanel.removeFromParent()
            optionsPanel.removeFromParent()
            
            // Remove buttons from scene
            restartButton.removeFromParent()
            nextLevelButton.removeFromParent()
            nextLevelPage.removeFromParent()
            prevLevelPage.removeFromParent()
            exitSettingsButton.removeFromParent()
            
            // Other changes
            restartButton.position.x = 0
            
            switch state {
            case .PUZZLE:
                headerLabel.text = "Level \(currentLevel)"
                self.addChild(puzzlePanel)
                self.addChild(restartButton)
                //self.addChild(nextLevelButton)
                break
            case .LEVELS:
                headerLabel.text = "Levels"
                self.addChild(levelsPanel)
                self.addChild(nextLevelPage)
                self.addChild(prevLevelPage)
                break
            case .OPTIONS:
                headerLabel.text = "Options"
                self.addChild(optionsPanel)
                self.addChild(exitSettingsButton)
                break
            }
        }
    }
    
    // MARK: Animations
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func puzzleSolved() {
        let finalTile = puzzlePanel.getFinalSprite()!
        
        let wait = SKAction.wait(forDuration: 0.2)
        let move = SKAction.group([
            SKAction.move(to: nextLevelButton.position, duration: 0.2),
            SKAction.rotate(byAngle: CGFloat(2*Double.pi), duration: 0.2),
            SKAction.scale(by: 2, duration: 0.2),
            SKAction.run { self.restartButton.run(SKAction.moveTo(x: -self.nextLevelButton.position.x, duration: 0.2)) }
        ])
        
        let switchSprite = SKAction.run {
            self.nextLevelButton.fillColor = finalTile.fillColor
            self.nextLevelButton.strokeColor = finalTile.strokeColor
            finalTile.removeFromParent()
            self.addChild(self.nextLevelButton)
        }
        
        finalTile.run(SKAction.sequence([wait, move, switchSprite]))
    }
    
    // MARK: Button Functions
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func nextLevelButtonPressed() {
        if currentLevel+1 != Levels.amount() {
            displayLevel(level: currentLevel+1)
            if currentLevel > DataStore.getLevel() {
                DataStore.setLevel(level: currentLevel)
            }
            
            restartButton.run(SKAction.moveTo(x: 0, duration: 0.2))
            nextLevelButton.run(SKAction.sequence([
                SKAction.scale(to: 0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: restartButton.frame.size, duration: 0)
            ]))
        }
    }
    
    private func restartButtonPressed() {
        displayLevel(level: currentLevel)
        if nextLevelButton.parent != nil {
            restartButton.run(SKAction.moveTo(x: 0, duration: 0.2))
            nextLevelButton.run(SKAction.sequence([
                SKAction.scale(to: 0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: restartButton.frame.size, duration: 0)
            ]))
        }
    }
    
    private func nextLevelsPage() {
        if levelsPageFirst+16 < Levels.amount() {
            displayLevels(firstLevel: levelsPageFirst+16)
        }
    }
    
    private func prevLevelsPage() {
        if levelsPageFirst-16 >= 0 {
            displayLevels(firstLevel: levelsPageFirst-16)
        }
    }
    
    private func levelsButtonPressed() {
        if gameState == .LEVELS {
            displayLevel(level: currentLevel)
        }else {
            displayLevels(firstLevel: currentLevel/16*16)
        }
    }
    
    private func optionsButtonPressed() {
        if gameState == .OPTIONS {
            displayLevel(level: currentLevel)
        }else {
            displayOptions()
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/\(APP_ID)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func resetProgress() {
        let msg = "This will permanently delete all progress. Continue?"
        let controller = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { (action) in
            DataStore.setLevel(level: 0)
            self.displayLevel(level: 0)
        }))
        
        viewController.present(controller, animated: true, completion: nil)
    }
}
