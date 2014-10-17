//
//  SignUpViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adicionaUsuarioQB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adicionaUsuarioQB{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.QBUser = [def objectForKey:@"facebook_usuario"];
    self.QBPassword = [def objectForKey:@"facebook_usuario"];
    
    QBUUser *user = [QBUUser user];
    user.login = self.QBUser;
    user.password = self.QBPassword;

    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        // Success, do something
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"error: %@", response.error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
