//
//  PCJelly.h
//  JellyCrush
//
//  Created by Paulo Cristo on 23/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const NSUInteger NumCookieTypes = 6;

@interface PCJelly : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;  // 1 - 6
@property (strong, nonatomic) SKSpriteNode *sprite;
@property (strong, nonatomic) SKAction *swapAction;
@property (strong, nonatomic) SKAction *swapActionForever;

@property (copy, nonatomic)  NSString *itemId; //store good id

- (NSString *)spriteName;
- (NSString *)spriteNameAnim01; //first anim
- (NSString *)spriteNameAnim03; //3rd anim
- (NSString *)highlightedSpriteName;

- (NSString *)spriteNameForLabel: (NSString *) label;
- (NSString *)spriteNameAnim01ForLabel: (NSString *) label;
- (NSString *)spriteNameAnim03ForLabel: (NSString *) label;

@end
