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
#import "ChatViewController.h"

@interface MinhasCombinacoesTableViewController ()<QBActionStatusDelegate>{
    NSString *meu_id_qb;
}

@property (nonatomic, strong) NSMutableArray *arrCombinacoes;
@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) QBChatDialog *dialog;

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
        
    meu_id_qb = [NSString stringWithFormat:@"%lu",(unsigned long)[LocalStorageService shared].currentUser.ID];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];

    [self carregaCombinacoes];

}

-(void)viewWillAppear:(BOOL)animated{
    if([LocalStorageService shared].currentUser != nil){
//        [self.activityIndicator startAnimating];
//        loading carregando usuário
        
        // get dialogs
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;

    QBChatDialog *dialog = self.dialogs[((UITableViewCell *)sender).tag];
    destinationViewController.dialog = dialog;
    
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(dialog.recipientID)];
    destinationViewController.oponentName = recipient.login == nil ? recipient.email : recipient.fullName;
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
	return [self.dialogs count];
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
        
        [self.tableView reloadData];
        [self.refreshControl performSelector:@selector(endRefreshing)];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Erro 404");
        [self carregaCombinacoes];
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

    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    
    cell.detailTextLabel.text = @"private";
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
    cell.lblNomeCombinacao.text = recipient.login == nil ? recipient.email : recipient.fullName;
    
    if (recipient.ID == [match.id_qb intValue]) {
        cell.userProfilePictureView.profileID = match.facebook_usuario;
    }
    
    [cell.lblNomeCombinacao setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:17]];
    cell.lblNomeCombinacao.textColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        self.dialogs = [dialogs mutableCopy];
        
        // Get dialogs users
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 100;
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBUsers usersWithIDs:[[dialogsUsersIDs allObjects] componentsJoinedByString:@","] pagedRequest:pagedRequest delegate:self];
        
    }else if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
        QBUUserPagedResult *res = (QBUUserPagedResult *)result;
        [LocalStorageService shared].users = res.users;
        //
        [self.tableView reloadData];
    }
}

@end