/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "IStoreAssets.h"


/**
 This class defines our game's economy model, which includes virtual goods, 
 virtual currencies and currency packs, virtual categories, and non-consumable
 items.
 */


// Currencies
extern NSString* const JELLY_CURRENCY_ITEM_ID;

//5 moves
extern NSString* const JELLY_MANIACS_5MOVES_PACK_ITEM_ID;

//10 moves
extern NSString* const JELLY_MANIACS_10MOVES_PACK_ITEM_ID;

//10 levels
extern NSString* const JELLY_MANIACS_10LEVELS_PACK_ITEM_ID;

// Goods

extern NSString* const GREEN_JELLY_ITEM_ID;
extern NSString* const DARK_JELLY_ITEM_ID;
extern NSString* const PINK_JELLY_ITEM_ID;
extern NSString* const YELLOW_JELLY_ITEM_ID;
extern NSString* const RED_JELLY_ITEM_ID;
extern NSString* const BLUE_JELLY_ITEM_ID;
extern NSString* const SMASH_BOMB_ITEM_ID;

// Currency Packs
//extern NSString* const _10_JELLY_LEVELS_PACK_ITEM_ID;
//extern NSString* const _10_JELLY_PRODUCT_ID;
//extern NSString* const _50_JELLY_PACK_ITEM_ID;
//extern NSString* const _50_JELLY_PRODUCT_ID;
//extern NSString* const _400_JELLY_PACK_ITEM_ID;
//extern NSString* const _400_JELLY_PRODUCT_ID;
//extern NSString* const _1000_JELLY_PACK_ITEM_ID;
//extern NSString* const _1000_JELLY_PRODUCT_ID;

// Non Consumables
//extern NSString* const NO_ADS_NON_CONS_ITEM_ID;
//extern NSString* const NO_ADS_PRODUCT_ID;

@interface JellyStoreAssets : NSObject <IStoreAssets>{
    
}

@end