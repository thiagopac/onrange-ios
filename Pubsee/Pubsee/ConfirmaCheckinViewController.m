//
//  ConfirmaCheckinViewController.m
//  Onrange
//
//  Created by Thiago Castro on 19/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "ConfirmaCheckinViewController.h"

@interface ConfirmaCheckinViewController ()

@end

@implementation ConfirmaCheckinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnFechar:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
