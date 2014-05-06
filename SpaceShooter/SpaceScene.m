//
//  SpaceScene.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/4/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

//levels by time
//different ammo
//switch different ammo
//points display and level
//enemies

@import CoreMotion;
#import "SpaceScene.h"

typedef enum {
    BULLETS, BULLETS_DOUBLE, LASER, LASER_DOUBLE
}AmmunitionType;

@interface SpaceScene()

@property BOOL contentCreated;
@property (nonatomic, strong)CMMotionManager *motionManager;
@property (nonatomic, strong)SKSpriteNode *spaceship;
@property (nonatomic, strong)NSMutableArray *asteroids;
@property int nextAsteroidTime;
@property NSMutableArray *ammunitionNodes;
@property AmmunitionType selectedAmmunition;
@property int lives;
@property int level;
@property int points;
@property BOOL gameOver;

@end



@implementation SpaceScene

#pragma mark - Set Up

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated){
        [self createSceneContents];
        [self moveSpaceshipToStartingPosition];
        [self startTheGame];
    }
}

- (void)createSceneContents{
    
    //ammunition
    self.ammunitionNodes = [NSMutableArray array];
    self.selectedAmmunition = BULLETS;
    
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
    self.spaceship = [self newSpaceship];
    [self addChild:self.spaceship];
    self.contentCreated = YES;
    
    //asteroids
    self.asteroids = [self newAsteroids];
    for (int i = 0; i < self.asteroids.count; i++)[self addChild:self.asteroids[i]];
    self.nextAsteroidTime = 0;
    
    //scoreboard
    [self addChild:[self newScoreboard]];
}

- (SKSpriteNode *)newAmmunitionSingle:(AmmunitionType)type{
    SKColor *color = [SKColor yellowColor];
    CGSize size = CGSizeMake(4, 4);
//    switch (type) {
//        case BULLETS:
//            filename = @"bullets.png";
//            break;
//        case BULLETS_DOUBLE:
//            filename = @"bullets_double.png";
//            break;
//        case LASER:
//            filename = @"laser.png";
//            break;
//        case LASER_DOUBLE:
//            filename = @"laser_double.png";
//            break;
//    }
    SKSpriteNode *ammunition = [SKSpriteNode spriteNodeWithColor:color size:size];
    ammunition.name = @"bullet";
    return ammunition;
}

- (SKSpriteNode *)newAsteroid{
    SKSpriteNode *asteroid = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(32, 32)];
    asteroid.hidden = YES;
    asteroid.name = @"asteroid";
    return asteroid;
}

- (NSMutableArray *)newAsteroids{
    int num = 15;
    NSMutableArray *asteroids = [NSMutableArray arrayWithCapacity:num];
    for (int i = 0; i < num; i++){
        asteroids[i] = [self newAsteroid];
    }
    return asteroids;
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
    spaceship.color = [SKColor redColor];////
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

- (SKLabelNode *)newScoreboard{
    SKLabelNode *scoreboard = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    scoreboard.name = @"scoreboard";
    scoreboard.position = CGPointMake(self.size.width * .05, self.size.height * .95);
    scoreboard.fontSize = 16;
    scoreboard.text = @"1 - 0";
    return scoreboard;
}

#pragma mark - Start and End Game

- (void) startTheGame{
    self.lives = 3;
    self.level = self.points = 0;
    self.spaceship.colorBlendFactor = 0;
    self.spaceship.hidden = NO;
    self.gameOver = NO;
    [self startMonitoringGyro];
}

- (void)endGame{
    self.gameOver = YES;
    [self removeAllActions];
    [self stopMonitoringGyro];
    self.spaceship.hidden = YES;
    
    NSString *message = [NSString stringWithFormat:@"level: %i\npoints: %i",self.level, self.points];
    SKLabelNode *label;
    label = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    label.name = @"winLoseLabel";
    label.text = message;
    label.scale = 0.1;
    label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.6);
    label.fontColor = [SKColor yellowColor];
    [self addChild:label];
    
    SKLabelNode *restartLabel;
    restartLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    restartLabel.name = @"restartLabel";
    restartLabel.text = @"Play Again?";
    restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    restartLabel.fontColor = [SKColor yellowColor];
    [self addChild:restartLabel];
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    
    [restartLabel runAction:labelScaleAction];
    [label runAction:labelScaleAction];
}

- (void)updateScoreboard{
    SKLabelNode *scoreboard = (SKLabelNode *)[self childNodeWithName:@"scoreboard"];
    scoreboard.text = [NSString stringWithFormat:@"%i - %i",self.level, self.points];
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
    CMGyroData *data = self.motionManager.gyroData;
    if (fabs(data.rotationRate.x) > 0.2) {
        CGFloat dx = 30.0 * data.rotationRate.x;
        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft)
            dx = dx * -1;
        [self.spaceship.physicsBody applyForce:CGVectorMake(dx, 0)];
    }
}

#pragma mark - Asteroids

static inline CGFloat skRand(CGFloat low, CGFloat high){
    return rand()/(CGFloat)RAND_MAX * (high - low) + low;
}

- (void)startAsteroid:(SKSpriteNode *)asteroid{
    [asteroid removeAllActions]; //not needed
    asteroid.position = CGPointMake(skRand(0, self.size.width), self.size.height + asteroid.size.height/2);
    asteroid.hidden = NO;
    CGPoint positionBelowScreen = CGPointMake(asteroid.position.x, 0 - asteroid.size.height/2);
    SKAction *moveAction = [SKAction moveTo:positionBelowScreen duration:skRand(2, 10)];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        asteroid.hidden = YES;
    }];
    [asteroid runAction:[SKAction sequence:@[moveAction, doneAction]] withKey:@"asteroidMoving"];
}

- (void)startAsteroidIfNeeded:(NSTimeInterval)currentTime{
    if (self.nextAsteroidTime < currentTime){
        [self.asteroids enumerateObjectsUsingBlock:^(SKSpriteNode *asteroid, NSUInteger idx, BOOL *stop) {
            if (asteroid.hidden == YES){
                [self startAsteroid:asteroid];
                *stop = YES;
            }
            else if (idx == self.asteroids.count - 1){
                SKSpriteNode *newAsteroid = [self newAsteroid];
                [self.asteroids addObject:newAsteroid];
                [self startAsteroid:newAsteroid];
                *stop = YES;
            }
        }];
        self.nextAsteroidTime = currentTime + skRand(.5, 3);
    }
}

#pragma mark - Shooting

- (void)shoot:(AmmunitionType)type{
    SKSpriteNode *ammo = [self newAmmunitionSingle:type];
    [self.ammunitionNodes addObject:ammo];
    ammo.position = CGPointMake(self.spaceship.position.x, self.spaceship.position.y + self.spaceship.size.height/2);
//    ammo.position = self.spaceship.position;
    CGPoint positionAboveScreen = CGPointMake(ammo.position.x, self.size.height + ammo.size.height/2);
    SKAction *moveAction = [SKAction moveTo:positionAboveScreen duration:5];//duration in class?
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        [self.ammunitionNodes removeObject:ammo];
        [ammo removeFromParent];
    }];
    [self addChild:ammo];
    [ammo runAction:[SKAction sequence:@[moveAction, doneAction]] withKey:@"shooting"];
}

#pragma mark - Run Loop

- (void)update:(NSTimeInterval)currentTime{
    if(!self.gameOver){
        [self startAsteroidIfNeeded:currentTime];
        [self updateSpaceshipPositionFromGyro];
        
        //check for collisions
        for (SKSpriteNode *asteroid in self.asteroids) {
            if (!asteroid.hidden){
                if ([self.spaceship intersectsNode:asteroid]){
                    if (self.lives == 3) self.spaceship.colorBlendFactor = .3;
                    else if (self.lives == 2) self.spaceship.colorBlendFactor = .6;
                    else if (self.lives == 1) {[self endGame]; break;}
                    self.lives--;
                    asteroid.hidden = YES;
                    self.spaceship.color = [SKColor redColor];
                    
                    //particle emmitter/////////
                    SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:.2], [SKAction fadeInWithDuration:.2]]];
                    SKAction *blinkTimes = [SKAction repeatAction:blink count:4];
                    [self.spaceship runAction:blinkTimes];
                    
                }
                SKSpriteNode *toRemove = nil;
                for (SKSpriteNode *ammo in self.ammunitionNodes){
                    if ([ammo intersectsNode:asteroid]){
                        self.points += 5;
                        [self updateScoreboard];
                        asteroid.hidden = YES;
                        toRemove = ammo;
                        [ammo removeFromParent];
                    }
                }
                [self.ammunitionNodes removeObject:toRemove];
            }
        }
    }
}

#pragma mark - Actions

- (void)moveSpaceshipToStartingPosition{
    float scaleTo =CGRectGetWidth(self.frame) / 10 / CGRectGetWidth(self.spaceship.frame);
    SKAction *move = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), 50) duration:1];
    SKAction *scale = [SKAction scaleTo:scaleTo duration:1];
    [self.spaceship runAction:[SKAction group:@[move, scale]]];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //check if restart
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: @"restartLabel"]) {
            [[self childNodeWithName:@"restartLabel"] removeFromParent];
            [[self childNodeWithName:@"winLoseLabel"] removeFromParent];
            [self startTheGame];
            return;
        }
    }
    
    //do not process anymore touches since it's game over
    if (self.gameOver) return;
    
    //shoot
    [self shoot:self.selectedAmmunition];
}



@end
