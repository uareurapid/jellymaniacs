//
//  Constants.h
//  JellyCrush
//
//  Created by Paulo Cristo on 01/08/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#ifndef JellyCrush_Constants_h
#define JellyCrush_Constants_h

//total available
#define NUM_AVAILABLE_LEVELS 100
//total purchased (in default installation is 50)
#define NUM_PURCHASED_LEVELS 50
//define number of purchased moves
//this will increment by 5 or 10
#define NUM_PURCHASED_MOVES 0

//i can only play this 10 without share to twitter
//otherwise i need to wait 3 minutes
#define MAX_PLAYS_WITHOUT_SHARE 10

//max times i can share to facebook and wind 500 stars
#define MAX_FACEBOOK_SHARES 3

#define TARGET_INCREASE_BY_LEVEL 20

#define EXTRA_MOVE_BONUS_LEVEL 20

#define NUM_PURCHASED_MOVES_KEY     @"NUM_PURCHASED_MOVES_KEY"
#define NUM_AVAILABLE_LEVELS_KEY    @"NUM_AVAILABLE_LEVELS_KEY"
#define NUM_PURCHASED_LEVELS_KEY    @"NUM_PURCHASED_LEVELS_KEY"
#define NUM_JELLY_PLAYS_KEY         @"NUM_JELLY_PLAYS_KEY"
#define LAST_SAVE_KEY               @"LAST_SAVE_KEY"
#define SHARED_TWITTER_KEY          @"SHARED_TWITTER_KEY"
#define SHARED_FACEBOOK_KEY         @"SHARED_FACEBOOK_KEY"

#define LEVEL_20_BONUS_KEY          @"LEVEL_20_BONUS_KEY"

#define JELLY_MANIACS_LEADERBOARD                   @"jelly_maniacs_leaderboard"
#define JELLY_MANIACS_REACH_LEVEL_50_ACHIEVEMENT    @"jelly_maniacs_level50_achievement"
#define JELLY_MANIACS_REACH_LEVEL_100_ACHIEVEMENT   @"jelly_maniacs_level100_achievement"

//applovin key
//r1p6n7_2ZCyP6V4tANBKvL4oM4mkbSkRUWXGeWICiEbqkghu2tDyDHlZLUIyy0NQXwgAQ-M8CzyxedqgV1diJM

#endif
