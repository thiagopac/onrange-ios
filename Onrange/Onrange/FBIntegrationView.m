//
//  FBIntegrationView.m
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import "FBIntegrationView.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FBIntegrationView

- (IBAction)btnFB:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate closeSession];
    
    [appDelegate openSessionWithAllowLoginUI:YES];

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
    self.lblNomeUsuario.text = @"";
    self.imgFotoUsuario.layer.cornerRadius = 70.0f;
    self.imgFotoUsuario.layer.masksToBounds = YES;
}

- (void)populateUserDetails {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user) {

        [self.btnFB setBackgroundColor:[UIColor colorWithHexString:@"#3498db"]];
        [self.btnFB setTitle:@"          Conectado!" forState:UIControlStateNormal];
        [self.btnFB setUserInteractionEnabled:NO];
        self.viewContainer.hidden = NO;
        self.imgFBmedal.hidden = YES;
        
        self.imgFotoUsuario.hidden = NO;
        
        NSString *strURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=280&height=280",[user objectForKey:@"id"]];
        [self.imgFotoUsuario sd_setImageWithURL:[NSURL URLWithString:strURL]];
        self.lblNomeUsuario.text = user.first_name;
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"vinculouFacebook" object:nil userInfo:nil];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FBSessionStateChangedNotification object:nil];
}

@end
