//
//  AppDelegate.m
//  Onrange
//
//  Created by Thiago Castro on 16/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"
#import "AppDelegate.h"
#import "CWStatusBarNotification.h"
#import "MinhasCombinacoesTableViewController.h"
#import "MPGNotification.h"
#import "ErroQB.h"


NSString *const FBSessionStateChangedNotification =
@"Onrange:FBSessionStateChangedNotification";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
	
	MenuViewController *leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
	
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;
	
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    
    // Creating a custom bar button for left menu
	UIButton *button2  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 35)];
	[button2 setImage:[UIImage imageNamed:@"icone_menu"] forState:UIControlStateNormal];
	[button2 addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
	[SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;

     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//integração com QuickBlox
    // Set QuickBlox credentials
    [QBApplication sharedApplication].applicationId = 10625;
    [QBConnection registerServiceKey:@"rrTrFYFOECqjTAe"];
    [QBConnection registerServiceSecret:@"hM5vAmpBYYGV-p5"];
    [QBSettings setAccountKey:@"TzErECZmN1ELxzE22avj"];

#ifndef DEBUG
    [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
#endif
    
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
#endif
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    
    // Get push alert
    NSString *message = [[userInfo objectForKey:QBMPushMessageApsKey] objectForKey:QBMPushMessageAlertKey];
    
    NSMutableDictionary *pushInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    
    // get push rich content
    NSString *richContent = [userInfo objectForKey:@"rich_content"];
    if(richContent != nil){
        [pushInfo setObject:richContent forKey:@"rich_content"];
    }
    
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MinhaNotificacao" object:self userInfo:pushInfo];
    
    NSDictionary *aps = userInfo[@"aps"];
    NSString *msgBody = aps[@"alert"];
    
    NSString *nome;
    NSString *msg;
    
    NSArray *tempArray = [msgBody componentsSeparatedByString:@":"];
    
    if([tempArray count]==2){
        nome = [tempArray objectAtIndex:0];
        msg = [tempArray objectAtIndex:1];
    }

    NSArray *buttonArray = [NSArray arrayWithObjects:@"Ver", nil];
    
    MPGNotification *notification = [MPGNotification new];
    
    if (nome != nil && msg != nil) {
        
        notification = [MPGNotification notificationWithTitle:nome subtitle:msg backgroundColor:[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] iconImage:[UIImage imageNamed:@"ChatIcon"]];
        [notification setButtonConfiguration:buttonArray.count withButtonTitles:buttonArray];
    
    }else{  
        notification = [MPGNotification notificationWithTitle:@"Aviso" subtitle:msgBody backgroundColor:[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0] iconImage:[UIImage imageNamed:@"ChatIcon"]];
    
    }
    
    notification.duration = 3.0;
    notification.swipeToDismissEnabled = YES;
    [notification setAnimationType:MPGNotificationAnimationTypeLinear];

    [notification setButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex) {

        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MinhasCombinacoesTableViewController *controller = (MinhasCombinacoesTableViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MinhasCombinacoesTableViewController"];
        
        [navigationController pushViewController:controller animated:YES];

    }];
    
    [notification show];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    
    // QuickBlox session creation
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = usuario.facebook_usuario;
    extendedAuthRequest.userPassword = usuario.facebook_usuario;
    //
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session) {
        
        // register for push notifications
        [QBRequest registerSubscriptionForDeviceToken:deviceToken successBlock:^(QBResponse *response, NSArray *subscriptions) {
            // successfully subscribed
        } errorBlock:^(QBError *error) {
            // Handle error
            NSString *erroResponse = [NSString stringWithFormat:@"%@",[error.reasons objectForKey:@"errors"]];
            
            ErroQB *erroQB = [ErroQB new];
            erroQB.facebook_usuario = usuario.facebook_usuario;
            erroQB.erro = erroResponse;
            erroQB.funcao = @"didRegisterForRemoteNotificationsWithDeviceToken";
            erroQB.plataforma = @"iOS";
            
            [erroQB adicionaErroQB:erroQB];
        }];
        
    } errorBlock:^(QBResponse *response) {
        NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
        
        NSLog(@"Erro ao se registrar para pushes. Detalhes: %@",errorMessage);
        
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[QBChat instance] logout];
//    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
//        // Successful logout
//    } errorBlock:^(QBResponse *response) {
//        // Handle error
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[QBChat instance] logout];
}

#pragma mark - Authentication methods
/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
            self.user = nil;
            break;
        case FBSessionStateClosedLoginFailed:
            self.user = nil;
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Aviso"
                                  message:@"O Onrange precisa de permissão para acessar o seu facebook e criar o seu perfil. Clique em Conectar com Facebook novamente. Se o erro persistir, feche o aplicativo e abra novamente."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        
    }

}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    // Ask for permissions for getting info about uploaded
    // custom photos.
    NSArray *permissions = [NSArray arrayWithObjects:
                            @"basic_info",@"email",
                            nil];
    
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

/*
 * Closes the active Facebook session
 */
- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - Personalization methods
/*
 * Makes a request for user data and invokes a callback
 */
- (void)requestUserData:(UserDataLoadedHandler)handler
{
    // If there is saved data, return this.
    if (nil != self.user) {
        if (handler) {
            handler(self, self.user);
        }
    } else if (FBSession.activeSession.isOpen) {
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 // Update menu user info
                 self.menu.profileID = [user objectForKey:@"id"];
                 // Save the user data
                 self.user = user;
                                  
                 Usuario *usuario = [Usuario new];
                 
                 usuario.nome_usuario = user.first_name;
                 usuario.sobrenome_usuario = user.last_name;
                 usuario.email_usuario = [user objectForKey:@"email"];
                 usuario.facebook_usuario = [user objectForKey:@"id"];
                 usuario.idioma_usuario = [user objectForKey:@"locale"];
                 usuario.aniversario_usuario = [user objectForKey:@"birthday"];
                 
                 NSArray *tempArray = [[user objectForKey:@"location"][@"name"] componentsSeparatedByString:@","];
                 usuario.cidade_usuario = [tempArray objectAtIndex:0];
                 usuario.pais_usuario = [tempArray objectAtIndex:1];
                 
                 _valida_sexo = [user objectForKey:@"gender"];
                 if ([_valida_sexo isEqualToString:@"male"]) {
                     usuario.sexo_usuario = @"M";
                 }else if([_valida_sexo isEqualToString:@"female"]) {
                     usuario.sexo_usuario = @"F";
                 }
                 
                 [Usuario salvarPreferenciasUsuario:usuario];
                
                 [usuario loginUsuarioDelegate:usuario];
                 if (handler) {
                     handler(self, self.user);
                 }
             }
         }];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    return [FBSession.activeSession handleOpenURL:url];
}

@end
