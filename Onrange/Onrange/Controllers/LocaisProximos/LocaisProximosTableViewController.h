//
//  LocaisProximosTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 23/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CWStatusBarNotification.h"

@interface LocaisProximosTableViewController : UITableViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CWStatusBarNotification *notification;
@property (assign, nonatomic) NSInteger status;
@property (strong, nonatomic) IBOutlet UIButton *btnTentarNovamente;
- (IBAction)btnTentarNovamente:(id)sender;

@end