//
//  FlipsideViewController.m
//  Around Me
//
//  Created by Jean-Pierre Distler on 30.01.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "RealidadeAumentada.h"
#import "Local.h"
#import "MarkerView.h"
#import "PerfilLocalTableViewController.h"

NSString * const kPhoneKey = @"formatted_phone_number";
NSString * const kWebsiteKey = @"website";

const int kInfoViewTag = 1001;

@interface RealidadeAumentada () <MarkerViewDelegate>{
    Local *localSelecionado;
}

@property (nonatomic, strong) AugmentedRealityController *arController;
@property (nonatomic, strong) NSMutableArray *geoLocations;

@end

@implementation RealidadeAumentada

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    if(!_arController) {
        _arController = [[AugmentedRealityController alloc] initWithView:[self view] parentViewController:self withDelgate:self];
    }
    
    [_arController setMinimumScaleFactor:0.5];
    [_arController setScaleViewsBasedOnDistance:YES];
    [_arController setRotateViewsBasedOnPerspective:YES];
    [_arController setDebugMode:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self geoLocations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)generateGeoLocations {
	//1
	[self setGeoLocations:[NSMutableArray arrayWithCapacity:[_locations count]]];
    
	//2
	for(Local *local in _locations) {
		//3
		ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:[local location] locationTitle:[local nome] qtCheckin:[local qt_checkin] andTipoLocal:[local tipo_local]];
		//4
		[coordinate calibrateUsingOrigin:[_userLocation location]];
        
		MarkerView *markerView = [[MarkerView alloc] initWithCoordinate:coordinate delegate:self];
        [coordinate setDisplayView:markerView];
        
		//5
		[_arController addCoordinate:coordinate];
		[_geoLocations addObject:coordinate];
	}
}

- (void)didTapMarker:(ARGeoCoordinate *)coordinate {
}

- (NSMutableArray *)geoLocations {
	if(!_geoLocations) {
		[self generateGeoLocations];
	}
	return _geoLocations;
}

-(void)didUpdateHeading:(CLHeading *)newHeading {
    
}

-(void)didUpdateLocation:(CLLocation *)newLocation {
    
}

-(void)didUpdateOrientation:(UIDeviceOrientation)orientation {
    
}

- (void)didTouchMarkerView:(MarkerView *)markerView {
	//1
	ARGeoCoordinate *tappedCoordinate = [markerView coordinate];
	CLLocation *location = [tappedCoordinate geoLocation];
    
	//2
	int index = [_locations indexOfObjectPassingTest:^(id obj, NSUInteger index, BOOL *stop) {
		return [[(Local *)obj location] isEqual:location];
	}];
    
	//3
	if(index != NSNotFound) {
		//4
		localSelecionado = [_locations objectAtIndex:index];
        [self performSegueWithIdentifier:@"ARperfilLocalSegue" sender:self];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ARperfilLocalSegue"]) {
        PerfilLocalTableViewController *perfilLocalTVC = [segue destinationViewController];
        perfilLocalTVC.local = localSelecionado;
        
    }
}

@end
