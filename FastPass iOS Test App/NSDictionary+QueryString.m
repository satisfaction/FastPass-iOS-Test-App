//
//  NSDictionary+QueryString.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "NSDictionary+QueryString.h"

@implementation NSDictionary (QueryString)

- (NSString *)queryStringRepresentation {
    NSMutableArray *queryComponents = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *parameter = [NSString stringWithFormat:@"%@=%@", key, obj];
        [queryComponents addObject:parameter];
    }];
    
    return [queryComponents componentsJoinedByString:@"&"];
}

@end
