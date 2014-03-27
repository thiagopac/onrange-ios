//
//  LocaisTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 21/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "LocaisTableViewController.h"
#import "AppDelegate.h"
#import <Restkit/RestKit.h>
#import "MappingProvider.h"
#import "TopLocaisComCheckinCell.h"
#import "Local.h"
#import "UsuariosCheckedViewController.h"
#import <SVProgressHUD.h>

@interface LocaisTableViewController (){
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic, strong) NSMutableArray *arrLocais;

@end

@implementation LocaisTableViewController

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
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        
    [refresh addTarget:self action:@selector(carregaLocais) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
}

-(void)viewWillAppear:(BOOL)animated{
    [self statusBarCustomizadaWithMsg:@"Carregando lista de locais..."];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaLocais];
    });
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

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    latitude = [def objectForKey:@"userLatitude"];
    longitude = [def objectForKey:@"userLongitude"];
    
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Locais" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/20/checkin",API,latitude,longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];
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

-(void)viewDidDisappear:(BOOL)animated{
    [self.notification dismissNotification];
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
    return self.arrLocais.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Top checkins";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalCell";
    TopLocaisComCheckinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Local *local = [self.arrLocais objectAtIndex:indexPath.row];
    
    [self configureCell:cell withLocal:local];
    
    return cell;
}

- (void)configureCell:(TopLocaisComCheckinCell *)cell withLocal:(Local *)local {
    
    cell.lblLocal.text = local.nome;
    cell.lblQuantidadeCheckins.text = local.qt_checkin;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UsuariosCheckedViewController *usuariosCheckedVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"UsuariosCheckedViewController"];
    
    Local *local = [[self arrLocais]objectAtIndex:indexPath.row];
    
    [usuariosCheckedVC setLocal:local];
    
    [[self navigationController]pushViewController:usuariosCheckedVC animated:YES];
}

@end
