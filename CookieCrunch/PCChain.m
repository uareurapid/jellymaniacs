
#import "PCChain.h"

@implementation PCChain {
  NSMutableArray *_cookies;
}

//ads a new cookie to the chain
//can be horizontal-row/vertical-collumn or L and T shapes
- (void)addCookie:(PCJelly *)cookie {
  if (_cookies == nil) {
    _cookies = [NSMutableArray array];
  }
  [_cookies addObject:cookie];
}

- (NSArray *)cookies {
  return _cookies;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"type:%ld cookies:%@", (long)self.chainType, self.cookies];
}

@end
