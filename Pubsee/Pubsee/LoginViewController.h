//
//  LoginViewController.h
//  Pubsee
//
//  Created by Thiago Castro on 18/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)LoginButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;

@end
