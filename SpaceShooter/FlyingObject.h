//
//  FlyingObject.h
//  SpaceShooter
//
//  Created by Roselle Milvich on 5/6/14.
//  Copyright (c) 2014 Roselle Milvich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FlyingObject : SKSpriteNode

@property (nonatomic, assign)int strength;
@property (nonatomic, assign)int maxStrength;
@property (nonatomic, assign)int worth;
@property (nonatomic, assign)int direction;

- (id)initWithImageNamed:(NSString *)imageName name:(NSString *)name strength:(int)strength worth:(int)worth direction:(int)direction speed:(CGFloat)speed;
- (id)initWithColor:(SKColor *)color size:(CGSize)size name:(NSString *)name strength:(int)strength worth:(int)worth direction:(int)direction speed:(CGFloat)speed;
- (void)flyAcrossScreenSize:(CGSize)size position:(CGPoint)position forLevel:(int)level remove:(BOOL)removeNotHidden;


@end
