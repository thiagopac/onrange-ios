//
//  HomeViewController.h
//  Onrange
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import <SlideNavigationController.h>
#import "Local.h"
#import "Promo.h"

#import "PointLocais.h"

@interface HomeViewController : UIViewController<CLLocationManagerDelegate, QBChatDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapGlobal;
@property (strong, nonatomic) NSString *profileID;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;
@property (strong, nonatomic) Local *local;
@property (strong, nonatomic) Promo *promo;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *btnMe;
@property (strong, nonatomic) IBOutlet UIButton *btnMatches;
@property (assign, nonatomic) NSInteger status;
- (IBAction)btnMatches:(id)sender;

- (IBAction)btnMe:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnOnrangeClub;
- (IBAction)btnOnrangeClub:(UIButton *)sender;

- (void) recebeNotificacao:(NSNotification *)notification;

@end