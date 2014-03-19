//
//  SettingsTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 03/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISlider *sliderRaio;
@property (strong, nonatomic) IBOutlet UILabel *lblRadio;
- (IBAction)inicioToque:(UISlider *)sender;
- (IBAction)fimToque:(UISlider *)sender;
- (IBAction)fimToqueFora:(UISlider *)sender;


@end
