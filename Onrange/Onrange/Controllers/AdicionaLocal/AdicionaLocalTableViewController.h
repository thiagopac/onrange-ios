//
//  AdicionaLocalTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 06/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ControleTeclado.h"

@interface AdicionaLocalTableViewController : UITableViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITextField *txtNomeLocal;
@property (strong, nonatomic) IBOutlet MKMapView *mapLocal;
@property (strong, nonatomic) IBOutlet UIButton *btnConfirmar;
@property (assign, nonatomic) int tipoLocal;
@property (strong, nonatomic) IBOutlet UILabel *lblCategoria;
@property (strong, nonatomic) NSString *nomeCategoria;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (nonatomic, strong) ControleTeclado *controleTeclado;
@property (assign, nonatomic) NSInteger status;

@end