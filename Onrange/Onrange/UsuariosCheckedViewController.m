//
//  UsuariosCheckedViewController.m
//  Onrange
//
//  Created by Thiago Castro on 05/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "UsuariosCheckedViewController.h"

#import <Restkit/RestKit.h>
#import "MappingProvider.h"
#import "Usuario.h"
#import "Checkin.h"
#import "ConfirmaCheckinViewController.h"
#import <SVProgressHUD.h>
#import "PerfilUsuarioViewController.h"

@interface UsuariosCheckedViewController (){
    Usuario *usuarioDispositivo;
    NSInteger id_local;
    NSString *nome_local;
    NSString *qt_checkin;
    NSString *genero;
}

@property (nonatomic, strong) NSMutableArray *arrUsuarios;
@property (nonatomic, assign) BOOL usuarioEstaNoLocal;

@end

@implementation UsuariosCheckedViewController

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
    
    if (_annotation) {
        id_local = _annotation.id_local;
        nome_local = _annotation.title;
        qt_checkin = _annotation.qt_checkin;
    }else{
        id_local = self.local.id_local;
        nome_local = self.local.nome;
        qt_checkin = self.local.qt_checkin;

    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    usuarioDispositivo = [Usuario carregarPreferenciasUsuario];
    
    if (![def objectForKey:@"genero"]) {
        genero = @"MF";
    }else{
        genero = [def objectForKey:@"genero"];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
    
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.notification dismissNotification];
}

-(void)statusBarCustomizadaWithMsg:(NSString *)msg{
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationAnimationType = CWNotificationAnimationTypeOverlay;
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    UIColor *themeColor = [UIColor colorWithHexString:[def objectForKey:@"tema_cor"]];
    self.notification.notificationLabelBackgroundColor = themeColor;
    
    self.notification.notificationLabelTextColor = [UIColor whiteColor];
    [self.notification displayNotificationWithMessage:msg completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self statusBarCustomizadaWithMsg:@"Carregando usuários no local..."];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaUsuarios];
    });
    [self.collectionView reloadData];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"Ainda logado");
    } else {
        [appDelegate closeSession];
    }
}

- (void)carregaUsuarios {

    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider usuarioMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d/%@/%d",API,(int)id_local,genero,(int)usuarioDispositivo.id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        qt_checkin = [NSString stringWithFormat:@"%d",(int)[self.arrUsuarios count]];
        [self verificaUsuarioNoLocal];
        [self.collectionView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 531) {
              NSLog(@"Erro %ld",self.status);
            [self carregaUsuarios];
        }else{
              NSLog(@"Erro %ld",self.status);
            [self alert:@"Erro ao carregar usuários no local. Tente novamente em alguns minutos.":@"Erro"];
        }

        [self.notification  dismissNotification];
        NSLog(@"ERROR: %@", error);
    }];
    
    [operation start];
}

-(BOOL)verificaUsuarioNoLocal{
    
    for (int i=0; i<[self.arrUsuarios count]; i++) {
        Usuario *usuario = [self.arrUsuarios objectAtIndex:i];
        
        if (usuario.id_usuario == usuarioDispositivo.id_usuario) {
            self.usuarioEstaNoLocal = YES;
            return self.usuarioEstaNoLocal;
        }else{
            self.usuarioEstaNoLocal = NO;
        }
    }
    return self.usuarioEstaNoLocal;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_arrUsuarios count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UsuarioFotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fotoCell" forIndexPath:indexPath];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    Usuario *usuario = [_arrUsuarios objectAtIndex:[indexPath item]];

    [self configureCell:cell withUsuario:usuario];

    return cell;
}

- (void)configureCell:(UsuarioFotoCollectionCell *)cell withUsuario:(Usuario *)usuario {
    cell.userProfilePictureView.profileID = usuario.facebook_usuario;
    if (usuario.liked == 1 && usuario.matched == 0) {
        cell.imgLiked.hidden = NO;
        cell.imgMatch.hidden = YES;
        cell.viewContainerUsuarios.backgroundColor = [UIColor colorWithHexString:@"#FCB826"];
    }else if (usuario.liked == 1 && usuario.matched == 1) {
        cell.imgLiked.hidden = YES;
        cell.imgMatch.hidden = NO;
        cell.viewContainerUsuarios.backgroundColor = [UIColor colorWithHexString:@"#48B163"];
    }else if (usuario.liked == 0 && usuario.matched == 1) {
        cell.imgLiked.hidden = YES;
        cell.imgMatch.hidden = NO;
        cell.viewContainerUsuarios.backgroundColor = [UIColor colorWithHexString:@"#48B163"];
    }else{
        cell.imgLiked.hidden = YES;
        cell.imgMatch.hidden = YES;
        cell.viewContainerUsuarios.backgroundColor = [UIColor whiteColor];
    }

    [self.notification dismissNotification];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UsuariosCheckinHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];

        UIImage *imgCheckout = [UIImage imageNamed:@"btn_checkout_quadrado"];
        UIImage *imgCheckin = [UIImage imageNamed:@"btn_checkin_quadrado"];
        
            if (self.usuarioEstaNoLocal == YES) {
                NSLog(@"O usuário está no local");
                [headerView.btCheckinLocal setImage:imgCheckout forState: UIControlStateNormal];
            }else{
                [headerView.btCheckinLocal setImage:imgCheckin forState: UIControlStateNormal];
            }
        
        NSString *pluralPessoas = [NSString new];
        if ([qt_checkin integerValue] == 1) {
            pluralPessoas = @"pessoa";
        }else{
            pluralPessoas = @"pessoas";
        }
        NSString *nomeLocalCheckins = [NSString stringWithFormat:@"%@ %@ neste local",qt_checkin,pluralPessoas];
        
        [headerView.lblNomeLocal setText:nome_local];
        [headerView.lblQtPessoas setText:nomeLocalCheckins];

        reusableview = headerView;
    }
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UsuarioFotoCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.userProfilePictureView.profileID = nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.usuarioEstaNoLocal == YES) {
        PerfilUsuarioViewController *perfilUsuarioVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"PerfilUsuarioViewController"];
        
        Usuario *usuario = [[self arrUsuarios]objectAtIndex:indexPath.item];
        
        Local *localatual = [Local new];
        localatual.id_local = id_local;
        localatual.nome = nome_local;
        localatual.qt_checkin = qt_checkin;
        
        [perfilUsuarioVC setUsuario:usuario];
        [perfilUsuarioVC setLocal:localatual];
        
        [[self navigationController]pushViewController:perfilUsuarioVC animated:YES];
    }else{
        [self alert:@"Faça checkin neste local para interagir com os outros usuários." :@"Aviso"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Realiza Checkin

- (IBAction)btCheckinLocal:(id)sender {
    if (self.usuarioEstaNoLocal == YES){
        UIActionSheet* actionCheckout = [[UIActionSheet alloc]
                                         initWithTitle:[NSString stringWithFormat:@"Confirmar checkout de %@?", nome_local]
                                         delegate:(id<UIActionSheetDelegate>)self
                                         cancelButtonTitle:@"Sim"
                                         destructiveButtonTitle:@"Não"
                                         otherButtonTitles:nil];
        [actionCheckout setTag:2];
        [actionCheckout showInView:self.view];
    }else{
        UIActionSheet* actionCheckin = [[UIActionSheet alloc]
                                        initWithTitle:[NSString stringWithFormat:@"Confirmar checkin em %@?", nome_local]
                                        delegate:(id<UIActionSheetDelegate>)self
                                        cancelButtonTitle:@"Sim"
                                        destructiveButtonTitle:@"Não"
                                        otherButtonTitles:nil];
        [actionCheckin setTag:1];
        [actionCheckin showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0: //Não
                break;
            case 1: //Sim
                NSLog(@"Tentativa de checkin!");
                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
                [self fazCheckin];
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0: //Não
                break;
            case 1: //Sim
                NSLog(@"Tentativa de checkout!");
                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
                [self fazCheckout];
                break;
        }
    }

}


-(void)fazCheckin{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Checkin class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @"id_checkin", @"checkin_vigente", @"id_checkin_anterior", @"id_local_anterior", @"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Checkin class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"checkin/adicionacheckin";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = usuarioDispositivo.id_usuario;
    checkin.id_local = id_local;
    
    [objectManager postObject:checkin path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    
      self.status = operation.HTTPRequestOperation.response.statusCode;
        
      if(mappingResult != nil){
          
         Checkin *checkinefetuado = [mappingResult firstObject];
          
          [SVProgressHUD dismiss];

              [self carregaUsuarios];
              
              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
              ConfirmaCheckinViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaCheckinViewController"];
              vc.strNomeLocal = nome_local;
              [self presentViewController:vc animated:YES completion:nil];
              [self.view setNeedsLayout];
          }
      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
          
          self.status = operation.HTTPRequestOperation.response.statusCode;
          
          if(self.status == 516) { //Checkin anterior em menos de 5 minutos
              NSLog(@"Erro %ld",self.status);
              [self alert:@"Você deve aguardar alguns minutos para fazer checkin novamente.":@"Erro"];
          }else if(self.status == 517) { //Erro ao fazer checkin
              NSLog(@"Erro %ld",self.status);
              [self fazCheckin];
          }else{
              NSLog(@"Erro %ld",self.status);
              [self alert:@"Erro ao fazer checkin. Tente novamente em alguns minutos.":@"Erro"];
          }
          NSLog(@"Error: %@", error);
          [SVProgressHUD dismiss];
  }];
}

-(void)fazCheckout{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Checkin class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Checkin class] rootKeyPath:nil method:RKRequestMethodPUT];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPUT
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"checkin/fazcheckout";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = usuarioDispositivo.id_usuario;
    
    [objectManager putObject:checkin path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
      self.status = operation.HTTPRequestOperation.response.statusCode;

      Checkin *checkoutefetuado = [mappingResult firstObject];

      [SVProgressHUD dismiss];
      
      [SVProgressHUD showSuccessWithStatus:@"Checkout efetuado!"];
      
      if (checkoutefetuado.id_output == 1) {
          self.usuarioEstaNoLocal = NO;
          [self carregaUsuarios];
          
          [self.view setNeedsLayout];
      }
  }
  failure:^(RKObjectRequestOperation *operation, NSError *error) {
      
      self.status = operation.HTTPRequestOperation.response.statusCode;
      
      if(self.status == 533) {
          NSLog(@"Erro %ld",self.status);
          [self fazCheckout];
      }else{
          NSLog(@"Erro %ld",self.status);
          [self alert:@"Erro ao fazer checkout. Tente novamente em alguns minutos.":@"Erro"];
      }

      NSLog(@"Error: %@", error);
      [SVProgressHUD dismiss];
  }];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

@end
