//
//  AppDelegate.h
//  Onrange
//
//  Created by Thiago Castro on 16/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LocaisTableViewController.h"


@class HomeViewController;
@class MenuViewController;

extern NSString *const FBSessionStateChangedNotification;

typedef void(^UserDataLoadedHandler)(id sender, id<FBGraphUser> user);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>{
    HomeViewController *homeVC;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSURL *openedURL;
@property (strong, nonatomic) id<FBGraphUser> user;
@property (strong, nonatomic) MenuViewController *menu;


@property (strong, nonatomic) NSString *valida_sexo;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;
- (void)requestUserData:(UserDataLoadedHandler)handler;
    
@end
