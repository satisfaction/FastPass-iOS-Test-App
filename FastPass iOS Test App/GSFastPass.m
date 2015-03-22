//
//  GSFastPass.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/22/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "GSFastPass.h"

#import <BDBOAuth1Manager/BDBOAuth1RequestOperationManager.h>
#import <BDBOAuth1Manager/NSString+BDBOAuth1Manager.h>

@interface BDBOAuth1RequestSerializer ()

- (NSString *)OAuthAuthorizationHeaderForMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;

@end

@implementation GSFastPass {
    NSURL *baseURL;
    BDBOAuth1RequestSerializer *requestSerializer;
}

- (instancetype)initWithHost:(NSString *)host protocol:(NSString *)protocol consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
   
    self = [super init];
    
    if (self) {
        baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", protocol, host]];
        requestSerializer = [[BDBOAuth1RequestOperationManager alloc] initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret].requestSerializer;
        
        return self;
    }
    
    return nil;
}

- (NSURL *)loginUrlForCommunity:(NSString *)community email:(NSString *)email name:(NSString *)name uid:(NSString *)uid {
    NSURL *callbackURL = [self callbackURLForEmail:email name:name uid:uid];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?fastpass=%@", [baseURL absoluteString], community, [[callbackURL absoluteString] bdb_URLEncode]]];
}

- (NSURL *)callbackURLForEmail:(NSString *)email name:(NSString *)name uid:(NSString *)uid {

    NSDictionary *parameters = @{
        @"email": email,
        @"name": name,
        @"uid": uid
    };

    NSURL *fastPassURL = [NSURL URLWithString:@"/fastpass" relativeToURL:baseURL];
    NSString *authorizationQuery = [self authorizationQueryForURL:fastPassURL parameters:parameters];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [fastPassURL absoluteString], authorizationQuery]];
}

- (NSDictionary *)authorizationDataForURL:(NSURL *)url parameters:(NSDictionary *)parameters {
    NSString *headers = [self cleanupHeaders:[requestSerializer OAuthAuthorizationHeaderForMethod:@"GET" URLString:[url absoluteString] parameters:parameters error:nil]];
    
    NSMutableDictionary *authorizationData = [[NSMutableDictionary alloc] init];
    
    NSArray *headerPair;
    
    for (NSString *rawHeaderPair in [headers componentsSeparatedByString:@", "]) {
        headerPair = [rawHeaderPair componentsSeparatedByString:@"="];
        
        [authorizationData setObject:[headerPair objectAtIndex:1] forKey:[headerPair objectAtIndex:0]];
    }
    
    [authorizationData addEntriesFromDictionary:parameters];
    
    return authorizationData;
}

- (NSString *)authorizationQueryForURL:(NSURL *)url parameters:(NSDictionary *)parameters {
    NSDictionary *authorizationData = [self authorizationDataForURL:url parameters:parameters];
    
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [authorizationData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
        [parameterArray addObject:param];
    }];
    
    return [parameterArray componentsJoinedByString:@"&"];
}

- (NSString *)cleanupHeaders:(NSString *)headers {
    NSMutableString *mutableHeaders = [headers mutableCopy];
    
    [mutableHeaders replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableHeaders length])];
    
    [mutableHeaders replaceOccurrencesOfString:@"OAuth " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableHeaders length])];
    
    return mutableHeaders;
}

@end
