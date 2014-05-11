//
//  SpriteViewController.m
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/4/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

#import "SpriteViewController.h"
#import "MenuScene.h"

@implementation SpriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //observe if entering background
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appWillEnterBackground)
     name:UIApplicationWillResignActiveNotification
     object:NULL];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene){
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        MenuScene * scene = [MenuScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (void)appWillEnterBackground
{
    SKView *skView = (SKView *)self.view;
    skView.paused = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appWillEnterForeground)
     name:UIApplicationWillEnterForegroundNotification
     object:NULL];
}

- (void)appWillEnterForeground
{
    SKView * skView = (SKView *)self.view;
    skView.paused = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appWillEnterBackground)
     name:UIApplicationWillResignActiveNotification
     object:NULL];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //attempt to fix gyro issue on ipad
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
