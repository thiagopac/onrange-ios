//
//  LoadingViewController.m
//  Onrange
//
//  Created by Thiago Castro on 16/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "IntroViewController.h"
#import "AnimatedGif.h"
#import <Restkit/RestKit.h>
#import "Usuario.h"
#import "MappingProvider.h"

static NSString * const sampleDescription1 = @"Pagina 1. Aqui vai o texto explicativo do que é o Onrange, que ele usa mapas, que ele possibilita visualizar os locais com as baladas mais bacanas da cidade.";
static NSString * const sampleDescription2 = @"Página 2. Aqui terá deverá apresentar o botão para link com facebook, pois já faremos o cadastro dele na base Onrange e também no Quickblox";
static NSString * const sampleDescription3 = @"Página 3. Aqui vamos mostrar um pouco do aplicativo, podemos fazer propaganda e mostrar algumas imagens de uso do app.";
static NSString * const sampleDescription4 = @"Página 4. Boas-vindas ao usuário, vamos apresentar uma forma dele nos contactar e podemos dar dicas iniciais sobre o uso do aplicativo, para ele aproveitar ao máximo a sua experiência.";

@interface IntroViewController (){
    UIView *rootView;
}


@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rootView = self.view;
    
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"finding" ofType:@"gif"]];
    UIImageView *localAnimation = [AnimatedGif getAnimationForGifAtUrl: localUrl];
    
    // For local files (that are loaded immediatly) you can request the size
    localAnimation.frame = CGRectMake(96.0f, 194.0f, localAnimation.image.size.width, localAnimation.image.size.height);
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self.view addSubview:localAnimation];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
//    [self showIntroWithCustomViewFromNib];
    [self loginUsuario];
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
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.user = [def objectForKey:@"graph_usuario"];
    
    usuario.facebook_usuario = [self.user objectForKey:@"id"];
    
    [objectManager postObject:usuario
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          
                        NSInteger status = operation.HTTPRequestOperation.response.statusCode;

                          if(mappingResult != nil){
                              Usuario *userLogged = [mappingResult firstObject];

                              if (userLogged != nil) {
                                  NSLog(@"Login efetuado na base Onrage");
                                  NSUserDefaults  *def = [NSUserDefaults standardUserDefaults];
                                  [def setInteger:userLogged.id_usuario forKey:@"id_usuario"];
                                  [def synchronize];
                                  [self performSegueWithIdentifier:@"SegueToHome" sender:self];
                              }else{
                                  NSLog(@"Usuário inexistente");
                                  [self showIntroWithCustomViewFromNib];
                              }
                          }else{
                              NSLog(@"Erro na resposta de LOGIN USUARIO");
                              [self loginUsuario];
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                        NSInteger status = operation.HTTPRequestOperation.response.statusCode;
                          [self loginUsuario];
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de login");
                      }];
}

- (void)introDidFinish:(EAIntroView *)introView {
    [self loginUsuario];
}

@end