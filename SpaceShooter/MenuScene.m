//
//  MenuScene.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/4/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//
#import "MenuScene.h"
#import "SpaceScene.h"

@interface MenuScene()
@property BOOL contentCreated;
@end


@implementation MenuScene

#pragma mark - Set Up

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated){
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    //label with name of the game
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    label.text = @"Space Shooter";
    label.fontSize = 36;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:label];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //transition to next scene with doors
    SpaceScene *nextScene = [[SpaceScene alloc]initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:1];
    [self.view presentScene:nextScene transition:doors];
}

@end
