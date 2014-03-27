//
//  CheckinViewController.h
//  Onrange
//
//  Created by Thiago Castro on 24/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Local.h"
#import "QBFlatButton.h"
#import <MapKit/MapKit.h>

@interface CheckinViewController : UIViewController

@property (weak, nonatomic) Local *local;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocal;
@property (strong, nonatomic) IBOutlet QBFlatButton *btnCheckin;
- (IBAction)btnCheckin:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapLocal;

@end
