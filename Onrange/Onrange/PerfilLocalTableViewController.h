//
//  PerfilLocalTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 22/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Local.h"
#import "PointLocais.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PerfilLocalTableViewController : UITableViewController<UIScrollViewDelegate>

@property (strong, nonatomic) PointLocais *annotation;
@property (strong, nonatomic) Local *local;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocal;
@property (strong, nonatomic) IBOutlet MKMapView *mapLocal;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckin;
- (IBAction)btnCheckin:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblDestaque;
@property (strong, nonatomic) IBOutlet UIImageView *imgStar;

@end
