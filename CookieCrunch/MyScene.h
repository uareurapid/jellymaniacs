
#import <SpriteKit/SpriteKit.h>

@class PCLevel;
@class PCSwap;
@class PCJelly;

@interface MyScene : SKScene

@property (strong, nonatomic) PCLevel *level;
@property (strong, nonatomic) NSMutableArray *cookies;

// The scene handles touches. If it recognizes that the user makes a swipe,
// it will call this swipe handler. This is how it communicates back to the
// ViewController that a swap needs to take place. You can also use a delegate
// for this.
@property (copy, nonatomic) void (^swipeHandler)(PCSwap *swap);

- (void)addSpritesForCookies:(NSSet *)cookies;
- (void)addTiles;
-(void)clearTiles;
- (void)removeAllCookieSprites;

- (void)animateSwap:(PCSwap *)swap completion:(dispatch_block_t)completion;
- (void)animateInvalidSwap:(PCSwap *)swap completion:(dispatch_block_t)completion;
- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion;
- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion;
- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

//my animation
- (void)animateAllCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

- (void)animateGameOver;
- (void)animateBeginGame;

- (void)loadBackgroundForLevel:(NSUInteger) levelNumber;

- (void)addBoosterImageNamed:(NSString *) imageName;
-(NSSet *) getNeighbourBombedCookiesChain: (PCJelly *) blastedJelly;

- (void)playSuperCoolSound;
- (void)playAwesomeMoveSound;
- (void)playJellyManiacSound;
- (void)playPassLevelSound;
- (void)playGameOverSound;
- (void)playRewardsSound;

- (NSTimeInterval)getPlayerSleepingTime;
- (void)resetSleepingTimer;

@end
