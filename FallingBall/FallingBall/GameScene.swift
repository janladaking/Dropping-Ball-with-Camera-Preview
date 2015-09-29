//
//  GameScene.swift
//  FallBall
//
//  Created by Jan Lada on 9/22/15.
//  Copyright (c) 2015 Jan Lada. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class GameScene: SKScene {
    var playerShip:SKSpriteNode=SKSpriteNode(imageNamed: "ball")
    
    var brown:SKSpriteNode = SKSpriteNode(imageNamed: "brown")
    var yellow:SKSpriteNode = SKSpriteNode(imageNamed: "yellow")
    
    var enemyCount:Int=5
    var enemies:NSMutableArray=NSMutableArray(capacity: 5)
    var currentBullet:Int=0
    var playerBullets:NSMutableArray=NSMutableArray(capacity: 5)
    var mManager:CMMotionManager?=CMMotionManager()
    var scoreLabel:SKLabelNode=SKLabelNode()
    var playerScore:Int=0
    var audioEffect:AVAudioPlayer?=nil
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var flag:Int=1
    
    var startFlag:Bool = false
    var originalTime: CFTimeInterval = 0
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func didMoveToView(view: SKView) {
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Front }
        
        if let captureDevice = devices.first as? AVCaptureDevice  {
            
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                captureSession.startRunning()
                
            } catch{
                
            }
            
        }
        self.playerShip.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - self.playerShip.frame.size.height/2)
        self.addChild(self.playerShip)
        
        if((self.mManager?.accelerometerAvailable) == true){
            self.mManager?.startAccelerometerUpdates()
        }else{
        }
        self.physicsBody=SKPhysicsBody(edgeLoopFromRect:self.frame)
        
        self.playerShip.physicsBody=SKPhysicsBody(rectangleOfSize: self.playerShip.frame.size)
        self.playerShip.physicsBody?.dynamic=true
        self.playerShip.physicsBody?.affectedByGravity=false
        self.playerShip.physicsBody?.mass=0.1
        self.playerShip.physicsBody?.friction = 0.1
        self.playerShip.physicsBody?.restitution = 1
        
        self.brown.physicsBody=SKPhysicsBody(rectangleOfSize: self.brown.frame.size)
        self.brown.physicsBody?.dynamic=true
        self.brown.physicsBody?.affectedByGravity=false
        self.brown.physicsBody?.mass=0.1
        self.brown.physicsBody?.friction=0.1
        self.brown.physicsBody?.restitution=1
        
        self.yellow.physicsBody=SKPhysicsBody(rectangleOfSize: self.yellow.frame.size)
        self.yellow.physicsBody?.dynamic=true
        self.yellow.physicsBody?.affectedByGravity=false
        self.yellow.physicsBody?.mass=0.1
        self.yellow.physicsBody?.friction=0.1
        self.yellow.physicsBody?.restitution=1
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //        if previewLayer {
        previewLayer?.bounds = CGRectMake(0.0, 0.0, 200, 200)
        previewLayer?.cornerRadius = 100;
        
        previewLayer?.position = self.playerShip.position //CGPointMake(view.bounds.midX, view.bounds.midY)
        self.previewLayer?.position.y = view.bounds.maxY - 100;
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.opacity = 1
        view.layer.addSublayer(previewLayer!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if startFlag == false{
           startOtherBalls(currentTime)
        }
        self.shipUpdates()
        
        self.previewLayer?.position.x = self.playerShip.position.x
        
        if (self.playerShip.position.x < 90){
            self.previewLayer?.position.x = 100
            
        } else if (self.playerShip.position.x > (view!.bounds.maxX - 90)) {
            self.previewLayer?.position.x = view!.bounds.maxX - 100
            
        } else {
            self.previewLayer?.position.x = self.playerShip.position.x
        }
        
        self.previewLayer?.position.y = view!.bounds.maxY - self.playerShip.position.y
        
        if (self.previewLayer?.position.y < 80){
            self.previewLayer?.position.y = 100
        }
        if (self.previewLayer?.position.y > (view!.bounds.maxY - 80)){
            self.previewLayer?.position.y = view!.bounds.maxY - 100
        }
    }
    var deltaTime: CFTimeInterval = 0.0
    func startOtherBalls(currentTime: CFTimeInterval){
        
        if (self.playerShip.position.y <= 20) { //(view!.bounds.height -
            self.deltaTime = currentTime - self.originalTime
 
            if(self.deltaTime > 1){
 
                let brown_positionActualX = random(min: 0.0, max: view!.bounds.width)
                
                self.brown.position = CGPointMake(brown_positionActualX, CGRectGetMaxY(self.frame) - self.brown.frame.size.height/2)
                self.addChild(self.brown)
            
                let yellow_positionActualX = random(min:0.0, max: view!.bounds.width)
            
                self.yellow.position = CGPointMake(yellow_positionActualX, CGRectGetMaxY(self.frame) - self.yellow.frame.size.height/2)
                self.addChild(self.yellow)
                
                if (flag == 1) {
                    
                    let brown_fvectorLeftValue = random(min: -10.0, max: 10.0)
                    let brown_fvectorRightValue = random(min: 0.0, max: 20.0)
                    
                    let brown_fvector=CGVectorMake(brown_fvectorLeftValue , brown_fvectorRightValue)
                    self.brown.physicsBody?.applyForce(brown_fvector)
                    
                    let yellow_fvectorLeftValue = random(min: -10.0, max: 10.0)
                    let yellow_fvectorRightValue = random(min: 0.0, max: 20.0)
                    
                    let yellow_fvector=CGVectorMake(yellow_fvectorLeftValue , yellow_fvectorRightValue)
                    self.yellow.physicsBody?.applyForce(yellow_fvector)
                    
                    flag = flag + 1
                }
                
                self.startFlag = true
            }
        }
        else{
            self.originalTime = currentTime;
        }

    }
    
    func shipUpdates(){
        let data:CMAccelerometerData?=self.mManager?.accelerometerData
        
        var value:Double?=data?.acceleration.x;
        var valueY:Double?=data?.acceleration.y
        
        if(value==nil){
            value=0
        }
        
        if(valueY==nil){
            valueY=0
        }
        
        if(fabs(value!) > 0.2 || fabs(valueY!) > 0.2)
        {
            let fvector=CGVectorMake(10.0*CGFloat(value!) , 10.0*CGFloat(valueY!))
            self.playerShip.physicsBody?.applyForce(fvector)
            
            let fvector1=CGVectorMake(15.0*CGFloat(value!) , 15.0*CGFloat(valueY!))
            self.brown.physicsBody?.applyForce(fvector1)
            
            let fvector2=CGVectorMake(20.0*CGFloat(value!) , 20.0*CGFloat(valueY!))
            self.yellow.physicsBody?.applyForce(fvector2)
        }
    }
    
}
