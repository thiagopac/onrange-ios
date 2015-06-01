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
#import "Usuario.h"
#import "ChatViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MinhasCombinacoesTableViewController ()<QBActionStatusDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>{
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self.dialogs removeAllObjects];
    [self.tableView reloadData];
    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    self.QBUser = usuario.facebook_usuario;
    self.QBPassword = usuario.facebook_usuario;
    
    meu_id_qb = [NSString stringWithFormat:@"%lu",(unsigned long)[LocalStorageService shared].currentUser.ID];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    [self statusBarCustomizadaWithMsg:@"Carregando suas combinações..."];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
//    if([LocalStorageService shared].currentUser == nil){

    // QuickBlox session creation
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = self.QBUser;
    extendedAuthRequest.userPassword = self.QBPassword;
    //
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session) {
        
        [self registerForRemoteNotifications];
        
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
            
        }];
        
    } errorBlock:^(QBResponse *response) {
        NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
        
        [self.notification dismissNotification];
        
        [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro. Tente novamente em alguns segundos."];
    }];
//    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerForRemoteNotifications{
    
    if ([[UIApplication sharedApplication]respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}


- (void(^)(QBResponse *))handleError
{
    return ^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro. Tente novamente em alguns segundos."];
        [self.notification dismissNotification];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Minhas combinações";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dialogs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    
    return YES;
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
    
    cell.imgFotoUsuario.layer.cornerRadius = 21.0f;
    cell.imgFotoUsuario.layer.masksToBounds = YES;
    
    NSString *strURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=84&height=84",recipient.login];
    [cell.imgFotoUsuario sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"fb-medal2.png"]];

    [cell.lblNomeCombinacao setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:17]];

    NSString *qtdMsgsNaoLidas = [NSString stringWithFormat:@"%lu",(unsigned long)chatDialog.unreadMessagesCount];

    if ([qtdMsgsNaoLidas isEqualToString:@"0"]) {
        cell.imgUnreadMessages.hidden = YES;
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

        [self.notification dismissNotification];

        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        self.dialogs = [dialogs mutableCopy];
        
        if ([self.dialogs count]<1) {
            self.tableView.emptyDataSetSource = self;
            [self.tableView setUserInteractionEnabled:NO];
        }
        
        // Get dialogs users
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 200;
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBUsers usersWithIDs:[[dialogsUsersIDs allObjects] componentsJoinedByString:@","] pagedRequest:pagedRequest delegate:self];

        [self.tableView reloadData];

    }else if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {

        [self.notification dismissNotification];

        QBUUserPagedResult *res = (QBUUserPagedResult *)result;
        [LocalStorageService shared].users = res.users;
        //
        [self.tableView reloadData];
    }
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Você ainda não tem nenhuma combinação.\n:(";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:22.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(void)appWillTerminate:(NSNotification*)note
{
    NSLog(@"Foi fechado");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if([[QBChat instance] isLoggedIn]){
        [[QBChat instance] logout];
    }
}

-(void)appDidBecomeActive:(NSNotification*)note
{
    NSLog(@"Foi aberto");
    [self viewDidAppear:YES];
}

-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"Foi minimizado");
    
    if([[QBChat instance] isLoggedIn]){
        [[QBChat instance] logout];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.notification dismissNotification];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinish];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinish];
}
- (void)scrollingFinish {
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

@end