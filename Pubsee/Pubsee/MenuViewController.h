//
//  MenuViewController.h
//  Onrange
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SlideNavigationController.h"

@interface MenuViewController : UITableViewController

@property (strong, nonatomic) NSString *profileID;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;


@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfilePictureView;

- (IBAction)logoutButtonClicked:(UIButton *)sender;
- (IBAction)settingsButtonClicked:(UIButton *)sender;
- (IBAction)inicioButtonClicked:(UIButton *)sender;

-(void)sessionStateChanged:(NSNotification*)notification;
-(void)populateUserDetails;

@end