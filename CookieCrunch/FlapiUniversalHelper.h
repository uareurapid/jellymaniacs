//
//  FlapiUniversalHelper.h
//  Flapi
//
//  Created by Paulo Cristo on 22/03/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlapiUniversalHelper : NSObject

+(NSString*) myImageFilename:(NSString*)baseName;
+(NSString*) myImageFilename:(NSString*)baseName andExtension:(NSString *)ext;

@end
