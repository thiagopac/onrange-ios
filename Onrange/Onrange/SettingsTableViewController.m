//
//  SettingsTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 03/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "CWStatusBarNotification.h"

@interface SettingsTableViewController (){
    int prev;
}

@end

@implementation SettingsTableViewController


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

-(void)alterarLabelRaio
{
    self.lblRadio.text = [NSString stringWithFormat:@"%d KM",(int)[[self sliderRaio] value]];
}

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
    
    self.lblRadio.frame = CGRectMake(250, -25 , 50, 20);
    self.lblRadio.backgroundColor = [UIColor clearColor];
    self.lblRadio.textColor = [UIColor grayColor];
    self.lblRadio.shadowColor = [UIColor whiteColor];
    self.lblRadio.shadowOffset = CGSizeMake(0.0, 1.0);
    

    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def integerForKey:@"userRange"])
        [[self sliderRaio]setValue:[def integerForKey:@"userRange"]];
    else
        [[self sliderRaio]setValue:20];

    [self alterarLabelRaio];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.strGenero = [def objectForKey:@"genero"];
    
    if (self.strGenero == nil) {
        self.lblGenero.text = @"Homens e mulheres";
    }else if([self.strGenero isEqualToString:@"MF"]){
        self.lblGenero.text = @"Homens e mulheres";
    }else if([self.strGenero isEqualToString:@"M"]){
        self.lblGenero.text = @"Homens";
    }else if([self.strGenero isEqualToString:@"F"]){
        self.lblGenero.text = @"Mulheres";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alterandoValores:(id)sender {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setInteger:(int)[[self sliderRaio] value] forKey:@"userRange"];
    [self alterarLabelRaio];
    
    [def synchronize];
}

- (IBAction)inicioToque:(UISlider *)sender {
    NSLog(@"inicio toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
}

- (IBAction)fimToque:(UISlider *)sender {
    NSLog(@"fim toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

- (IBAction)fimToqueFora:(UISlider *)sender {
    NSLog(@"fim toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

- (IBAction)btnTestes:(id)sender {
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    [notification setNotificationStyle:CWNotificationStyleNavigationBarNotification];
    
    [notification setNotificationAnimationInStyle:CWNotificationAnimationStyleTop];
    [notification setNotificationAnimationOutStyle:CWNotificationAnimationStyleTop];
    notification.notificationLabelBackgroundColor = [UIColor whiteColor];
    notification.notificationLabelTextColor = [UIColor orangeColor];
    
    [notification displayNotificationWithMessage:@"Mensagem recebida de Paulo Felipe" forDuration:1.0f];
}

- (IBAction)btnLogout:(id)sender {
    UIActionSheet* action = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:(id<UIActionSheetDelegate>)self
                             cancelButtonTitle:@"Cancelar"
                             destructiveButtonTitle:@"Logout"
                             otherButtonTitles:nil ];
    action.tag = 1;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
    if(actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0: // logout
                NSLog(@"Fazendo logout do usuário");
                [self performSegueWithIdentifier:@"SegueToLogout" sender:self];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                break;
            case 1: // cancelar
                break;
        }
    }else if(actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0: // apagar
                NSLog(@"Apagando o usuário");
                [self performSegueWithIdentifier:@"SegueToLogout" sender:self];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                break;
            case 1: // cancelar
                break;
        }
    }
}

- (IBAction)btnApagarUsuario:(id)sender {
    UIActionSheet* action2 = [[UIActionSheet alloc]
                             initWithTitle:@"Cuidado! Se você apagar o seu usuário, todos os seus dados serão perdidos. Tem certeza de que deseja apagar seu usuário?"
                             delegate:(id<UIActionSheetDelegate>)self
                             cancelButtonTitle:@"Cancelar"
                             destructiveButtonTitle:@"Apagar"
                             otherButtonTitles:nil ];
    action2.tag = 2;
    [action2 showInView:self.view];
}

@end
