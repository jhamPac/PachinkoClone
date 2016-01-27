//
//  GameScene.swift
//  PeggleClone
//
//  Created by jhampac on 1/26/16.
//  Copyright (c) 2016 jhampac. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode
            {
                editLabel.text = "Done"
            }
            else
            {
                editLabel.text = "Edit"
            }
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background2.png")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.contactDelegate = self
        
        makeSlotAt(CGPoint(x: 128, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 384, y: 0), isGood: false)
        makeSlotAt(CGPoint(x: 640, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 896, y:0), isGood: false)
        
        makeBouncerAt(CGPoint(x: 0, y: 0))
        makeBouncerAt(CGPoint(x: 256, y: 0))
        makeBouncerAt(CGPoint(x: 512, y: 0))
        makeBouncerAt(CGPoint(x: 768, y: 0))
        makeBouncerAt(CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first
        {
            let location = touch.locationInNode(self)
            let objects = nodesAtPoint(location)
            
            if objects.contains(editLabel)
            {
                editingMode = !editingMode
            }
            else
            {
                if editingMode
                {
                    //select a random width between 16 - 128; height is set to 16
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
                    box.physicsBody!.dynamic = false
                    addChild(box)
                }
                else
                {
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody!.restitution = 0.8
                    ball.position = location
                    ball.name = "ball"
                    addChild(ball)
                }
            }
        }
    }
    
    func makeBouncerAt(pos: CGPoint)
    {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = pos
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.dynamic = false
        addChild(bouncer)
    }
    
    func makeSlotAt(pos: CGPoint, isGood: Bool)
    {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood
        {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }
        else
        {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.contactTestBitMask = slotBase.physicsBody!.collisionBitMask
        slotBase.physicsBody!.dynamic = false
        
        slotBase.position = pos
        slotGlow.position = pos
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
        let spinForever = SKAction.repeatActionForever(spin)
        slotGlow.runAction(spinForever)
    }
    
    func collisionBetweenBall(ball: SKNode, object: SKNode)
    {
        if object.name == "good"
        {
            destroyBall(ball)
            ++score
        }
        else if object.name == "bad"
        {
            destroyBall(ball)
            --score
        }
    }
    
    func destroyBall(ball: SKNode)
    {
        if let fireparticle = SKEmitterNode(fileNamed: "FireParticles")
        {
            fireparticle.position = ball.position
            addChild(fireparticle)
        }
        
        ball.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        if contact.bodyA.node!.name == "ball"
        {
            collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
        }
        else if contact.bodyB.node!.name == "ball"
        {
            collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
}
