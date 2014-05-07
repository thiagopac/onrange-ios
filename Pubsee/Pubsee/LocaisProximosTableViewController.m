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
#import "PerfilLocalViewController.h"
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Locais" statusCodes:statusCodeSet];
    
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
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro"];
        [self.notification dismissNotification];
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
    [self.refreshControl performSelector:@selector(endRefreshing)];
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
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
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
    
    self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:244/255.0f green:97/255.0f blue:34/255.0f alpha:1.0f];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalProximoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (indexPath.row == self.arrLocais.count) {
        cell.textLabel.text = @"Adicionar novo local...";
        return cell;
    }
    
    Local *local = [self.arrLocais objectAtIndex:indexPath.row];
    cell.textLabel.text = [local nome];
    

    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.arrLocais.count) {
        NSLog(@"Abriu adição de local");
    }else{
    
    PerfilLocalViewController *perfilLocalVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"PerfilLocalViewController"];
    
    Local *local = [[self arrLocais]objectAtIndex:indexPath.row];
    
    [perfilLocalVC setLocal:local];
    
        [[self navigationController]pushViewController:perfilLocalVC animated:YES];
    }
}


@end
