//  Created by Paulo Cristo on 23/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "MyScene.h"
#import "PCJelly.h"
#import "PCLevel.h"
#import "PCSwap.h"
#import "iToast.h"
#import "JellyStoreAssets.h"
#import "StoreInventory.h"
#import "ParticleEmitterNode.h"

// static const
CGFloat TileWidth = 32.0;//was 32
CGFloat TileHeight = 36.0;
CGFloat myScale = 1.0;

@interface MyScene ()

@property (strong, nonatomic) SKNode *gameLayer;
@property (strong, nonatomic) SKNode *cookiesLayer;
@property (strong, nonatomic) SKNode *tilesLayer;

// The column and row numbers of the cookie that the player first touched
// when he started his swipe movement.
@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;

// Sprite that is drawn on top of the cookie that the player is trying to swap.
@property (strong, nonatomic) SKSpriteNode *selectionSprite;

@property (strong, nonatomic) SKAction *explosionSound;
@property (strong, nonatomic) SKAction *swapSound;
@property (strong, nonatomic) SKAction *invalidSwapSound;
@property (strong, nonatomic) SKAction *matchSound;
@property (strong, nonatomic) SKAction *fallingCookieSound;
@property (strong, nonatomic) SKAction *addCookieSound;

@property (strong, nonatomic) SKAction *superCoolSound;
@property (strong, nonatomic) SKAction *awesomeMoveSound;
@property (strong, nonatomic) SKAction *jellyManiacSound;
@property (strong, nonatomic) SKAction * passLevelSound;
@property (strong, nonatomic) SKAction * gameOverSound;

@property (strong, nonatomic) SKAction * rewardsSound;

@property (strong, nonatomic) SKCropNode *cropLayer;
@property (strong, nonatomic) SKNode *maskLayer;


@property BOOL touchedBooster;
@property (strong, nonatomic) PCJelly *booster;

@property NSTimeInterval lastUpdateTime;
@property NSTimeInterval lastMoveTime;


@end

@implementation MyScene

- (id)initWithSize:(CGSize)size {
  if ((self = [super initWithSize:size])) {

    self.anchorPoint = CGPointMake(0.5, 0.5);
      
      if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
      {
          
          myScale = 2.0;
          TileHeight = TileHeight * myScale;
          TileWidth = TileWidth * myScale;
      }
    
    self.touchedBooster = false;
    self.booster = nil;
      
    self.lastMoveTime = 0;
    self.lastUpdateTime = 0;
    
    // Put an image on the background. Because the scene's anchorPoint is
    // (0.5, 0.5), the background image will always be centered on the screen.
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"grass-and-the-sky-background.jpg"];//"@"grass-and-the-sky-background.jpg"
    background.name = @"background";
    [self addChild:background];

    // Add a new node that is the container for all other layers on the playing
    // field. This gameLayer is also centered in the screen.
    self.gameLayer = [SKNode node];
    self.gameLayer.hidden = YES;
    [self addChild:self.gameLayer];

    CGPoint layerPosition = CGPointMake(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);

    // The tiles layer represents the shape of the level. It contains a sprite
    // node for each square that is filled in.
    self.tilesLayer = [SKNode node];
    self.tilesLayer.position = layerPosition;
    [self.gameLayer addChild:self.tilesLayer];

    // We use a crop layer to prevent cookies from being drawn across gaps
    // in the level design.
    self.cropLayer = [SKCropNode node];
    [self.gameLayer addChild:self.cropLayer];

    // The mask layer determines which part of the cookiesLayer is visible.
    self.maskLayer = [SKNode node];
    self.maskLayer.position = layerPosition;
    self.cropLayer.maskNode = self.maskLayer;

    // This layer holds the RWTCookie sprites. The positions of these sprites
    // are relative to the cookiesLayer's bottom-left corner.
    self.cookiesLayer = [SKNode node];
    self.cookiesLayer.position = layerPosition;

    [self.cropLayer addChild:self.cookiesLayer];

    // NSNotFound means that these properties have invalid values.
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;

    self.selectionSprite = [SKSpriteNode node];

    [self preloadResources];
      
      [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(SwapAnimationsTimer:) userInfo:nil repeats:YES];
  }
  return self;
}

//gives the freeze time
- (NSTimeInterval)getPlayerSleepingTime {
    if(self.lastMoveTime==0) {
        self.lastMoveTime = self.lastUpdateTime;
    }
    return self.lastUpdateTime - self.lastMoveTime;
}

- (void)resetSleepingTimer {
    self.lastMoveTime = self.lastUpdateTime;
}

- (void)loadBackgroundForLevel:(NSUInteger) levelNumber {
    
    SKSpriteNode *background = (SKSpriteNode *)[self childNodeWithName:@"background"];
    
    //if mount
    if(background!=nil) {
        switch(levelNumber) {
            case 10:
                background.texture = [SKTexture textureWithImageNamed:@"beach.jpg"];
                break;
            case 20:
                background.texture = [SKTexture textureWithImageNamed:@"paradise.jpg"];
                break;
            case 30:
                background.texture = [SKTexture textureWithImageNamed:@"rocky-desert.jpg"];//@"dunes.jpg"
                break;
                
            case 40:
                background.texture = [SKTexture textureWithImageNamed:@"autumn-leaves.jpg"];//there is also desert.jpg
                break;
            case 50:
                background.texture = [SKTexture textureWithImageNamed:@"glaciar.jpg"];
                break;
            case 60:
                background.texture = [SKTexture textureWithImageNamed:@"mountain.jpg"];
                break;
                
            case 70:
                background.texture = [SKTexture textureWithImageNamed:@"dunes.jpg"];
                break;
              
            case 80:
                background.texture = [SKTexture textureWithImageNamed:@"caribbean.jpg"];
                break;
                
            case 90:
                background.texture = [SKTexture textureWithImageNamed:@"grass.jpg"];
                break;
                
            case 100:
                background.texture = [SKTexture textureWithImageNamed:@"bg_dirt@2x.png"];
                break;

            default:
                background.texture = [SKTexture textureWithImageNamed:@"brickwall@2x.png"];
                break;
        }
    }
    
}

- (void)preloadResources {
  self.swapSound = [SKAction playSoundFileNamed:@"Chomp.wav" waitForCompletion:NO];
  self.invalidSwapSound = [SKAction playSoundFileNamed:@"Error.wav" waitForCompletion:NO];
  self.matchSound = [SKAction playSoundFileNamed:@"Ka-Ching.wav" waitForCompletion:NO];
  self.fallingCookieSound = [SKAction playSoundFileNamed:@"Scrape.wav" waitForCompletion:NO];
  self.addCookieSound = [SKAction playSoundFileNamed:@"Drip.wav" waitForCompletion:NO];
  self.explosionSound = [SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO];
    
  self.awesomeMoveSound = [SKAction playSoundFileNamed:@"awsomemove3.m4a" waitForCompletion:NO];
  self.superCoolSound = [SKAction playSoundFileNamed:@"supercool2.m4a" waitForCompletion:NO];
  self.jellyManiacSound = [SKAction playSoundFileNamed:@"jellymaniac2.m4a" waitForCompletion:NO];
  self.passLevelSound = [SKAction playSoundFileNamed:@"iuu.m4a" waitForCompletion:NO];
    
  self.gameOverSound = [SKAction playSoundFileNamed:@"gameover_broken.mp3" waitForCompletion:NO];
    
  self.rewardsSound = [SKAction playSoundFileNamed:@"magic_01.wav" waitForCompletion:NO];


  [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
}

//this will run the animations
- (void) SwapAnimationsTimer: (NSTimer *)timer {
    
    //get 6 random cookies at vaild positions
    
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:6];
    
    int cols =  [self.level getNumCols];
    int rows = [self.level getNumRows];
    
    do {
        int randomCol = arc4random() % (cols-1);
        int randomRow = arc4random() % (rows-1);
        
        PCJelly *cookie = [self.level cookieAtColumn:randomCol row:randomRow];
        if(cookie!=nil && ![array containsObject:cookie]) {
            
            [array addObject:cookie];
            [cookie.sprite runAction:cookie.swapAction];
        }
    
        
        //[array addObject:cookie];
    }while(array.count<6);
    
    
    
    
    
    
    //animate those
    
    /**
    level.getCookiAtcollumn
    
    - (RWTCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row
    
    for (RWTCookie *cookie in cookies) {
        cookie.sprite runAction cookie.swapAction];
    }*/
}

#pragma mark - Conversion Routines

// Converts a column,row pair into a CGPoint that is relative to the cookieLayer.
- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
  return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}

// Converts a point relative to the cookieLayer into column and row numbers.
- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {

  // "column" and "row" are output parameters, so they cannot be nil.
  NSParameterAssert(column);
  NSParameterAssert(row);

  // Is this a valid location within the cookies layer? If yes,
  // calculate the corresponding row and column numbers.
  if (point.x >= 0 && point.x < NumColumns*TileWidth &&
      point.y >= 0 && point.y < NumRows*TileHeight) {

    *column = point.x / TileWidth;
    *row = point.y / TileHeight;
    return YES;

  } else {
    *column = NSNotFound;  // invalid location
    *row = NSNotFound;
    return NO;
  }
}

#pragma mark - Game Setup

//clear the existing tiles
-(void)clearTiles {
    [self.maskLayer removeAllChildren];
    [self.tilesLayer removeAllChildren];
}

- (void)addTiles {
  for (NSInteger row = 0; row < NumRows; row++) {
    for (NSInteger column = 0; column < NumColumns; column++) {

      // If there is a tile at this position, then create a new tile
      // sprite and add it to the mask layer.
      if ([self.level tileAtColumn:column row:row] != nil) {
        SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"MaskTile@2x.png"];
          [tileNode setScale:myScale];
        tileNode.position = [self pointForColumn:column row:row];
        [self.maskLayer addChild:tileNode];
      }
    }
  }

  // The tile pattern is drawn *in between* the level tiles. That's why
  // there is an extra column and row of them.
  for (NSInteger row = 0; row <= NumRows; row++) {
    for (NSInteger column = 0; column <= NumColumns; column++) {

      BOOL topLeft     = (column > 0)          && (row < NumRows) && [self.level tileAtColumn:column - 1 row:row];
      BOOL bottomLeft  = (column > 0)          && (row > 0)       && [self.level tileAtColumn:column - 1 row:row - 1];
      BOOL topRight    = (column < NumColumns) && (row < NumRows) && [self.level tileAtColumn:column     row:row];
      BOOL bottomRight = (column < NumColumns) && (row > 0)       && [self.level tileAtColumn:column     row:row - 1];

      // The tiles are named from 0 to 15, according to the bitmask that is
      // made by combining these four values.
      NSUInteger value = topLeft | topRight << 1 | bottomLeft << 2 | bottomRight << 3;

      // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
      if (value != 0 && value != 6 && value != 9) {
        NSString *name = [NSString stringWithFormat:@"Tile_%lu@2x.png", (long)value];
        SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:name];
          [tileNode setScale:myScale];
        CGPoint point = [self pointForColumn:column row:row];
        point.x -= TileWidth/2;
        point.y -= TileHeight/2;
          
        tileNode.position = point;
        [self.tilesLayer addChild:tileNode];
      }
    }
  }
}

- (void)addSpritesForCookies:(NSSet *)cookies {
  //save the cookies on the scene
 _cookies = [[NSMutableArray alloc] init];
    
  for (PCJelly *cookie in cookies) {

    [_cookies addObject:cookie];
      
    // Create a new sprite for the cookie and add it to the cookiesLayer.
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
    sprite.position = [self pointForColumn:cookie.column row:cookie.row];
    [self.cookiesLayer addChild:sprite];
    cookie.sprite = sprite;
    
    
    //TODO my animation
    
    //get the first animation
    SKTexture* spriteTexture1 = [SKTexture textureWithImageNamed:[cookie spriteNameAnim01 ]];
    spriteTexture1.filteringMode = SKTextureFilteringNearest;
      
    SKTexture* spriteTexture2 = [SKTexture textureWithImageNamed:[cookie spriteName ]];
    spriteTexture2.filteringMode = SKTextureFilteringNearest;
      
    SKTexture* spriteTexture3 = [SKTexture textureWithImageNamed:[cookie spriteNameAnim03 ]];
    spriteTexture3.filteringMode = SKTextureFilteringNearest;
      
    cookie.swapAction= [SKAction animateWithTextures:@[spriteTexture1, spriteTexture2, spriteTexture3] timePerFrame:0.9];
      

    // Give each cookie sprite a small, random delay. Then fade them in.
    cookie.sprite.alpha = 0;
    cookie.sprite.xScale = cookie.sprite.yScale = myScale/2;

    [cookie.sprite runAction:[SKAction sequence:@[
      [SKAction waitForDuration:0.25 withRange:0.5],
      [SKAction group:@[
        [SKAction fadeInWithDuration:0.25],
        [SKAction scaleTo:myScale duration:0.25]
        ]]]]completion:^{

    } ];
      
      
 
  }
}

//called from the main view controller to add a booster sprite

- (void)addBoosterImageNamed:(NSString *) imageName {
    
    NSLog(@"adding booster %@",imageName);
    
    self.touchedBooster = true;
    
    

    
    if(![self childNodeWithName:@"help_booster"]) {
        
        if([imageName isEqualToString:@"bomb"]) {
            //bomb is special case
            
            self.booster = [[PCJelly alloc] init];
            self.booster.itemId = SMASH_BOMB_ITEM_ID;
            
            // Create a new sprite for the cookie and add it to the cookiesLayer.
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[self.booster spriteNameForLabel:imageName]];
            [sprite setName:@"help_booster"];
            [sprite setScale:myScale];
            
            
            
            
        }
        else {
            
            self.booster = [[PCJelly alloc] init];
            
            
            // Create a new sprite for the cookie and add it to the cookiesLayer.
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[self.booster spriteNameForLabel:imageName]];
            
            
            self.booster.sprite = sprite;
            
            self.booster.cookieType = [self getCookieType:imageName];
            
            //add a store id, to remove it from the inventory as soon as we use it
            self.booster.itemId = [self getStoreItemId: self.booster.cookieType];
            //TODO my animation
            
            //get the first animation
            SKTexture* spriteTexture1 = [SKTexture textureWithImageNamed:[self.booster spriteNameAnim01ForLabel:imageName ]];
            spriteTexture1.filteringMode = SKTextureFilteringNearest;
            
            
            SKTexture* spriteTexture2 = [SKTexture textureWithImageNamed:[self.booster spriteNameForLabel:imageName ]];
            spriteTexture2.filteringMode = SKTextureFilteringNearest;
            
            SKTexture* spriteTexture3 = [SKTexture textureWithImageNamed:[self.booster spriteNameAnim03ForLabel:imageName ]];
            spriteTexture3.filteringMode = SKTextureFilteringNearest;
            
            self.booster.swapAction= [SKAction animateWithTextures:@[spriteTexture1, spriteTexture2, spriteTexture3] timePerFrame:0.9];
            
            
            [sprite setName:@"help_booster"];
            
            
            // Give each cookie sprite a small, random delay. Then fade them in.
            sprite.alpha = 0;
            [sprite setScale:myScale];
            //sprite.xScale = self.booster.sprite.yScale = myScale/2;
            
            
            //TODO i think this should be only after touch too
            [sprite runAction:[SKAction sequence:@[
                                                   [SKAction waitForDuration:0.25 withRange:0.5],
                                                   [SKAction group:@[
                                                                     [SKAction fadeInWithDuration:0.25],
                                                                     [SKAction scaleTo:myScale duration:0.25]
                                                                     ]]]]completion:^{
                
            } ];
        }

        
    }

    
    
    
}

//get the cookie type to add, based on the name
-(NSInteger) getCookieType: (NSString *) forName{
    
    if([forName isEqualToString:@"blue"]) {
        return 1;
    }
    else if([forName isEqualToString:@"green"]) {
        return 2;
    }
    else if([forName isEqualToString:@"pink"]) {
        return 3;
    }
    else if([forName isEqualToString:@"red"]) {
        return 4;
    }
    else if([forName isEqualToString:@"yellow"]) {
        return 5;
    }
    else if([forName isEqualToString:@"dark"]) {
        return 6;
    }
    
    return 1;

}

//get the store id, given the jelly type, does not apply to bomb
-(NSString *)getStoreItemId: (NSUInteger) forType {
    
    switch (forType) {
        case 1:
            return BLUE_JELLY_ITEM_ID;
            break;
        case 2:
            return GREEN_JELLY_ITEM_ID;
            break;
        case 3:
            return PINK_JELLY_ITEM_ID;
            break;
        case 4:
            return RED_JELLY_ITEM_ID;
            break;
        case 5:
            return YELLOW_JELLY_ITEM_ID;
            break;
        case 6:
            return DARK_JELLY_ITEM_ID;
            break;
            
        default:
            break;
    }
    return BLUE_JELLY_ITEM_ID;
}

//adds a particle to the scene
-(ParticleEmitterNode *) addParticle: (NSString *) particleName andInterval: (float) timeToLive {
    
    ParticleEmitterNode *myParticle = [[ParticleEmitterNode alloc] initWithName:particleName andTimeToLive:timeToLive andCreationDate:self.lastUpdateTime];
    return myParticle;
}

//timer called, to remove the bomb related particles
-(void) removeParticles {
    
    
    [[self childNodeWithName:@"MySmokeParticle"] removeFromParent];
    [[self childNodeWithName:@"MyFireParticle"] removeFromParent];
    
    
}

/*pulseRed = [SKAction sequence:@[
 [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
 [SKAction waitForDuration:0.1],
 [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
 */

- (void)removeAllCookieSprites {
  [self.cookiesLayer removeAllChildren];
}

#pragma mark - Detecting Swipes

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  BOOL touchedBoosterTemp = self.touchedBooster;
  // Convert the touch location to a point relative to the cookiesLayer.
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self.cookiesLayer];

  // If the touch is inside a square, then this might be the start of a
  // swipe motion.
  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]) {

    // The touch must be on a cookie, not on an empty tile.
    PCJelly *cookie = [self.level cookieAtColumn:column row:row];
    if (cookie != nil) {
        
        //touched a jelly reset the time
        [self resetSleepingTimer];
        
        //**************** SWAP THEM *******************//
        if( touchedBoosterTemp && self.booster!=nil) {
           
            if([self.booster.itemId isEqualToString:SMASH_BOMB_ITEM_ID]) {
                
                self.booster.sprite.position = cookie.sprite.position;
                
                //remove the old one from the layer
                [cookie.sprite removeFromParent];
                //add the new sprite to the cookies layer
                [self addChild:cookie.sprite];
                
                
                [self runAction:[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO]];
                ParticleEmitterNode * mySmokeParticle = [self addParticle:@"MySmokeParticle" andInterval:1];
                mySmokeParticle.particle.particlePosition = [touch locationInNode:self.scene];
                //mySmokeParticle.particle.name = @"smoke";
                [self addChild: mySmokeParticle.particle];
                
                [self runAction:self.explosionSound];
                
                //[firstBody.node runAction:pulseRed];
                ParticleEmitterNode * myFireParticle = [self addParticle:@"MyFireParticle" andInterval:5000];
                myFireParticle.particle.particlePosition = [touch locationInNode:self.scene];
                //myFireParticle.particle.name = @"fire";
                [self addChild: myFireParticle.particle];
                
                
                //remove them
                //lazy load
                //if(self.particlesArray==nil) {
                  //  self.particlesArray = [[NSMutableArray alloc] init];
                //}
                
                //add the perticles to the array, to allow themselves to remove later
                //[self.particlesArray addObject:myFireParticle];
                //[self.particlesArray addObject:mySmokeParticle];
                
                //try to autoremove particles from scene, if ttl is over
                [NSTimer scheduledTimerWithTimeInterval:2.0  target:self
                                               selector:@selector(removeParticles)
                                               userInfo:nil
                                                repeats:NO];
                
                
                
                
            }
            else if(self.booster.cookieType!=cookie.cookieType){
                //make sure we don´t tap one of the same type
            
            
            //set the type to the new type
            cookie.cookieType = self.booster.cookieType;
            
            //save the position
            self.booster.sprite.position = cookie.sprite.position;
           
            //remove the old one from the layer
            [cookie.sprite removeFromParent];
            
            //assign the new sprite to the old cookie
            cookie.sprite = self.booster.sprite;
            
            //add the new sprite to the cookies layer
            [self.cookiesLayer addChild:cookie.sprite];

            //assign the new swap action
            cookie.swapAction = self.booster.swapAction;
            
            
            }

            //remove 1 unit from the inventory
            [StoreInventory takeAmount:1 ofItem:self.booster.itemId];
            //notify the controller, of the touched cookie
            [self notifyBoosterUsage: cookie];
            
            
            self.touchedBooster = false;
        }

      //*******************************************************/
      // Remember in which column and row the swipe started, so we can compare
      // them later to find the direction of the swipe. This is also the first
      // cookie that will be swapped.
      self.swipeFromColumn = column;
      self.swipeFromRow = row;

      [self showSelectionIndicatorForCookie:cookie];
      self.touchedBooster = false;
      
    }
    else {
        //clicked outside
        self.touchedBooster = false;
    }
  }
  else {
      //clicked outside
      self.touchedBooster = false;
  }

 
    
}

//gets the neighbours of the blasted cookie
-(NSSet *) getNeighbourBombedCookiesChain: (PCJelly *) blastedJelly{
    NSMutableSet *set = [NSMutableSet set];
    
    PCChain *chain = [[PCChain alloc] init];
    [chain addCookie:blastedJelly];
    
    NSInteger startCol = blastedJelly.column;
    NSInteger startRow = blastedJelly.row;
    
    //get the left and the right one and build first chain
    if(startCol+1 < NumColumns ) {
        PCJelly *cookieRight = [self.level cookieAtColumn:startCol+1 row:startRow];
        if(cookieRight!=nil) {
            [chain addCookie:cookieRight];
        }
    }
    if(startCol-1 >=0 ) {
        PCJelly *cookieLeft = [self.level cookieAtColumn:startCol-1 row:startRow];
        if(cookieLeft!=nil) {
            [chain addCookie:cookieLeft];
        }
    }
    
    //add this first chain to the set
    chain.score = chain.cookies.count*20 ;
    [set addObject:chain];
    
    //now get the top chain
    PCChain *chainTop = [[PCChain alloc] init];
    if(startRow-1>=0) {
        PCJelly *cookieTop = [self.level cookieAtColumn:startCol row:startRow-1];
        if(cookieTop!=nil) {
            [chainTop addCookie:cookieTop];
        }
        //top left
        if(startCol-1>=0 ){
            PCJelly *cookieTopLeft = [self.level cookieAtColumn:startCol-1 row:startRow-1];
            if(cookieTopLeft!=nil) {
                [chainTop addCookie:cookieTopLeft];
            }
        }
        //top right
        if(startCol+1<NumColumns ){
            PCJelly *cookieTopRight = [self.level cookieAtColumn:startCol+1 row:startRow-1];
            if(cookieTopRight!=nil) {
                [chainTop addCookie:cookieTopRight];
            }
        }
        chainTop.score = chainTop.cookies.count*20 ;
        [set addObject:chainTop];
    }
    
    //now get the bottom chain
    PCChain *chainBottom = [[PCChain alloc] init];
    if(startRow+1<NumRows) {
        PCJelly *cookieBottom = [self.level cookieAtColumn:startCol row:startRow+1];
        if(cookieBottom!=nil) {
            [chainBottom addCookie:cookieBottom];
        }
        //bottom left
        if(startCol-1>=0 ){
            PCJelly *cookieBottomLeft = [self.level cookieAtColumn:startCol-1 row:startRow+1];
            if(cookieBottomLeft!=nil) {
                [chainBottom addCookie:cookieBottomLeft];
            }
        }
        //top right
        if(startCol+1<NumColumns ){
            PCJelly *cookieBottomRight = [self.level cookieAtColumn:startCol+1 row:startRow+1];
            if(cookieBottomRight!=nil) {
                [chainBottom addCookie:cookieBottomRight];
            }
        }
        chainBottom.score = chainBottom.cookies.count*20 ;
        [set addObject:chainBottom];
    }
    
    
    
    /**
     NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
     NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
     
     return _cookies[column][row];
     *
     **/
    
    return set;
}

- (void)notifyBoosterUsage:(PCJelly *)touchedJelly {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                              touchedJelly forKey:@"booster"];
                              [[NSNotificationCenter defaultCenter]
                               postNotificationName:@"ReportBoosterInPlace" object:self userInfo:userInfo];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

  // If swipeFromColumn is NSNotFound then either the swipe began outside
  // the valid area or the game has already swapped the cookies and we need
  // to ignore the rest of the motion.
  if (self.swipeFromColumn == NSNotFound) return;

  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self.cookiesLayer];

  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]) {

    // Figure out in which direction the player swiped. Diagonal swipes
    // are not allowed.
    NSInteger horzDelta = 0, vertDelta = 0;
    if (column < self.swipeFromColumn) {          // swipe left
      horzDelta = -1;
    } else if (column > self.swipeFromColumn) {   // swipe right
      horzDelta = 1;
    } else if (row < self.swipeFromRow) {         // swipe down
      vertDelta = -1;
    } else if (row > self.swipeFromRow) {         // swipe up
      vertDelta = 1;
    }

    // Only try swapping when the user swiped into a new square.
    if (horzDelta != 0 || vertDelta != 0) {
      [self trySwapHorizontal:horzDelta vertical:vertDelta];
      [self hideSelectionIndicator];

      // Ignore the rest of this swipe motion from now on. Just setting
      // swipeFromColumn is enough; no need to set swipeFromRow as well.
      self.swipeFromColumn = NSNotFound;
    }
  }
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {

  // We get here after the user performs a swipe. This sets in motion a whole
  // chain of events: 1) swap the cookies, 2) remove the matching lines, 3)
  // drop new cookies into the screen, 4) check if they create new matches,
  // and so on.

  NSInteger toColumn = self.swipeFromColumn + horzDelta;
  NSInteger toRow = self.swipeFromRow + vertDelta;

  // Going outside the bounds of the array? This happens when the user swipes
  // over the edge of the grid. We should ignore such swipes.
  if (toColumn < 0 || toColumn >= NumColumns) return;
  if (toRow < 0 || toRow >= NumRows) return;

  // Can't swap if there is no cookie to swap with. This happens when the user
  // swipes into a gap where there is no tile.
  PCJelly *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
  if (toCookie == nil) return;

  PCJelly *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];

  // Communicate this swap request back to the ViewController.
  if (self.swipeHandler != nil) {
    PCSwap *swap = [[PCSwap alloc] init];
    swap.cookieA = fromCookie;
    swap.cookieB = toCookie;

    self.swipeHandler(swap);
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

  // Remove the selection indicator with a fade-out. We only need to do this
  // when the player didn't actually swipe.
  if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
    [self hideSelectionIndicator];
  }

  // If the gesture ended, regardless of whether if was a valid swipe or not,
  // reset the starting column and row numbers.
  self.swipeFromColumn = self.swipeFromRow = NSNotFound;
    
  //we record this as the time of the last move
  self.lastMoveTime = self.lastUpdateTime;
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

#pragma mark - Selection Indicator

- (void)showSelectionIndicatorForCookie:(PCJelly *)cookie {

  // If the selection indicator is still visible, then first remove it.
  if (self.selectionSprite.parent != nil) {
    [self.selectionSprite removeFromParent];
  }

  // Add the selection indicator as a child to the cookie that the player
  // tapped on and fade it in. Note: simply setting the texture on the sprite
  // doesn't give it the correct size; using an SKAction does.
  SKTexture *texture = [SKTexture textureWithImageNamed:[cookie highlightedSpriteName]];
  self.selectionSprite.size = texture.size;
  [self.selectionSprite runAction:[SKAction setTexture:texture]];

  [cookie.sprite addChild:self.selectionSprite];
  self.selectionSprite.alpha = 1.0;
}

- (void)hideSelectionIndicator {
  [self.selectionSprite runAction:[SKAction sequence:@[
    [SKAction fadeOutWithDuration:0.3],
    [SKAction removeFromParent]]]];
}

#pragma  update override
- (void)update:(NSTimeInterval)currentTime {
    
    if(_cookies!=nil && _cookies.count>0) {
       
        for(int i=0; i<6; i++) {
            PCJelly *theCookie = [_cookies objectAtIndex:i];
            [theCookie.sprite runAction:theCookie.swapAction withKey:@"swap"];
            
        }
        
         //cookie.swapActionForever = [SKAction repeatActionForever:cookie.swapAction];
    }
    self.lastUpdateTime = currentTime;
    //get 6 random sprites and animate them
  
}

#pragma mark - Animations

- (void)animateSwap:(PCSwap *)swap completion:(dispatch_block_t)completion {

  // Put the cookie you started with on top.
  swap.cookieA.sprite.zPosition = 100;
  swap.cookieB.sprite.zPosition = 90;

  const NSTimeInterval Duration = 0.3;

  SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:Duration];
  moveA.timingMode = SKActionTimingEaseOut;
  [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];

  SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:Duration];
  moveB.timingMode = SKActionTimingEaseOut;
  [swap.cookieB.sprite runAction:moveB];

  [self runAction:self.swapSound];
}

- (void)animateInvalidSwap:(PCSwap *)swap completion:(dispatch_block_t)completion {
  swap.cookieA.sprite.zPosition = 100;
  swap.cookieB.sprite.zPosition = 90;

  const NSTimeInterval Duration = 0.2;

  SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:Duration];
  moveA.timingMode = SKActionTimingEaseOut;

  SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:Duration];
  moveB.timingMode = SKActionTimingEaseOut;

  [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
  [swap.cookieB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];

  [self runAction:self.invalidSwapSound];
}

- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion {

  for (PCChain *chain in chains) {
    [self animateScoreForChain:chain];
    for (PCJelly *cookie in chain.cookies) {

      if (cookie.sprite != nil) {
        SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
        scaleAction.timingMode = SKActionTimingEaseOut;
        [cookie.sprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];

        // It may happen that the same RWTCookie object is part of two chains
        // (L-shape match). In that case, its sprite should only be removed
        // once.
        cookie.sprite = nil;
      }
    }
  }

  [self runAction:self.matchSound];

  // Continue with the game after the animations have completed.
  [self runAction:[SKAction sequence:@[
    [SKAction waitForDuration:0.3],
    [SKAction runBlock:completion]
    ]]];
}

//play sounds from controller

- (void)playRewardsSound {
    [self runAction:self.rewardsSound];
}

- (void)playGameOverSound {
    [self runAction:self.gameOverSound];
}

- (void)playSuperCoolSound {
    [self runAction:self.superCoolSound];
}
- (void)playAwesomeMoveSound {
    [self runAction:self.awesomeMoveSound];
}
- (void)playJellyManiacSound{
    [self runAction:self.jellyManiacSound];
}

- (void)playPassLevelSound{
    [self runAction:self.passLevelSound];
}




- (void)animateScoreForChain:(PCChain *)chain {
  // Figure out what the midpoint of the chain is.
  PCJelly *firstCookie = [chain.cookies firstObject];
  PCJelly *lastCookie = [chain.cookies lastObject];
  CGPoint centerPosition = CGPointMake(
    (firstCookie.sprite.position.x + lastCookie.sprite.position.x)/2,
    (firstCookie.sprite.position.y + lastCookie.sprite.position.y)/2 - 8);

  // Add a label for the score that slowly floats up.
  SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
  scoreLabel.fontSize = 16;
  scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)chain.score];
  scoreLabel.position = centerPosition;
  scoreLabel.zPosition = 300;
  [self.cookiesLayer addChild:scoreLabel];

  SKAction *moveAction = [SKAction moveBy:CGVectorMake(0, 3) duration:0.7];
  moveAction.timingMode = SKActionTimingEaseOut;
  [scoreLabel runAction:[SKAction sequence:@[
    moveAction,
    [SKAction removeFromParent]
    ]]];
}

- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
  __block NSTimeInterval longestDuration = 0;

  for (NSArray *array in columns) {

    [array enumerateObjectsUsingBlock:^(PCJelly *cookie, NSUInteger idx, BOOL *stop) {
      CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];

      // The further away from the hole you are, the bigger the delay
      // on the animation.
      NSTimeInterval delay = 0.05 + 0.15*idx;

      // Calculate duration based on far cookie has to fall (0.1 seconds
      // per tile).
      NSTimeInterval duration = ((cookie.sprite.position.y - newPosition.y) / TileHeight) * 0.1;
      longestDuration = MAX(longestDuration, duration + delay);

      SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
      moveAction.timingMode = SKActionTimingEaseOut;
      [cookie.sprite runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction group:@[moveAction, self.fallingCookieSound]]]]];
    }];
  }

  // Wait until all the cookies have fallen down before we continue.
  [self runAction:[SKAction sequence:@[
    [SKAction waitForDuration:longestDuration],
    [SKAction runBlock:completion]
    ]]];
}

- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {

  // We don't want to continue with the game until all the animations are
  // complete, so we calculate how long the longest animation lasts, and
  // wait that amount before we trigger the completion block.
  __block NSTimeInterval longestDuration = 0;

  for (NSArray *array in columns) {

    // The new sprite should start out just above the first tile in this column.
    // An easy way to find this tile is to look at the row of the first cookie
    // in the array, which is always the top-most one for this column.
    NSInteger startRow = ((PCJelly *)[array firstObject]).row + 1;

    [array enumerateObjectsUsingBlock:^(PCJelly *cookie, NSUInteger idx, BOOL *stop) {

      // Create a new sprite for the cookie.
      SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
        [sprite setScale:myScale];
      sprite.position = [self pointForColumn:cookie.column row:startRow];
      [self.cookiesLayer addChild:sprite];
      cookie.sprite = sprite;

      // Give each cookie that's higher up a longer delay, so they appear to
      // fall after one another.
      NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);

      // Calculate duration based on far the cookie has to fall.
      NSTimeInterval duration = (startRow - cookie.row) * 0.1;
      longestDuration = MAX(longestDuration, duration + delay);

      // Animate the sprite falling down. Also fade it in to make the sprite
      // appear less abruptly.
      CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];
      SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
      moveAction.timingMode = SKActionTimingEaseOut;
      cookie.sprite.alpha = 0;
      [cookie.sprite runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction group:@[
          [SKAction fadeInWithDuration:0.05], moveAction, self.addCookieSound]]]]];
    }];
  }

  // Wait until the animations are done before we continue.
  [self runAction:[SKAction sequence:@[
    [SKAction waitForDuration:longestDuration],
    [SKAction runBlock:completion]
    ]]];
}

//TODO my animation
- (void)animateAllCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        
        [array enumerateObjectsUsingBlock:^(PCJelly *cookie, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];
            
            // The further away from the hole you are, the bigger the delay
            // on the animation.
            NSTimeInterval delay = 0.05 + 0.15*idx;
            
            // Calculate duration based on far cookie has to fall (0.1 seconds
            // per tile).
            NSTimeInterval duration = ((cookie.sprite.position.y - newPosition.y) / TileHeight) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            [cookie.sprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[moveAction, self.fallingCookieSound]]]]];
        }];
    }
    
    // Wait until all the cookies have fallen down before we continue.
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}


- (void)animateGameOver {
  SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
  action.timingMode = SKActionTimingEaseIn;
  [self.gameLayer runAction:action];
}

- (void)animateBeginGame {
  self.gameLayer.hidden = NO;

  self.gameLayer.position = CGPointMake(0, self.size.height);
  SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
  action.timingMode = SKActionTimingEaseOut;
  [self.gameLayer runAction:action];
}

@end
