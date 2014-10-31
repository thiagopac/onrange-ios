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
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.QBUser = [def objectForKey:@"facebook_usuario"];
    self.QBPassword = [def objectForKey:@"facebook_usuario"];

    meu_id_qb = [NSString stringWithFormat:@"%lu",(unsigned long)[LocalStorageService shared].currentUser.ID];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.topItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];

    if([LocalStorageService shared].currentUser == nil){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        // QuickBlox session creation
        QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
        extendedAuthRequest.userLogin = self.QBUser;
        extendedAuthRequest.userPassword = self.QBPassword;
        //
        [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session) {
            
            //        [self registerForRemoteNotifications];
            
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            
            //        PROBLEMA DE IOS 7 E IOS 8
            //        // register for notifications
            [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
            //
            //        // resister for push notifications
            //        // this method will call didRegisterForRemoteNotificationsWithDeviceToken
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
            // Save current user
            //
            QBUUser *currentUser = [QBUUser user];
            currentUser.ID = session.userID;
            currentUser.login = self.QBUser;
            currentUser.password = self.QBPassword;
            //
            [[LocalStorageService shared] setCurrentUser:currentUser];
            
            // Login to QuickBlox Chat
            //
            [[ChatService instance] loginWithUser:currentUser completionBlock:^{
                
                [QBChat dialogsWithExtendedRequest:nil delegate:self];
                
                // hide alert after delay
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            
            
            
        } errorBlock:^(QBResponse *response) {
            NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [alert show];
            [SVProgressHUD dismiss];
        }];
    }

}


- (void(^)(QBResponse *))handleError
{
    return ^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
        [SVProgressHUD dismiss];
    };
}

// Chat delegate
- (void)chatDidLogin{
    NSLog(@"Logou no chat!");
    [self.tableView reloadData];
}

- (void)chatDidNotLogin{
    NSLog(@"Não logou no chat!");
}

-(void)viewWillAppear:(BOOL)animated{
    if([LocalStorageService shared].currentUser != nil){
//        [self.activityIndicator startAnimating];
//        loading carregando usuário
        
        // get dialogs
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        self.HomeViewController.viewUnredMessages.hidden = YES;
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
	return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"combinacaoCell";
    MinhasCombinacoesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    
    cell.detailTextLabel.text = @"private";
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
    cell.lblNomeCombinacao.text = recipient.login == nil ? recipient.email : recipient.fullName;
    
//    if (recipient.ID == [match.id_qb intValue]) {
//        cell.userProfilePictureView.profileID = match.facebook_usuario;
//    }
    cell.imgProfile.pictureCropping = FBProfilePictureCroppingSquare;
    cell.imgProfile.profileID = recipient.login;
    
    [cell.lblNomeCombinacao setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:17]];

    NSString *qtdMsgsNaoLidas = [NSString stringWithFormat:@"%lu",(unsigned long)chatDialog.unreadMessagesCount];
    
    if ([qtdMsgsNaoLidas isEqualToString:@"0"]) {
        cell.viewUnredMessages.hidden = YES;
    }
    
// contagem de mensagens não-lidas
//     [ NSString stringWithFormat:@"%lu",(unsigned long)chatDialog.unreadMessagesCount]
    
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
        
        [SVProgressHUD dismiss];
        
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
        
        [self.tableView reloadData];
        
    }else if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {

        [SVProgressHUD dismiss];
        
        QBUUserPagedResult *res = (QBUUserPagedResult *)result;
        [LocalStorageService shared].users = res.users;
        //
        [self.tableView reloadData];
    }
}

@end