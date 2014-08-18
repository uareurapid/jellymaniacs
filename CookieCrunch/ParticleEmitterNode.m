//
//  SmokeEmitterNode.m
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "ParticleEmitterNode.h"

@implementation ParticleEmitterNode

@synthesize particleCreationDate,timeToLive;
@synthesize particle;

-(id) initWithName: (NSString *) name andTimeToLive: (float) ttl andCreationDate: (CFTimeInterval) creationDate {
    if(self = [super init]) {
        
        NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
        particle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
        particle.name = name==nil ? @"particle" : name;
        particleCreationDate = creationDate;
        timeToLive = ttl;
    }
    
    
    return self;
}


/**
 * Check if is time to remove it
 */
-(BOOL) checkIfRemoveParticle:(CFTimeInterval ) actualTime {
    
    
    if(actualTime - particleCreationDate > timeToLive) {
        [particle removeFromParent];
        return true;
    }
    NSLog(@"actual time %f",actualTime);
    NSLog(@"particleCreationDate time %f",particleCreationDate);
    NSLog(@"timeToLive time %f",timeToLive);
    return false;
    
}

@end