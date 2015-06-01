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
#import "Usuario.h"
#import <SDWebImage/UIImageView+WebCache.h>

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];

    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    self.imgFotoUsuario.layer.cornerRadius = 50.0f;
    self.imgFotoUsuario.layer.masksToBounds = YES;

    NSString *strURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200&height=200",usuario.facebook_usuario];
    [self.imgFotoUsuario sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"fb-medal2.png"] options:SDWebImageRefreshCached];
    
    self.userNameLabel.text = [[usuario nome_usuario] uppercaseString];
    
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
