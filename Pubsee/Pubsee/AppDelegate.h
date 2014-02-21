//
//  AppDelegate.h
//  Pubsee
//
//  Created by Thiago Castro on 16/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HomeViewController.h"
#import "MenuViewController.h"


@class HomeViewController;

extern NSString *const FBSessionStateChangedNotification;
extern NSString *const FBMenuDataChangedNotification;

typedef void(^UserDataLoadedHandler)(id sender, id<FBGraphUser> user);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<FBGraphUser> user;
@property (strong, nonatomic) NSURL *openedURL;
@property (strong, nonatomic) HomeViewController *home;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;
- (void)requestUserData:(UserDataLoadedHandler)handler;

@end
