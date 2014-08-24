//
//  ViewController.m
//  JellyCrush
//
//  Created by Paulo Cristo on 23/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "SWRevealViewController.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

#define NUM_LEVELS  100
#define LEVEL_COMPLETION_BONUS_AMOUNT 40

@interface ViewController : UIViewController<SWRevealViewControllerDelegate,GKLeaderboardViewControllerDelegate,GameCenterManagerDelegate>

- (void)handleMatches;
-(void)notifyMarketPurchase:(NSString*)itemId;
-(void)notifyBoosterItemPurchase:(NSString*)itemId;

@end
