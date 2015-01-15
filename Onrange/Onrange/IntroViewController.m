//
//  LoadingViewController.m
//  Onrange
//
//  Created by Thiago Castro on 16/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "IntroViewController.h"
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"

static NSString * const sampleDescription1 = @"Pagina 1. Aqui vai o texto explicativo do que é o Onrange, que ele usa mapas, que ele possibilita visualizar os locais com as baladas mais bacanas da cidade.";
static NSString * const sampleDescription2 = @"Página 2. Aqui terá deverá apresentar o botão para link com facebook, pois já faremos o cadastro dele na base Onrange e também no Quickblox";
static NSString * const sampleDescription3 = @"Página 3. Aqui vamos mostrar um pouco do aplicativo, podemos fazer propaganda e mostrar algumas imagens de uso do app.";
static NSString * const sampleDescription4 = @"Página 4. Boas-vindas ao usuário, vamos apresentar uma forma dele nos contactar e podemos dar dicas iniciais sobre o uso do aplicativo, para ele aproveitar ao máximo a sua experiência.";

int contErros = 0;

@interface IntroViewController (){
    UIView *rootView;
}


@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rootView = self.view;
    
    [self.jmImageView reloadAnimationImagesFromGifNamed:@"preloader1"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showIntroWithCustomViewFromNib {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Bem-vindo ao Onrange!";
    page1.desc = sampleDescription1;
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage"];
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Onde irei esta noite?";
    page3.desc = sampleDescription3;
    page3.bgImage = [UIImage imageNamed:@"bg3"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"Aproveite sua experiência";
    page4.desc = sampleDescription4;
    page4.bgImage = [UIImage imageNamed:@"bg4"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
    [intro showInView:rootView animateDuration:0.3];

}

- (void)introDidFinish:(EAIntroView *)introView {    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    [usuario loginUsuario:usuario];
}

@end
