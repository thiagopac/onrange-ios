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
#import "PerfilLocalTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MinhasCombinacoesTableViewController.h"
#import "PromoCaixaEntradaTableViewController.h"
#import "PlaceAnnotation.h"

@interface HomeViewController (){
    int raio;
    NSString *latitude;
    NSString *longitude;
    NSString *ambienteAPI;
    NSArray *locations;
}

@property (nonatomic, strong) NSMutableArray *arrLocais;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) id<MKAnnotation> selectedAnnotation;
@property (nonatomic, strong) Local *localOndeEstou;

@end

@implementation HomeViewController

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Erro" message:@"Não foi possível determinar sua localização. Tentar novamente?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim",nil];
//    [errorAlert show];
    
    //nao mais apresentar o Alert para o usuário, apenas já fazer a busca novamente quando resultar erro
    [self buscarLocalizacao];
}


//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) //NÃO
//    {
//        UIAlertView *errorAlert = [[UIAlertView alloc]
//                                   initWithTitle:@"Erro" message:@"Não foi possível determinar sua localização. Nenhum local será mapeado." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//
////        Estava em loop infinito e não há motivos para mostrar isto para o usuário
////        [errorAlert show];
//    }
//    else //SIM
//    {
//        [self buscarLocalizacao];
//    }
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    if (currentLocation != nil) {
    
        latitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.latitude];
        longitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.longitude];
    
//guardando o local atualizado nas preferências para que tenha sempre algo a apresentar ao usuário

        [def setObject:latitude forKey:@"userLatitude"];
        
        [def setObject:longitude forKey:@"userLongitude"];
        
        [def synchronize];
        
    }else{

        latitude = [def objectForKey:@"userLatitude"];
        longitude = [def objectForKey:@"userLongitude"];

    }
    
    [self carregaLocais];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)buscarLocalizacao{
// Checar se é iOS 8. Sem isso, vai dar crash pq é iOS 7
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 2000.00;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }

    [self.locationManager startUpdatingLocation];
}

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    raio = (int)[def integerForKey:@"userRange"];
    
    if(raio == 0)
        raio = 20;
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/%d/checkin",ambienteAPI,latitude,longitude,raio]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];
        [self montarMapaWithArray:self.arrLocais];
        
        id locais = self.arrLocais;
        //3
        NSMutableArray *temp = [NSMutableArray array];
        
        //4
        if([locais isKindOfClass:[NSArray class]]) {
            for(NSDictionary *resultsDict in locais) {
                
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[[resultsDict valueForKeyPath:@"latitude"] floatValue] longitude:[[resultsDict valueForKeyPath:@"longitude"] floatValue]];
                
                
                Local *currentPlace = [[Local alloc] initWithLocation:location nome:[resultsDict valueForKeyPath:@"nome"] latitude:[resultsDict valueForKeyPath:@"latitude"] longitude:[resultsDict valueForKeyPath:@"longitude"] idLocal:[[resultsDict valueForKeyPath:@"id_local"]integerValue] destaque:[[resultsDict valueForKeyPath:@"destaque"]boolValue] qtCheckin:[resultsDict valueForKeyPath:@"qt_checkin"] andTipoLocal:[[resultsDict valueForKeyPath:@"tipo_local"]integerValue]];
                
                [temp addObject:currentPlace];
            }
            if(locations == nil)
                locations = [temp copy];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 502) { //Erro na listagem de locais
            NSLog(@"Erro %ld",(long)self.status);
            [self carregaLocais];
        }else{
            NSLog(@"ERRO FATAL - CarregaLocais");
            NSLog(@"Erro da API: %ld",(long)self.status);
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self carregaLocais];
        }
    }];
    
    [operation start];
}

- (void)ondeEstou:(Usuario *)usuario{
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/verificaCheckinUsuario/%ld",ambienteAPI,(long)usuario.id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.localOndeEstou = [mappingResult firstObject];
        if (self.localOndeEstou.id_local != 0 && self.localOndeEstou != nil) {
            self.btnMe.hidden = NO;
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 537) { //Erro ao buscar local
            NSLog(@"Erro %ld",(long)self.status);
            [self ondeEstou:usuario];
        }else{
            NSLog(@"ERRO FATAL - ondeEstou");
            NSLog(@"Erro da API: %ld",(long)self.status);
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self ondeEstou:usuario];
        }
    }];
    
    [operation start];
}

-(void)montarMapaWithArray:(NSArray *)locais {
    
    [_mapGlobal removeAnnotations:_mapGlobal.annotations];

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
        myAnnotation.tipo_local = (int)local.tipo_local;
        myAnnotation.destaque = local.destaque;
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
    
    self.navigationController.navigationBar.hidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
//    chegou notificação de push
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recebeNotificacao:) name:@"MinhaNotificacao" object:nil];
    
    [self buscarLocalizacao];
    
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
    
    [self.btnOnrangeClub addTarget:self action:@selector(btnOnrangeClubTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];

    self.navigationController.navigationBar.barTintColor = navcolor;
    
    if([[QBChat instance] isLoggedIn]){
        [[QBChat instance] logout];
    }

    [self addGestureRecognizer];
    
}

- (void)addGestureRecognizer{

    UILongPressGestureRecognizer *longPress_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doAction:)];
    [longPress_gr setMinimumPressDuration:5]; // dispara a ação após 5 segundos
   
    [self.btnOnrangeClub addGestureRecognizer:longPress_gr];
    
}

- (void)doAction:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.arrLocais != nil) {
            [self.btnRealidadeAumentada setHidden:NO];
        }

    }
}

-(void)viewWillAppear:(BOOL)animated{

    self.btnMe.hidden = YES;
    
    [_mapGlobal removeAnnotations:_mapGlobal.annotations];
    

    [self buscarLocalizacao];

    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    [self ondeEstou:usuario];
    [self verificaPromosNaoLidos:usuario];
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
    int destaque = ((PointLocais *)annotation).destaque;
    int annType = ((PointLocais *)annotation).tipo_local;
    
    switch (annType)
    {
        case 1 :   //Balada
            if (checkins <10) {
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-balada-1-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-balada-1"];
            }else if(checkins >= 10 && checkins <30){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-balada-2-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-balada-2"];
            }else if(checkins >= 30 && checkins <50){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-balada-3-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-balada-3"];
            }else if(checkins >= 50 && checkins <99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-balada-4-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-balada-4"];
            }else if(checkins >= 99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-balada-5-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-balada-5"];
            }
            break;
        case 2 :   //Bar
            if (checkins <10) {
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-bar-1-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-bar-1"];
            }else if(checkins >= 10 && checkins <30){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-bar-2-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-bar-2"];
            }else if(checkins >= 30 && checkins <50){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-bar-3-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-bar-3"];
            }else if(checkins >= 50 && checkins <99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-bar-4-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-bar-4"];
            }else if(checkins >= 99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-bar-5-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-bar-5"];
            }
            break;
        case 3 :   //Festa
            if (checkins <10) {
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-festa-1-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-festa-1"];
            }else if(checkins >= 10 && checkins <30){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-festa-2-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-festa-2"];
            }else if(checkins >= 30 && checkins <50){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-festa-3-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-festa-3"];
            }else if(checkins >= 50 && checkins <99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-festa-4-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-festa-4"];
            }else if(checkins >= 99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-festa-5-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-festa-5"];
            }
            break;
        case 4 :   //Local público
            if (checkins <10) {
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-publicos-1-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-publicos-1"];
            }else if(checkins >= 10 && checkins <30){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-publicos-2-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-publicos-2"];
            }else if(checkins >= 30 && checkins <50){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-publicos-3-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-publicos-3"];
            }else if(checkins >= 50 && checkins <99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-publicos-4-star"];
                else
                    pin.image = [UIImage imageNamed:@"pin-publicos-4"];
            }else if(checkins >= 99){
                if (destaque == YES)
                    pin.image = [UIImage imageNamed:@"pin-publicos-5-star"];
                else
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
    
    //Tipos de local
    //  1-Balada
    //  2-Bar
    //  3-Festa
    //  4-Locais Públicos
    
    NSString *cor;
    
    if (((PointLocais *)annotation).tipo_local == 1) {
        cor = @"#ee4e30"; //vermelho
    }else if (((PointLocais *)annotation).tipo_local == 2) {
        cor = @"#fcb826"; //amarelo
    }else if (((PointLocais *)annotation).tipo_local == 3) {
        cor = @"#48b163"; //verde
    }else{
        cor = @"#5a8eaf"; //azul
    }
    
    UIView *left = [[UIView alloc]initWithFrame:CGRectMake(0,0, 50.0, 65.0)];
//    left.backgroundColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f];
    left.backgroundColor = [UIColor colorWithHexString:cor];
    
    UILabel *lblqt_checkin = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 50, 25)];
    [lblqt_checkin setText:((PointLocais *)annotation).qt_checkin];
    [lblqt_checkin setTextAlignment:NSTextAlignmentCenter];
    [lblqt_checkin setTextColor:[UIColor whiteColor]];
    [lblqt_checkin setFont:[UIFont fontWithName: @"GillSans" size: 25.0f]];

    UIImage *estrela = [UIImage imageNamed:@"star2.png"];
    UIImageView *estrelaView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 21, 21)];
    [estrelaView setImage:estrela];
    
    if (checkins > 0)
        [left addSubview:lblqt_checkin];
    else
        [left addSubview:estrelaView];
    
    NSInteger annotationValue = [self.annotations indexOfObject:annotation];
    
    detailButton.tag = annotationValue;
    
    pin.rightCalloutAccessoryView = detailButton;
    
    pin.leftCalloutAccessoryView = left;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    if ([view.annotation isKindOfClass:[PointLocais class]]) {

        self.selectedAnnotation = view.annotation;
        [self performSegueWithIdentifier:@"perfilLocalSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"perfilLocalSegue"]) {
        PerfilLocalTableViewController *perfilLocalTVC = [segue destinationViewController];
        perfilLocalTVC.annotation = self.selectedAnnotation;
        
    }else if ([[segue identifier] isEqualToString:@"realidadeAumentadaSegue"]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setLocations:locations];
        [[segue destinationViewController] setUserLocation:[self.mapGlobal userLocation]];
    }
}

- (IBAction)btnMe:(UIButton *)sender {
    PerfilLocalTableViewController *perfilLocalTVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"PerfilLocalTableViewController"];
    
    [perfilLocalTVC setLocal:self.localOndeEstou];
    
    [[self navigationController]pushViewController:perfilLocalTVC animated:YES];
}

- (IBAction)btnMatches:(id)sender {
    MinhasCombinacoesTableViewController *minhasCombinacoesTVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"MinhasCombinacoesTableViewController"];
    
    [[self navigationController]pushViewController:minhasCombinacoesTVC animated:YES];
}

- (void) recebeNotificacao:(NSNotification *)notification {
    UIImage *imgBtn = [UIImage imageNamed:@"btn_minhascombinacoes2.png"];
    [self.btnMatches setImage:imgBtn forState:UIControlStateNormal];
//    [self.view setNeedsDisplay];
    NSLog(@"A mensagem foi: %@", [notification.userInfo objectForKey:@"message"]);
}

- (void)btnOnrangeClubTapped:(id)sender {
    PromoCaixaEntradaTableViewController *promoCaixaEntradaTVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"PromoCaixaEntradaTableViewController"];
    
    [[self navigationController]pushViewController:promoCaixaEntradaTVC animated:YES];
}

- (void)verificaPromosNaoLidos:(Usuario *)usuario{
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider promoMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@promo/verificapromosnaolidos/%ld",ambienteAPI,(long)usuario.id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.promo = [mappingResult firstObject];
        
        if (self.promo.nao_lido == 1) {
            UIImage *imgBtn = [UIImage imageNamed:@"btn_onrangeclub2.png"];
            [self.btnOnrangeClub setImage:imgBtn forState:UIControlStateNormal];
        }else{
            UIImage *imgBtn = [UIImage imageNamed:@"btn_onrangeclub.png"];
            [self.btnOnrangeClub setImage:imgBtn forState:UIControlStateNormal];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 547) { //Erro ao buscar local
            NSLog(@"Erro %ld",(long)self.status);
            [self verificaPromosNaoLidos:usuario];
        }else{
            NSLog(@"ERRO FATAL - verificaPromosNaoLidos");
            NSLog(@"Erro da API: %ld",(long)self.status);
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self verificaPromosNaoLidos:usuario];
        }
    }];
    
    [operation start];
}

@end
