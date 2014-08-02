//
//  ViewController.h
//  CookieCrunch
//

//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "SWRevealViewController.h"

#define NUM_LEVELS  100

@interface ViewController : UIViewController<SWRevealViewControllerDelegate>

- (void)handleMatches;

@end
