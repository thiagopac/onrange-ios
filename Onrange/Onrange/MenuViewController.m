//
//  MenuViewController.m
//  Onrange
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"

@implementation MenuViewController

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.user = [def objectForKey:@"graph_usuario"];
    self.userProfilePictureView.profileID = [self.user objectForKey:@"id"];
    self.userNameLabel.text = [[self.user objectForKey:@"first_name"] uppercaseString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action methods

- (IBAction)minhasCombinacoesButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
    UITableViewController *SettingsTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"MinhasCombinacoesTableViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:SettingsTableViewController withCompletion:nil];
}

- (IBAction)settingsButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
    UITableViewController *SettingsTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingsTableViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:SettingsTableViewController withCompletion:nil];
}

- (IBAction)inicioButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
    UIViewController *HomeViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:HomeViewController withCompletion:nil];
}

- (IBAction)fazerCheckinButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
     UITableViewController *LocaisProximosTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"LocaisProximosTableViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:LocaisProximosTableViewController withCompletion:nil];
}

- (IBAction)onrangeClubButtonClicked:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UITableViewController *PromoCaixaEntradaTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"PromoCaixaEntradaTableViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:PromoCaixaEntradaTableViewController withCompletion:nil];
}

@end
