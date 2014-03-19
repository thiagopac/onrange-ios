//
//  SettingsTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 03/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SlideNavigationController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
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
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [[self sliderRaio]setValue:[def integerForKey:@"userRange"]];
    [self alterarLabelRaio];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }

    UILabel *title = [[UILabel alloc] init];
    title.frame = CGRectMake(15, 30 , 110, 20);
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor grayColor];
    title.shadowColor = [UIColor whiteColor];
    title.shadowOffset = CGSizeMake(0.0, 1.0);
    title.text = sectionTitle;
    title.adjustsFontSizeToFitWidth=YES;
    title.minimumScaleFactor=0.5;
    
    self.lblRadio.frame = CGRectMake(250, 30 , 50, 20);
    self.lblRadio.backgroundColor = [UIColor clearColor];
    self.lblRadio.textColor = [UIColor grayColor];
    self.lblRadio.shadowColor = [UIColor whiteColor];
    self.lblRadio.shadowOffset = CGSizeMake(0.0, 1.0);
//
//    self.lblRadio.adjustsFontSizeToFitWidth=YES;
//    self.lblRadio.minimumScaleFactor=0.5;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    [view addSubview:title];
    [view addSubview:self.lblRadio];
    
    return view;
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
