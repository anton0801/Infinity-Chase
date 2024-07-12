import Foundation
import SpriteKit
import SwiftUI

func formatTime(seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}


class ChaseGameScene: SKScene, SKPhysicsContactDelegate {
    
    private var chaseRecordsViewModel = ChaseRecordsViewModel()
    
    var selectedChase = UserDefaults.standard.string(forKey: "selected_chase") ?? ""
    var selectedPlane = UserDefaults.standard.string(forKey: "plane") ?? ""
    
    private var plane: SKSpriteNode = SKSpriteNode()
    
    private var rulesNode: RulesNode!
    private var gameOverNode: GameOverNode!
    private var newRecordNode: NewRecordNode!
    private var pauseNode: PauseNode!
    
    private var prevObstaclePosX: Int = -1
    private var obstacles: [SKNode] = []
    
    var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    
    private var time = 0 {
        didSet {
            if !isPaused {
                timeLabel.text = formatTime(seconds: time)
            }
        }
    }
    private var timer = Timer()
    
    private var timeLabel: SKLabelNode = SKLabelNode(text: "00:00")
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 1335, height: 750)
        physicsWorld.contactDelegate = self
        
        createGame()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contunueGameObjc), name: .continueGameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartActionObjc), name: .restartGameNotification, object: nil)
    }
    
    private func createGame() {
        let chaseMapTexture = SKTexture(imageNamed: selectedChase)
        let chasegame = SKSpriteNode(texture: chaseMapTexture)
        chasegame.position = CGPoint(x: size.width / 2, y: size.height / 2 + 350)
        chasegame.size = CGSize(width: 1335, height: 2500)
        addChild(chasegame)
        createPlane()
        
        let rulesGameBtn = SKSpriteNode(imageNamed: "rules_game")
        rulesGameBtn.position = CGPoint(x: size.width - 100, y: 80)
        rulesGameBtn.name = "rules_btn"
        addChild(rulesGameBtn)
        
        let pauseGame = SKSpriteNode(imageNamed: "pause_game")
        pauseGame.position = CGPoint(x: 100, y: size.height - 80)
        pauseGame.name = "pause_btn"
        addChild(pauseGame)
        
        let balanceBack = SKSpriteNode(imageNamed: "balance")
        balanceBack.position = CGPoint(x: size.width - 100, y: size.height - 80)
        balanceBack.size = CGSize(width: 190, height: 160)
        addChild(balanceBack)
        
        let balanceLabel = SKLabelNode(text: "\(UserDefaults.standard.integer(forKey: "balance"))")
        balanceLabel.position = CGPoint(x: size.width - 110, y: size.height - 90)
        balanceLabel.fontName = "Knewave-Regular"
        balanceLabel.fontSize = 32
        balanceLabel.fontColor = .white
        addChild(balanceLabel)
        
        let balanceCoin = SKSpriteNode(imageNamed: "coin")
        balanceCoin.position = CGPoint(x: size.width - 70, y: size.height - 80)
        balanceCoin.size = CGSize(width: 32, height: 32)
        addChild(balanceCoin)
        
        timeLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        timeLabel.fontName = "Knewave-Regular"
        timeLabel.fontSize = 72
        timeLabel.fontColor = .white
        addChild(timeLabel)
        
        rulesNode = RulesNode(size: size)
        pauseNode = PauseNode(size: size)
        
        timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        movePlane()
    }
    
    @objc private func fireTimer() {
        time += 1
    }
    
    private func createPlane() {
        plane = .init(imageNamed: selectedPlane)
        plane.position = CGPoint(x: 200, y: size.height / 2)
        plane.size = CGSize(width: 250, height: 180)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = false
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.categoryBitMask = 1
        plane.physicsBody?.collisionBitMask = 2
        plane.physicsBody?.contactTestBitMask = 2
        plane.name = "plane"
        addChild(plane)
    }
    
    private func movePlane() {
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        
        let movingPlaneAction = SKAction.moveTo(x: size.width + 100, duration: Double(Int.random(in: 6...8)))
        plane.position = CGPoint(x: -100, y: size.height / 2)
        plane.run(movingPlaneAction) { [weak self] in
            self?.prevObstaclePosX = -1
            self?.movePlane()
        }
        
        createObstacles()
        createObstacles()
    }
    
    private func createObstacles() {
        let obstacle = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 160))
        obstacle.position = CGPoint(x: prevObstaclePosX + 250 + Int.random(in: 200...300), y: Int.random(in: 250...Int(size.height) - 250))
        prevObstaclePosX = Int(obstacle.position.x)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.physicsBody?.collisionBitMask = 1
        obstacle.name = "obstacle"
        addChild(obstacle)
        obstacles.append(obstacle)
        
        if Bool.random() {
            let speed = Int.random(in: 2..<4)
            let moveObstacleUpAction = SKAction.move(to: CGPoint(x: obstacle.position.x, y: size.height - 100), duration: TimeInterval(speed))
            let moveObstacleDownAction = SKAction.move(to: CGPoint(x: obstacle.position.x, y: 150), duration: TimeInterval(speed))
            let seq = SKAction.sequence([moveObstacleUpAction, moveObstacleDownAction])
            let forever = SKAction.repeatForever(seq)
            obstacle.run(forever)
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) ||
            (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            let obstacle: SKPhysicsBody
            if bodyA.categoryBitMask == 2 {
                obstacle = bodyA
            } else {
                obstacle = bodyB
            }
            
            obstacle.node?.removeFromParent()
            plane.removeFromParent()
            
            if chaseRecordsViewModel.records.isEmpty {
                newRecordNode = NewRecordNode(size: size, time: time, restartAction: { })
                addChild(newRecordNode)
                chaseRecordsViewModel.addRecord(RecordItem(levelNum: 1, recordTime: time, setUpDate: Date()))
                balance += 100
            } else {
                let lastRecord = chaseRecordsViewModel.getLastRecordItem()
                if time > (lastRecord?.recordTime ?? 0) {
                    newRecordNode = NewRecordNode(size: size, time: time, restartAction: { })
                    addChild(newRecordNode)
                    chaseRecordsViewModel.addRecord(RecordItem(levelNum: 1, recordTime: time, setUpDate: Date()))
                    balance += 100
                } else {
                    gameOverNode = GameOverNode(size: size, time: time, restartAction: { })
                    addChild(gameOverNode)
                    balance += 50
                }
            }
        }
    }
    
    func contunueGame() {
        isPaused = false
    }
    
    @objc func contunueGameObjc() {
        isPaused = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let atPoint = atPoint(touch.location(in: self))
            
            if atPoint.name == "rules_btn" {
                isPaused = true
                addChild(rulesNode)
            }
            if atPoint.name == "pause_btn" {
                pauseGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let atPoint = atPoint(loc)
            
            if atPoint.name == "plane" {
                if plane.position.y > 50 && plane.position.y < size.height - 50 {
                    plane.position.y = loc.y
                }
            }
        }
    }
    
    func pauseGame() {
        addChild(pauseNode)
        isPaused = true
    }
    
    func restartAction() {
        let newGameScene = ChaseGameScene(size: size)
        view?.presentScene(newGameScene)
    }
    
    @objc func restartActionObjc() {
        let newGameScene = ChaseGameScene(size: size)
        view?.presentScene(newGameScene)
    }
    
}

class PauseNode: SKSpriteNode {
    
    init(size: CGSize) {
        let blackOverlay = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        blackOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let pauseTitle = SKLabelNode(text: "PAUSE")
        pauseTitle.fontName = "Knewave-Regular"
        pauseTitle.fontSize = 62
        pauseTitle.fontColor = .white
        pauseTitle.position = CGPoint(x: size.width / 2, y: size.height - 100)
    
        let gameResultBg = SKSpriteNode(imageNamed: "game_result_back")
        gameResultBg.position = CGPoint(x: size.width / 2 + 20, y: size.height / 2)
        gameResultBg.size = CGSize(width: gameResultBg.size.width * 0.8, height: gameResultBg.size.height * 0.8)
        
        let playBtn = SKSpriteNode(imageNamed: "play_btn")
        playBtn.name = "continue_game"
        playBtn.size = CGSize(width: playBtn.size.width * 0.8, height: playBtn.size.height * 0.7)
        playBtn.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let backBtn = SKSpriteNode(imageNamed: "back_btn_2")
        backBtn.name = "back_btn"
        backBtn.size = CGSize(width: backBtn.size.width * 0.8, height: backBtn.size.height * 0.7)
        backBtn.position = CGPoint(x: size.width / 2 - 220, y: size.height / 2)
        
        let restartGame = SKSpriteNode(imageNamed: "restart_action_2")
        restartGame.name = "restart_game"
        restartGame.size = CGSize(width: restartGame.size.width * 0.8, height: restartGame.size.height * 0.7)
        restartGame.position = CGPoint(x: size.width / 2 + 220, y: size.height / 2)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(blackOverlay)
        addChild(gameResultBg)
        addChild(pauseTitle)
        addChild(playBtn)
        addChild(backBtn)
        addChild(restartGame)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let atPoint = atPoint(loc)
            
            if atPoint.name == "continue_game" {
                removeFromParent()
                NotificationCenter.default.post(name: .continueGameNotification, object: nil)
            }
            
            if atPoint.name == "back_btn" {
                NotificationCenter.default.post(name: Notification.Name("back_btn"), object: nil)
            }
            
            if atPoint.name == "restart_game" {
                NotificationCenter.default.post(name: .restartGameNotification, object: nil)
            }
        }
    }
    
}

extension Notification.Name {
    static let continueGameNotification = Notification.Name("continueGameNotification")
    static let restartGameNotification = Notification.Name("restartGameNotification")
}

class RulesNode: SKSpriteNode {
    
    private var rulesContent: SKSpriteNode
    
    init(size: CGSize) {
        let blackOverlay = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        blackOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let rulesTitle = SKLabelNode(text: "RULES")
        rulesTitle.fontName = "Knewave-Regular"
        rulesTitle.fontSize = 62
        rulesTitle.fontColor = .white
        rulesTitle.position = CGPoint(x: size.width / 2, y: size.height - 100)
        rulesContent = .init(imageNamed: "rules_content")
        rulesContent.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rulesContent.size = CGSize(width: rulesContent.size.width * 0.8, height: rulesContent.size.height)
        let playBtn = SKSpriteNode(imageNamed: "play_btn")
        playBtn.position = CGPoint(x: size.width / 2, y: rulesContent.position.y - (rulesContent.size.height / 2) - 20)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(blackOverlay)
        addChild(rulesTitle)
        addChild(rulesContent)
        addChild(playBtn)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromParent()
        NotificationCenter.default.post(name: .continueGameNotification, object: nil)
    }
    
}

class GameOverNode: SKSpriteNode {
    
    init(size: CGSize, time: Int, restartAction: () -> Void) {
        let gameResultBgBlack = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        gameResultBgBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let gameOverTitle = SKLabelNode(text: "GAME OVER!")
        gameOverTitle.fontName = "Knewave-Regular"
        gameOverTitle.fontSize = 92
        gameOverTitle.fontColor = .red
        gameOverTitle.position = CGPoint(x: size.width / 2, y: size.height - 140)
        
        let gameResultBg = SKSpriteNode(imageNamed: "game_result_back")
        gameResultBg.position = CGPoint(x: size.width / 2 + 20, y: size.height / 2)
        gameResultBg.size = CGSize(width: gameResultBg.size.width * 0.6, height: gameResultBg.size.height * 0.8)
        
        let gameTimeLabel = SKLabelNode(text: "TIME:")
        gameTimeLabel.fontName = "Knewave-Regular"
        gameTimeLabel.fontSize = 42
        gameTimeLabel.fontColor = .white
        gameTimeLabel.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y + 60)
        
        let gameTimeValue = SKLabelNode(text: formatTime(seconds: time))
        gameTimeValue.fontName = "Knewave-Regular"
        gameTimeValue.fontSize = 72
        gameTimeValue.fontColor = .white
        gameTimeValue.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y - 30)
        
        let balanceLabel = SKLabelNode(text: "+50")
        balanceLabel.position = CGPoint(x: size.width / 2 - 20, y: gameResultBg.position.y - 100)
        balanceLabel.fontName = "Knewave-Regular"
        balanceLabel.fontSize = 32
        balanceLabel.fontColor = .white
        
        let balanceCoin = SKSpriteNode(imageNamed: "coin")
        balanceCoin.position = CGPoint(x: size.width / 2 + 30, y: gameResultBg.position.y - 90)
        balanceCoin.size = CGSize(width: 32, height: 32)
        
        let backBtn = SKSpriteNode(imageNamed: "back_btn")
        backBtn.name = "back_btn"
        backBtn.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y - 240)
        backBtn.size = CGSize(width: backBtn.size.width * 0.7, height: backBtn.size.height * 0.6)
        
        let restartAction = SKSpriteNode(imageNamed: "restart_action")
        restartAction.name = "restart_btn"
        restartAction.position = CGPoint(x: size.width / 2 - 190, y: gameResultBg.position.y - 240)
        restartAction.size = CGSize(width: backBtn.size.width * 0.7, height: backBtn.size.height * 0.8)
        
        super.init(texture: nil, color: .clear, size: size)
        addChild(gameResultBgBlack)
        addChild(gameOverTitle)
        addChild(gameResultBg)
        addChild(gameTimeLabel)
        addChild(gameTimeValue)
        addChild(balanceLabel)
        addChild(balanceCoin)
        addChild(backBtn)
        addChild(restartAction)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let atPoint = atPoint(loc)
            
            if atPoint.name == "back_btn" {
                NotificationCenter.default.post(name: Notification.Name("back_btn"), object: nil)
            }
            
            if atPoint.name == "restart_btn" {
                (parent as? ChaseGameScene)?.restartAction()
            }
        }
    }
    
}

class NewRecordNode: SKSpriteNode {
    
    init(size: CGSize, time: Int, restartAction: () -> Void) {
        let gameResultBgBlack = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        gameResultBgBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let gameOverTitle = SKLabelNode(text: "NEW RECORD!")
        gameOverTitle.fontName = "Knewave-Regular"
        gameOverTitle.fontSize = 92
        gameOverTitle.fontColor = .green
        gameOverTitle.position = CGPoint(x: size.width / 2, y: size.height - 140)
        
        let gameResultBg = SKSpriteNode(imageNamed: "game_result_back")
        gameResultBg.position = CGPoint(x: size.width / 2 + 20, y: size.height / 2)
        gameResultBg.size = CGSize(width: gameResultBg.size.width * 0.6, height: gameResultBg.size.height * 0.8)
        
        let gameTimeLabel = SKLabelNode(text: "TIME:")
        gameTimeLabel.fontName = "Knewave-Regular"
        gameTimeLabel.fontSize = 42
        gameTimeLabel.fontColor = .white
        gameTimeLabel.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y + 60)
        
        let gameTimeValue = SKLabelNode(text: formatTime(seconds: time))
        gameTimeValue.fontName = "Knewave-Regular"
        gameTimeValue.fontSize = 72
        gameTimeValue.fontColor = .white
        gameTimeValue.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y - 30)
        
        let balanceLabel = SKLabelNode(text: "+100")
        balanceLabel.position = CGPoint(x: size.width / 2 - 20, y: gameResultBg.position.y - 100)
        balanceLabel.fontName = "Knewave-Regular"
        balanceLabel.fontSize = 32
        balanceLabel.fontColor = .white
        
        let balanceCoin = SKSpriteNode(imageNamed: "coin")
        balanceCoin.position = CGPoint(x: size.width / 2 + 30, y: gameResultBg.position.y - 90)
        balanceCoin.size = CGSize(width: 32, height: 32)
        
        let backBtn = SKSpriteNode(imageNamed: "back_btn")
        backBtn.name = "back_btn"
        backBtn.position = CGPoint(x: size.width / 2, y: gameResultBg.position.y - 240)
        backBtn.size = CGSize(width: backBtn.size.width * 0.7, height: backBtn.size.height * 0.6)
        
        let restartAction = SKSpriteNode(imageNamed: "restart_action")
        restartAction.name = "restart_btn"
        restartAction.position = CGPoint(x: size.width / 2 - 190, y: gameResultBg.position.y - 240)
        restartAction.size = CGSize(width: backBtn.size.width * 0.7, height: backBtn.size.height * 0.8)
        
        super.init(texture: nil, color: .clear, size: size)
        addChild(gameResultBgBlack)
        addChild(gameOverTitle)
        addChild(gameResultBg)
        addChild(gameTimeLabel)
        addChild(gameTimeValue)
        addChild(balanceLabel)
        addChild(balanceCoin)
        addChild(backBtn)
        addChild(restartAction)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let atPoint = atPoint(loc)
            
            if atPoint.name == "back_btn" {
                NotificationCenter.default.post(name: Notification.Name("back_btn"), object: nil)
            }
            
            if atPoint.name == "restart_btn" {
                (parent as? ChaseGameScene)?.restartAction()
            }
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: ChaseGameScene())
            .ignoresSafeArea()
    }
}
