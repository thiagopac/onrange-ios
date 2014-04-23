//
//  HomeViewController.m
//  Onrange
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "HomeViewController.h"
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"
#import "UsuariosCheckedViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController (){
    int raio;
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic, strong) NSMutableArray *arrLocais;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) id<MKAnnotation> selectedAnnotation;

@end

@implementation HomeViewController

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Erro" message:@"Não foi possível determinar sua localização" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"userLatitude"];
        
        [def setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"userLongitude"];
        
        [def synchronize];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKAnnotationView *userLocationView = [_mapGlobal viewForAnnotation:userLocation];
    userLocationView.canShowCallout = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

#pragma mark - Helper methods
/*
 * Configure the logged in versus logged out UX
 */
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else {
        [self performSegueWithIdentifier:@"SegueToLogin" sender:self];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)btnMe:(UIButton *)sender {
}

-(id)init {
    return [self initWithProfileID:nil];
}

-(id)initWithProfileID:(NSString *)profileID {
    self = [super init];
    if (self) {
        self.profileID = profileID;
    }
    return self;
}

-(void)buscarLocalizacao{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 2000.00;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }

    [self.locationManager startUpdatingLocation];
}

- (void)populateUserDetails {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {

    }];
}

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    latitude = [def objectForKey:@"userLatitude"];
    longitude = [def objectForKey:@"userLongitude"];
    raio = [def integerForKey:@"userRange"];
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Locais" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/%d/checkin",API,latitude,longitude,raio]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];
        [self montarMapaWithArray:self.arrLocais];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro ao carregar locais",nil));
    }];
    
    [operation start];
}

-(void)montarMapaWithArray:(NSArray *)locais {

    NSMutableArray *annotations = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[locais count]; i++) {
        
        Local *local = [locais objectAtIndex:i];
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [local.latitude doubleValue];
        theCoordinate.longitude = [local.longitude doubleValue];
        
        PointLocais *myAnnotation = [[PointLocais alloc]init];
        myAnnotation.latitude = local.latitude;
        myAnnotation.longitude = local.longitude;
        myAnnotation.id_local = local.id_local;
        myAnnotation.qt_checkin = local.qt_checkin;
        myAnnotation.tipo_local = local.tipo_local;
        myAnnotation.coordinate = theCoordinate;
        myAnnotation.title = [NSString stringWithFormat:@"%@",local.nome];
        [_mapGlobal addAnnotation:myAnnotation];
        [annotations addObject:myAnnotation];
        
        MKMapRect flyTo = MKMapRectNull;
        for (id <MKAnnotation> annotation in annotations) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
            if (MKMapRectIsNull(flyTo)) {
                flyTo = pointRect;
            } else {
                flyTo = MKMapRectUnion(flyTo, pointRect);
            }
        }
        _mapGlobal.visibleMapRect = flyTo;
    }
    
}

-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"Foi minimizado");
    [self.locationManager stopUpdatingLocation];
}
-(void)appWillTerminate:(NSNotification*)note
{
    NSLog(@"Foi fechado");
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidBecomeActive:(NSNotification*)note
{
    NSLog(@"Foi aberto");
    [self.locationManager startUpdatingLocation];
}


- (void)menuAbriu:(NSNotification *)notification {
    if([[SlideNavigationController sharedInstance] isMenuOpen]){
        _mapGlobal.scrollEnabled = NO;
    }else{
        _mapGlobal.scrollEnabled = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
    [self buscarLocalizacao];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];

    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.btnMe.layer.cornerRadius = 10;
    self.btnMe.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
    [_mapGlobal removeAnnotations:_mapGlobal.annotations];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaLocais];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    if (FBSession.activeSession.isOpen ||
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded ||
        FBSession.activeSession.state == FBSessionStateCreatedOpening) {
    } else {
        [self performSegueWithIdentifier:@"SegueToLogin" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Boilerplate pin annotation code
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapGlobal dequeueReusableAnnotationViewWithIdentifier: @"AnnotationIdentifier"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"AnnotationIdentifier"];
    } else {
        pin.annotation = annotation;
    }
    
    int checkins = [((PointLocais *)annotation).qt_checkin intValue];
    
    int annType = ((PointLocais *)annotation).tipo_local;
    
//    SIMULACAO COM PINS DE GRANDE NUMERO DE PESSOAS
//    switch (annType)
//    {
//        case 1 :   //Balada
//            if (checkins <2) {
//                pin.image = [UIImage imageNamed:@"pin-balada-1"];
//            }else if(checkins >= 2 && checkins <3){
//                pin.image = [UIImage imageNamed:@"pin-balada-2"];
//            }else if(checkins >= 3 && checkins <20){
//                pin.image = [UIImage imageNamed:@"pin-balada-3"];
//            }else if(checkins >= 20 && checkins <22){
//                pin.image = [UIImage imageNamed:@"pin-balada-4"];
//            }else if(checkins >= 22){
//                pin.image = [UIImage imageNamed:@"pin-balada-5"];
//            }
//            break;
//        case 2 :   //Bar
//            if (checkins <2) {
//                pin.image = [UIImage imageNamed:@"pin-bar-1"];
//            }else if(checkins >= 2 && checkins <3){
//                pin.image = [UIImage imageNamed:@"pin-bar-2"];
//            }else if(checkins >= 3 && checkins <20){
//                pin.image = [UIImage imageNamed:@"pin-bar-3"];
//            }else if(checkins >= 20 && checkins <22){
//                pin.image = [UIImage imageNamed:@"pin-bar-4"];
//            }else if(checkins >= 22){
//                pin.image = [UIImage imageNamed:@"pin-bar-5"];
//            }
//            break;
//        case 3 :   //Festa
//            if (checkins <2) {
//                pin.image = [UIImage imageNamed:@"pin-festa-1"];
//            }else if(checkins >= 2 && checkins <3){
//                pin.image = [UIImage imageNamed:@"pin-festa-2"];
//            }else if(checkins >= 3 && checkins <20){
//                pin.image = [UIImage imageNamed:@"pin-festa-3"];
//            }else if(checkins >= 20 && checkins <22){
//                pin.image = [UIImage imageNamed:@"pin-festa-4"];
//            }else if(checkins >= 22){
//                pin.image = [UIImage imageNamed:@"pin-festa-5"];
//            }
//            break;
//        case 4 :   //Local público
//            if (checkins <2) {
//                pin.image = [UIImage imageNamed:@"pin-publicos-1"];
//            }else if(checkins >= 2 && checkins <3){
//                pin.image = [UIImage imageNamed:@"pin-publicos-2"];
//            }else if(checkins >= 3 && checkins <20){
//                pin.image = [UIImage imageNamed:@"pin-publicos-3"];
//            }else if(checkins >= 20 && checkins <22){
//                pin.image = [UIImage imageNamed:@"pin-publicos-4"];
//            }else if(checkins >= 22){
//                pin.image = [UIImage imageNamed:@"pin-publicos-5"];
//            }
//            break;
//        default :
//            NSLog(@"Local não compatível com tipos de local cadastrados");
//    }
    
    switch (annType)
    {
        case 1 :   //Balada
            if (checkins <10) {
                pin.image = [UIImage imageNamed:@"pin-balada-1"];
            }else if(checkins >= 10 && checkins <30){
                pin.image = [UIImage imageNamed:@"pin-balada-2"];
            }else if(checkins >= 30 && checkins <50){
                pin.image = [UIImage imageNamed:@"pin-balada-3"];
            }else if(checkins >= 50 && checkins <99){
                pin.image = [UIImage imageNamed:@"pin-balada-4"];
            }else if(checkins >= 99){
                pin.image = [UIImage imageNamed:@"pin-balada-5"];
            }
            break;
        case 2 :   //Bar
            if (checkins <10) {
                pin.image = [UIImage imageNamed:@"pin-bar-1"];
            }else if(checkins >= 10 && checkins <30){
                pin.image = [UIImage imageNamed:@"pin-bar-2"];
            }else if(checkins >= 30 && checkins <50){
                pin.image = [UIImage imageNamed:@"pin-bar-3"];
            }else if(checkins >= 50 && checkins <99){
                pin.image = [UIImage imageNamed:@"pin-bar-4"];
            }else if(checkins >= 99){
                pin.image = [UIImage imageNamed:@"pin-bar-5"];
            }
            break;
        case 3 :   //Festa
            if (checkins <10) {
                pin.image = [UIImage imageNamed:@"pin-festa-1"];
            }else if(checkins >= 10 && checkins <30){
                pin.image = [UIImage imageNamed:@"pin-festa-2"];
            }else if(checkins >= 30 && checkins <50){
                pin.image = [UIImage imageNamed:@"pin-festa-3"];
            }else if(checkins >= 50 && checkins <99){
                pin.image = [UIImage imageNamed:@"pin-festa-4"];
            }else if(checkins >= 99){
                pin.image = [UIImage imageNamed:@"pin-festa-5"];
            }
            break;
        case 4 :   //Local público
            if (checkins <10) {
                pin.image = [UIImage imageNamed:@"pin-publicos-1"];
            }else if(checkins >= 10 && checkins <30){
                pin.image = [UIImage imageNamed:@"pin-publicos-2"];
            }else if(checkins >= 30 && checkins <50){
                pin.image = [UIImage imageNamed:@"pin-publicos-3"];
            }else if(checkins >= 50 && checkins <99){
                pin.image = [UIImage imageNamed:@"pin-publicos-4"];
            }else if(checkins >= 99){
                pin.image = [UIImage imageNamed:@"pin-publicos-5"];
            }
            break;
        default :
            NSLog(@"Local não compatível com tipos de local cadastrados");
    }
    
    pin.canShowCallout = YES;
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [detailButton setImage:[UIImage imageNamed:@"seta"] forState:UIControlStateNormal];
    detailButton.frame = CGRectMake(0,0, 40.0, 45.0);
    
    UIView *left = [[UIView alloc]initWithFrame:CGRectMake(0,0, 50.0, 65.0)];
    left.backgroundColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f];
    
    UILabel *lblqt_checkin = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 50, 25)];
    [lblqt_checkin setText:((PointLocais *)annotation).qt_checkin];
    [lblqt_checkin setTextAlignment:NSTextAlignmentCenter];
    [lblqt_checkin setTextColor:[UIColor whiteColor]];
    [lblqt_checkin setFont:[UIFont fontWithName: @"Brie_Medium" size: 24.0f]];
    [left addSubview:lblqt_checkin];
    
    NSInteger annotationValue = [self.annotations indexOfObject:annotation];
    
    detailButton.tag = annotationValue;
    
    pin.rightCalloutAccessoryView = detailButton;
    
    pin.leftCalloutAccessoryView = left;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    if ([view.annotation isKindOfClass:[PointLocais class]]) {
        // Store a reference to the annotation so that we can pass it on in prepare for segue.
        self.selectedAnnotation = view.annotation;
        [self performSegueWithIdentifier:@"checkinsFotosSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Check that the segue is our showPinDetails-segue
    if ([segue.identifier isEqualToString:@"checkinsFotosSegue"]) {
        // Pass the annotation reference to the detail view controller.
        UsuariosCheckedViewController *usuarioCheckedVC = [segue destinationViewController];
        usuarioCheckedVC.annotation = self.selectedAnnotation;
        
    }
}

@end
