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
    label.fontSize = 120;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + label.fontSize);
    [self addChild:label];
    
    //instructions label
    SKLabelNode *instructionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    instructionsLabel.name = @"instructions";
    instructionsLabel.text = @"Instructions";
    instructionsLabel.fontSize = 36;
    instructionsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:instructionsLabel];
    
    //start label
    SKLabelNode *startLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    startLabel.name = @"start";
    startLabel.text = @"Start";
    startLabel.fontSize = 36;
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - startLabel.fontSize * 2);
    [self addChild:startLabel];
    

}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches){
        SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
        if ([node.name isEqualToString:@"instructions"]){
            UIAlertView * instructions = [[UIAlertView alloc]initWithTitle:@"Instructions" message:@"Objective: get the most points or levels by shooting the asteroids until you run out of strength.\n\nGame Rules: Lose 1 for each asteroid that passes you, lose 3 if you crash into an asteroid.  There are more asteroids and faster asteroids as the levels go up.\n\nTo Use: Tap screen to shoot, swipe up or down to change ammunition, gyro to move spaceship." delegate:self cancelButtonTitle:@"Got It!" otherButtonTitles:nil];
            [instructions show];
            return;
        }else if ([node.name isEqualToString:@"start"]){
            
            //transition to space scene with doors
            SpaceScene *nextScene = [[SpaceScene alloc]initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:1];
            [self.view presentScene:nextScene transition:doors];
            return;
        }
    }
    
    
}
         
@end
