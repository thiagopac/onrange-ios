//
//  SettingsTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 03/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SlideNavigationController.h"

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

@end
