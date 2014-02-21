//
//  HomeViewController.m
//  Pubsee
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return YES;
}

#pragma mark - Helper methods
/*
 * Configure the logged in versus logged out UX
 */
- (void)sessionStateChanged:(NSNotification*)notification {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else {
        [self performSegueWithIdentifier:@"SegueToLogin" sender:self];
    }
}

- (void)populateUserDetails {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {
        self.userNameLabel.text = user.name;
        self.userProfilePictureView.profileID = [user objectForKey:@"id"];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
    return [self initWithProfileID:nil];
}

-(id)initWithProfileID:(NSString *)profileID {
    self = [super init];
    if (self) {
        self.profileID = profileID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"logado");
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (FBSession.activeSession.isOpen ||
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded ||
        FBSession.activeSession.state == FBSessionStateCreatedOpening) {
    } else {
        [self performSegueWithIdentifier:@"SegueToLogin" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
