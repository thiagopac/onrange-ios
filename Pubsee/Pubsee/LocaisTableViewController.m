//
//  LocaisTableViewController.m
//  Pubsee
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
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaLocais];
    });
}

- (void)carregaLocais {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    latitude = [def objectForKey:@"userLatitude"];
    longitude = [def objectForKey:@"userLongitude"];
    
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider localMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@local/listaLocaisRange/%@/%@/20",API,latitude,longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrLocais = [NSMutableArray arrayWithArray:mappingResult.array];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
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


//SEGUE POR PUSH NÃO FUNCIONA SE AS VIEWS NÃO ESTIVEREM NA MESMA NAVIGATION

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UsuariosCheckedViewController *usuariosCheckedVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"UsuariosCheckedViewController"];
    
    Local *local = [[self arrLocais]objectAtIndex:indexPath.row];
    
    [usuariosCheckedVC setLocal:local];
    
    [[self navigationController]pushViewController:usuariosCheckedVC animated:YES];
}

@end
