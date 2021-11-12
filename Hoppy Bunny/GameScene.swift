//
//  GameScene.swift
//  Hoppy Bunny
//
//  Created by Sawyer Cherry on 10/25/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var sinceTouch: CFTimeInterval = 0
    var fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat =  100
    
    
    override func didMove(to view: SKView) {
        
        hero = (self.childNode(withName: "//hero") as! SKSpriteNode)
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        hero.isPaused = false
        
        obstacleSource = self.childNode(withName: "//obstacle")
        
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // called when touch begins
        
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        
        hero.physicsBody?.applyAngularImpulse(1)
        
        sinceTouch = 0
    }
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // get the current velocity
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        
        //apply falling rotation
        
        if sinceTouch > 0.2 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)
        
        /* Update last touch timer */
        sinceTouch += fixedDelta
        
        
        scrollWorld()
        updateObstacles()
        
        spawnTimer += fixedDelta
    }
    
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        for ground in scrollLayer.children as! [SKSpriteNode] {
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
        
    }
    
    func updateObstacles() {
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= -26 {
                // 26 is one half the width of an obstacle
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.5 {

            /* Create a new obstacle by copying the source obstacle */
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)

            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition =  CGPoint(x: 347, y: CGFloat.random(in: 234...382))

            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)

            // Reset spawn timer
            spawnTimer = 0
        }

        
        
    }
    
}
