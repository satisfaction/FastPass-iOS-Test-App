//
//  GSFastPass.h
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/22/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSFastPass : NSObject

- (instancetype)initWithHost:(NSString *)host
                    protocol:(NSString *)protocol
                 consumerKey:(NSString *)consumerKey
              consumerSecret:(NSString *)consumerSecret;

- (NSURL *)loginUrlForCommunity:(NSString *)community email:(NSString *)email name:(NSString *)name uid:(NSString *)uid;

@end
