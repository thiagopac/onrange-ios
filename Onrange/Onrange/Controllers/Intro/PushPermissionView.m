//
//  PushPermissionView.m
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import "PushPermissionView.h"
#import "Usuario.h"

@implementation PushPermissionView


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(habilitaBotao) name:@"vinculouFacebook" object:nil];
    
    [self.btnPushPermission setTitle:@"Faça antes login com Facebook" forState:UIControlStateNormal];
    [self.btnPushPermission setBackgroundColor:[UIColor grayColor]];
    [self.btnPushPermission setUserInteractionEnabled:NO];
}

-(void)habilitaBotao{
    [self.btnPushPermission setTitle:@"Ok! Me avise quando necessário!" forState:UIControlStateNormal];
    [self.btnPushPermission setBackgroundColor:[UIColor colorWithHexString:@"FF9B00"]];
    [self.btnPushPermission setUserInteractionEnabled:YES];
}

- (void)registerForRemoteNotifications{
    
    if ([[UIApplication sharedApplication]respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
//    [QBRequest destroySessionWithSuccessBlock:^(QBResponse *response){
//        NSLog(@"Sessão para registrar push destruída destruída.");
//    }errorBlock:^(QBResponse *response){
//        NSLog(@"Erro ao destruir sessão para registrar push");
//    }];
}

- (IBAction)btnPushPermission:(id)sender {
    [self registerForRemoteNotifications];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"vinculouFacebook" object:nil];
}

@end
