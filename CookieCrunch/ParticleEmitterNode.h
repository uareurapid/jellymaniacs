//
//  SmokeEmitterNode.h
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ParticleEmitterNode: NSObject

@property CFTimeInterval particleCreationDate;
@property float timeToLive;
@property (strong,nonatomic) SKEmitterNode *particle;
-(id) initWithName: (NSString *) name andTimeToLive: (float) ttl andCreationDate: (CFTimeInterval) creationDate;
-(BOOL) checkIfRemoveParticle:(CFTimeInterval ) actualTime;
@end
