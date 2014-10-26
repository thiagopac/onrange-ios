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
#import "SignUpViewController.h"
#import "CWStatusBarNotification.h"


NSString *const FBSessionStateChangedNotification =
@"com.facebook.samples.SocialCafe:FBSessionStateChangedNotification";

NSString *const FBMenuDataChangedNotification =
@"com.facebook.samples.SocialCafe:FBMenuDataChangedNotification";

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
    
    [[NSNotificationCenter defaultCenter]  postNotificationName:kPushDidReceive object:nil userInfo:pushInfo];
    
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    [notification setNotificationStyle:CWNotificationStyleNavigationBarNotification];
    
    [notification setNotificationAnimationInStyle:CWNotificationAnimationStyleTop];
    [notification setNotificationAnimationOutStyle:CWNotificationAnimationStyleTop];
    notification.notificationLabelBackgroundColor = [UIColor whiteColor];
    notification.notificationLabelTextColor = [UIColor orangeColor];
    
    [notification displayNotificationWithMessage:@"Mensagem recebida" forDuration:1.0f];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // register for push notifications
    [QBRequest registerSubscriptionForDeviceToken:deviceToken successBlock:^(QBResponse *response, NSArray *subscriptions) {
        // successfully subscribed
    } errorBlock:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

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
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
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
                                  message:@"O Onrange precisa de permissão para acessar o seu facebook e criar o seu perfil. Clique em Conectar com Facebook novamente."
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
                 self.menu.profileID = user.id;
                 // Save the user data
                 self.user = user;
                 
                 //cadastra usuário ou valida
                 _nome_usuario = user.first_name;
                 _email_usuario = [user objectForKey:@"email"];
                 _facebook_usuario = user.id;
                 NSUserDefaults  *def = [NSUserDefaults standardUserDefaults];
                 [def setObject:user.id forKey:@"facebook_usuario"];
                 _valida_sexo = [user objectForKey:@"gender"];
                 if ([_valida_sexo isEqualToString:@"male"]) {
                     _sexo_usuario = @"M";
                 }else if([_valida_sexo isEqualToString:@"female"]) {
                     _sexo_usuario = @"F";
                 }
                 [self loginUsuario];
                 if (handler) {
                     handler(self, self.user);
                 }
             }
         }];
    }
}

-(void)loginUsuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"nome_usuario", @"sexo_usuario", @"facebook_usuario", @"email_usuario", @"id_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Usuario"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/login";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario = [Usuario new];

    usuario.facebook_usuario = _facebook_usuario;
    
    [objectManager postObject:usuario
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                              Usuario *userLogged = [mappingResult firstObject];
                              if (userLogged != nil) {
                                  NSLog(@"Login efetuado na base Onrage");
                                  NSUserDefaults  *def = [NSUserDefaults standardUserDefaults];
                                  [def setInteger:userLogged.id_usuario forKey:@"id_usuario"];
                                  
                                  [def synchronize];
                              }else{
                                  NSLog(@"Usuário inexistente");
                                  [self adicionaUsuario];
                              }
                          }else{
                              NSLog(@"Erro na resposta de LOGIN USUARIO");
                              [self loginUsuario];
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Erro 404");
                          [self loginUsuario];
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de login");
                      }];
}

-(void)adicionaUsuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"nome_usuario", @"sexo_usuario", @"facebook_usuario", @"email_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"nome_usuario", @"sexo_usuario", @"facebook_usuario", @"email_usuario", @"id_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Usuario"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/adicionausuario";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario = [Usuario new];
    
    usuario.nome_usuario = _nome_usuario;
    usuario.sexo_usuario = _sexo_usuario;
    usuario.email_usuario = _email_usuario;
    usuario.facebook_usuario = _facebook_usuario;
    
    [objectManager postObject:usuario
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                              NSLog(@"Login efetuado na base Onrage");
                              Usuario *userLogged = [mappingResult firstObject];
                              NSUserDefaults  *def = [NSUserDefaults standardUserDefaults];
                              [def setInteger:userLogged.id_usuario forKey:@"id_usuario"];

                              [def synchronize];
                              
                              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                              SignUpViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
                              [self.window makeKeyAndVisible];
                              [self.window.rootViewController presentViewController:vc animated:YES completion:NULL];
                              
                          }else{
                              NSLog(@"Falha ao tentar logar na base Onrange");
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Erro 404");
                          [self adicionaUsuario];
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de login");
                      }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    return [FBSession.activeSession handleOpenURL:url];
}



@end
