//
//  MinhasCombinacoesTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 14/07/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "MinhasCombinacoesTableViewController.h"
#import "SlideNavigationController.h"
#import "MappingProvider.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "MinhasCombinacoesTableViewCell.h"
#import "Match.h"

@interface MinhasCombinacoesTableViewController ()

@property (nonatomic, strong) NSMutableArray *arrCombinacoes;

@end

@implementation MinhasCombinacoesTableViewController

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)menuAbriu:(NSNotification *)notification {
    if([[SlideNavigationController sharedInstance] isMenuOpen]){
        self.tableView.scrollEnabled = NO;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];

    [self carregaCombinacoes];

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
    if (self.arrCombinacoes.count == 0) {
        return 1;
    }
    return self.arrCombinacoes.count;
}

- (void)carregaCombinacoes {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger id_usuario = [def integerForKey:@"id_usuario"];
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider matchMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Matches" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@match/listaMatches/%d",API, (int)id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrCombinacoes = [NSMutableArray arrayWithArray:mappingResult.array];
        
        if (self.arrCombinacoes.count < 1) {
            [SVProgressHUD showErrorWithStatus:@"Nenhum local próximo encontrado"];
        }
        [self.tableView reloadData];
        [self.refreshControl performSelector:@selector(endRefreshing)];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro"];
        [self.refreshControl performSelector:@selector(endRefreshing)];
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"combinacaoCell";
    MinhasCombinacoesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (self.arrCombinacoes.count == 0 && self.arrCombinacoes != nil) {
        cell.lblNomeCombinacao.hidden = YES;
        cell.userProfilePictureView.hidden = YES;
        cell.textLabel.text = @"Você não possui combinações";
     
        return cell;
    }

    cell.lblNomeCombinacao.hidden = NO;
    cell.userProfilePictureView.hidden = NO;
    cell.textLabel.text = @"";
    
    Match *match = [self.arrCombinacoes objectAtIndex:indexPath.row];
    cell.lblNomeCombinacao.text = match.nome_usuario;
    cell.userProfilePictureView.profileID = match.facebook_usuario;
    
    [cell.lblNomeCombinacao setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:17]];
    cell.lblNomeCombinacao.textColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Clicou em algo");
}

@end