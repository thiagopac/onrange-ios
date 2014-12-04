//
//  PerfilUsuarioViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PerfilUsuarioViewController.h"
#import "Like.h"
#import "RestKit.h"
#import "MappingProvider.h"
#import "ConfirmaMatchViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PerfilUsuarioViewController ()<QBActionStatusDelegate>{
    NSInteger id_usuario1;
    NSInteger id_usuario2;
    NSString *qbtoken;
}

@end

@implementation PerfilUsuarioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=640",self.usuario.facebook_usuario];
//    NSURL *url = [NSURL URLWithString:link];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    self.imgFotoPerfilUsuario.image = [UIImage imageWithData:data];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.QBUser = [def objectForKey:@"facebook_usuario"];
    self.QBPassword = [def objectForKey:@"facebook_usuario"];
    
//    View Header com cores aleatórias no array

//#9BC9AB
    UIColor * color1 = [UIColor colorWithRed:9/255.0f green:188/255.0f blue:154/255.0f alpha:1.0f];
//#9BC9DE
    UIColor * color2 = [UIColor colorWithRed:155/255.0f green:201/255.0f blue:222/255.0f alpha:1.0f];
//#BBB3C8
    UIColor * color3 = [UIColor colorWithRed:187/255.0f green:179/255.0f blue:200/255.0f alpha:1.0f];
//#D58B94
    UIColor * color4 = [UIColor colorWithRed:213/255.0f green:139/255.0f blue:148/255.0f alpha:1.0f];
//#D5D294
    UIColor * color5 = [UIColor colorWithRed:213/255.0f green:210/255.0f blue:148/255.0f alpha:1.0f];
//#D5A194
    UIColor * color6 = [UIColor colorWithRed:213/255.0f green:161/255.0f blue:148/255.0f alpha:1.0f];
//#60CD80
    UIColor * color7 = [UIColor colorWithRed:96/255.0f green:205/255.0f blue:128/255.0f alpha:1.0f];
//#F88B80
    UIColor * color8 = [UIColor colorWithRed:248/255.0f green:139/255.0f blue:128/255.0f alpha:1.0f];
//#5FAFEC
    UIColor * color9 = [UIColor colorWithRed:95/255.0f green:175/255.0f blue:236/255.0f alpha:1.0f];
//#F0895B
    UIColor * color10 = [UIColor colorWithRed:240/255.0f green:137/255.0f blue:91/255.0f alpha:1.0f];
//#F0B25B
    UIColor * color11 = [UIColor colorWithRed:240/255.0f green:178/255.0f blue:91/255.0f alpha:1.0f];
//#F0585B
    UIColor * color12 = [UIColor colorWithRed:240/255.0f green:88/255.0f blue:91/255.0f alpha:1.0f];
//#86C05B
    UIColor * color13 = [UIColor colorWithRed:134/255.0f green:192/255.0f blue:91/255.0f alpha:1.0f];
//#C9B1E0
    UIColor * color14 = [UIColor colorWithRed:201/255.0f green:177/255.0f blue:224/255.0f alpha:1.0f];
//#93B1E0
    UIColor * color15 = [UIColor colorWithRed:147/255.0f green:177/255.0f blue:224/255.0f alpha:1.0f];
//#36C1A2
    UIColor * color16 = [UIColor colorWithRed:54/255.0f green:193/255.0f blue:162/255.0f alpha:1.0f];
//#EE8067
    UIColor * color17 = [UIColor colorWithRed:238/255.0f green:128/255.0f blue:103/255.0f alpha:1.0f];
//#B99079
    UIColor * color18 = [UIColor colorWithRed:185/255.0f green:144/255.0f blue:121/255.0f alpha:1.0f];
//#6C7A89
    UIColor * color19 = [UIColor colorWithRed:108/255.0f green:122/255.0f blue:137/255.0f alpha:1.0f];
//#3498DB
    UIColor * color20 = [UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f];
//#1ABC9C
    UIColor * color21 = [UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f];
//#F1C40F
    UIColor * color22 = [UIColor colorWithRed:241/255.0f green:196/255.0f blue:15/255.0f alpha:1.0f];
//#BDC3C7
    UIColor * color23 = [UIColor colorWithRed:189/255.0f green:195/255.0f blue:199/255.0f alpha:1.0f];
//#34495E
    UIColor * color24 = [UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f];
//#27AE60
    UIColor * color25 = [UIColor colorWithRed:39/255.0f green:174/255.0f blue:96/255.0f alpha:1.0f];
    
    NSArray *arrayColors = [NSArray arrayWithObjects:color1,color2,color3,color4,color5,color6,color7,color8,color9,color10,color11,color12,color13,color14,color15,color16,color17,color18,color19,color20,color21,color22,color23,color24,color25, nil];
    
    uint32_t rnd = arc4random_uniform([arrayColors count]);
    
    UIColor *corAleatoria = [arrayColors objectAtIndex:rnd];
    
    self.viewColoredHeader.backgroundColor = corAleatoria;
    
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        // session created
        
        qbtoken = [[QBBaseModule sharedModule]token];
        
        NSLog(@"QB-Token: %@",qbtoken);
        
    } errorBlock:^(QBResponse *response) {
        // handle errors
        NSLog(@"%@", response.error);
    }];
    
    self.imgProfileUsuario.pictureCropping = FBProfilePictureCroppingSquare;
    self.imgProfileUsuario.profileID = self.usuario.facebook_usuario;
    self.lblNomeUsuario.text = self.usuario.nome_usuario;
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    if (([def integerForKey:@"id_usuario"] == self.usuario.id_usuario) || self.usuario.matched == 1) {
        self.btnCurtirUsuario.hidden = YES;
    }
    if (self.usuario.liked == 1) {
        [self botaoSelecionado];
    }else{
        [self botaoNaoSelecionado];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCurtirUsuario:(id)sender {
    [self curtirUsuario];
    [self botaoLoading];
}

-(void)botaoSelecionado{
    [self.loading stopAnimating];
    
    [self.btnCurtirUsuario setTag:2];
    
    UIImage *imgCurtido = [UIImage imageNamed:@"btn_like2"];
    [self.btnCurtirUsuario setImage:imgCurtido forState:UIControlStateNormal];
}

-(void)botaoLoading{
    [self.loading startAnimating];
}

-(void)botaoNaoSelecionado{
    [self.loading stopAnimating];
    
    [self.btnCurtirUsuario setTag:1];
    
    UIImage *imgCurtir = [UIImage imageNamed:@"btn_like"];
    [self.btnCurtirUsuario setImage:imgCurtir forState:UIControlStateNormal];
}

-(void)curtirUsuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario1",@"id_usuario2",@"id_local", @"qbtoken"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Like class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario1", @"id_usuario2", @"id_local", @"id_like", @"match", @"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Like class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Like"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"like/adicionalike";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Like *like= [Like new];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    like.id_usuario2 = self.usuario.id_usuario;

    id_usuario1 = [def integerForKey:@"id_usuario"];
    like.id_usuario1 = id_usuario1;    like.id_local = self.local.id_local;
    like.qbtoken = qbtoken;
    
    [objectManager postObject:like path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      if(mappingResult != nil){
          NSLog(@"Dados de like enviados e recebidos com sucesso!");
          Like *likeefetuado = [mappingResult firstObject];
          
              if (likeefetuado.match == 1) {
                  
                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                  ConfirmaMatchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaMatchViewController"];
                  vc.strNomeUsuario = self.usuario.nome_usuario;
                  [self presentViewController:vc animated:YES completion:nil];
                  [self.view setNeedsLayout];
                  [self botaoLoading];
              }else if(likeefetuado.match == 0){
                  if(self.btnCurtirUsuario.tag == 1) {
                      [self botaoSelecionado];
                  }else{
                      [self botaoNaoSelecionado];
                  }
              }
      }
  }failure:^(RKObjectRequestOperation *operation, NSError *error) {
      if(self.status == 521){
          NSLog(@"Erro ao buscar checkin do usuario de destino.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 522){
          NSLog(@"Usuario de destino realizou checkout.");
          [self botaoNaoSelecionado];
          [SVProgressHUD showErrorWithStatus:@"Erro. Esta pessoa deixou o local."];
      }else if(self.status == 523){
          NSLog(@"Erro ao verificar se ja existe like.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 524){
          NSLog(@"Erro ao curtir.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 525){
          NSLog(@"Erro ao verificar se houve match.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 526){
          NSLog(@"Erro ao buscar ID do QB do usuario 1.");
          [self botaoNaoSelecionado];
      }else if(self.status == 527){
          NSLog(@"Erro ao buscar ID do QB do usuario 2.");
          [self botaoNaoSelecionado];
      }else if(self.status == 528){
          NSLog(@"Erro ao criar match.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 529){
          NSLog(@"Erro ao descurtir.");
          [self botaoSelecionado];
          [self curtirUsuario];
      }else if(self.status == 543){
          NSLog(@"Erro ao criar chat no QB.");
          [self botaoNaoSelecionado];
          [self curtirUsuario];
      }else{
          [self curtirUsuario];
          NSLog(@"Error: %@", error);
          NSLog(@"Falha ao tentar enviar dados de like");
      }

  }];
}

@end