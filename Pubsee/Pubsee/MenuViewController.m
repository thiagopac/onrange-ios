//
//  MenuViewController.m
//  Pubsee
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    self.userProfilePictureView.layer.cornerRadius = 45;
    self.userProfilePictureView.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else {
        [appDelegate closeSession];
    }
}

- (void)populateUserDetails {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {
//        self.userNameLabel.text = user.name;
        self.userNameLabel.text = user.first_name;
//        self.userNameLabel.text = [user objectForKey:@"email"];
        self.userProfilePictureView.profileID = [user objectForKey:@"id"];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
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

- (IBAction)settingsButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
    UIViewController *SettingsTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingsTableViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:SettingsTableViewController withCompletion:nil];
}

- (IBAction)inicioButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
    UIViewController *HomeViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:HomeViewController withCompletion:nil];
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
