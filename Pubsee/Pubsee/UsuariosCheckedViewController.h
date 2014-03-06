//
//  UsuariosCheckedViewController.h
//  Pubsee
//
//  Created by Thiago Castro on 05/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "UsuarioFotoCollectionCell.h"
#import "PointLocais.h"
#import "Local.h"

@interface UsuariosCheckedViewController : UICollectionViewController

@property (strong, nonatomic) NSString *profileID;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;
@property (strong, nonatomic) PointLocais *annotation;
@property (strong, nonatomic) Local *local;

@end