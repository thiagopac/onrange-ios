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

@interface UsuariosCheckedViewController (){
    NSInteger id_local;
    NSString *nome_local;
    NSString *qt_checkin;
    bool usuario_no_local;
    int id_usuario;
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
    
    UsuariosCheckinHeaderView *headerView = [[UsuariosCheckinHeaderView alloc]init];
    
    headerView.btCheckinLocal.faceColor = [UIColor colorWithRed:0.333 green:0.631 blue:0.851 alpha:1.0];
    headerView.btCheckinLocal.sideColor = [UIColor colorWithRed:0.310 green:0.498 blue:0.702 alpha:1.0];
    
    headerView.btCheckinLocal.radius = 4.0;
    headerView.btCheckinLocal.margin = 4.0;
    headerView.btCheckinLocal.depth = 3.0;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    id_usuario = [def integerForKey:@"id_usuario"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaUsuarios];
    });
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
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
    
    self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:244/255.0f green:97/255.0f blue:34/255.0f alpha:1.0f];
    self.notification.notificationLabelTextColor = [UIColor whiteColor];
    [self.notification displayNotificationWithMessage:msg completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self statusBarCustomizadaWithMsg:@"Carregando usuários no local..."];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Usuarios" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d/MF",API,id_local]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        qt_checkin = [NSString stringWithFormat:@"%d",[self.arrUsuarios count]];
        [self.collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Ocorreu um erro"];
        [self.notification  dismissNotification];
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
}

-(BOOL)verificaUsuarioNoLocal{
    if ([self.arrUsuarios containsObject:[NSNumber numberWithInt:id_usuario]]) {
        usuario_no_local = YES;
    }else{
        usuario_no_local = NO;
    }
    return usuario_no_local;
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
    [self.notification dismissNotification];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UsuariosCheckinHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];

        for (int i=0; i<[self.arrUsuarios count]; i++) {
            Usuario *usuario = [self.arrUsuarios objectAtIndex:i];
            
            if (usuario.id_usuario == id_usuario) {
                NSLog(@"O usuário está no local");
                self.usuarioEstaNoLocal = YES;
                [headerView.btCheckinLocal setTitle:@"Checkout" forState: UIControlStateNormal];
            }else{
                NSString *nomeLocalCheckins = [NSString stringWithFormat:@"Entrar em %@ [ %@ ]",nome_local,qt_checkin];
                if (nomeLocalCheckins != nil) {
                    self.usuarioEstaNoLocal = NO;
                    [headerView.btCheckinLocal setTitle:nomeLocalCheckins forState: UIControlStateNormal];
                }
            }
        }

        reusableview = headerView;
    }
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UsuarioFotoCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.userProfilePictureView.profileID = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Realiza Checkin

- (IBAction)btCheckinLocal:(id)sender {
    if (self.usuarioEstaNoLocal == YES){
       NSLog(@"vou deslogar ele agora");
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
//                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
//                [self fazCheckin];
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Checkin"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"checkin/adicionacheckin";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = id_usuario;
    checkin.id_local = id_local;
    
    [objectManager postObject:checkin
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                                NSLog(@"Dados de checkin enviados e recebidos com sucesso!");
                                Checkin *checkinefetuado = [mappingResult firstObject];
                              [SVProgressHUD dismiss];
                              if (checkinefetuado.id_output == 1) {
                                  [self carregaUsuarios];
                                  
                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  ConfirmaCheckinViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaCheckinViewController"];
                                  vc.strNomeLocal = nome_local;
                                  [self presentViewController:vc animated:YES completion:nil];
                                  [self.view setNeedsLayout];
                              }else if(checkinefetuado.id_output == 2){
                                  [self alert:@"Ocorreu um erro na tentativa de efetuar checkin. Tente novamente em alguns segundos":@"Erro"];
                              }else if(checkinefetuado.id_output == 3){
                                  [self alert:@"O tempo mínimo para fazer um novo checkin é de 5 minutos":@"Erro"];
                              }else{
                                  NSLog(@"Ocorreu um erro ao efetuar o checkin");
                              }
                          }else{
                              NSLog(@"Falha ao tentar fazer checkin");
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de checkin");
                      }];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

@end
