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

#import "JellyStoreAssets.h"
#import "VirtualCategory.h"
#import "VirtualCurrency.h"
#import "VirtualGood.h"
#import "VirtualCurrencyPack.h"
#import "NonConsumableItem.h"
#import "SingleUseVG.h"
#import "PurchaseWithMarket.h"
#import "PurchaseWithVirtualItem.h"
#import "MarketItem.h"
#import "LifetimeVG.h"
#import "EquippableVG.h"
#import "SingleUsePackVG.h"
#import "UpgradeVG.h"

// Currencies
NSString* const JELLY_CURRENCY_ITEM_ID = @"jelly_currency";

// Goods


NSString* const GREEN_JELLY_ITEM_ID = @"green_jelly_item_id";
NSString* const DARK_JELLY_ITEM_ID= @"dark_jelly_item_id";
NSString* const PINK_JELLY_ITEM_ID= @"pink_jelly_item_id";
NSString* const YELLOW_JELLY_ITEM_ID= @"yellow_jelly_item_id";
NSString* const RED_JELLY_ITEM_ID= @"red_jelly_item_id";
NSString* const BLUE_JELLY_ITEM_ID= @"blue_jelly_item_id";
NSString* const SMASH_BOMB_ITEM_ID= @"smash_bomb_item_id";


// Currency Packs

//5 moves
NSString* const JELLY_MANIACS_5MOVES_PACK_ITEM_ID = @"jelly_maniacs_moves5";
NSString* const JELLY_MANIACS_5MOVES_PRODUCT_ID = @"jelly_maniacs_moves5";

//10 moves
NSString* const JELLY_MANIACS_10MOVES_PACK_ITEM_ID = @"jelly_maniacs_moves10";
NSString* const JELLY_MANIACS_10MOVES_PRODUCT_ID = @"jelly_maniacs_moves10";
//10 levels
NSString* const JELLY_MANIACS_10LEVELS_PACK_ITEM_ID = @"jelly_maniacs_levels10";
NSString* const JELLY_MANIACS_10LEVELS_PRODUCT_ID = @"jelly_maniacs_levels10";

// Non Consumables
//NSString* const NO_ADS_NON_CONS_ITEM_ID = @"no_ads";
//NSString* const NO_ADS_PRODUCT_ID = @"my.game.no_ads";

@implementation JellyStoreAssets

//virtual category
VirtualCategory* JELLY_CATEGORY;

//virtual currency
VirtualCurrency* JELLY_CURRENCY;

//virtual goods
VirtualGood* BLUE_JELLY_GOOD;
VirtualGood* RED_JELLY_GOOD;
VirtualGood* YELLOW_JELLY_GOOD;
VirtualGood* PINK_JELLY_GOOD;
VirtualGood* GREEN_JELLY_GOOD;
VirtualGood* DARK_JELLY_GOOD;

VirtualGood* SMASH_BOMB_GOOD;

//10 extra levels
//VirtualCurrencyPack* _10_JELLY_MANIACS_LEVELS_PACK;

//5 and 10 extra moves
VirtualCurrencyPack* PRODUCT_EXTRA_10_LEVELS;
VirtualCurrencyPack* PRODUCT_EXTRA_10_MOVES;
VirtualCurrencyPack* PRODUCT_EXTRA_5_MOVES;

NonConsumableItem *NO_ADS_NON_CONS;
NSString *NO_ADS_NON_CONS_ITEM_ID = @"no.ads";
NSString *NO_ADS_PRODUCT_ID = @"no.ads.id";
+ (void)initialize{
    
    /** Virtual Currencies **/
    JELLY_CURRENCY = [[VirtualCurrency alloc] initWithName:@"Jelly" andDescription:@"" andItemId:JELLY_CURRENCY_ITEM_ID];
    
    
    /** Virtual Currency Packs **/
    
    PRODUCT_EXTRA_10_LEVELS = [[VirtualCurrencyPack alloc] initWithName:@"10 Extra Levels" andDescription:@"10 Extra Levels"  andItemId:JELLY_MANIACS_10LEVELS_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_10LEVELS_PRODUCT_ID andConsumable:kConsumable andPrice:2.99]]];
    
    PRODUCT_EXTRA_10_LEVELS.currencyItemId = JELLY_CURRENCY_ITEM_ID;
    
    PRODUCT_EXTRA_10_MOVES = [[VirtualCurrencyPack alloc] initWithName:@"10 Extra Moves" andDescription:@"10 Extra Moves" andItemId:JELLY_MANIACS_10MOVES_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_10MOVES_PRODUCT_ID andConsumable:kConsumable andPrice:1.99]]];
    
    PRODUCT_EXTRA_10_MOVES.currencyItemId = JELLY_CURRENCY_ITEM_ID;
    
    PRODUCT_EXTRA_5_MOVES = [[VirtualCurrencyPack alloc] initWithName:@"5 Extra Moves" andDescription:@"5 Extra Moves" andItemId:JELLY_MANIACS_5MOVES_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_5MOVES_PRODUCT_ID andConsumable:kConsumable andPrice:0.99]]];
    
    PRODUCT_EXTRA_5_MOVES.currencyItemId = JELLY_CURRENCY_ITEM_ID;
                               
    
    /** Virtual Goods **/
    
    /* SingleUseVGs */
    
    SMASH_BOMB_GOOD = [[SingleUseVG alloc] initWithName:@"smash" andDescription:@"Smash Bomb" andItemId:SMASH_BOMB_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:500]];
    
    DARK_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"dark" andDescription:@"1x dark Jelly" andItemId:DARK_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];
    
    BLUE_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"blue" andDescription:@"1x Blue Jelly" andItemId:BLUE_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];
    
    GREEN_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"green" andDescription:@"1x Green Jelly" andItemId:GREEN_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];
    
    YELLOW_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"yellow" andDescription:@"1x Yellow Jelly" andItemId:YELLOW_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];
    
    RED_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"red" andDescription:@"1x Red Jelly" andItemId:RED_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];

    PINK_JELLY_GOOD = [[SingleUseVG alloc] initWithName:@"pink" andDescription:@"1x Pink Jelly" andItemId:PINK_JELLY_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:JELLY_CURRENCY_ITEM_ID andAmount:200]];
    
    
    
    /* LifetimeVGs */
    
    //MARRIAGE_GOOD = [[LifetimeVG alloc] initWithName:@"Marriage" andDescription:@"This is a LIFETIME thing." andItemId:MARRIAGE_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:MARRIAGE_PRODUCT_ID andConsumable:kConsumable andPrice:9.99]]];
    
    /* EquippableVGs */
    
    /*JERRY_GOOD = [[EquippableVG alloc] initWithName:@"Jerry" andDescription:@"Your friend Jerry" andItemId:JERRY_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:250] andEquippingModel:kCategory];
    
    GEORGE_GOOD = [[EquippableVG alloc] initWithName:@"George" andDescription:@"The best muffin eater in the north" andItemId:GEORGE_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:350] andEquippingModel:kCategory];
    
    KRAMER_GOOD = [[EquippableVG alloc] initWithName:@"Kramer" andDescription:@"Knows how to get muffins" andItemId:KRAMER_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:450] andEquippingModel:kCategory];
    
    ELAINE_GOOD = [[EquippableVG alloc] initWithName:@"Elaine" andDescription:@"Kicks muffins like superman" andItemId:ELAINE_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1000] andEquippingModel:kCategory];
    
    // SingleUsePackVGs
    
    _20_CHOCOLATE_CAKES_GOOD = [[SingleUsePackVG alloc] initWithName:@"20 chocolate cakes" andDescription:@"A pack of 20 chocolate cakes" andItemId:_20_CHOCOLATE_CAKES_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:34] andSingleUseGood:CHOCOLATE_CAKE_GOOD_ITEM_ID andAmount:20];
    
    _50_CHOCOLATE_CAKES_GOOD = [[SingleUsePackVG alloc] initWithName:@"50 chocolate cakes" andDescription:@"A pack of 50 chocolate cakes" andItemId:_50_CHOCOLATE_CAKES_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:340] andSingleUseGood:CHOCOLATE_CAKE_GOOD_ITEM_ID andAmount:50];
    
    _100_CHOCOLATE_CAKES_GOOD = [[SingleUsePackVG alloc] initWithName:@"100 chocolate cakes" andDescription:@"A pack of 100 chocolate cakes" andItemId:_100_CHOCOLATE_CAKES_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:3410] andSingleUseGood:CHOCOLATE_CAKE_GOOD_ITEM_ID andAmount:100];
    
    _200_CHOCOLATE_CAKES_GOOD = [[SingleUsePackVG alloc] initWithName:@"200 chocolate cakes" andDescription:@"A pack of 200 chocolate cakes" andItemId:_200_CHOCOLATE_CAKES_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:4000] andSingleUseGood:CHOCOLATE_CAKE_GOOD_ITEM_ID andAmount:200];
    
    // UpgradeVGs
    
    LEVEL_1_GOOD = [[UpgradeVG alloc] initWithName:@"Level 1" andDescription:@"Muffin Cake Level 1" andItemId:LEVEL_1_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:50] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:@"" andNextUpgrade:LEVEL_2_GOOD_ITEM_ID];
    
    LEVEL_2_GOOD = [[UpgradeVG alloc] initWithName:@"Level 2" andDescription:@"Muffin Cake Level 2" andItemId:LEVEL_2_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:250] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:LEVEL_1_GOOD_ITEM_ID andNextUpgrade:LEVEL_3_GOOD_ITEM_ID];
    
    LEVEL_3_GOOD = [[UpgradeVG alloc] initWithName:@"Level 3" andDescription:@"Muffin Cake Level 3" andItemId:LEVEL_3_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:500] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:LEVEL_2_GOOD_ITEM_ID andNextUpgrade:LEVEL_4_GOOD_ITEM_ID];
    
    LEVEL_4_GOOD = [[UpgradeVG alloc] initWithName:@"Level 4" andDescription:@"Muffin Cake Level 4" andItemId:LEVEL_4_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1000] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:LEVEL_3_GOOD_ITEM_ID andNextUpgrade:LEVEL_5_GOOD_ITEM_ID];
    
    LEVEL_5_GOOD = [[UpgradeVG alloc] initWithName:@"Level 5" andDescription:@"Muffin Cake Level 5" andItemId:LEVEL_5_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1250] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:LEVEL_4_GOOD_ITEM_ID andNextUpgrade:LEVEL_6_GOOD_ITEM_ID];
    
    LEVEL_6_GOOD = [[UpgradeVG alloc] initWithName:@"Level 6" andDescription:@"Muffin Cake Level 6" andItemId:LEVEL_6_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1500] andLinkedGood:MUFFIN_CAKE_GOOD_ITEM_ID andPreviousUpgrade:LEVEL_5_GOOD_ITEM_ID andNextUpgrade:@""];
    
    _LEVEL_1_GOOD = [[UpgradeVG alloc] initWithName:@"Level 1" andDescription:@"Pavlova Level 1" andItemId:_LEVEL_1_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:150] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:@"" andNextUpgrade:_LEVEL_2_GOOD_ITEM_ID];
    
    _LEVEL_2_GOOD = [[UpgradeVG alloc] initWithName:@"Level 2" andDescription:@"Pavlova Level 2" andItemId:_LEVEL_2_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:350] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:_LEVEL_1_GOOD_ITEM_ID andNextUpgrade:_LEVEL_3_GOOD_ITEM_ID];
    
    _LEVEL_3_GOOD = [[UpgradeVG alloc] initWithName:@"Level 3" andDescription:@"Pavlova Level 3" andItemId:_LEVEL_3_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:700] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:_LEVEL_2_GOOD_ITEM_ID andNextUpgrade:_LEVEL_4_GOOD_ITEM_ID];
    
    _LEVEL_4_GOOD = [[UpgradeVG alloc] initWithName:@"Level 4" andDescription:@"Pavlova Level 4" andItemId:_LEVEL_4_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1200] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:_LEVEL_3_GOOD_ITEM_ID andNextUpgrade:_LEVEL_5_GOOD_ITEM_ID];
    
    _LEVEL_5_GOOD = [[UpgradeVG alloc] initWithName:@"Level 5" andDescription:@"Pavlova Level 5" andItemId:_LEVEL_5_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:1850] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:_LEVEL_4_GOOD_ITEM_ID andNextUpgrade:_LEVEL_6_GOOD_ITEM_ID];
    
    _LEVEL_6_GOOD = [[UpgradeVG alloc] initWithName:@"Level 6" andDescription:@"Pavlova Level 6" andItemId:_LEVEL_6_GOOD_ITEM_ID andPurchaseType:[[PurchaseWithVirtualItem alloc] initWithVirtualItem:MUFFINS_CURRENCY_ITEM_ID andAmount:2500] andLinkedGood:PAVLOVA_GOOD_ITEM_ID andPreviousUpgrade:_LEVEL_5_GOOD_ITEM_ID andNextUpgrade:@""];
    
    
    // Virtual Categories
    
    _MUFFINS_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Muffins" andGoodsItemIds:@[MUFFIN_CAKE_GOOD_ITEM_ID, CHOCOLATE_CAKE_GOOD_ITEM_ID, PAVLOVA_GOOD_ITEM_ID, MUFFIN_CAKE_GOOD_ITEM_ID]];
    
    MUFFIN_CAKE_UPGRADES_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Muffin Cake Upgrades" andGoodsItemIds:@[LEVEL_1_GOOD_ITEM_ID, LEVEL_2_GOOD_ITEM_ID, LEVEL_3_GOOD_ITEM_ID, LEVEL_4_GOOD_ITEM_ID, LEVEL_5_GOOD_ITEM_ID, LEVEL_6_GOOD_ITEM_ID]];
    
    PAVLOVA_UPGRADES_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Pavlova Upgrades" andGoodsItemIds:@[_LEVEL_1_GOOD_ITEM_ID, _LEVEL_2_GOOD_ITEM_ID, _LEVEL_3_GOOD_ITEM_ID, _LEVEL_4_GOOD_ITEM_ID, _LEVEL_5_GOOD_ITEM_ID, _LEVEL_6_GOOD_ITEM_ID]];
    
    CHARACTERS_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Characters" andGoodsItemIds:@[JERRY_GOOD_ITEM_ID, GEORGE_GOOD_ITEM_ID, KRAMER_GOOD_ITEM_ID, ELAINE_GOOD_ITEM_ID]];
    
    LIFETIME_THINGS_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Lifetime things" andGoodsItemIds:@[MARRIAGE_GOOD_ITEM_ID]];
    
    PACKS_OF_CHOCOLATE_CAKES_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Packs of Chocolate Cakes" andGoodsItemIds:@[_20_CHOCOLATE_CAKES_GOOD_ITEM_ID, _50_CHOCOLATE_CAKES_GOOD_ITEM_ID, _100_CHOCOLATE_CAKES_GOOD_ITEM_ID, _200_CHOCOLATE_CAKES_GOOD_ITEM_ID]];*/
    
    JELLY_CATEGORY  = [[VirtualCategory alloc] initWithName:@"Jelly" andGoodsItemIds:@[BLUE_JELLY_ITEM_ID, RED_JELLY_ITEM_ID, YELLOW_JELLY_ITEM_ID, GREEN_JELLY_ITEM_ID,PINK_JELLY_ITEM_ID]];
    
    
    /** Non Consumables **/
    NO_ADS_NON_CONS = [[NonConsumableItem alloc] initWithName:@"No Ads" andDescription:@"No more ads" andItemId:NO_ADS_NON_CONS_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:NO_ADS_PRODUCT_ID andConsumable:kNonConsumable andPrice:1.99]]];
    
    /*PRODUCT_EXTRA_10_LEVELS = [[NonConsumableItem alloc] initWithName:@"10 Extra Levels" andDescription:@"10 Extra Levels" andItemId:JELLY_MANIACS_10LEVELS_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_10LEVELS_PRODUCT_ID andConsumable:kNonConsumable andPrice:2.99]]];
    
    PRODUCT_EXTRA_10_MOVES = [[NonConsumableItem alloc] initWithName:@"10 Extra Moves" andDescription:@"10 Extra Moves" andItemId:JELLY_MANIACS_10MOVES_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_10MOVES_PRODUCT_ID andConsumable:kNonConsumable andPrice:1.99]]];
    
    PRODUCT_EXTRA_5_MOVES = [[NonConsumableItem alloc] initWithName:@"5 Extra Moves" andDescription:@"5 Extra Moves" andItemId:JELLY_MANIACS_5MOVES_PACK_ITEM_ID andPurchaseType:[[PurchaseWithMarket alloc] initWithMarketItem:[[MarketItem alloc] initWithProductId:JELLY_MANIACS_5MOVES_PRODUCT_ID andConsumable:kNonConsumable andPrice:0.99]]];*/
    
}

- (int)getVersion {
    return 0;
}

- (NSArray*)virtualCurrencies{
    return @[JELLY_CURRENCY];
}

- (NSArray*)virtualGoods{
    return @[
    SMASH_BOMB_GOOD,DARK_JELLY_GOOD,BLUE_JELLY_GOOD,GREEN_JELLY_GOOD,YELLOW_JELLY_GOOD,RED_JELLY_GOOD,PINK_JELLY_GOOD];
}

- (NSArray*)virtualCurrencyPacks{
    return @[PRODUCT_EXTRA_5_MOVES,PRODUCT_EXTRA_10_MOVES,PRODUCT_EXTRA_10_LEVELS];
}

- (NSArray*)virtualCategories{
    return @[JELLY_CATEGORY];
}

- (NSArray*)nonConsumableItems{
    return @[];//NO_ADS_NON_CONS
}

@end