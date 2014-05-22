//
//  CheckinViewController.h
//  Onrange
//
//  Created by Thiago Castro on 24/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Local.h"
#import "PointLocais.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PerfilLocalViewController : UIViewController

@property (strong, nonatomic) PointLocais *annotation;
@property (strong, nonatomic) Local *local;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocal;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckin;
- (IBAction)btnCheckin:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapLocal;
- (IBAction)btnUsuariosNoLocal:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnUsuariosNoLocal;
@property (strong, nonatomic) IBOutlet UIView *viewCabecalho;

@end