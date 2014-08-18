//
//  ViewController.m
//  CookieCrunch
//
//  Created by Matthijs on 25-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
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
    
   //now do the proper check
   [self checkSocialServicesAvailability];
    
   [self setupShareToWinTouch];
    self.shareToWinClicked = false;
    
    
    self.leaderboardIcon.hidden = true;
    self.replayButton.hidden = true;
    self.bonusView.hidden = true;
    self.coolMoveView.hidden = true;
    self.needHelpImageView.hidden = true;
    
    
    
 [self.navigationController setNavigationBarHidden:YES animated:YES];
  // Configure the view.
  SKView *skView = (SKView *)self.view;
  skView.multipleTouchEnabled = NO;
  
  // Create and configure the scene.
  self.scene = [MyScene sceneWithSize:skView.bounds.size];
  self.scene.scaleMode = SKSceneScaleModeAspectFill;

    
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
    
    
  // Load the level.

  self.currentLevel = 1;
  self.overallScore = 0;
  self.level = [[PCLevel alloc] initWithFile: [NSString stringWithFormat:@"Level_%lu",(unsigned long)self.currentLevel-1]];
  self.scene.level = self.level;


  [self.scene addTiles];
    
  self.shareAndWinView.hidden = true;

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

  // Hide the game over panel from the screen.
  self.gameOverPanel.hidden = YES;
  [self.gameOverBestScoreLabel setHidden:true];
  [self.gameOverScoreLabel setHidden:true];
  
  // Present the scene.
  [skView presentScene:self.scene];

  // Load and start background music.
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"Gonna Start v2" withExtension:@"mp3"];//Mining by Moonlight
  self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.backgroundMusic.numberOfLoops = -1;
  [self.backgroundMusic play];
    
    
  [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                   selector:@selector(showHideNeedHelpView)
                                   userInfo:nil
                                    repeats:YES];

 
  // Let's start the game!
    [self beginGame: false];
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

- (void)didTapShareToWinWithGesture:(UITapGestureRecognizer *)tapGesture {
    self.shareToWinClicked = true;
    [self sendToFacebook:self];
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
        if(self.leaderboardIcon.hidden == NO) {
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
    NSLog(@"moves purchased %d",self.numMovesPurchased);
    self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
    NSLog(@"levels purchased %d",self.numLevelsPurchased);
}

-(NSUInteger) getNumAvailableLevels {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
    return self.numLevelsPurchased;
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
  
   self.levelScore = 0;
   self.shareAndWinView.hidden = true;
    //force load the next level
    if(self.level==nil) {
        
        self.level = [[PCLevel alloc] initWithFile: [NSString stringWithFormat:@"Level_%lu",(unsigned long)self.currentLevel-1]];
        //always increase target in 10 points
        if(self.currentLevel>1) {
            self.level.targetScore = self.level.targetScore + (self.currentLevel * TARGET_INCREASE_BY_LEVEL); //level 100 will be 1000 + (100*10) = 2000
            if(self.currentLevel>9) {
                //reduce moves every 10 levels
                NSUInteger restOverTenLevels = (NSUInteger)self.currentLevel%10;
                self.level.maximumMoves = self.level.maximumMoves-restOverTenLevels;
            }

        }
        

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
        //we change the background every 10 levels
        if(self.currentLevel %10 ==0) {
            [self.scene loadBackgroundForLevel:self.currentLevel];
        }
        
    }
    
  [self updateLabels];
    

  [self.level resetComboMultiplier];
  [self.scene animateBeginGame];
  [self shuffle];
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
  self.levelLabel.text = [NSString stringWithFormat: @"%@: %lu / %lu", NSLocalizedString(@"level", @"level"), (long)self.currentLevel, [self getNumAvailableLevels]];
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
      
      //sum the level score
      self.overallScore+=self.levelScore;
      
  	  self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
      
      
      //********************* CHECK SCORES *****************************/
      //check previous score, add first if not exists previous
      if (![[NSUserDefaults standardUserDefaults] valueForKey:@"jelly_score"]) {
          
          [[NSUserDefaults standardUserDefaults] setInteger:self.overallScore forKey:@"jelly_score"];
          //submit the score if first time
          [self submitScore];
      }
      
      //get the best saved score
      NSUInteger currentBestScore = [[NSUserDefaults standardUserDefaults]  integerForKey:@"jelly_score" ];
      
      //if current is new best, override it
      if(self.overallScore > currentBestScore) {
          //set is as best
         [[NSUserDefaults standardUserDefaults] setInteger:self.overallScore forKey:@"jelly_score"];
         //submit the new best
         [self submitScore];
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

  self.gameOverPanel.hidden = NO;
  
    //total scores, for all levesl played
    //just passed level
    if(autoAdvance) {
        
       self.leaderboardIcon.hidden = YES;
       self.gameOverBestScoreLabel.hidden = YES;
       self.gameOverScoreLabel.hidden = YES;
        //really is game over
       self.replayButton.hidden = YES;
        
       self.bonusLabel.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"you_won", @"you_won"), LEVEL_COMPLETION_BONUS_AMOUNT];
        
        if(!self.coolMoveView.hidden) {
            self.coolMoveView.hidden = true;
        }
        
        [self.scene playPassLevelSound];
        
       self.bonusView.hidden = false;
        
        //anytime i pass a level i give 40 jelly stars to the user
       [StoreInventory giveAmount:LEVEL_COMPLETION_BONUS_AMOUNT ofItem: JELLY_CURRENCY_ITEM_ID];
        self.currentLevel+=1;
        
        
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
            //"no_more_moves" = "Jogadas insuficientes";
            //"running_out_moves"="Comprar jogadas extra para terminar o nível?";
            //"running_out_levels"="Comprar níveis extra para continuar a jogar?";
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
                                                                message:NSLocalizedString(@"buy_10_levels", @"buy_10_levels")
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
            if(self.currentLevel%5==0 && [ALInterstitialAd isReadyForDisplay]) {
                //show interstitial
                [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
            }
            
            //time to swicth musics
            if(self.currentLevel%10==0) {
                NSURL *url = nil;
                if([self.backgroundMusic.url.relativeString rangeOfString:@"Gonna"].location != NSNotFound) {
                    url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
                }
                else {
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
        //really is game over
        self.replayButton.hidden = NO;
        
        //only show if facebook available
        if(self.isFacebookAvailable) {
            self.shareAndWinView.hidden = false;
        }
        
        self.bonusView.hidden = true;
        
        [self.gameOverScoreLabel setText:[NSString stringWithFormat: @"%lu",(unsigned long)self.overallScore ]];
        [self.gameOverBestScoreLabel setText: [NSString stringWithFormat: @"%lu",(unsigned long)bestSavedScore ]];
        
        self.leaderboardIcon.hidden = NO;
        self.gameOverBestScoreLabel.hidden = NO;
        self.gameOverScoreLabel.hidden = NO;
        
        if(self.isFacebookAvailable) {
            self.facebookIcon.hidden = NO;
        }
        if(self.isTwitterAvailable) {
            self.twitterIcon.hidden = NO;
        }
        self.currentLevel = 1;
        
        
    }
    

  self.level = nil;
  self.scene.userInteractionEnabled = NO;

 

  self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
  [self.view addGestureRecognizer:self.tapGestureRecognizer];
  self.shuffleButton.hidden = YES;
  self.sideMenu.hidden = YES;
    
    //auto advance to the next level, after 2 seconds
    if(autoAdvance) {
        [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                       selector:@selector(hideGameOver)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    
}

//hide the game over menu, start new game
- (void)hideGameOver {
  [self.view removeGestureRecognizer:self.tapGestureRecognizer];
  self.tapGestureRecognizer = nil;

  self.gameOverPanel.hidden = YES;
  self.scene.userInteractionEnabled = YES;
  self.replayButton.hidden = YES;

  [self beginGame:true];

  self.shuffleButton.hidden = NO;
  self.sideMenu.hidden = NO;
    
  self.leaderboardIcon.hidden = true;
  self.gameOverBestScoreLabel.hidden = true;
  self.gameOverScoreLabel.hidden = true;
  self.facebookIcon.hidden = YES;
  self.twitterIcon.hidden = YES;
    
    
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

- (void)didTapReplayWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self beginGame:YES];
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

- (void)didTapFacebookWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self sendToFacebook:nil];
}

- (void)didTapTwitterWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self sendToTwitter:nil];
}


//will send the message to facebook
- (IBAction)sendToFacebook:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText: [NSString stringWithFormat: @"Check my Jelly Maniacs score %lu",(unsigned long)self.levelScore] ];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"blue_candy_anim_02"]];
        
        //[mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/flapi-the-bird-fish/id837165900?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *msg;
            
            self.shareToWinClicked = false;
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"facebook_post_canceled", @"facebook_post_canceled");
                    
                    break;
                case SLComposeViewControllerResultDone:
                    msg = NSLocalizedString(@"facebook_post_ok", @"facebook_post_ok");
                    
                    [StoreInventory giveAmount:500 ofItem:JELLY_CURRENCY_ITEM_ID];
                    [self updateLabels];
                    
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
- (IBAction)sendToTwitter:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText: [NSString stringWithFormat: @"Check my Jelly Maniacs score %lu",(unsigned long)self.levelScore] ];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"blue_candy_anim_02"]];
        
        //[mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/flapi-the-bird-fish/id837165900?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            
            NSString *msg;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = NSLocalizedString(@"twitter_post_canceled", @"twitter_post_canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    msg = NSLocalizedString(@"twitter_post_ok", @"twitter_post_ok");
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
        
        
        //need to update the number of moves
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSUInteger newNumMovesPurchased = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
        
        //this i can just update directly
        self.numLevelsPurchased = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
        
        //for this i need to check if we have more now, than last saved value
        if(newNumMovesPurchased > self.numMovesPurchased) {
            //do i have more now?? Add the difference
            NSUInteger dif = newNumMovesPurchased - self.numMovesPurchased;
            //NSLog(@"number of moves willMoveToPosition: %lu",(unsigned long)self.level.maximumMoves);
            self.level.maximumMoves = self.level.maximumMoves + dif;
            
            self.scene.level.maximumMoves = self.scene.level.maximumMoves + dif;
            self.movesLeft = self.movesLeft + dif;
            
        }
        [self updateLabels];
        
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
