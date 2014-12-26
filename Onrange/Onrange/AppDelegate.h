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
extern NSString *const FBMenuDataChangedNotification;

typedef void(^UserDataLoadedHandler)(id sender, id<FBGraphUser> user);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>{
    HomeViewController *homeVC;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSURL *openedURL;
@property (strong, nonatomic) id<FBGraphUser> user;
@property (strong, nonatomic) MenuViewController *menu;
@property (assign, nonatomic) NSInteger status;

//usuário na base
@property (strong, nonatomic) NSString *nome_usuario;
@property (strong, nonatomic) NSString *sexo_usuario;
@property (strong, nonatomic) NSString *facebook_usuario;
@property (strong, nonatomic) NSString *email_usuario;
@property (strong, nonatomic) NSString *valida_sexo;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;
- (void)requestUserData:(UserDataLoadedHandler)handler;

@end
