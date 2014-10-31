//
//  PerfilUsuarioTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PerfilUsuarioTableViewController.h"
#import "Like.h"
#import "RestKit.h"
#import "MappingProvider.h"
#import "ConfirmaMatchViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PerfilUsuarioTableViewController ()<QBActionStatusDelegate>{
    NSInteger id_usuario1;
    NSInteger id_usuario2;
    NSString *qbtoken;
}

@end

@implementation PerfilUsuarioTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
        self.cellCurtir.hidden = YES;
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
    [self.btnCurtirUsuario setBackgroundColor:[UIColor colorWithRed:139/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f]];
    [self.btnCurtirUsuario setTitle:@"Curtido" forState:UIControlStateNormal];
}

-(void)botaoLoading{
    [self.loading startAnimating];
    [self.btnCurtirUsuario setBackgroundColor:[UIColor colorWithRed:255/255.0f green:87/255.0f blue:15/255.0f alpha:1.0f]];
    [self.btnCurtirUsuario setTitle:@"" forState:UIControlStateNormal];
}

-(void)botaoNaoSelecionado{
    [self.loading stopAnimating];
    [self.btnCurtirUsuario setBackgroundColor:[UIColor colorWithRed:255/255.0f green:87/255.0f blue:15/255.0f alpha:1.0f]];
    [self.btnCurtirUsuario setTitle:@"Curtir" forState:UIControlStateNormal];
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
    id_usuario1 = [def integerForKey:@"id_usuario"];
    like.id_usuario1 = id_usuario1;
    like.id_usuario2 = self.usuario.id_usuario;
    like.id_local = self.local.id_local;
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
              NSLog(@"Retorno da CallAPI: %@",likeefetuado.chat);
              [self.view setNeedsLayout];
              [self botaoLoading];
          }else if(likeefetuado.match == 0){
              if (likeefetuado.id_output == 4) {
                  [self botaoNaoSelecionado];
              }else if (likeefetuado.id_output ==1){
                  [self botaoSelecionado];
              }else if (likeefetuado.id_output == 2){
                  [self botaoSelecionado];
                  [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro"];
              }else if (likeefetuado.id_output == 3){
                  [self botaoSelecionado];
                  [SVProgressHUD showErrorWithStatus:@"Esta pessoa não está mais no local"];
              }
          }else{
              NSLog(@"Ocorreu um erro ao efetuar o like");
          }
      }else{
          NSLog(@"Falha ao tentar dar o like");
      }
  }
  failure:^(RKObjectRequestOperation *operation, NSError *error) {
      NSLog(@"Erro 404");
      [self curtirUsuario];
      NSLog(@"Error: %@", error);
      NSLog(@"Falha ao tentar enviar dados de like");
  }];
}
@end
