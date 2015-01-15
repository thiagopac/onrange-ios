//
//  PerfilUsuarioViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PerfilUsuarioViewController.h"
#import "Like.h"
#import "Usuario.h"
#import "RestKit.h"
#import "ErroQB.h"
#import "MappingProvider.h"
#import "ConfirmaMatchViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCurtirNotificationNaoSelecionado:) name:@"curtirNotificationNaoSelecionado" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCurtirNotificationSelecionado:) name:@"curtirNotificationSelecionado" object:nil];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    self.QBUser = usuario.facebook_usuario;
    self.QBPassword = usuario.facebook_usuario;
    
//    View Header com cores aleatórias no array

    NSString *color1 = @"#9BC9AB";
    NSString *color2 = @"#9BC9DE";
    NSString *color3 = @"#BBB3C8";
    NSString *color4 = @"#D58B94";
    NSString *color5 = @"#D5D294";
    NSString *color6 = @"#D5A194";
    NSString *color7 = @"#60CD80";
    NSString *color8 = @"#F88B80";
    NSString *color9 = @"#5FAFEC";
    NSString *color10 = @"#F0895B";
    NSString *color11 = @"#F0B25B";
    NSString *color12 = @"#F0585B";
    NSString *color13 = @"#86C05B";
    NSString *color14 = @"#C9B1E0";
    NSString *color15 = @"#93B1E0";
    NSString *color16 = @"#36C1A2";
    NSString *color17 = @"#EE8067";
    NSString *color18 = @"#B99079";
    NSString *color19 = @"#6C7A89";
    NSString *color20 = @"#3498DB";
    NSString *color21 = @"#1ABC9C";
    NSString *color22 = @"#F1C40F";
    NSString *color23 = @"#BDC3C7";
    NSString *color24 = @"#34495E";
    NSString *color25 = @"#27AE60";
    
    NSArray *arrayColors = [NSArray arrayWithObjects:color1,color2,color3,color4,color5,color6,color7,color8,color9,color10,color11,color12,color13,color14,color15,color16,color17,color18,color19,color20,color21,color22,color23,color24,color25, nil];
    
    uint32_t rnd = arc4random_uniform([arrayColors count]);
    
    UIColor *corAleatoria = [UIColor colorWithHexString:[arrayColors objectAtIndex:rnd]];
    
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
    
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    if ((usuario.id_usuario == self.usuario.id_usuario) || self.usuario.matched == 1) {
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
    Like *like = [Like new];
    [like curtirUsuario:self.usuario noLocal:self.local comQBToken:qbtoken];
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

- (void)sendPushNotificationWithMessage:(NSString *)message toUser:(NSUInteger)quickbloxUserID{
    if (quickbloxUserID == 0) {
        return;
    }
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    aps[QBMPushMessageSoundKey] = @"default";
    aps[QBMPushMessageAlertKey] = message;

//    aps[@"id"] = @"2495884";
//    testar amanhã se comentar esses dois itens abaixo, se continuará funcionando pq funcionou com o id errado
    
    NSString *strQuickbloxUserID = [NSString stringWithFormat:@"%lu",(unsigned long)quickbloxUserID];
    
    aps[@"id"] = @"";
    aps[@"quickbloxID"] =
    
    payload[QBMPushMessageApsKey] = aps;
    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];


    [QBRequest sendPush:pushMessage toUsers:strQuickbloxUserID  successBlock:^(QBResponse *response, QBMEvent *event) {
        NSLog(@"Entrou no sucesso!!!");
    } errorBlock:^(QBError *error) {
        NSLog(@"Entrou no erro!!!");
    }];

}

- (void)receiveCurtirNotificationSelecionado:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    Like *likeefetuado = [userInfo objectForKey:@"like"];

    if (likeefetuado.match == 1) {
        [self enviaPushAoSegundoUsuario];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ConfirmaMatchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaMatchViewController"];
        vc.strNomeUsuario = self.usuario.nome_usuario;
        [self presentViewController:vc animated:YES completion:nil];
        [self.view setNeedsLayout];
        [self botaoSelecionado];
    }else if(likeefetuado.match == 0){
        if(self.btnCurtirUsuario.tag == 1) {
            [self botaoSelecionado];
        }else{
            [self botaoNaoSelecionado];
        }
    }
}

- (void)receiveCurtirNotificationNaoSelecionado:(NSNotification *) notification{
    
    [self botaoNaoSelecionado];
}

-(void)enviaPushAoSegundoUsuario{

    Usuario *usuario = [Usuario new];
    usuario = [Usuario carregarPreferenciasUsuario];
    
    //loga na base QB
    [QBRequest logInWithUserLogin:self.QBUser password:self.QBPassword successBlock:^(QBResponse *response, QBUUser *user1){
        
        self.ID_QB1 = user1.ID;
        
        //usa método para saber qual o ID do quickblox de um usuário pelo seu login
        [QBRequest userWithLogin:self.usuario.facebook_usuario successBlock:^(QBResponse *response, QBUUser *user2){
            

            self.ID_QB2 = user2.ID;
            
            
            QBChatDialog *chatDialog = [QBChatDialog new];
            chatDialog.name = @"";
            chatDialog.occupantIDs = @[@(self.ID_QB1),@(self.ID_QB2)];
            
            chatDialog.occupantIDs = [[[chatDialog.occupantIDs sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
            
            chatDialog.type = QBChatDialogTypePrivate;
            
            [QBChat createDialog:chatDialog delegate:self];

            
            //enviando push para o ID do usuário que foi descoberto
            
            [self sendPushNotificationWithMessage:@"Uma pessoa combinou com você!" toUser:self.ID_QB2];
            
        }errorBlock:^(QBResponse *response) {
            //entrou no erro
            
            NSLog(@"Entrou no erro ao tentar descobrir qual o ID do QB de um usuário pelo seu login!");
            
            NSString *erroResponse = [NSString stringWithFormat:@"%@",[response.error.reasons objectForKey:@"errors"]];

            ErroQB *erroQB = [ErroQB new];
            erroQB.id_usuario = usuario.id_usuario;
            erroQB.erro = erroResponse;
            erroQB.funcao = @"enviaPushAoSegundoUsuario-userWithLogin";
            erroQB.plataforma = @"iOS";
            
            [erroQB adicionaErroQB:erroQB];
            
        }];
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"Erro %@",response.error);
        NSLog(@"Entrou no erro de login antes de enviar push!");
        
        NSString *erroResponse = [NSString stringWithFormat:@"%@",[response.error.reasons objectForKey:@"errors"]];
        
        ErroQB *erroQB = [ErroQB new];
        erroQB.id_usuario = usuario.id_usuario;
        erroQB.erro = erroResponse;
        erroQB.funcao = @"enviaPushAoSegundoUsuario-logInWithUserLogin";
        erroQB.plataforma = @"iOS";
        
        [erroQB adicionaErroQB:erroQB];
        
        
        
    }];
}

- (void)completedWithResult:(Result *)result{
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        QBChatDialogResult *res = (QBChatDialogResult *)result;
        QBChatDialog *dialog = res.dialog;
        NSLog(@"Dialog: %@", res.dialog);
    }
}

@end