//
//  RWTCookie.m
//  CookieCrunch
//
//  Created by Paulo Cristo on 25-02-14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "PCJelly.h"

@implementation PCJelly

static NSString * const spriteNames[] = {
    @"blue_candy_anim_02",
    @"green_candy_anim_02",
    @"purple_candy_anim_02",
    @"red_candy_anim_02",
    @"yellow_candy_anim_02",
    @"dark_b_jelly_02",
};

static NSString * const spriteNamesAnim01[] = {
    @"blue_candy_anim_01",
    @"green_candy_anim_01",
    @"purple_candy_anim_01",
    @"red_candy_anim_01",
    @"yellow_candy_anim_01",
    @"dark_b_jelly_01",
};

static NSString * const spriteNamesAnim03[] = {
    @"blue_candy_anim_03",
    @"green_candy_anim_03",
    @"purple_candy_anim_03",
    @"red_candy_anim_03",
    @"yellow_candy_anim_03",
    @"dark_b_jelly_03",
};

static NSString * const highlightedSpriteNames[] = {
    @"blue_candy_anim_03",
    @"green_candy_anim_03",
    @"purple_candy_anim_03",
    @"red_candy_anim_03",
    @"yellow_candy_anim_03",
    @"dark_b_jelly_03",
};

- (NSString *)spriteName {
  
  return spriteNames[self.cookieType - 1];
}

- (NSString *)spriteNameAnim01 {
    
    
    
    return spriteNamesAnim01[self.cookieType - 1];
}

- (NSString *)spriteNameAnim03 {
    
    
    
    return spriteNamesAnim03[self.cookieType - 1];
}


- (NSString *)highlightedSpriteName {
  
    

  return highlightedSpriteNames[self.cookieType - 1];
}

- (NSString *)spriteNameForLabel: (NSString *) label {
    if([label isEqualToString:@"red"]) {
      return spriteNames[3];
    }
    else if([label isEqualToString:@"blue"]) {
        return spriteNames[0];
    }
    else if([label isEqualToString:@"green"]) {
        return spriteNames[1];
    }
    else if([label isEqualToString:@"yellow"]) {
        return spriteNames[4];
    }
    else if([label isEqualToString:@"dark"]) {
        return spriteNames[5];
    }
    else if([label isEqualToString:@"pink"]) {
        return spriteNames[2];
    }
    return spriteNames[0];
    
}
- (NSString *)spriteNameAnim01ForLabel: (NSString *) label{
    if([label isEqualToString:@"red"]) {
        return spriteNamesAnim01[3];
    }
    else if([label isEqualToString:@"blue"]) {
        return spriteNamesAnim01[0];
    }
    else if([label isEqualToString:@"green"]) {
        return spriteNamesAnim01[1];
    }
    else if([label isEqualToString:@"yellow"]) {
        return spriteNamesAnim01[4];
    }
    else if([label isEqualToString:@"dark"]) {
        return spriteNamesAnim01[5];
    }
    else if([label isEqualToString:@"pink"]) {
        return spriteNamesAnim01[2];
    }
    return spriteNamesAnim01[0];
}//first anim
- (NSString *)spriteNameAnim03ForLabel: (NSString *) label {
    
    if([label isEqualToString:@"red"]) {
        return spriteNamesAnim03[3];
    }
    else if([label isEqualToString:@"blue"]) {
        return spriteNamesAnim03[0];
    }
    else if([label isEqualToString:@"green"]) {
        return spriteNamesAnim03[1];
    }
    else if([label isEqualToString:@"yellow"]) {
        return spriteNamesAnim03[4];
    }
    else if([label isEqualToString:@"dark"]) {
        return spriteNamesAnim03[5];
    }
    else if([label isEqualToString:@"pink"]) {
        return spriteNamesAnim03[2];
    }
    return spriteNamesAnim03[0];
}//3rd anim

- (NSString *)description {
  return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}

@end
