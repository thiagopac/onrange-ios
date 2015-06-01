//
//  LocationPermissionView.m
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import "LocationPermissionView.h"



@implementation LocationPermissionView


- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(habilitaBotao) name:@"vinculouFacebook" object:nil];
    
    [self.btnLocationPermission setTitle:@"Faça antes login com Facebook" forState:UIControlStateNormal];
    [self.btnLocationPermission setBackgroundColor:[UIColor grayColor]];
    [self.btnLocationPermission setUserInteractionEnabled:NO];
}

-(void)habilitaBotao{
    [self.btnLocationPermission setTitle:@"Ok! Pode usar minha localização!" forState:UIControlStateNormal];
    [self.btnLocationPermission setBackgroundColor:[UIColor colorWithHexString:@"0A7CFF"]];
    [self.btnLocationPermission setUserInteractionEnabled:YES];
}

- (IBAction)btnLocationPermission:(id)sender {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingLocation];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"vinculouFacebook" object:nil];
}

@end
