//
//  PromoCaixaEntradaTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStatusBarNotification.h"

@interface PromoCaixaEntradaTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *lblResumo;
@property (strong, nonatomic) CWStatusBarNotification *notification;
@property (assign, nonatomic) NSInteger status;

@end
