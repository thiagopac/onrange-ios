//
//  ConfirmaMatchViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "ConfirmaMatchViewController.h"

@interface ConfirmaMatchViewController (){
    
@private
    
    NSTimer * countdownTimer;
    NSUInteger remainingTicks;
    
}

-(void)handleTimerTick;

-(void)updateLabel;

@end

@implementation ConfirmaMatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)handleTimerTick
{
    remainingTicks--;
    [self updateLabel];
    
    if (remainingTicks <= 0) {
        [countdownTimer invalidate];
        countdownTimer = nil;
        self.lblTimer.hidden = YES;
        self.btnFechar.hidden = NO;
    }
}

-(void)updateLabel
{
    self.lblTimer.text = [[NSNumber numberWithUnsignedInt:(int)remainingTicks] stringValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.lblNomeUsuario setText:self.strNomeUsuario];
    
    self.btnFechar.hidden = YES;
    
    if (countdownTimer)
        return;
    
    
    remainingTicks = 3;
    [self updateLabel];
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnFechar:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
