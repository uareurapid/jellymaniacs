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
@import GoogleMobileAds;

#define NUM_LEVELS  100
#define LEVEL_COMPLETION_BONUS_AMOUNT 40
#define REWARD_VIDEO_AD_UNIT_ID @"ca-app-pub-9531252796858598/6932609016"
#define INTERSTITTIAL_AD_UNIT_ID @"ca-app-pub-9531252796858598/4703043259"

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



@interface ViewController : UIViewController<SWRevealViewControllerDelegate,GKLeaderboardViewControllerDelegate,GameCenterManagerDelegate, GADRewardBasedVideoAdDelegate, UIAlertViewDelegate>

- (void)handleMatches;
-(void)notifyMarketPurchase:(NSString*)itemId;
-(void)notifyBoosterItemPurchase:(NSString*)itemId;

@end
