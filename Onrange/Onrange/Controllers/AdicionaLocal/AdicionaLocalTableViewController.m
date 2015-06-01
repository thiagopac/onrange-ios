//
//  AdicionaLocalTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 06/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "AdicionaLocalTableViewController.h"
#import "LocaisProximosTableViewController.h"
#import "ConfirmaAdicaoViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <RestKit/RestKit.h>
#import "PointLocais.h"
#import "Local.h"
#import "Usuario.h";

@interface AdicionaLocalTableViewController ()<ControleTecladoDelegate>{
    NSString *ambienteAPI;
}

@end

@implementation AdicionaLocalTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
	if ([def objectForKey:@"ambiente"] != nil) {
        NSString *ambiente = [def objectForKey:@"ambiente"];
        
        if ([ambiente isEqualToString:@"Produção"]) {
            ambienteAPI = API;
        }else if ([ambiente isEqualToString:@"Desenvolvimento"]){
            ambienteAPI = API_DEV;
        }else{
            ambienteAPI = API;
		}
    }else{
            ambienteAPI = API;
	}
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    UIBarButtonItem *btnCriar = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Criar "
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(criarLocal)];
    self.navigationItem.rightBarButtonItem = btnCriar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self buscarLocalizacao];
    
    [self setControleTeclado:[[ControleTeclado alloc] init]];
    
    [[self controleTeclado]setDelegate:self];
}

-(void)montarMapaWithLatitude:(NSString *)latitude eLongitude:(NSString *)longitude {
    
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [latitude doubleValue];
        theCoordinate.longitude = [longitude doubleValue];
        
        PointLocais *myAnnotation = [[PointLocais alloc]init];
        myAnnotation.latitude = self.latitude;
        myAnnotation.longitude = self.longitude;
        myAnnotation.coordinate = theCoordinate;
        [_mapLocal addAnnotation:myAnnotation];
        
        MKMapRect flyTo = MKMapRectNull;
        MKMapPoint annotationPoint = MKMapPointForCoordinate(myAnnotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
        _mapLocal.visibleMapRect = flyTo;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Boilerplate pin annotation code
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapLocal dequeueReusableAnnotationViewWithIdentifier: @"AnnotationIdentifier"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"AnnotationIdentifier"];
    } else {
        pin.annotation = annotation;
    }
    
    pin.draggable = YES;
    
    return pin;
}


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
        self.latitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude];
        
        [def setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"userLongitude"];
        self.longitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude];
        
        [def synchronize];
        [self montarMapaWithLatitude:self.latitude eLongitude:self.longitude];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKAnnotationView *userLocationView = [_mapLocal viewForAnnotation:userLocation];
    userLocationView.canShowCallout = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.locationManager stopUpdatingLocation];
}

-(void)buscarLocalizacao{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 300000.00;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    [self.locationManager startUpdatingLocation];
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
    NSLog(@"Foi re-aberto");
    LocaisProximosTableViewController *locaisProximosTVC = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:locaisProximosTVC animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        // custom code when drag ends...
        
        NSLog(@"Pino terminou de se mover");
        
        CLLocationCoordinate2D pinMoveu = annotationView.annotation.coordinate;
        NSLog(@"latitude: %f",pinMoveu.latitude);
        NSLog(@"longitude: %f",pinMoveu.longitude);
        
        self.latitude = [NSString stringWithFormat:@"%f",pinMoveu.latitude];
        self.longitude = [NSString stringWithFormat:@"%f",pinMoveu.longitude];
        
        // tell the annotation view that the drag is done
        [annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
    
    else if (newState == MKAnnotationViewDragStateCanceling) {
        // custom code when drag canceled...
        
        NSLog(@"Pino cancelou movimento");
        
        CLLocationCoordinate2D pinMesmoLocal = annotationView.annotation.coordinate;
        NSLog(@"latitude: %f",pinMesmoLocal.latitude);
        NSLog(@"longitude: %f",pinMesmoLocal.longitude);
        self.latitude = [NSString stringWithFormat:@"%f",pinMesmoLocal.latitude];
        self.longitude = [NSString stringWithFormat:@"%f",pinMesmoLocal.longitude];
        
        // tell the annotation view that the drag is done
        [annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)viewWillAppear:(BOOL)animated{
    if (self.tipoLocal) {
        [self.lblCategoria setText:self.nomeCategoria];
    }
}

-(void)criaLocal{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario", @"nome", @"latitude", @"longitude", @"tipo_local"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Local class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @"tipo_local", @"latitude", @"longitude", @"nome", @"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Local class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:ambienteAPI];
    NSString *path= @"local/adicionalocal";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    Local *local= [Local new];
    local.id_usuario = usuario.id_usuario;
    local.nome = self.txtNomeLocal.text;
    local.latitude = self.latitude;
    local.longitude = self.longitude;
    local.tipo_local = self.tipoLocal;
    
    [objectManager postObject:local path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          
      self.status = operation.HTTPRequestOperation.response.statusCode;
      
      if(mappingResult != nil){
          Local *localcriado = [mappingResult firstObject];
          [SVProgressHUD dismiss];

          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          ConfirmaAdicaoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaAdicaoViewController"];
          vc.strNomeLocal = localcriado.nome;
          [self presentViewController:vc animated:YES completion:nil];
          [self.view setNeedsLayout];
          
          LocaisProximosTableViewController *locaisProximosTVC = [self.navigationController.viewControllers objectAtIndex:1];
          [self.navigationController popToViewController:locaisProximosTVC animated:YES];

        }
  }failure:^(RKObjectRequestOperation *operation, NSError *error) {
    
        self.status = operation.HTTPRequestOperation.response.statusCode;

        if(self.status == 503) {
          [self criaLocal];
        }else if(self.status == 558) {
          [self alert:@"Você deve aguardar alguns minutos para criar um novo local.":@"Erro"];
        }else{
          [self alert:@"Erro ao adicionar o local. Tente novamente em alguns minutos.":@"Erro"];
        }
        [SVProgressHUD dismiss];
        NSLog(@"Error: %@", error);
        NSLog(@"Falha ao tentar enviar dados de checkin");
    }];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_txtNomeLocal resignFirstResponder];
}

-(NSArray *)inputsTextFieldAndTextViews
{
    return @[_txtNomeLocal];
}


-(void)criarLocal{
    
    UIActionSheet* actionCheckin = [[UIActionSheet alloc]
                                    initWithTitle:[NSString stringWithFormat:@"Se você tiver checkin em outro local, ele será apagado ao criar um novo local e você fará checkin nele automaticamente. Confirma criação do novo local?"]
                                    delegate:(id<UIActionSheetDelegate>)self
                                    cancelButtonTitle:@"Sim"
                                    destructiveButtonTitle:@"Não"
                                    otherButtonTitles:nil];
    [actionCheckin showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: //Não
            break;
        case 1: //Sim
            if ([self.txtNomeLocal.text isEqualToString:@""] || self.nomeCategoria == nil) {
                [self alert:@"Preencha o campo de nome e a categoria":@"Erro"];
                
            }else{
                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
                [self criaLocal];
                
            }
            break;
    }
}

@end
