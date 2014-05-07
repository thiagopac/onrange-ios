//
//  UsuariosCheckedViewController.h
//  Onrange
//
//  Created by Thiago Castro on 05/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "UsuarioFotoCollectionCell.h"
#import "UsuariosCheckinHeaderView.h"
#import "Local.h"
#import "QBFlatButton.h"
#import "CWStatusBarNotification.h"

@interface UsuariosCheckedViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) PointLocais *annotation;
@property (strong, nonatomic) NSString *profileID;
@property (strong, nonatomic) CWStatusBarNotification *notification;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;
@property (weak, nonatomic) Local *local;
- (IBAction)btCheckinLocal:(id)sender;

@end