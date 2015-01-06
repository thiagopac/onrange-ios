//
//  LocaisProximosTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 23/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "LocaisProximosTableViewController.h"
#import "SlideNavigationController.h"
#import "MappingProvider.h"
#import "Local.h"
#import "PerfilLocalTableViewController.h"
#import "AdicionaLocalTableViewController.h"
#import "LocaisProximosTableViewCell.h"
#import "SVProgressHUD.h"


@interface LocaisProximosTableViewController (){
    int raio;
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic, strong) NSMutableArray *arrLocais;

@end

@implementation LocaisProximosTableViewController

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
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
        
        [def setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"userLongitude"];
        
        [def synchronize];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.locationManager stopUpdatingLocation];
    [self.notification dismissNotification];
}


-(void)buscarLocalizacao{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200.00;
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
    NSLog(@"Foi aberto");
    [self.locationManager startUpdatingLocation];
}

- (void)menuAbriu:(NSNotification *)notification {
    if([[SlideNavigationController sharedInstance] isMenuOpen]){
        self.tableView.scrollEnabled = NO;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    latitude = [def objectForKey:@"userLatitude"];
    longitude = [def objectForKey:@"userLongitude"];
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/80.0/distancia",API,latitude,longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];

        if (self.arrLocais.count < 1) {
            [SVProgressHUD showErrorWithStatus:@"Nenhum local próximo encontrado"];
            [self.notification dismissNotification];
        }
        [self.notification dismissNotification];
        [self.tableView reloadData];
        [self.refreshControl performSelector:@selector(endRefreshing)];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 502) { //Erro na listagem de locais
            NSLog(@"Erro %ld",self.status);
            [self carregaLocais];
        }else{
            [self.refreshControl performSelector:@selector(endRefreshing)];
            [self.notification dismissNotification];
            NSLog(@"ERRO FATAL - carregaLocais");
            NSLog(@"Erro da API: %ld",self.status);
            NSLog(@"ERROR: %@", error);
            NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
            [self carregaLocais];
        }

    }];
    
    [operation start];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
    [self buscarLocalizacao];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(carregaLocais) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
}

-(void)statusBarCustomizadaWithMsg:(NSString *)msg{
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationAnimationType = CWNotificationAnimationTypeOverlay;
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    UIColor *themeColor = [UIColor colorWithHexString:[def objectForKey:@"tema_cor"]];
    self.notification.notificationLabelBackgroundColor = themeColor;
    
    self.notification.notificationLabelTextColor = [UIColor whiteColor];
    [self.notification displayNotificationWithMessage:msg completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self statusBarCustomizadaWithMsg:@"Buscando locais próximos..."];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaLocais];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrLocais.count +1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Locais próximos";
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"Lista de locais mais próximos";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalProximoCell";
    LocaisProximosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == self.arrLocais.count) {
        [cell.lblCell setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:15]];
        cell.lblCell.text = @"Adicionar novo local...";
        cell.lblCell.textColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0f];
        
        NSString *cor = @"#ffffff"; //branco
        cell.viewCorTipoLocal.backgroundColor = [UIColor colorWithHexString:cor];
        
        return cell;
    }
    
    Local *local = [self.arrLocais objectAtIndex:indexPath.row];
    cell.lblCell.text = local.nome;
    
    [cell.lblCell setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15]];
    cell.lblCell.textColor = [UIColor scrollViewTexturedBackgroundColor];
    
    //Tipos de local
    //  1-Balada
    //  2-Bar
    //  3-Festa
    //  4-Locais Públicos
    
    NSString *cor;
    
    if (local.tipo_local == 1) {
        cor = @"#ee4e30"; //vermelho
    }else if (local.tipo_local == 2) {
        cor = @"#fcb826"; //amarelo
    }else if (local.tipo_local == 3) {
        cor = @"#48b163"; //verde
    }else{
        cor = @"#5a8eaf"; //azul
    }
    
    if (local.destaque == 1) {
        cell.imgDestaque.hidden = NO;
    }else{
        cell.imgDestaque.hidden = YES;
    }

    
    cell.viewCorTipoLocal.backgroundColor = [UIColor colorWithHexString:cor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.arrLocais.count) {
       
        AdicionaLocalTableViewController *adicionaLocalTVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"AdicionaLocalTableViewController"];
        
        [[self navigationController]pushViewController:adicionaLocalTVC animated:YES];
        
    }else{
    
        PerfilLocalTableViewController *perfilLocalTVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"PerfilLocalTableViewController"];
        
        Local *local = [[self arrLocais]objectAtIndex:indexPath.row];
        [perfilLocalTVC setLocal:local];
        [[self navigationController]pushViewController:perfilLocalTVC animated:YES];
    }
}

@end
