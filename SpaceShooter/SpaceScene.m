//
//  SpaceScene.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/4/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

@import CoreMotion;
#import "SpaceScene.h"

@interface SpaceScene()
@property BOOL contentCreated;
@property (nonatomic, strong)CMMotionManager *motionManager;
@end

@implementation SpaceScene

#pragma mark - Set Up

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated){
        [self createSceneContents];
        [self moveSpaceshipToStartingPosition];
        [self startMonitoringGyro];
    }
}

- (void)createSceneContents{
    //scene parameters
    self.scaleMode = SKSceneScaleModeAspectFit;

    //physics body frame
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.restitution = 0;
    
    //background
    self.backgroundColor = [SKColor blackColor];
    
    //stars
    [self addChild:[self newStars]];
    
    //spaceship
    [self addChild:[self newSpaceship]];
    self.contentCreated = YES;
    
}

- (SKSpriteNode *)newSpaceship{
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    spaceship.name = @"spaceship";
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    spaceship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spaceship.size];
    spaceship.physicsBody.dynamic = YES;
    spaceship.physicsBody.affectedByGravity = NO;
    spaceship.physicsBody.mass = .01;
    spaceship.physicsBody.restitution = 0;
    return spaceship;
    
}

- (SKEmitterNode * )newStars{
    NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars" ofType:@".sks"];
    SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
    stars.name = @"stars";
    stars.targetNode = self;
    stars.particlePosition = CGPointMake(self.size.width/2.0, self.size.height);
    stars.particlePositionRange = CGVectorMake(self.size.width, 0);
    return stars;
}

#pragma mark - Gyro

- (void)startMonitoringGyro{
    if (!self.motionManager) self.motionManager = [CMMotionManager new];
    if (self.motionManager.gyroAvailable) {
        [self.motionManager startGyroUpdates];
    }
}

- (void)stopMonitoringGyro{
    if (self.motionManager.gyroAvailable && self.motionManager.gyroActive) {
        [self.motionManager stopGyroUpdates];
    }
}

- (void)updateSpaceshipPositionFromGyro{
    CMGyroData* data = self.motionManager.gyroData;
    if (fabs(data.rotationRate.x) > 0.2) {
        SKNode *spaceship = [self childNodeWithName:@"spaceship"];
        [spaceship.physicsBody applyForce:CGVectorMake(30.0 * data.rotationRate.x, 0)];
    }
}

#pragma mark - Run Loop

- (void)update:(NSTimeInterval)currentTime{
    [self updateSpaceshipPositionFromGyro];
}

#pragma mark - Actions

- (void)moveSpaceshipToStartingPosition{
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    float scaleTo =CGRectGetWidth(self.frame) / 10 / CGRectGetWidth(spaceship.frame);
    SKAction *move = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), 50) duration:1];
    SKAction *scale = [SKAction scaleTo:scaleTo duration:1];
    [spaceship runAction:[SKAction group:@[move, scale]]];
}

@end
