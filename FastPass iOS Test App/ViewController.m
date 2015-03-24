
//
//  ViewController.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "ViewController.h"
#import "NSDictionary+QueryString.h"

#import <GSFastPass/GSFastPass.h>
#import <PixateFreestyle/PixateFreestyle.h>

static NSString *const kOAuthProtocol = @"https";
static NSString *const kOAuthHost = @"dev.gsfn.us";
static NSString *const kOAuthConsumerKey = @"hssewhwk32i1";
static NSString *const kOAuthConsumerSecret = @"97ffsfe2ryqspj1ye345li6g3x3eu0ua";

@interface ViewController ()

@end

@implementation ViewController {
    UITextField *communityTextField;
    UITextField *emailTextField;
    UITextField *nameTextField;
    UITextField *uidTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int randomNumber = arc4random() % 9000000 + 1000000;
    
    NSDictionary *parameters = @{
        @"community": @"fastpass-enabled",
        @"email": [NSString stringWithFormat:@"qa%d@getsatisfaction.com", randomNumber],
        @"name": [NSString stringWithFormat:@"qa%d", randomNumber],
        @"uid": [NSString stringWithFormat:@"qa%d", randomNumber]
    };
    
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
    [button setStyleId:@"submit-button"];
    [button setTitle:@"Launch Community" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openCommunityInBrowser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)openCommunityInBrowser:(id)sender {
    GSFastPass *fastPass = [[GSFastPass alloc] initWithHost:kOAuthHost protocol:kOAuthProtocol consumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret];
    
    NSURL *communityFastPassURL = [fastPass loginUrlForCommunity:[communityTextField text] email:[emailTextField text] name:[nameTextField text] uid:[uidTextField text]];
    
    [[UIApplication sharedApplication] openURL:communityFastPassURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
