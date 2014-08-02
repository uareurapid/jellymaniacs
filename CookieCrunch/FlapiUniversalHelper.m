//
//  FlapiUniversalHelper.m
//  Flapi
//
//  Created by Paulo Cristo on 22/03/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "FlapiUniversalHelper.h"

@implementation FlapiUniversalHelper

+(NSString*) myImageFilename:(NSString*)baseName  { //withExtension:(NSString*)ext
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"%@@2x~ipad.png", baseName];
    } else {
        return baseName;//[NSString stringWithFormat:@"%@.png", baseName];
    }
    
}

+(NSString*) myImageFilename:(NSString*)baseName andExtension:(NSString *)ext {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"%@@2x~ipad.%@", baseName,ext];
    } else {
        return [NSString stringWithFormat:@"%@.%@", baseName,ext];
    }
}

@end
