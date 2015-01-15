//
//  FBIntegrationView.m
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import "FBIntegrationView.h"
#import "AppDelegate.h"

@implementation FBIntegrationView

- (IBAction)btnFB:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate openSessionWithAllowLoginUI:YES];
    [self.activityIndicator startAnimating];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter]addObserver:self
     selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
}

- (void)populateUserDetails {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {
        [self.activityIndicator stopAnimating];
        self.btnFB.hidden = YES;
        self.viewContainer.hidden = NO;
        self.lblNomeUsuario.hidden = NO;

        self.imgProfileUsuario.profileID = user.id;
        self.lblNomeUsuario.text = user.first_name;
    }];
}

@end
