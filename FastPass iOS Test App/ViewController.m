//
//  ViewController.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "ViewController.h"
#import "NSDictionary+QueryString.h"

#import <BDBOAuth1Manager/BDBOAuth1RequestOperationManager.h>
#import <BDBOAuth1Manager/NSString+BDBOAuth1Manager.h>
#import <PixateFreestyle/PixateFreestyle.h>

static NSString *const kOAuthScheme = @"https";
static NSString *const kOAuthHost = @"dev.gsfn.us";
static NSString *const kOAuthConsumerKey = @"hssewhwk32i1";
static NSString *const kOAuthConsumerSecret = @"97ffsfe2ryqspj1ye345li6g3x3eu0ua";

@interface BDBOAuth1RequestSerializer ()

- (NSString *)OAuthSignatureForMethod:(NSString *)method
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                                error:(NSError *__autoreleasing *)error;

- (NSString *)OAuthAuthorizationHeaderForMethod:(NSString *)method
                                      URLString:(NSString *)URLString
                                     parameters:(NSDictionary *)parameters
                                          error:(NSError *__autoreleasing *)error;

@end

@interface ViewController ()

@end

@implementation ViewController {
    UITextField *communityTextField;
    UITextField *emailTextField;
    UITextField *nameTextField;
    UITextField *uidTextField;
    
    NSURL *baseURL;
    NSMutableDictionary *parameters;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int randomNumber = arc4random() % 9000 + 1000;
    
    baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", kOAuthScheme, kOAuthHost]];
    parameters = [@{
                  @"community": @"fastpass-enabled",
                  @"email": [NSString stringWithFormat:@"qa%d@getsatisfaction.com", randomNumber],
                  @"name": [NSString stringWithFormat:@"qa%d", randomNumber],
                  @"uid": [NSString stringWithFormat:@"qa%d", randomNumber]
                  } mutableCopy];
    
    UIImage *logo = [UIImage imageNamed:@"get-satisfaction.png"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
    [logoView setStyleId:@"logo"];
    [self.view addSubview:logoView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setStyleId:@"label-title"];
    [titleLabel setText:@"iOS Fastpass Tester"];
    [self.view addSubview:titleLabel];
    
    UIView *formContainer = [[UIView alloc] init];
    [formContainer setStyleId:@"container"];
    [self.view addSubview:formContainer];
    
    communityTextField = [[UITextField alloc] init];
    [communityTextField setStyleId:@"input-community"];
    [communityTextField setPlaceholder:@"Community"];
    [communityTextField setText:[parameters objectForKey:@"community"]];
    [self.view addSubview:communityTextField];
    
    emailTextField = [[UITextField alloc] init];
    [emailTextField setStyleId:@"input-email"];
    [emailTextField setPlaceholder:@"E-mail Address"];
    [emailTextField setText:[parameters objectForKey:@"email"]];
    [self.view addSubview:emailTextField];
    
    nameTextField = [[UITextField alloc] init];
    [nameTextField setStyleId:@"input-name"];
    [nameTextField setPlaceholder:@"User Name"];
    [nameTextField setText:[parameters objectForKey:@"name"]];
    [self.view addSubview:nameTextField];
    
    uidTextField = [[UITextField alloc] init];
    [uidTextField setStyleId:@"input-uid"];
    [uidTextField setPlaceholder:@"User ID"];
    [uidTextField setText:[parameters objectForKey:@"uid"]];
    [self.view addSubview:uidTextField];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(openCommunityInBrowser:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Launch Community" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
}

- (void)openCommunityInBrowser:(id)sender {
    NSURL *fastpassUrl = [self fastPassUrlForCommunity];
    NSString *communityUrlWithFastpass = [NSString stringWithFormat:@"%@://%@/%@?fastpass=%@", kOAuthScheme, kOAuthHost, [parameters objectForKey:@"community"], [[fastpassUrl absoluteString] bdb_URLEncode]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:communityUrlWithFastpass]];
}

- (NSURL *)fastPassUrlForCommunity {
    
    BDBOAuth1RequestOperationManager *manager = [[BDBOAuth1RequestOperationManager alloc] initWithBaseURL:baseURL consumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret];
    
    NSString *header = [manager.requestSerializer OAuthAuthorizationHeaderForMethod:@"GET" URLString:[[NSURL URLWithString:@"/fastpass" relativeToURL:baseURL] absoluteString] parameters:parameters error:nil];
    
    NSString *authorizationHeader = [[header stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    
    NSMutableDictionary *authorizationKeyValuePairs = [[NSMutableDictionary alloc] init];
    
    for (NSString *authorizationHeaderValue in [authorizationHeader componentsSeparatedByString:@", "]) {
        NSArray *keyValuePair = [authorizationHeaderValue componentsSeparatedByString:@"="];
        [authorizationKeyValuePairs setObject:[keyValuePair objectAtIndex:1] forKey:[keyValuePair objectAtIndex:0]];
    }
    
    [authorizationKeyValuePairs addEntriesFromDictionary:parameters];
    
    NSURL *fastpassURL = [[NSURL URLWithString:[NSString stringWithFormat:@"/fastpass?%@", [authorizationKeyValuePairs queryStringRepresentation]] relativeToURL:baseURL] absoluteURL];
    
    return fastpassURL;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
