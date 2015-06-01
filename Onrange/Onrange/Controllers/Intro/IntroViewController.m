//
//  IntroViewController.m
//  Onrange
//
//  Created by Thiago Castro on 16/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "IntroViewController.h"
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"
#import "AppDelegate.h"

@interface IntroViewController (){
    UIView *rootView;    
}


@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rootView = self.view;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //tema
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if ([def objectForKey:@"tema_cor"] == nil) {
        [def setObject:@"#F46122" forKey:@"tema_cor"];
        [def setObject:@"icone_nav.png" forKey:@"tema_img"];
        
        [def synchronize];
    }
    
    [self.jmImageView reloadAnimationImagesFromGifNamed:@"preloader2"];
    self.jmImageView.animationType = JMAnimatedImageViewAnimationTypeAutomaticLinearWithoutTransition;
    [self.jmImageView startAnimating];

    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoginNotification:) name:@"loginNotification" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];

    [self tentaLogin];

}

-(void)tentaLogin{
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    if (usuario == nil) {
        [self showIntroWithCustomViewFromNib];
    }else{
        
        [usuario loginUsuario:usuario];
    }
}

- (void)receiveLoginNotification:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
//    Usuario *usuario = [userInfo objectForKey:@"usuario"];
   [self performSegueWithIdentifier:@"SegueToHome" sender:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showIntroWithCustomViewFromNib {
    
    EAIntroPage *page1 = [EAIntroPage pageWithCustomViewFromNibNamed:@"FirstScreenView"];
    
    EAIntroPage *page2 = [EAIntroPage pageWithCustomViewFromNibNamed:@"FBIntegrationView"];
    
    EAIntroPage *page3 = [EAIntroPage pageWithCustomViewFromNibNamed:@"PushPermissionView"];
    
    EAIntroPage *page4 = [EAIntroPage pageWithCustomViewFromNibNamed:@"LocationPermissionView"];
    
    EAIntroPage *page5 = [EAIntroPage pageWithCustomViewFromNibNamed:@"LastScreenView"];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4,page5]];
    [intro setDelegate:self];
    
    [intro showInView:rootView animateDuration:0.3];

}

- (void)introDidFinish:(EAIntroView *)introView {    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    if (usuario.id_usuario == 0) {
        [self showIntroWithCustomViewFromNib];
    }
    
    [usuario loginUsuario:usuario];
}

@end
