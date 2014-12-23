//
//  MenuTableViewController.m
//  JellyCrush
//
//  Created by Paulo Cristo on 23/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "MenuTableViewController.h"
#import "ViewController.h"
#import "SWRevealViewController.h"
#import "VirtualGood.h"
#import "StoreInfo.h"
#import "InsufficientFundsException.h"
#import "JellyStoreAssets.h"
#import "StoreEventHandling.h"
#import "StoreInventory.h"
#import "MyStoreTableViewCell.h"
#import "SoomlaStore.h"
#import "StoreInventory.h"
#import "iToast.h"
#import "Constants.h"



@interface MenuTableViewController ()

@property (nonatomic, strong) NSArray *menuItems;



@end

@implementation MenuTableViewController

@synthesize currencyBalanceLabel;
int balance;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _menuItems = @[@"moves5",@"moves10",@"levels",@"levels25",@"smash",@"dark",@"blue",@"green",@"yellow",@"red",@"pink"];
    //[StoreInventory giveAmount:10 ofItem:@"currency_coin"];
   
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goodBalanceChanged:) name:EVENT_GOOD_BALANCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(curBalanceChanged:) name:EVENT_CURRENCY_BALANCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemPurchased:) name:EVENT_ITEM_PURCHASED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(marketItemPurchased:) name:EVENT_MARKET_PURCHASED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(marketPurchaseCancelled:) name:EVENT_MARKET_PURCHASE_CANCELLED object:nil];
    
    
    balance = [StoreInventory getItemBalance:JELLY_CURRENCY_ITEM_ID];
    currencyBalanceLabel = [NSString stringWithFormat:@"%d", balance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return _menuItems.count;
}

//get the main controller
-(ViewController*) getMainController {

    SWRevealViewController *reveal = (SWRevealViewController*)self.parentViewController;
    UINavigationController *nav = (UINavigationController*)reveal.frontViewController;
    ViewController *viewController = (ViewController*)[nav.childViewControllers objectAtIndex:0];
    return viewController;
    
}

-(void) refreshTable {
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    MyStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger purchasedLevels = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY]; //the standard value
    
    if(row==2) {
        
        if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
            //if not buy
            
            //at least 10 available?
            if(NUM_AVAILABLE_LEVELS - purchasedLevels < 10) {
                 cell.levels10Locker.hidden=false;
            }
            else {
                 cell.levels10Locker.hidden=true;
            }
        }
        else {
            cell.levels10Locker.hidden=false;
        }
        
    }
    else if(row==3) {
        if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
            //if not buy
            
            //at least 25 available?
            if(NUM_AVAILABLE_LEVELS - purchasedLevels < 25) {
                cell.levels25Locker.hidden=false;
            }
            else {
                cell.levels25Locker.hidden=true;
            }
        }
        else {
            cell.levels25Locker.hidden=false;
        }
    }
    else if(row==4) {
        if(balance < 500) {
            cell.smashBombLocker.hidden=false;
        }
        else {
            cell.smashBombLocker.hidden=true;
        }
        
    }
    else if(row>4) {
        
        if(balance<200) {
            
            cell.darkJellyLocker.hidden=false;
            cell.blueJellyLocker.hidden=false;
            cell.greenJellyLocker.hidden=false;
            cell.yellowJellyLocker.hidden=false;
            cell.redJellyLocker.hidden=false;
            cell.pinkJellyLocker.hidden=false;
            
        }
        else {
            cell.darkJellyLocker.hidden=true;
            cell.blueJellyLocker.hidden=true;
            cell.greenJellyLocker.hidden=true;
            cell.yellowJellyLocker.hidden=true;
            cell.redJellyLocker.hidden=true;
            cell.pinkJellyLocker.hidden=true;
        }
        
        
    }
    

    
    return cell;
    
    
}

//I can only purchase a booster good if the balance for all is empty
//cause i can only use 1 at the time, as help
-(BOOL)checkBoosterGoodsBalanceEmpty {

    if([StoreInventory getItemBalance:BLUE_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:DARK_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:RED_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:GREEN_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:YELLOW_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:PINK_JELLY_ITEM_ID]>0) {
        return false;
    }
    else if([StoreInventory getItemBalance:SMASH_BOMB_ITEM_ID]>0) {
        return false;
    }
    return true;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSInteger section = indexPath.section;
    NSInteger row =indexPath.row;
    //NSInteger restore = _menuItems.count-1;//last one
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    /*if(row==restore) {
        [[[[iToast makeText:NSLocalizedString(@"restore_purchases", @"restore_purchases")]
           setGravity:iToastGravityBottom] setDuration:2000] show];
        [[SoomlaStore getInstance] restoreTransactions];
    }*/
    if(row>=4 ) {
        //row 4 is smash bomb
        
        NSInteger index = row-4; //we subtract 4, which are the market ones (5,10 moves and 10,25 levels)
        //from row 4 to 8 is jellies
        VirtualGood* good = [[[StoreInfo getInstance] virtualGoods] objectAtIndex:index];
        
        if([self checkBoosterGoodsBalanceEmpty]) {
            
            @try {
                //[good buyWithPayload:@"this is a payload"];
                [StoreInventory buyItemWithItemId:good.itemId andPayload:@""];
                
                NSString * msg = [NSString stringWithFormat: @"%@ %@",NSLocalizedString(@"congratulations_purchased", @"congratulations_purchased"),
                                  good.description ];
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityCenter] setDuration:2000] show];
                
                //NSLog(@"remaining balance is %d",[StoreInventory getItemBalance:good.itemId]);
                
            }
            @catch (InsufficientFundsException *exception) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"insufficient_funds", @"insufficient_funds")
                                                                message:NSLocalizedString(@"not_enough_jellys", @"not_enough_jellys")
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }
            
        }//cannot purchase already have one
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"already_purchased_booster", @"already_purchased_booster")
                                                            message:NSLocalizedString(@"only_one_booster", @"only_one_booster")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            
        }
        
        
        
    }
    else {
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSInteger purchasedLevels = NUM_PURCHASED_LEVELS; //the standard value
        
        switch (row) {
            //these are always available
            //buy 5 moves
            case 0:
                [StoreInventory buyItemWithItemId:JELLY_MANIACS_5MOVES_PACK_ITEM_ID andPayload:@"buy 5 extra moves"];
                break;
            //buy 10 moves
            case 1:
                [StoreInventory buyItemWithItemId:JELLY_MANIACS_10MOVES_PACK_ITEM_ID andPayload:@"buy 10 extra moves" ];
                break;
            //buy 10 levels
            case 2:
                
                purchasedLevels = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
                //do we already have the 100 available?
                if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
                    //if not buy
                    
                    //at least 10 available?
                    if(NUM_AVAILABLE_LEVELS - purchasedLevels < 10) {
                        //cannot buy more, not available
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                        message:NSLocalizedString(@"no_more_levels_fit_pack", @"no_more_levels_fit_pack")
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                    }
                    else {
                       [StoreInventory buyItemWithItemId:JELLY_MANIACS_10LEVELS_PACK_ITEM_ID andPayload:@"buy 10 extra levels"]; 
                    }
                    
                   
                }
                else {
                    //cannot buy more, not available
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                    message:NSLocalizedString(@"have_all_levels", @"have_all_levels")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                }
                
                break;
            //buy 25 levels
            case 3:
                
                purchasedLevels = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
                //do we already have the 100 available?
                if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
                    //if not buy
                    
                    //need to have at least 25 available to be able to buy this pack
                    if(NUM_AVAILABLE_LEVELS - purchasedLevels < 25) {
                        //cannot buy more, not available
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                        message:NSLocalizedString(@"no_more_levels_fit_pack", @"no_more_levels_fit_pack")
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                    }
                    else {
                       [StoreInventory buyItemWithItemId:JELLY_MANIACS_25LEVELS_PACK_ITEM_ID andPayload:@"buy 25 extra levels"];
                    }
                    
                    
                    
                }
                else {
                    //cannot buy more, not available
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_more_levels", @"no_more_levels")
                                                                    message:NSLocalizedString(@"have_all_levels", @"have_all_levels")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                }
                
                break;

            default:
                break;
                
        }
        
    }
    
    
    
}

- (void)curBalanceChanged:(NSNotification*)notification{
    //NSLog(@"called curBalanceChanged");
    NSDictionary* userInfo = [notification userInfo];
    balance = [(NSNumber*)[userInfo objectForKey:DICT_ELEMENT_BALANCE] intValue];
    currencyBalanceLabel = [NSString stringWithFormat:@"%d", balance];
    [self refreshTable];
}

- (void)goodBalanceChanged:(NSNotification*)notification{
    NSLog(@"called goodBalanceChanged");
    [self refreshTable];
}

- (void)itemPurchased:(NSNotification*)notification{
    //NSLog(@"called itemPurchased");
    NSDictionary* userInfo = [notification userInfo];
    PurchasableVirtualItem *item = [userInfo objectForKey:DICT_ELEMENT_PURCHASABLE];
    NSLog(@"item purchased: %@ - %@",item.itemId,item.description);
    
    if([item.itemId rangeOfString:@"_item_id"].location != NSNotFound) {
        
        [[self getMainController] notifyBoosterItemPurchase:item.itemId];
    }
    
    [self refreshTable];
    
}

/**
 * Here we update the settings for the items purchased from market
 */
 
- (void) marketItemPurchased:(NSNotification*)notification{

    //NSLog(@"called marketItemPurchased");
    NSDictionary* userInfo = [notification userInfo];
    PurchasableVirtualItem *item = [userInfo objectForKey:DICT_ELEMENT_PURCHASABLE];
    NSLog(@"market item purchased: %@ - %@",item.itemId,item.description);
    
    NSString * msg = [NSString stringWithFormat: @"%@ %@",NSLocalizedString(@"congratulations_purchased", @"congratulations_purchased"),
                      item.description ];
    [[[[iToast makeText:msg]
       setGravity:iToastGravityBottom] setDuration:2000] show];
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];;
    //did i just bought the 10 extra levels???
    //if so i need to update the settings
    if([item.itemId isEqualToString:JELLY_MANIACS_10LEVELS_PACK_ITEM_ID]) {

        NSInteger purchasedLevels = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
        //double check the limit
        if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
           purchasedLevels = purchasedLevels + 10;
        }
        
        //add the new 10 and save the settings
        [defaults setInteger: purchasedLevels forKey:NUM_PURCHASED_LEVELS_KEY];
      
    }
    //did i just bought the 25 extra levels???
    //if so i need to update the settings
    if([item.itemId isEqualToString:JELLY_MANIACS_25LEVELS_PACK_ITEM_ID]) {
        
        NSInteger purchasedLevels = [defaults integerForKey:NUM_PURCHASED_LEVELS_KEY];
        //double check the limit
        if(purchasedLevels < NUM_AVAILABLE_LEVELS) {
            purchasedLevels = purchasedLevels + 25;
        }
        
        //add the new 25 and save the settings
        [defaults setInteger: purchasedLevels forKey:NUM_PURCHASED_LEVELS_KEY];
        
    }
    else if([item.itemId isEqualToString:JELLY_MANIACS_10MOVES_PACK_ITEM_ID]) {
        
        NSInteger purchasedMoves = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
        purchasedMoves = purchasedMoves + 10;
        
        
        //add the new 10 and save the settings
        [defaults setInteger: purchasedMoves forKey:NUM_PURCHASED_MOVES_KEY];
        
    }
    else if([item.itemId isEqualToString:JELLY_MANIACS_5MOVES_PACK_ITEM_ID]) {
        
        NSInteger purchasedMoves = [defaults integerForKey:NUM_PURCHASED_MOVES_KEY];
        purchasedMoves = purchasedMoves + 5;
        //add the new 5 and save the settings
        [defaults setInteger: purchasedMoves forKey:NUM_PURCHASED_MOVES_KEY];
        //NSLog(@"setting purchased moves value to %ld",(long)purchasedMoves);
        
    }
    //notify the main view
    [[self getMainController] notifyMarketPurchase:item.itemId];
    
    
}

-(void) marketPurchaseCancelled:(NSNotification*)notification{
    
    //NSLog(@"called marketPurchaseCancelled");
    NSDictionary* userInfo = [notification userInfo];
    PurchasableVirtualItem *item = [userInfo objectForKey:DICT_ELEMENT_PURCHASABLE];
    NSLog(@"canceled market purchase of item : %@ - %@",item.itemId,item.description);
    //[self refreshTable];
}
/**
 *#define DICT_ELEMENT_BALANCE           @"balance"
 #define DICT_ELEMENT_CURRENCY          @"VirtualCurrency"
 #define DICT_ELEMENT_AMOUNT_ADDED      @"amountAdded"
 #define DICT_ELEMENT_GOOD              @"VirtualGood"
 #define DICT_ELEMENT_EquippableVG      @"EquippableVG"
 #define DICT_ELEMENT_UpgradeVG         @"UpgradeVG"
 #define DICT_ELEMENT_PURCHASABLE       @"PurchasableVirtualItem"
 #define DICT_ELEMENT_DEVELOPERPAYLOAD  @"DeveloperPayload"
 #define DICT_ELEMENT_RECEIPT           @"receipt"
 #define DICT_ELEMENT_TOKEN             @"token"
 #define DICT_ELEMENT_SUCCESS           @"success"
 #define DICT_ELEMENT_VERIFIED          @"verified"
 #define DICT_ELEMENT_TRANSACTION       @"transaction"
 #define DICT_ELEMENT_ERROR_CODE        @"error_code"
 #define DICT_ELEMENT_PRODUCTID         @"productId"
 #define DICT_ELEMENT_PRICE             @"price"
 #define DICT_ELEMENT_TITLE             @"title"
 #define DICT_ELEMENT_DESCRIPTION       @"description"
 #define DICT_ELEMENT_LOCALE            @"locale"
 #define DICT_ELEMENT_MARKET_ITEMS      @"marketItems"
 */


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.section == 1 && indexPath.row == 1) {
    //    return SPECIAL_HEIGHT;
    //}
    return 80.0;//NORMAL_HEIGHT;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    
    return [NSString stringWithFormat: @"%@: %d %@",NSLocalizedString(@"current_balance", @"current_balance"),
            balance,
            NSLocalizedString(@"jelly_stars", @"jelly_stars")];

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0;
}

/*
 
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
 // Create custom view to display section header...
UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
[label setFont:[UIFont boldSystemFontOfSize:12]];
NSString *string =[list objectAtIndex:section];
// Section header is in 0th index...
[label setText:string];
[view addSubview:label];
[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
//your background color...
return view;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
