//
//  ViewController.m
//  JellyCrush
//
//  Created by Paulo Cristo on 23/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

@import AVFoundation;

#import "ViewController.h"
#import "MyScene.h"
#import "PCLevel.h"
#import <Social/Social.h>
#import "iToast.h"
#import "StoreInventory.h"
#import "JellyStoreAssets.h"
#import "ImageLoaderUniversalHelper.h"
#import "Constants.h"
#import "VirtualItemNotFoundException.h"
#import "ALInterstitialAd.h"
#import "GameCenterManager.h"



@interface ViewController ()

// The level contains the tiles, the cookies, and most of the gameplay logic.
@property (strong, nonatomic) PCLevel *level;

// The scene draws the tiles and cookie sprites, and handles swipes.
@property (strong, nonatomic) MyScene *scene;
@property (assign, nonatomic) NSUInteger currentLevel;
@property (strong, nonatomic) IBOutlet UIImageView *shareAndWinView;
@property (strong, nonatomic) IBOutlet UIImageView *shareToPlayOrWaitView;
@property (strong, nonatomic) IBOutlet UILabel *waitToPlayTimerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *unlockMoveLevel20View;
@property (strong, nonatomic) IBOutlet UIImageView *lastSaveView;
@property (strong, nonatomic) IBOutlet UILabel *lastSaveLabel;
@property (strong, nonatomic) IBOutlet UIImageView *denyLastSaveView;
@property (strong, nonatomic) IBOutlet UIImageView *acceptLastSaveView;

@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger levelScore;
@property (assign, nonatomic) NSUInteger overallScore;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *facebookIcon;
@property (strong, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (strong, nonatomic) IBOutlet UIImageView *replayButton;
@property (strong, nonatomic) IBOutlet UIImageView *musicSettingView;

@property (strong, nonatomic) IBOutlet UIImageView *jellyStarsView;
@property (strong, nonatomic) IBOutlet UILabel *jellyStarsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *needHelpImageView;

@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *sideMenu;
@property (strong, nonatomic) IBOutlet UILabel *gameOverScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameOverBestScoreLabel;
@property (strong, nonatomic) IBOutlet UIImageView *leaderboardIcon;

@property BOOL isGameCenterAvailable;

//the bonus for level completion
@property (strong, nonatomic) IBOutlet UIView *bonusView;
@property (strong, nonatomic) IBOutlet UILabel *bonusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coolMoveView;

@property (weak, nonatomic) IBOutlet UIImageView *gameOverPanel;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

@property BOOL isFacebookAvailable;
@property BOOL isTwitterAvailable;
@property BOOL isMusicOn;
@property BOOL shareToWinClicked;

//GAME CENTER STUFF
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;

//need to check the values before and after the change to store view
@property NSUInteger numLevelsPurchased;
@property NSUInteger numMovesPurchased;

@property (assign, nonatomic) NSUInteger currentHelperGoodIndex;

//the image in the button
@property (strong, nonatomic) IBOutlet UIImageView *boosterImage;
//the sprite name, to identify the sprite node to build on the scene
@property NSString *boosterSpriteName;

//boosters
@property (strong, nonatomic) UIImage *boosterBlue;
@property (strong, nonatomic) UIImage *boosterRed;
@property (strong, nonatomic) UIImage *boosterGreen;
@property (strong, nonatomic) UIImage *boosterYellow;
@property (strong, nonatomic) UIImage *boosterDark;
@property (strong, nonatomic) UIImage *boosterPink;
@property (strong, nonatomic) UIImage *boosterBomb;

@property NSUInteger waitToPlayTimer;
@property NSTimer *waitTimer;

@property NSTimer *helperTimer;
@property BOOL startFromLastSave;

- (IBAction) showLeaderboard;
- (IBAction) submitScore;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    //_sideMenu.target = self.revealViewController;
    //_sideMenu.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    // Don't forget to add an action handler to toggle the selected property
    
    [_sideMenu addTarget: self action:@selector(revealToggleX:) forControlEvents:UIControlEventTouchUpInside];
    self.revealViewController.delegate = self;
    
    //hide this by default
    self.isFacebookAvailable = self.isTwitterAvailable = false;
    
    self.facebookIcon.hidden = true;
    self.twitterIcon.hidden = true;
    self.startFromLastSave = false;
    
   //now do the proper check
    [self checkSocialServicesAvailability];
    [self setupShareToWinTouch];
    
   //must be done after check the services
    [self setupReplayButton];
    
    
    self.shareToWinClicked = false;
    
    
    self.leaderboardIcon.hidden = true;
    self.replayButton.hidden = true;
    self.bonusView.hidden = true;
    self.coolMoveView.hidden = true;
    self.needHelpImageView.hidden = true;
    self.boosterImage.hidden = true;
    
    
   [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    
    
  //***************************
    
   //section 1, configure scene
    self.currentLevel = 1;
    self.overallScore = 0;
    self.levelScore = 0;
    
    
  //***************************
    
   //share to facebook and win 500 stars
   self.shareAndWinView.hidden = true;
   //every 10 plays i show the share to twitter
   self.shareToPlayOrWaitView.hidden = true;
   self.waitToPlayTimerLabel.hidden = true;
    

  //*******************************
    
    //section 2 configure the scene
    
    // Hide the game over panel from the screen.
    self.gameOverPanel.hidden = YES;
    [self.gameOverBestScoreLabel setHidden:true];
    [self.gameOverScoreLabel setHidden:true];
    
   //*******************************
    
   //show this
   self.unlockMoveLevel20View.hidden = false;

    
    NSUInteger lastSavedLevel = [self checkLastSaves];
    self.currentLevel = lastSavedLevel;
    
    if(lastSavedLevel>1) {

        [self setupLastSaveAcceptTouch];
        [self setupLastSaveDenyTouch];
            
        self.unlockMoveLevel20View.hidden = true;
        self.lastSaveLabel.hidden = false;
        self.lastSaveView.hidden = false;
        self.acceptLastSaveView.hidden = false;
        self.denyLastSaveView.hidden = false;
        self.shuffleButton.hidden = true;
        self.sideMenu.hidden = true;
        self.lastSaveLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.currentLevel];
            
        self.targetLabel.hidden = true;
        self.levelLabel.hidden = true;
        self.scoreLabel.hidden = true;
        self.movesLabel.hidden = true;
        self.musicSettingView.hidden = true;
        
        
        
    }
    else {
        self.unlockMoveLevel20View.hidden = false;
        self.lastSaveLabel.hidden = true;
        self.lastSaveView.hidden = true;
        self.acceptLastSaveView.hidden = true;
        self.denyLastSaveView.hidden = true;
        // Let's start the game!
        
        [self configureGameScene];
        [self beginGame: false];
    }
    
    //TODO USE if(self.isTwitterAvailable
    //&& [self getNumberOfPlays]>MAX_PLAYS_WITHOUT_SHARE
    //&& ![self alreadySharedToTwitter]) {
        
    //    [self configureTwitterShareWaitBeforePlay];
    //}

  
}

-(void) configureGameScene {
    
    //******* SECTION 1 **************
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    
    // Create and configure the scene.
    self.scene = [MyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    self.musicSettingView.hidden = false;
    
    [self initHelperGoods];
    [self setupBoosterTouch];
    
    
    //set notifications, for when a booster was used on the scene
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportBoosterAction:)
                                                 name:@"ReportBoosterInPlace"
                                               object:nil];
    
    //setup music, on by default
    [self setupMusicSettingsTouch];
    
    //setup game center
    [self setupGameCenter];
    
    
    self.level = [[PCLevel alloc] initWithFile: [NSString stringWithFormat:@"Level_%lu",(unsigned long)self.currentLevel-1]];
    self.scene.level = self.level;
    
    //configure moves and target
    [self configureMovesAndTarget];
    
    [self.scene addTiles];
    
    
    //************* SECTION 2 *********
    // This is the swipe handler. MyScene invokes this block whenever it
    // detects that the player performs a swipe.
    id block = ^(PCSwap *swap) {
        
        // While cookies are being matched and new cookies fall down to fill up
        // the holes, we don't want the player to tap on anything.
        self.view.userInteractionEnabled = NO;
        
        if ([self.level isPossibleSwap:swap]) {
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
                [self handleMatches];
            }];
        } else {
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    
    
    // Present the scene.
    [skView presentScene:self.scene];
    
    // Load and start background music.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Gonna Start v2" withExtension:@"mp3"];//Mining by Moonlight
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
    
    
}


//check the last saved level
-(NSUInteger) checkLastSaves {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger lastSavedLevel = [defaults integerForKey:LAST_SAVE_KEY];
    return lastSavedLevel;
    
}

//save game/level played
-(void) saveGame:(NSUInteger)level {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:level forKey:LAST_SAVE_KEY];
}

-(void)setupBoosterTouch {
    self.boosterImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapBoosterWithGesture:)];
    [self.boosterImage addGestureRecognizer:tapGesture];
}


-(void)setupShareToWinTouch {
    self.shareAndWinView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapShareToWinWithGesture:)];
    [self.shareAndWinView addGestureRecognizer:tapGesture];

}

-(void)setupLastSaveAcceptTouch {
    self.acceptLastSaveView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapLastSaveAcceptWithGesture:)];
    [self.acceptLastSaveView addGestureRecognizer:tapGesture];
    
}

-(void)setupLastSaveDenyTouch {
    self.denyLastSaveView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapLastSaveDenyWithGesture:)];
    [self.denyLastSaveView addGestureRecognizer:tapGesture];

}

- (void)didTapLastSaveAcceptWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    self.startFromLastSave = true;
    [self hideLastSaveChoicesView];
    [self configureGameScene];
    [self beginGame:false];
}

- (void)didTapLastSaveDenyWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    self.startFromLastSave = false;
    self.currentLevel = 1;
    [self hideLastSaveChoicesView];
    [self configureGameScene];
    [self beginGame:false];
}


//hides the view and shows the game
-(void) hideLastSaveChoicesView {
    
    
    self.shuffleButton.hidden = false;
    self.sideMenu.hidden = false;
    self.lastSaveView.hidden = true;
    self.acceptLastSaveView.hidden = true;
    self.denyLastSaveView.hidden = true;
    self.lastSaveLabel.hidden=true;
    
    
    self.targetLabel.hidden = false;
    self.levelLabel.hidden = false;
    self.scoreLabel.hidden = false;
    self.movesLabel.hidden = false;
    
    
}

-(void)setupShareToPlayOrWaitTouch {
    
    
    //if twitter is available, setup the timer (if met conditions) and allow interaction
    
        
    self.shareToPlayOrWaitView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapShareToPlayOrWaitWithGesture:)];
    [self.shareToPlayOrWaitView addGestureRecognizer:tapGesture];

    //set the timer running
    
    
}
//click on twitter or wait 03:00 to play
- (void)didTapShareToPlayOrWaitWithGesture:(UITapGestureRecognizer *)tapGesture {
    self.shareToWinClicked = true;
    [self sendToTwitter:self message:NSLocalizedString(@"checkout_my_app", @"checkout_my_app")];
}

-(void) setWaitToPlayOrShareTimer {
    
    self.waitToPlayTimer = 180; //180 secs == 3 minutes
    self.waitToPlayTimerLabel.text = @"03:00";
    
    self.waitTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.waitTimer forMode:NSRunLoopCommonModes];
 
}

-(void)updateTimer: (NSTimer*)aTimer {
    //NSDate *now = [NSDate date];
    self.waitToPlayTimer-=1;
    
    NSUInteger seconds = 0;
    //2 minutes and something
    if(self.waitToPlayTimer>=120) {
        
        seconds = 180 - self.waitToPlayTimer;
        
        if(seconds > 50) {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"02:0%lu",60 - seconds ];
        }
        else {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"02:%lu",(unsigned long) 60 - seconds ];
        }
        
    }
    //1 minute and something
    else if(self.waitToPlayTimer>=60){
        
        seconds = 120 - self.waitToPlayTimer;
        
   
        if(seconds > 50) {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"01:0%lu",60-seconds ];
        }
        else {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"01:%lu",(unsigned long) 60 - seconds ];
        }
        
        
    }
    else if(self.waitToPlayTimer>0){
        
        seconds = 60 - self.waitToPlayTimer;
        
        if(seconds > 50) {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"00:0%lu",60-seconds ];
        }
        else {
            self.waitToPlayTimerLabel.text = [NSString stringWithFormat: @"00:%lu",(unsigned long) 60 - seconds ];
        }
    }
    else if(self.waitToPlayTimer==0) {
        
        //allow play it again
        self.shareToPlayOrWaitView.hidden = true;
        self.waitToPlayTimerLabel.hidden = true;
        [self.waitTimer invalidate];
        //rest to 1
        [self saveNumberOfPlays:1];
        
        //start from the last save, since is a replay
        self.currentLevel = [self checkLastSaves];
        
        // Let's start the game!
        [self hideGameOver];
    }
    
    
    
}

//share to facebook and wind 500 stars
- (void)didTapShareToWinWithGesture:(UITapGestureRecognizer *)tapGesture {
    self.shareToWinClicked = true;
    [self sendToFacebook:self message:NSLocalizedString(@"checkout_my_app", @"checkout_my_app")];
}

-(void)setupMusicSettingsTouch {
    
    self.isMusicOn = true;
    
    //update UI
    //self.musicSettingView.image = self.musicOffIcon;
    
    self.musicSettingView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapMusicSettingsWithGesture:)];
    [self.musicSettingView addGestureRecognizer:tapGesture];
}

- (void)didTapMusicSettingsWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    if(self.isMusicOn) {
      //stop it
        [self.backgroundMusic stop];
        self.isMusicOn = false;
        [[[[iToast makeText:NSLocalizedString(@"music_off", @"music_off")]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    else {
        //restart it
        [self.backgroundMusic play];
        self.isMusicOn = true;
        [[[[iToast makeText:NSLocalizedString(@"music_on", @"music_on")]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
    
    //update UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.isMusicOn) {
            self.musicSettingView.image = [UIImage imageNamed:@"musicoff"];
        }
        else {
            self.musicSettingView.image = [UIImage imageNamed:@"musicon"];
        }
        
    });
    
    
    
    
}

//show or hide need help view
-(void) showHideNeedHelpView {
    //NSTimeInterval is a double typedef
        
    
    
        //if we are on game over view, hidde
        if(self.leaderboardIcon.hidden == NO || self.shareToPlayOrWaitView.hidden==NO) {
            self.needHelpImageView.hidden = true;
        }
        else {
            //otherwise show it
            NSTimeInterval dif = [self.scene getPlayerSleepingTime];
            if(dif>20.0) {
                self.needHelpImageView.hidden = !self.needHelpImageView.hidden;
                
            }//less than 20 and showing
            else if(!self.needHelpImageView.hidden) {
                self.needHelpImageView.hidden = true;
            }
        }
    
    if(!self.unlockMoveLevel20View.hidden) {
        self.unlockMoveLevel20View.hidden = true;
    }
    
    
}

- (void)didTapBoosterWithGesture:(UITapGestureRecognizer *)tapGesture {
    

    
    if(self.boosterSpriteName!=nil) {
        
        if([self.boosterSpriteName isEqualToString:@"bomb"]) {
            [[[[iToast makeText:NSLocalizedString(@"bomb_touch_msg", @"bomb_touch_msg")]
               setGravity:iToastGravityBottom] setDuration:1000] show];
        }
        else {
            [[[[iToast makeText:NSLocalizedString(@"jelly_touch_msg", @"jelly_touch_msg")]
               setGravity:iToastGravityBottom] setDuration:1000] show];
        }

        
        [self.scene addBoosterImageNamed:self.boosterSpriteName];
        
    }

}

//send a notification when i used a booster on the scene
-(void)reportBoosterAction:(NSNotification *) notification {
    
    //NSLog(@"received booster notification....");
    
    if(self.boosterSpriteName!=nil && [self.boosterSpriteName isEqualToString:@"bomb"]) {
        //NSLog(@"checking for the bomb....");
        //checking for the bomb
        NSDictionary *userInfo = notification.userInfo;
        PCJelly *touchedJelly = [userInfo objectForKey:@"booster"];
        if(touchedJelly!=nil) {
            //get the set with the chains
            NSSet *setOfChains = [self.scene getNeighbourBombedCookiesChain: touchedJelly];
            [self blastNeighbourJellys: setOfChains];
            
        }
  
        
    }
    else {
        [self handleMatches];
        
    }
    
    self.boosterImage.hidden=true;
    self.boosterSpriteName=nil;
    
    
}

//blast neighbour jellys after explosion
-(void) blastNeighbourJellys: (NSSet *) setOfChains{
    
    if ([setOfChains count] == 0) {
        [self beginNextTurn];
        return;
    }

    //remove them from the level
    [self.level removeCookies:setOfChains];
    
    
    //animate falling ones and fil holes
    
    
    // First, remove any matches...
    [self.scene animateMatchedCookies:setOfChains completion:^{
        
        
        // Add the new scores to the total.
        for (PCChain *chain in setOfChains) {
            self.levelScore += chain.score;
        }
        [self updateLabels];
        
        // ...then shift down any cookies that have a hole below them...
        NSArray *columns = [self.level fillHoles];
        [self.scene animateFallingCookies:columns completion:^{
            
            // ...and finally, add new cookies at the top.
            NSArray *columns = [self.level topUpCookies];
            [self.scene animateNewCookies:columns completion:^{
                
                // Keep repeating this cycle until there are no more matches.
                [self handleMatches];
            }];
        }];
    }];
}

-(void)initHelperGoods {
    

    self.boosterBlue = [UIImage imageNamed: @"blue_candy_anim_02"];
    self.boosterDark = [UIImage imageNamed: @"dark_b_jelly_02"];
    self.boosterRed = [UIImage imageNamed: @"red_candy_anim_02"];
    self.boosterYellow = [UIImage imageNamed: @"yellow_candy_anim_02"];
    self.boosterGreen = [UIImage imageNamed: @"green_candy_anim_02"];
    self.boosterPink = [UIImage imageNamed: @"purple_candy_anim_02"];
    self.boosterBomb = [UIImage imageNamed: @"1_bomb_blue"];
    
    
    self.currentHelperGoodIndex = 0;
    
    [self checkGoodsBalance];
    //TODO CHECK BOMB BOOSTER

}

-(void)checkGoodsBalance {
    
    self.boosterSpriteName = nil;
    UIImage *image = nil;
    
    
    if([StoreInventory getItemBalance:BLUE_JELLY_ITEM_ID]>0) {

        image = self.boosterBlue;
        self.boosterSpriteName = @"blue";
    }
    else if([StoreInventory getItemBalance:DARK_JELLY_ITEM_ID]>0) {
        image = self.boosterDark;
        self.boosterSpriteName = @"dark";
    }
    else if([StoreInventory getItemBalance:RED_JELLY_ITEM_ID]>0) {
        image = self.boosterRed;
        self.boosterSpriteName =@"red";
    }
    else if([StoreInventory getItemBalance:GREEN_JELLY_ITEM_ID]>0) {
        image = self.boosterGreen;
        self.boosterSpriteName =@"green";
    }
    else if([StoreInventory getItemBalance:YELLOW_JELLY_ITEM_ID]>0) {
        image = self.boosterYellow;
        self.boosterSpriteName = @"yellow";
    }
    else if([StoreInventory getItemBalance:PINK_JELLY_ITEM_ID]>0) {
        image = self.boosterPink;
        self.boosterSpriteName =@"pink";
    }
    else if([StoreInventory getItemBalance:SMASH_BOMB_ITEM_ID]>0) {
        image = self.boosterBomb;
        self.boosterSpriteName =@"bomb";
        
    }
    
    //update the UI
    if(image!=nil) {
        dispatch_async(dispatch_get_main_queue(), ^{

            self.boosterImage.image = image;
            self.boosterImage.hidden = false;
            
        });
    }
    else {
        self.boosterImage.hidden = true;
    }
}


//show the store, swipe left
- (IBAction)revealToggleX:(id)sender
{
    //save the "old" values before swipe
    [self checkSettings];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.revealViewController revealToggle:self];
}

//reads the saved market values
-(void) checkSettings {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.numMovesPurchased = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
    self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];

}

-(BOOL) hasMadeAnyPurchases {
    return self.numMovesPurchased > NUM_PURCHASED_MOVES && self.numLevelsPurchased > NUM_PURCHASED_LEVELS;
}

-(NSUInteger) getNumAvailableLevels {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
    return self.numLevelsPurchased;
}


//check if already added the level 20
-(BOOL) checkIfAlreadyAddedExtraMoveBonus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL result = [defaults boolForKey:LEVEL_20_BONUS_KEY];
    
    if(!result)  {
        //have not added the bonus yet, add now
        [defaults setBool:TRUE forKey:LEVEL_20_BONUS_KEY];
    }
    return result;

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)beginGame:(BOOL)addTiles {
    
   NSLog(@"begin game: addTiles %@",addTiles==true?@"yes":@"no");
    
    
  if(self.helperTimer==nil) {
    
      //timer to show/hide the need help
      //TODO this should be a member variable, and we should invalidate at game over
      //and create a new one
      self.helperTimer = [NSTimer scheduledTimerWithTimeInterval:3.0  target:self
                                                        selector:@selector(showHideNeedHelpView)
                                                        userInfo:nil
                                                         repeats:YES];
  }
    
   self.levelScore = 0;
   self.shareAndWinView.hidden = true;
    //force load the next level
    if(self.level==nil) {
       
        self.level = [[PCLevel alloc] initWithFile: [NSString stringWithFormat:@"Level_%lu",(unsigned long)self.currentLevel-1]];
        //configure proper number of moves and target score
        [self configureMovesAndTarget];

        //add the level to the scene
        self.scene.level = self.level;
    }
    
    //to update the number of moves
    [self checkSettings];
    
    //set moves left
    self.movesLeft = self.level.maximumMoves;
    self.bonusView.hidden = true;
    self.coolMoveView.hidden = true;

    NSLog(@"moves left: %lu",(unsigned long)self.movesLeft);
    
    if(addTiles) {
        [self.scene clearTiles];
        [self.scene addTiles];
    }
    //we change the background every 10 levels
    if(self.currentLevel %10 ==0) {
        [self.scene loadBackgroundForLevel:self.currentLevel];
    }
    else if(self.startFromLastSave && self.currentLevel>10) {
        
        NSUInteger div = (unsigned long)self.currentLevel / 10;

        //if 15 / 10 -> 1*10
        //if 36 /10 -->3*10
        //if 91/10 --> 9*10
        [self.scene loadBackgroundForLevel:div*10];
    }
    
  [self updateLabels];
    

  [self.level resetComboMultiplier];
  [self.scene animateBeginGame];
  [self shuffle];

    
}

//configures the proper number of moves and the level score
-(void) configureMovesAndTarget {
    //always increase target in 20 points
    if(self.currentLevel>1) {
        self.level.targetScore = self.level.targetScore + (self.currentLevel * TARGET_INCREASE_BY_LEVEL);
        
        //level 100 will be 1000 + (100*20 = 2000) = 3000

          if(self.currentLevel>9) {
              //reduce moves every 10 levels
              NSUInteger difOverTenLevels = (NSUInteger)self.currentLevel/10;
              self.level.maximumMoves = self.level.maximumMoves-difOverTenLevels;
              //TODO CHECK AFTER LEVEL 101
              //min allowed is 5 moves
              if(self.level.maximumMoves < MIN_NUM_MOVES_LEVEL) {
                  self.level.maximumMoves = MIN_NUM_MOVES_LEVEL;
              }
          }
        
    }
}

- (void)shuffle {
  // Delete the old cookie sprites, but not the tiles.
  [self.scene removeAllCookieSprites];

  // Fill up the level with new cookies, and create sprites for them.
  NSSet *newCookies = [self.level shuffle];
  [self.scene addSpritesForCookies:newCookies];
}

- (void)handleMatches {
  // This is the main loop that removes any matching cookies and fills up the
  // holes with new cookies. While this happens, the user cannot interact with
  // the app.

  // Detect if there are any matches left.
  NSSet *chains = [self.level removeMatches];

  // If there are no more matches, then the player gets to move again.
  if ([chains count] == 0) {
    [self beginNextTurn];
    return;
  }

  // First, remove any matches...
  [self.scene animateMatchedCookies:chains completion:^{

    NSUInteger scoreInChains = 0;
    UIImage *image = nil;
      
    // Add the new scores to the total.
    for (PCChain *chain in chains) {
      self.levelScore += chain.score;
        scoreInChains+=chain.score;
    }
    [self updateLabels];
      
      
      //only show if is hidden
      if(self.coolMoveView.hidden) {
          
          //show a congrats message, according the number of points earned
          if(scoreInChains>=100 && scoreInChains<=140) {
              //row of 5 jellys
              
              image = [UIImage imageNamed:@"supercool"];
              [self.scene playSuperCoolSound];
          }
          
          else if(scoreInChains > 140 && scoreInChains <=180) {
              
              image = [UIImage imageNamed:@"awsomemove"];
              [self.scene playAwesomeMoveSound];
          }
          else if(scoreInChains >180) {
              
              image = [UIImage imageNamed:@"jellymaniac"];
              [self.scene playJellyManiacSound];
          }
          
          if(image!=nil) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  
                  self.coolMoveView.image = image;
                  self.coolMoveView.hidden = false;
                  
                  [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                                 selector:@selector(hideCoolView)
                                                 userInfo:nil
                                                  repeats:NO];
                  
              });
          }
          
      }
      
      

    // ...then shift down any cookies that have a hole below them...
    NSArray *columns = [self.level fillHoles];
    [self.scene animateFallingCookies:columns completion:^{

      // ...and finally, add new cookies at the top.
      NSArray *columns = [self.level topUpCookies];
      [self.scene animateNewCookies:columns completion:^{

        // Keep repeating this cycle until there are no more matches.
        [self handleMatches];
      }];
    }];
  }];
}

//hide the message
-(void)hideCoolView {
    self.coolMoveView.hidden = true;
}

- (void)beginNextTurn {
  [self.level resetComboMultiplier];
  [self.level detectPossibleSwaps];
  self.view.userInteractionEnabled = YES;
  [self decrementMoves];
}

- (void)updateLabels {
  self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
  self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
  self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.levelScore];
  self.jellyStarsLabel.text = [NSString stringWithFormat:@"%d", [StoreInventory getItemBalance:JELLY_CURRENCY_ITEM_ID]];
  self.levelLabel.text = [NSString stringWithFormat: @"%@: %lu / %lu", NSLocalizedString(@"level", @"level"), (long)self.currentLevel, (unsigned long)self.numLevelsPurchased];
}

- (void)decrementMoves{
  self.movesLeft--;
  [self updateLabels];

  if (self.levelScore >= self.level.targetScore) {
      
      //just passed the level
	  self.gameOverPanel.image = [UIImage imageNamed:@"LevelComplete"];
      //sum the level score
      self.overallScore+=self.levelScore;
      
      [self showGameOver: true bestScore:0];
      
  } else if (self.movesLeft == 0) {
      
      //sum the level score, to the previous (all levels before this, on same play)
      self.overallScore+=self.levelScore;
  	  self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
      
      
      NSUInteger currentBestScore;
      //********************* CHECK SCORES *****************************/
      //check previous score, add first if not exists previous
      if (![[NSUserDefaults standardUserDefaults] valueForKey:@"jelly_score"]) {
          
          [[NSUserDefaults standardUserDefaults] setInteger:self.overallScore forKey:@"jelly_score"];
          //submit the score if first time
          currentBestScore = self.overallScore;
          [self submitScore];
      }
      else {
          
          //get the best saved score
          currentBestScore = [[NSUserDefaults standardUserDefaults]  integerForKey:@"jelly_score" ];
          
          //if current is new best, override it
          if(self.overallScore > currentBestScore) {
              //set is as new best
              [[NSUserDefaults standardUserDefaults] setInteger:self.overallScore forKey:@"jelly_score"];
              //congrat
              [[[[iToast makeText:NSLocalizedString(@"new_best_score", @"new_best_score")]
                 setGravity:iToastGravityBottom] setDuration:1000] show];
              
              //and submit the new best (will open leaderboard too)
              [self submitScore];
              
              currentBestScore = self.overallScore;
              
          }
      }
      
      
      
      //**************** SAVE LEVEL ************************************/
      if(self.currentLevel>1) {
          [self saveGame:self.currentLevel];
      }
      
      //********************* CHECK SCORES *****************************/
      
      
      [self showGameOver: false bestScore:currentBestScore];
  }
  else if(self.movesLeft==1) {
      //"no_more_moves" = "Jogadas insuficientes";
      //"running_out_moves"="Comprar jogadas extra para terminar o nível?";
      //"running_out_levels"="Comprar níveis extra para continuar a jogar?";
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_moves", @"no_more_moves")
                                                      message:NSLocalizedString(@"running_out_moves", @"running_out_moves")
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      [self revealToggleX:self];
  }
}

- (void)showGameOver: (BOOL)autoAdvance bestScore:(NSUInteger) bestSavedScore  {
  [self.scene animateGameOver];

  [self.gameOverScoreLabel setText:[NSString stringWithFormat: @"%lu",(unsigned long)self.overallScore ]];
  [self.gameOverBestScoreLabel setText: [NSString stringWithFormat: @"%lu",(unsigned long)bestSavedScore ]];
    
  self.gameOverPanel.hidden = NO;
  
    //total scores, for all levesl played
    //just passed level
    if(autoAdvance) {
        
       //hide/show views
       self.leaderboardIcon.hidden = YES;
       self.gameOverBestScoreLabel.hidden = YES;
       self.gameOverScoreLabel.hidden = YES;
       self.needHelpImageView.hidden = YES;
       self.bonusView.hidden = false;
       self.replayButton.hidden = YES;
        
       self.musicSettingView.hidden=true;
       self.boosterImage.hidden=true;
        
       self.bonusLabel.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"you_won", @"you_won"), LEVEL_COMPLETION_BONUS_AMOUNT];
        
        if(!self.coolMoveView.hidden) {
            self.coolMoveView.hidden = true;
        }
        
        [self.scene playPassLevelSound];
        
       
        
        //anytime i pass a level i give 40 jelly stars to the user
       [StoreInventory giveAmount:LEVEL_COMPLETION_BONUS_AMOUNT ofItem: JELLY_CURRENCY_ITEM_ID];
        self.currentLevel+=1;
        
        //level 20
        if(self.currentLevel==EXTRA_MOVE_BONUS_LEVEL) {
            if(![self checkIfAlreadyAddedExtraMoveBonus]) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSUInteger numMovesPurchased = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
                //add 1
                numMovesPurchased+=1;
                //update the settings
                [defaults setInteger:numMovesPurchased forKey:NUM_PURCHASED_MOVES_KEY];
                
                [self increaseNumberOfMovesBy:1];

                //add the extra move now
                [self updateLabels];
            }
        }
        

        if(self.currentLevel==50 && self.isGameCenterAvailable) {
            //report achievement 50
            NSLog(@"report achievement, reached level 50");
            [self submitAchievement:JELLY_MANIACS_REACH_LEVEL_50_ACHIEVEMENT];
        }
        else if(self.currentLevel==100 && self.isGameCenterAvailable) {
            //report achievement 100
            NSLog(@"report achievement, reached level 100");
            [self submitAchievement:JELLY_MANIACS_REACH_LEVEL_50_ACHIEVEMENT];
        }
        
        //if on last available level warn user to buy more
        if(self.currentLevel == self.numLevelsPurchased-1 && self.numLevelsPurchased < NUM_AVAILABLE_LEVELS) {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"last_level_buy_warning", @"last_level_buy_warning")
                                                            message:NSLocalizedString(@"running_out_levels", @"running_out_levels")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [self revealToggleX:self];
        }
        
        //do i have more levels to play???
        else if(self.currentLevel>self.numLevelsPurchased ) {
            
            //alert to buy more levels
            self.currentLevel = 1;
            //next is the first again
            
            //i can still buy more
            if(self.numLevelsPurchased < NUM_AVAILABLE_LEVELS) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                message:NSLocalizedString(@"buy_levels_generic", @"buy_levels_generic")
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
                [self revealToggleX:self];
            }
            else {
                
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                    message:NSLocalizedString(@"no_more_levels_improve", @"no_more_levels_improve")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                
            }
            
            
        }
        else {
            //show intertitial every 5 levels
            if(![self hasMadeAnyPurchases] && self.currentLevel%5==0 && [ALInterstitialAd isReadyForDisplay]) {
                //show interstitial
                [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
            }
            
            //time to switch musics
            if(self.currentLevel%10==0) {
                NSURL *url = nil;
                //if playing gonna start v2
                if([self.backgroundMusic.url.relativeString rangeOfString:@"Gonna"].location != NSNotFound) {
                    //play mining
                    url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
                }
                else {
                    //otherwise play gonna start
                    url = [[NSBundle mainBundle] URLForResource:@"Gonna Start v2" withExtension:@"mp3"];
                }
                //stop the music and allocate with new one
                [self.backgroundMusic stop];
                self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                self.backgroundMusic.numberOfLoops = -1;
                if(self.isMusicOn) {
                  [self.backgroundMusic play];
                }
                
            }
                
            
            
            
        }
        
    }
    else {//no autoadvance
        
        
        if(self.helperTimer!=nil) {
            [self.helperTimer invalidate];
            self.helperTimer = nil;
        }
        
        //really is game over
        [self saveNumberOfPlays : [self getNumberOfPlays]+1];
        
        //only show if facebook available
        if(self.isFacebookAvailable && [self getNumberOfFacebookShares]<MAX_FACEBOOK_SHARES) {
            self.shareAndWinView.hidden = false;
        }
        
        [self.scene playGameOverSound];
        
        
        //hide/show views
        self.replayButton.hidden = NO;
        self.bonusView.hidden = true;
        self.leaderboardIcon.hidden = NO;
        self.gameOverBestScoreLabel.hidden = NO;
        self.gameOverScoreLabel.hidden = NO;
        self.needHelpImageView.hidden = YES;
        
        if(self.isFacebookAvailable) {
            self.facebookIcon.hidden = NO;
        }
        if(self.isTwitterAvailable) {
            self.twitterIcon.hidden = NO;
        }
        
        //the replay touch can change this
        self.currentLevel = 1;
        
        
    }
    

  self.level = nil;
  self.scene.userInteractionEnabled = NO;
  self.shuffleButton.hidden = YES;
  self.sideMenu.hidden = YES;
    
    
  //self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
  //  [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    //auto advance to the next level, after 2 seconds
    if(autoAdvance) {
        [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                       selector:@selector(hideGameOver)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    
}

//get the number of times the game was played
-(NSUInteger) getNumberOfPlays {
    //key always exists, since is checked on delegate
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger numOfPlays = [defaults integerForKey:NUM_JELLY_PLAYS_KEY];
    return numOfPlays;
    
}

//get the number of times shared to facebook
-(NSUInteger) getNumberOfFacebookShares {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger numShares = [defaults integerForKey:SHARED_FACEBOOK_KEY];
    return numShares;
}

//increase the number of facebook shares
-(void) increaseNumberOfFacebookShares {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger numShares = [defaults integerForKey:SHARED_FACEBOOK_KEY];
    numShares+=1;
    [defaults setInteger:numShares forKey:SHARED_FACEBOOK_KEY];
}

//set the number of times the game was played
-(void) saveNumberOfPlays:(NSUInteger) num {
    //key always exists, since is checked on delegate
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:num forKey:NUM_JELLY_PLAYS_KEY];
    
}

//hide the game over menu, start new game
- (void)hideGameOver {
  
 //[self.view removeGestureRecognizer:self.tapGestureRecognizer];
  self.tapGestureRecognizer = nil;
  self.replayButton.userInteractionEnabled=YES;
    
  self.gameOverPanel.hidden = YES;
  self.scene.userInteractionEnabled = YES;
  self.replayButton.hidden = YES;
  self.shareToPlayOrWaitView.hidden = YES;
  self.waitToPlayTimerLabel.hidden = YES;

  [self beginGame:true];

  self.shuffleButton.hidden = NO;
  self.sideMenu.hidden = NO;
    
  self.leaderboardIcon.hidden = true;
  self.gameOverBestScoreLabel.hidden = true;
  self.gameOverScoreLabel.hidden = true;
  self.facebookIcon.hidden = YES;
  self.twitterIcon.hidden = YES;
  
//this is needed to update the booster image view
  self.musicSettingView.hidden=false;
  [self checkGoodsBalance];
    
    
    
}

- (IBAction)shuffleButtonPressed:(id)sender {
  [self shuffle];

  // Pressing the shuffle button costs a move.
  [self decrementMoves];
}

-(void) setupReplayButton {
    
    _replayButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(didTapReplayWithGesture:)];
    [_replayButton addGestureRecognizer:tapGesture];
}

//checks if already exists the key
-(BOOL) alreadySharedToTwitter {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:SHARED_TWITTER_KEY];
    //will return false if not exists
 
    
}
- (void)didTapReplayWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    //and if the key doesn´t exist yet
    
    self.overallScore = 0;
    
    if(self.isTwitterAvailable
       && [self getNumberOfPlays]>MAX_PLAYS_WITHOUT_SHARE
       && ![self alreadySharedToTwitter]) {
        
        [self configureTwitterShareWaitBeforePlay];
        
        
    }
    else {
        self.waitToPlayTimer = 0;
        self.shareToPlayOrWaitView.hidden = true;
        self.waitToPlayTimerLabel.hidden = true;
        //start from the last save, since is a replay
        self.currentLevel = [self checkLastSaves];
        
    }
    
    //if the timer is zero
    if(self.waitToPlayTimer==0) {
        [self hideGameOver];
    }
    
    
}

//configure twiiter share to be able to play
-(void) configureTwitterShareWaitBeforePlay {
    
        
        self.replayButton.userInteractionEnabled=NO;
        
        //show the labels
        self.waitToPlayTimerLabel.hidden =false;
        self.shareToPlayOrWaitView.hidden =false;
        //enable interaction
        [self setupShareToPlayOrWaitTouch];
        //start the timer
        [self setWaitToPlayOrShareTimer];
        
        
        self.leaderboardIcon.hidden = true;
        self.gameOverBestScoreLabel.hidden = true;
        self.gameOverScoreLabel.hidden = true;
        self.facebookIcon.hidden = YES;
        self.twitterIcon.hidden = YES;
        self.needHelpImageView.hidden = true;
        
    
}

#pragma social networks
//setup share facebook/twitter
- (void)setupSocialShareTouch {
    
    if(_isFacebookAvailable) {
        _facebookIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self action:@selector(didTapFacebookWithGesture:)];
        [_facebookIcon addGestureRecognizer:tapGesture];
        
        //self.facebookIcon.alpha = 0;
        //self.facebookIcon.transform = CGAffineTransformMakeScale(.9, .9);
        
    }
   
    [_facebookIcon setHidden:true];
    
    
    
    
    if(_isTwitterAvailable) {
        _twitterIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self action:@selector(didTapTwitterWithGesture:)];
        [_twitterIcon addGestureRecognizer:tapGesture];
        
        //self.twitterIcon.alpha = 0;
        //self.twitterIcon.transform = CGAffineTransformMakeScale(.9, .9);
        
    }

    [_twitterIcon setHidden:true];
    
    
    
}
//share the score to facebook
- (void)didTapFacebookWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    
    [self sendToFacebook: self message: [NSString stringWithFormat: NSLocalizedString(@"checkout_my_score_%lu", @"checkout_my_score"),[self getBestScore]]];
}
//share the score to twitter
- (void)didTapTwitterWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self sendToTwitter: self message: [NSString stringWithFormat: NSLocalizedString(@"checkout_my_score_%lu", @"checkout_my_score"),[self getBestScore]]];
}

//get the best score saved on settings
-(NSUInteger) getBestScore {
    NSUInteger currentBestScore = [[NSUserDefaults standardUserDefaults]  integerForKey:@"jelly_score" ];
    return currentBestScore;
}

//will send the message to facebook
- (IBAction)sendToFacebook:(id)sender message:(NSString* )theMessage {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText: theMessage];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"blue_candy_anim_02"]];
        
        [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/jelly-maniacs/id904072768?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *msg;
            
            
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"facebook_post_canceled", @"facebook_post_canceled");
                    self.shareToWinClicked = false;
                    break;
                case SLComposeViewControllerResultDone:
                    msg = NSLocalizedString(@"facebook_post_ok", @"facebook_post_ok");
                    
                    if(self.shareToWinClicked) {
                        
                        self.shareToWinClicked = false;
                        [StoreInventory giveAmount:500 ofItem:JELLY_CURRENCY_ITEM_ID];
                        [self updateLabels];
                        //increase the number of facebook shares by 1
                        [self increaseNumberOfFacebookShares];
                        
                    }

                    break;
                    
                default:
                    break;
            }
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
            
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

//send the message also to twitter
- (IBAction)sendToTwitter:(id)sender message:(NSString* )theMessage {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText: theMessage];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"blue_candy_anim_02"]];
        
        [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/jelly-maniacs/id904072768?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            
            NSString *msg;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"twitter_post_canceled", @"twitter_post_canceled");
                    self.shareToWinClicked = false;
                    break;
                    
                    
                case SLComposeViewControllerResultDone:
                    
                    
                    //this means we were locked on the share to play
                    if(self.shareToPlayOrWaitView.hidden==NO && self.shareToWinClicked) {
                        // Let's start the game!
                        
                        //reset the timer
                        [self.waitTimer invalidate];
                        //reset counter
                        [self saveNumberOfPlays:1];
                        
                        //reset time
                        self.waitToPlayTimer = 0;
                        
                        //start from the last save, since is a replay
                        self.currentLevel = [self checkLastSaves];
                        
                        //save the key to avoid ask for share again
                        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SHARED_TWITTER_KEY];
                        
                        self.shareToWinClicked = false;
                        self.replayButton.userInteractionEnabled=YES;
                        
                        msg = NSLocalizedString(@"thank_you_for_sharing", @"thank_you_for_sharing");
                        
                        [self hideGameOver];
                    }
                    else {
                        //normal share of score
                        msg = NSLocalizedString(@"twitter_post_ok", @"twitter_post_ok");
                    }
                    break;
                    
                default:
                    break;
            }
            
            
            //we need to dismiss manually for twitter
            //[mySLComposerSheet dismissViewControllerAnimated:YES completion:nil];
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}



//and add/remove them accordingly
-(void) checkSocialServicesAvailability {
    
    //facebook
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        _isFacebookAvailable=YES;
        
    }
    else {
        _isFacebookAvailable = NO;
    }
    //twitter
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        _isTwitterAvailable=YES;
    }
    else {
        _isTwitterAvailable = NO;
    }
    
    if(_isFacebookAvailable || _isTwitterAvailable) {
        [self setupSocialShareTouch];
    }
 
}




#pragma SWRevealControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    ;
}

// The following delegate methods will be called before and after the front view moves to a position
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
 
    //get back to game controller, disable the reveal viewcontroller gesture
    if(position==FrontViewPositionLeft) {
        [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
        //check if there is sprites to add
        [self checkGoodsBalance];
        
    }
    
    // Front controller is removed from view. Animated transitioning from this state will cause the same
    // effect than animating from FrontViewPositionLeftSideMost. Use this instead of FrontViewPositionLeftSideMost when
    // you want to remove the front view controller view from the view hierarchy.
    //FrontViewPositionLeftSideMostRemoved,
    
    // Left most position, front view is presented left-offseted by rightViewRevealWidth+rigthViewRevealOverdraw
    //FrontViewPositionLeftSideMost,
    
    // Left position, front view is presented left-offseted by rightViewRevealWidth
    //FrontViewPositionLeftSide,
    
    // Center position, rear view is hidden behind front controller
	//FrontViewPositionLeft,
    
    // Right possition, front view is presented right-offseted by rearViewRevealWidth
	//FrontViewPositionRight,
    
    // Right most possition, front view is presented right-offseted by rearViewRevealWidth+rearViewRevealOverdraw
	//FrontViewPositionRightMost,
    
    // Front controller is removed from view. Animated transitioning from this state will cause the same
    // effect than animating from FrontViewPositionRightMost. Use this instead of FrontViewPositionRightMost when
    // you intent to remove the front controller view from the view hierarchy.
    //FrontViewPositionRightMostRemoved,
}
//non market
-(void)notifyBoosterItemPurchase:(NSString*)itemId {
    
    [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                   selector:@selector(showHowToUseBooster)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) showHowToUseBooster {
    [[[[iToast makeText:NSLocalizedString(@"touch_booster_howto", @"touch_booster_howto")]
       setGravity:iToastGravityCenter] setDuration:1000] show];
}


//market
-(void)notifyMarketPurchase:(NSString*)itemId {
    
    NSLog(@"notify purchase of %@",itemId);
    //need to update the number of moves
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUInteger newNumMovesPurchased = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
    
    
    //for this i need to check if we have more now, than last saved value
    if(newNumMovesPurchased > self.numMovesPurchased) {
        //do i have more now?? Add the difference
        NSUInteger dif = newNumMovesPurchased - self.numMovesPurchased;
        //NSLog(@"number of moves willMoveToPosition: %lu",(unsigned long)self.level.maximumMoves);
        
        [self increaseNumberOfMovesBy:dif];
        
    }
    //this i can just update directly
    self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
    self.numMovesPurchased = newNumMovesPurchased;
    
    [self updateLabels];
}

-(void) increaseNumberOfMovesBy:(NSUInteger) dif {
    
    self.level.maximumMoves = self.level.maximumMoves + dif;
    self.scene.level.maximumMoves = self.scene.level.maximumMoves + dif;
    self.movesLeft = self.movesLeft + dif;
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma game_center
//setup game center
-(void) setupGameCenter {
    
    self.currentLeaderBoard = JELLY_MANIACS_LEADERBOARD;
    
    if ([GameCenterManager isGameCenterAvailable]) {
        
        
        self.isGameCenterAvailable = true;
        self.gameCenterManager = [[GameCenterManager alloc] init] ;
        [self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
        
        //setup touch on leaderboard icon
        self.leaderboardIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self action:@selector(didTapLeaderBoardWithGesture:)];
        [self.leaderboardIcon addGestureRecognizer:tapGesture];
        
        
    } else {
        
        // The current device does not support Game Center.
        self.isGameCenterAvailable = false;
        
    }
}

//show the leaderboard
- (void)didTapLeaderBoardWithGesture:(UITapGestureRecognizer *)tapGesture {
    [self showLeaderboard];
}

//TODO this is deprecated
-(void)showLeaderboard {
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != NULL)
    {
        leaderboardController.category = self.currentLeaderBoard;
        leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
        leaderboardController.leaderboardDelegate = self;
        [self presentViewController:leaderboardController animated: YES completion:nil];
    }
    else {
        [[[[iToast makeText:@"No Leaderboard"]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
}
//TODO this is deprecated
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//submit the score
- (void) submitScore {
    
    [self.gameCenterManager reportScore: self.overallScore forCategory: self.currentLeaderBoard];
    
}
//callback for score report
- (void) scoreReported: (NSError*) error {
    if(!error) {
        [self showLeaderboard];
    }
    else {
        [[[[iToast makeText:error.description]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
}

//submit the score
- (void) submitAchievement:(NSString *)identifier {
    
    [self.gameCenterManager submitAchievement:identifier percentComplete:100.0];
    
}

//calback for submit achievement
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error {
    if(!error) {
        [self showLeaderboard];
    }
    else {
        [[[[iToast makeText:error.description]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
}


@end
