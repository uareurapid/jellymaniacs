//
//  AppDelegate.m
//  CookieCrunch
//
//  Created by Matthijs on 25-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SoomlaStore.h"
#import "Soomla.h"
#import "JellyStoreAssets.h"
#import "StoreInventory.h"
#import "VirtualCurrency.h"
#import "Constants.h"
#import "ALSdk.h"
#import "Appirater.h"

#define DEBUG_RUN

@implementation AppDelegate

//UIViewController *rvc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    /**
     We initialize SoomlaStore when the application loads !
     */
    id<IStoreAssets> storeAssets = [[JellyStoreAssets alloc] init];
    [Soomla initializeWithSecret:@"jelly_store_secret"];
    [[SoomlaStore getInstance] initializeWithStoreAssets:storeAssets];
    
    // Checking if it's a first run and adding 10000 currencies if it is.
    // OFCOURSE... THIS IS JUST FOR TESTING.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"NotFirstLaunch"])
    {
        [defaults setBool:YES forKey:@"NotFirstLaunch"];
        [(VirtualCurrency*)[storeAssets.virtualCurrencies objectAtIndex:0] giveAmount:1000];
    }
    
    //if the key doesn´t exist yet, set the value to 1;
    if (![defaults integerForKey:NUM_JELLY_PLAYS_KEY])
    {
        [defaults setInteger:1 forKey:NUM_JELLY_PLAYS_KEY];
    }
    
    //if the key doesn´t exist yet, set the value to 1;
    if (![defaults integerForKey:SHARED_FACEBOOK_KEY])
    {
        [defaults setInteger:0 forKey:SHARED_FACEBOOK_KEY];
    }
    
    
    //test
#ifdef DEBUG_RUN
    [(VirtualCurrency*)[storeAssets.virtualCurrencies objectAtIndex:0] giveAmount:1000];
#endif
    //if not exists, set the total number of levels (as for version 1.0 is 100)
    if (![defaults integerForKey:NUM_AVAILABLE_LEVELS_KEY])
    {
        [defaults setInteger:NUM_AVAILABLE_LEVELS forKey:NUM_AVAILABLE_LEVELS_KEY];
    }
    
    //if not exists, set the total number of built-in/free levels (as for version 1.0 is 50)
    //any time i purchase 10 more, i need to update this number
    //and can only buy if <=100-10 --> 90
    if (![defaults integerForKey:NUM_PURCHASED_LEVELS_KEY])
    {
        [defaults setInteger:NUM_PURCHASED_LEVELS forKey:NUM_PURCHASED_LEVELS_KEY];
    }

    //start with 0
    if (![defaults integerForKey:NUM_PURCHASED_MOVES_KEY])
    {
        [defaults setInteger:NUM_PURCHASED_MOVES forKey:NUM_PURCHASED_MOVES_KEY];
    }
    
    //last saved game is level 1
    if (![defaults integerForKey:LAST_SAVE_KEY])
    {
        [defaults setInteger:1 forKey:LAST_SAVE_KEY];
    }
    
    //initialize applovin sdk
    [ALSdk initializeSdk];
    
    //API rater stuff
    //show it 5 days after
    //custom Rate code
    [Appirater setAppId:@"904072768"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    //end custom code
    
    //custom Rate code
    [Appirater appLaunched:YES];

    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
