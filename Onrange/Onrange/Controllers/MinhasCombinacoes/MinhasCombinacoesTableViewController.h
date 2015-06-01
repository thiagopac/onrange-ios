//
//  MinhasCombinacoesTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 14/07/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "Usuario.h"
#import "CWStatusBarNotification/CWStatusBarNotification.h"

@interface MinhasCombinacoesTableViewController : UITableViewController<QBChatDelegate>

@property (strong, nonatomic) HomeViewController *HomeViewController;
@property (strong, nonatomic) CWStatusBarNotification *notification;
@property (strong, nonatomic) QBChatDialog *createdDialog;
@property (strong, nonatomic) NSString *QBUser;
@property (strong, nonatomic) NSString *QBPassword;
@property (strong, nonatomic) Usuario *usuario;

@end
