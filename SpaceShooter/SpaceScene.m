//
//  SpaceScene.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/4/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

//background
//spaceship
//gyroscope
//asteroids
//bullets
//scoreboard
//collision detection
//levels by points
//level indicator
//sounds level, powerup,

//different ammo
//switch different ammo
//enemies
//power ups
//indicate levelups


@import CoreMotion;
#import "SpaceScene.h"
#import "FlyingObject.h"

#define SPACESHIP_STRENGTH 10
typedef enum {
    BULLETS, BULLETS_DOUBLE, LASER, LASER_DOUBLE
}AmmunitionType;

@interface SpaceScene()

@property BOOL contentCreated;
@property (nonatomic, strong)CMMotionManager *motionManager;
@property (nonatomic, strong)FlyingObject *spaceship;
@property (nonatomic, strong)NSMutableArray *asteroids;
@property int nextAsteroidTime;
@property NSMutableArray *ammunitionNodes;
@property AmmunitionType selectedAmmunition;
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
        [self addGestureRecognizers];
        [self startTheGame];
    }
}

- (void)createSceneContents{
    
    //ammunition
    self.ammunitionNodes = [NSMutableArray array];
    self.selectedAmmunition = BULLETS;
    
    //scene parameters
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    //background
    self.backgroundColor = [SKColor blackColor];
    
    //stars
    [self addChild:[self newStars:NO]];
    [self addChild:[self newStars:YES]];
    [self timedRemoveInitialStars];

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
    
    
    //physics body frame
    float offset = self.size.width / 20;
    CGRect physicsFrame = CGRectMake(0 - offset, 0, self.size.width + offset*2, self.size.height);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:physicsFrame];
    self.physicsBody.restitution = 0;
}

- (FlyingObject *)newAmmunitionSingle:(AmmunitionType)type{
    SKColor *color = [SKColor yellowColor];
    CGSize size = CGSizeMake(4, 4);
    int strength = 2;
    int worth = 2;
    float speed = 12;
    switch (type) {
        case BULLETS:
//            filename = @"bullets.png";
            break;
        case BULLETS_DOUBLE:
            color = [SKColor yellowColor];
            size = CGSizeMake(4, 12);
            strength = 4;
            worth = 5;
            speed = 16;
//            filename = @"bullets_double.png";
            break;
        case LASER:
            color = [SKColor redColor];
            size = CGSizeMake(6, 6);
            strength = 6;
            worth = 10;
            speed = 25;
//            filename = @"laser.png";
            break;
        case LASER_DOUBLE:
            color = [SKColor redColor];
            size = CGSizeMake(8, 12);
            strength = 8;
            worth = 15;
            speed = 30;
//            filename = @"laser_double.png";
            break;
    }
    FlyingObject *ammunition = [[FlyingObject alloc]initWithColor:color size:size name:@"bullet" strength:strength worth:worth direction:1 speed:speed];
    return ammunition;
}

- (FlyingObject *)newAsteroid{
    FlyingObject *asteroid = [[FlyingObject alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(32, 32) name:@"asteroid" strength:4 worth:2 direction:-1 speed:skRand(10, 20)];
    asteroid.hidden = YES;
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

- (FlyingObject *)newSpaceship{
    FlyingObject *spaceship = [[FlyingObject alloc]initWithImageNamed:@"Spaceship.png" name:@"spaceship" strength:SPACESHIP_STRENGTH worth:0 direction:0 speed:3];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    spaceship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spaceship.size];
    spaceship.physicsBody.dynamic = YES;
    spaceship.physicsBody.affectedByGravity = NO;
    spaceship.physicsBody.mass = .01;
    spaceship.physicsBody.restitution = 0;
    spaceship.color = [SKColor redColor];
    return spaceship;
}

- (SKEmitterNode * )newStars:(BOOL)initial{     //gravity formula, t = sqrt((2 * d)/g)
    NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars" ofType:@".sks"];
    SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
    stars.targetNode = self;
    int lifetime = ceil(sqrt((2 * self.size.height)/(stars.yAcceleration * -1)));//estimated initial velocity = 0 rather than v=10, insignificant .5 sec overestimate on ipad
    int numOnScreen = lifetime * stars.particleBirthRate;
    stars.particleLifetime = lifetime;
    if (initial){
        stars.name = @"initialStars";
        stars.particleBirthRate = numOnScreen * 100;
        stars.numParticlesToEmit = numOnScreen;
        stars.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2);
        stars.particlePositionRange = CGVectorMake(self.size.width, self.size.height);
    }
    else {
        stars.name = @"stars";
        stars.particlePosition = CGPointMake(self.size.width/2.0, self.size.height);
        stars.particlePositionRange = CGVectorMake(self.size.width, 0);
    }
    return stars;
}

- (SKNode *)newScoreboard{
    SKLabelNode *scoreboard = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    scoreboard.name = @"scoreboard";
    scoreboard.position = CGPointMake(28, 28);
    scoreboard.fontSize = 24;
    scoreboard.text = @"1 - 0";
    scoreboard.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    SKLabelNode *strengthboard = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    strengthboard.name = @"strengthboard";
    strengthboard.position = CGPointMake(0, 0);
    strengthboard.fontSize = 24;
    strengthboard.text = [NSString stringWithFormat:@"strength: %i", self.spaceship.strength];
    
    SKNode *board = [[SKNode alloc]init];
    board.name = @"board";
    [board addChild:scoreboard];
    [board addChild:strengthboard];
    board.position = CGPointMake(self.size.width * .1, self.size.height * .95 - 48);
    return board;
}

- (void)addGestureRecognizers{
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    up.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:up];
    
    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:down];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Start and End Game

- (void) startTheGame{
    self.spaceship.strength = SPACESHIP_STRENGTH;
    self.level = 1;
    self.points = 0;
    [self updateScoreboard];
    self.spaceship.colorBlendFactor = 0;
    self.spaceship.hidden = NO;
    self.gameOver = NO;
    [self startMonitoringGyro];
}

- (void)endGame{
    self.gameOver = YES;
    [self removeAllActions];
    [self runAction:[SKAction playSoundFileNamed:@"game_over.wav" waitForCompletion:NO]];
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
    //simple level algorithm, level every 20 points
    while (self.level * 20 < self.points) {
        self.level++;
        [self runAction:[SKAction playSoundFileNamed:@"level_up.mp3" waitForCompletion:NO]];
        [self displayLevelUp];
    }
    SKNode *board = [self childNodeWithName:@"board"];
    SKLabelNode *scoreboard = (SKLabelNode *)[board childNodeWithName:@"scoreboard"];
    scoreboard.text = [NSString stringWithFormat:@"%i - %i",self.level, self.points];
}

- (void)updateStrengthboard{
    SKNode *board = [self childNodeWithName:@"board"];
    SKLabelNode *strengthboard = (SKLabelNode *)[board childNodeWithName:@"strengthboard"];
    strengthboard.text = [NSString stringWithFormat:@"strength: %i",self.spaceship.strength];
}

- (void)displayLevelUp{
    SKLabelNode *levelLabel;
    levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
    levelLabel.name = @"levelLabel";
    levelLabel.text = [NSString stringWithFormat:@"Level %i", self.level];
    levelLabel.scale = 0.2;
    levelLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    levelLabel.fontColor = [SKColor blueColor];
    levelLabel.fontSize = 80;
    [self addChild:levelLabel];
    
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:1];
    SKAction *doneAction = [SKAction runBlock:^{
        [levelLabel removeFromParent];
    }];
    [levelLabel runAction:[SKAction sequence:@[labelScaleAction, doneAction]]];
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

- (void)startAsteroidIfNeeded:(NSTimeInterval)currentTime{
    if (self.nextAsteroidTime < currentTime){
        [self.asteroids enumerateObjectsUsingBlock:^(FlyingObject *asteroid, NSUInteger idx, BOOL *stop) {
            if (asteroid.hidden == YES){
                [asteroid flyAcrossScreenSize:self.size position:CGPointMake(-1, -1) forLevel:self.level remove:NO];
                *stop = YES;
            }
            else if (idx == self.asteroids.count - 1){
                FlyingObject *newAsteroid = [self newAsteroid];
                [self.asteroids addObject:newAsteroid];
                [asteroid flyAcrossScreenSize:self.size position:CGPointMake(-1, -1) forLevel:self.level remove:NO];
                *stop = YES;
            }
        }];
        self.nextAsteroidTime = currentTime + skRand(.5, 3);
    }
}

#pragma mark - Shooting

- (void)shoot:(AmmunitionType)type{
    FlyingObject *ammo = [self newAmmunitionSingle:type];
    [self.ammunitionNodes addObject:ammo];
    [self addChild:ammo];
    CGPoint position = CGPointMake(self.spaceship.position.x, self.spaceship.position.y + self.spaceship.size.height/2);
    
    [self runAction:[SKAction playSoundFileNamed:@"bullet.wav" waitForCompletion:NO]];
    [ammo flyAcrossScreenSize:self.size position:position forLevel:self.level remove:YES];
}

#pragma mark - Run Loop
- (void)update:(NSTimeInterval)currentTime{
    if(!self.gameOver){
        [self startAsteroidIfNeeded:currentTime];
        [self updateSpaceshipPositionFromGyro];

        //check for collisions
        for (FlyingObject *asteroid in self.asteroids) {
            if (!asteroid.hidden){
                if ([self.spaceship intersectsNode:asteroid]){
                    [self runAction:[SKAction playSoundFileNamed:@"small_explosion.wav" waitForCompletion:NO]];
                    self.spaceship.strength -= asteroid.strength;
                    [self updateStrengthboard];
                    if (self.spaceship.strength <= 0) {
                        [self endGame]; break;
                    }
                    asteroid.hidden = YES;
                    
                    //particle emmitter/////////
                    SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:.2], [SKAction fadeInWithDuration:.2]]];
                    SKAction *blinkTimes = [SKAction repeatAction:blink count:4];
                    [self.spaceship runAction:blinkTimes];
                    
                }
                SKSpriteNode *toRemove = nil;
                for (SKSpriteNode *ammo in self.ammunitionNodes){
                    if (ammo.parent == NULL){
                        toRemove = ammo;
                    }
                    if ([ammo intersectsNode:asteroid]){
                        self.points += asteroid.worth;
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

- (void)timedRemoveInitialStars{
    SKEmitterNode *initialStars = (SKEmitterNode*)[self childNodeWithName:@"initialStars"];
    int lifetime = ceil(sqrt((2 * self.size.height)/(initialStars.yAcceleration * -1)));
    SKAction *wait = [SKAction waitForDuration:lifetime];
    SKAction *remove = [SKAction runBlock:^{
        [initialStars removeFromParent];
    }];
    [initialStars runAction:[SKAction sequence:@[wait, remove]]];
}

#pragma mark - Gesture Recognizers


- (void)handleTap:(UISwipeGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded){
        //check if restart
        [sender locationInView:self.view];
        SKNode *n = [self nodeAtPoint:[sender locationInView:self.view]];
        if (n != self && [n.name isEqual: @"restartLabel"]) {
            [[self childNodeWithName:@"restartLabel"] removeFromParent];
            [[self childNodeWithName:@"winLoseLabel"] removeFromParent];
            [self startTheGame];
            return;
        }
        //do not process any more touches since it's game over
        if (self.gameOver) return;
        
        //shoot
        [self shoot:self.selectedAmmunition];
    }
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded){
        //view to select ammo //////////////
        NSLog(@"swipe----");
        
        
    }
}



@end
