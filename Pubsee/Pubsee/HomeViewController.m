//
//  HomeViewController.m
//  Pubsee
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"
#import "UsuariosCheckedViewController.h"

@interface HomeViewController (){
    int raio;
    CLLocationManager *locationManager;
    NSString *latitude;
    NSString *longitude;
    NSString *nome_usuario;
    NSString *sexo_usuario;
    NSString *facebook_usuario;
    NSString *email_usuario;
    NSString *valida_sexo;
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

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return YES;
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
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)populateUserDetails {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {
        nome_usuario = user.first_name;
        email_usuario = [user objectForKey:@"email"];
        facebook_usuario = user.id;
        valida_sexo = [user objectForKey:@"gender"];
        if ([valida_sexo isEqualToString:@"male"]) {
            sexo_usuario = @"M";
        }else if([valida_sexo isEqualToString:@"female"]) {
            sexo_usuario = @"F";
        }
        [self postUsuario];
    }];

}

-(void)postUsuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"nome_usuario", @"sexo_usuario", @"facebook_usuario", @"email_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"nome_usuario", @"sexo_usuario", @"facebook_usuario", @"email_usuario", @"id_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/adicionausuario";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario = [Usuario new];
    
    usuario.nome_usuario = nome_usuario;
    usuario.sexo_usuario = sexo_usuario;
    usuario.email_usuario = email_usuario;
    usuario.facebook_usuario = facebook_usuario;
    
    [objectManager postObject:usuario
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                              NSLog(@"Login efetuado na base Pubse");
                          }else{
                              NSLog(@"Falha ao tentar logar na base Pubsee");
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Error: %@", error);
                              NSLog(@"Falha ao tentar enviar dados de login");
                      }];    
}

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    latitude = [def objectForKey:@"userLatitude"];
    longitude = [def objectForKey:@"userLongitude"];
    raio = [def integerForKey:@"userRange"];
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/%d",API,latitude,longitude,raio]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];
        [self montarMapaWithArray:self.arrLocais];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buscarLocalizacao];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaLocais];
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(103, 23, 110, 38)];
    logo.image = [UIImage imageNamed:@"icone_nav.png"];
    [self.navigationController.view addSubview:logo];
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

    static NSInteger pinColorCount = 0;
    pinColorCount++;
    
    if (pinColorCount == 1) {
        pin.image = [UIImage imageNamed:@"pinred"];
    }
    else if (pinColorCount == 2) {
        pin.image = [UIImage imageNamed:@"pinblue"];
    }
    else if (pinColorCount == 3) {
        pin.image = [UIImage imageNamed:@"pingreen"];
    }
    else if (pinColorCount == 4) {
        pin.image = [UIImage imageNamed:@"pinyellow"];
    }
    else if (pinColorCount == 5) {
        pin.image = [UIImage imageNamed:@"pinpink"];
    }
    else if (pinColorCount == 6) {
        pin.image = [UIImage imageNamed:@"pinorange"];
        pinColorCount = 0;
    }
    
    pin.canShowCallout = YES;

    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    NSInteger annotationValue = [self.annotations indexOfObject:annotation];
    
    detailButton.tag = annotationValue;
    
    pin.rightCalloutAccessoryView = detailButton;
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
