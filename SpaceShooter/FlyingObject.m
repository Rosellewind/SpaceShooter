//
//  FlyingObject.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/6/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

#import "FlyingObject.h"

@implementation FlyingObject

@synthesize strength = _strength;
@synthesize worth = _worth;
@synthesize direction = _direction;

#pragma mark - Initialize

- (id)initWithImageNamed:(NSString *)imageName name:(NSString *)name strength:(int)strength worth:(int)worth direction:(int)direction speed:(CGFloat)speed{
    if (self == [super init]){
        self = [FlyingObject spriteNodeWithImageNamed:imageName];
        self.name = name;
        self.speed = speed;
        self.color = [SKColor redColor];
        self.colorBlendFactor = 0;
        self.strength = self.maxStrength = strength;
        self.worth = worth;
        self.direction = direction;
        
    }
    return self;
}

- (id)initWithColor:(SKColor *)color size:(CGSize)size name:(NSString *)name strength:(int)strength worth:(int)worth direction:(int)direction speed:(CGFloat)speed{
    if (self == [super init]){
        self = [FlyingObject spriteNodeWithColor:color size:size];
        self.name = name;
        self.speed = speed;
        self.color = color;
        self.strength = self.maxStrength = strength;
        self.worth = worth;
        self.direction = direction;

    }
    return self;
}

- (id)init{
    if (self == [super init]){
        self = [FlyingObject spriteNodeWithImageNamed:@"Spaceship.png"];
    }
    return self;
}

#pragma mark - Getters and Setters

- (void)setStrength:(int)strength{
    if (strength > self.maxStrength)_strength = self.maxStrength;
    else if (strength < 0)_strength = 0;
    else _strength = strength;
    self.colorBlendFactor = 1 - strength/(float)self.maxStrength;
}

#pragma mark - Random

static inline CGFloat skRand(CGFloat low, CGFloat high){
    return rand()/(CGFloat)RAND_MAX * (high - low) + low;
}

#pragma mark - Actions

- (void)flyAcrossScreenSize:(CGSize)size position:(CGPoint)position forLevel:(int)level remove:(BOOL)removeNotHidden{
    float x, y;
    if (position.x >= 0)x = position.x;
    else x = skRand(0, size.width);
    if (position.y >= 0)y = position.y;
    else if (self.direction < 0) y = size.height + self.size.height/2;
    else y = 0 - self.size.height/2;
    [self removeAllActions];
    CGPoint moveTo;
    if (self.direction < 0){
        CGPoint positionAboveScreen = CGPointMake(x, y);
        self.position = positionAboveScreen;
        moveTo = CGPointMake(self.position.x, 0 - self.size.height/2);
    } else{
        CGPoint positionBelowScreen = CGPointMake(x, y);
        self.position = positionBelowScreen;
        moveTo = CGPointMake(self.position.x, size.height + self.size.height/2);
    }
    self.hidden = NO;
    
    NSTimeInterval duration = size.height/(self.speed * (1 + level/2));
     SKAction *moveAction = [SKAction moveTo:moveTo duration:duration];
    [self runAction:moveAction completion:^{
        if (removeNotHidden) [self removeFromParent];
        else self.hidden = YES;
    }];
}



@end
