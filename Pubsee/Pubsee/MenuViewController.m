//
//  MenuViewController.m
//  Pubsee
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "AppDelegate.h"

@implementation MenuViewController
//@synthesize cellIdentifier;


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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods
/*
 * Configure the logged in versus logged out UX
 */
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else {
        [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
    }
}

- (void)populateUserDetails {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {
        self.userNameLabel.text = user.name;
        self.userProfilePictureView.profileID = [user objectForKey:@"id"];
    }];
}

-(id)init {
    return [self initWithProfileID:nil];
}

-(id)initWithProfileID:(NSString *)profileID {
    self = [super init];
    if (self) {
        self.profileID = profileID;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (FBSession.activeSession.isOpen ||
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded ||
        FBSession.activeSession.state == FBSessionStateCreatedOpening) {
    } else {
        [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (buttonIndex) {
        case 0: // logout
            [appDelegate closeSession];
            break;
        case 1: // cancel
            break;
    }
}

#pragma mark - Action methods
- (IBAction)logoutButtonClicked:(UIButton *)sender {
    UIActionSheet* action = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             destructiveButtonTitle:@"Logout"
                             otherButtonTitles:nil ];
    [action showInView:self.view];
}

#pragma mark - UITableView Delegate & Datasrouce -
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//	return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 3;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return nil;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
//		switch (indexPath.row)
//		{
//			case 0:
//				cell.textLabel.text = @"Usuário";
//				break;
//				
//			case 1:
//				cell.textLabel.text = @"Configurações";
//				break;
//				
//			case 2:
//				cell.textLabel.text = @"Logout";
//				break;
//		}
//	
//	return cell;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
//															 bundle: nil];
//		UIViewController *vc ;
//		
//		switch (indexPath.row)
//		{
//			case 0:
//				vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
//				break;
//				
//			case 1:
//				vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
//				break;
//				
//			case 2:
//				vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendsViewController"];
//				break;
//				
//			case 3:
//				[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
//				return;
//				break;
//		}
//		
//		[[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
//}

//CHEGUEI AQUI. TIREI O IF ACIMA DA CONDICAO DAS 2 SESSOES E FALTA TIRAR ABAIXO E COMENTAR OS METODOS DOS ESTILOS DE SLIDE PARA NÃO PERDER.
//
//	else
//	{
//		id <SlideNavigationContorllerAnimator> revealAnimator;
//		
//		switch (indexPath.row)
//		{
//			case 0:
//				revealAnimator = nil;
//				break;
//				
//			case 1:
//				revealAnimator = [[SlideNavigationContorllerAnimatorSlide alloc] init];
//				break;
//				
//			case 2:
//				revealAnimator = [[SlideNavigationContorllerAnimatorFade alloc] init];
//				break;
//				
//			case 3:
//				revealAnimator = [[SlideNavigationContorllerAnimatorSlideAndFade alloc] initWithMaximumFadeAlpha:.7 fadeColor:[UIColor purpleColor] andSlideMovement:100];
//				break;
//				
//			case 4:
//				revealAnimator = [[SlideNavigationContorllerAnimatorScale alloc] init];
//				break;
//				
//			case 5:
//				revealAnimator = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:.6 fadeColor:[UIColor blueColor] andMinimumScale:.7];
//				break;
//				
//			default:
//				return;
//		}
//		
//		[[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
//			[SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
//		}];
//	}
//}

@end
