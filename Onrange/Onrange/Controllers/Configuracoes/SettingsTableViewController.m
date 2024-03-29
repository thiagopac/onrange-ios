//
//  SettingsTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 03/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "CWStatusBarNotification.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Usuario.h"

@interface SettingsTableViewController (){
    int prev;
    NSString *ambienteAPI;
}

@end

@implementation SettingsTableViewController


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

-(void)alterarLabelRaio
{
    self.lblRadio.text = [NSString stringWithFormat:@"%d KM",(int)[[self sliderRaio] value]];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)menuAbriu:(NSNotification *)notification {
    if([[SlideNavigationController sharedInstance] isMenuOpen]){
        self.tableView.scrollEnabled = NO;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
    self.lblRadio.frame = CGRectMake(250, -25 , 50, 20);
    self.lblRadio.backgroundColor = [UIColor clearColor];
    self.lblRadio.textColor = [UIColor grayColor];
    self.lblRadio.shadowColor = [UIColor whiteColor];
    self.lblRadio.shadowOffset = CGSizeMake(0.0, 1.0);
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def integerForKey:@"userRange"])
        [[self sliderRaio]setValue:[def integerForKey:@"userRange"]];
    else
        [[self sliderRaio]setValue:20];

    [self alterarLabelRaio];
    
    if([[QBChat instance] isLoggedIn]){
        [[QBChat instance] logout];
    }
    
    Usuario *usuario = [Usuario new];
    
    usuario = [Usuario carregarPreferenciasUsuario];
    
    if([usuario.facebook_usuario isEqualToString:@"873898955974353"] || [usuario.facebook_usuario isEqualToString:@"10203049470773190"]){
        self.cellAmbiente.hidden = NO;
    }

    
	if ([def objectForKey:@"ambiente"] != nil) {
        NSString *ambiente = [def objectForKey:@"ambiente"];
        
        if ([ambiente isEqualToString:@"Produção"]) {
            ambienteAPI = API;
        }else if ([ambiente isEqualToString:@"Desenvolvimento"]){
            ambienteAPI = API_DEV;
        }else{
            ambienteAPI = API;
		}
    }else{
            ambienteAPI = API;
	}

}

-(void)viewDidAppear:(BOOL)animated{
  
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
}

-(void)viewWillAppear:(BOOL)animated{

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    self.strGenero = [def objectForKey:@"genero"];
    
    if (self.strGenero == nil) {
        self.lblGenero.text = @"Homens e mulheres";
    }else if([self.strGenero isEqualToString:@"MF"]){
        self.lblGenero.text = @"Homens e mulheres";
    }else if([self.strGenero isEqualToString:@"M"]){
        self.lblGenero.text = @"Homens";
    }else if([self.strGenero isEqualToString:@"F"]){
        self.lblGenero.text = @"Mulheres";
    }
    
    if ([def objectForKey:@"ambiente"]!= nil) {
        self.strAmbiente = [NSString stringWithFormat:@"Ambiente API: %@",[def objectForKey:@"ambiente"]];
    }else{
         self.strAmbiente = @"Ambiente API: Produção";
    }
    
    self.lblAmbiente.text = self.strAmbiente;
    
    if ([[def objectForKey:@"tema_cor"]isEqualToString:@"#F46122"]) { //DIA
        self.lblTema.text = @"Dia";
    } else if ([[def objectForKey:@"tema_cor"]isEqualToString:@"#2C3E50"]) { //NOITE
        self.lblTema.text = @"Noite";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alterandoValores:(id)sender {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setInteger:(int)[[self sliderRaio] value] forKey:@"userRange"];
    [self alterarLabelRaio];
    
    [def synchronize];
}

- (IBAction)inicioToque:(UISlider *)sender {
    NSLog(@"inicio toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
}

- (IBAction)fimToque:(UISlider *)sender {
    NSLog(@"fim toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

- (IBAction)fimToqueFora:(UISlider *)sender {
    NSLog(@"fim toque");
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

- (IBAction)btnLogout:(id)sender {
    UIActionSheet* action = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:(id<UIActionSheetDelegate>)self
                             cancelButtonTitle:@"Cancelar"
                             destructiveButtonTitle:@"Logout"
                             otherButtonTitles:nil ];
    action.tag = 1;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0: // logout
                NSLog(@"Fazendo logout do usuário");
                //finalizando sessão do facebook se tiver alguma
                
                if (FBSession.activeSession.isOpen || FBSession.activeSession.state ||FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateCreatedOpening){
                
                        [appDelegate closeSession];
                }
                
                [self performSegueWithIdentifier:@"SegueToLogout" sender:self];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                break;
            case 1: // cancelar
                break;
        }
    }else if(actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0: // apagar
                [self apagaUsuario];
                break;
            case 1: // cancelar
                break;
        }
    }
}

- (IBAction)btnApagarUsuario:(id)sender {
    UIActionSheet* action2 = [[UIActionSheet alloc]
                             initWithTitle:@"Cuidado! Se você apagar o seu usuário, todos os seus dados serão perdidos. Tem certeza de que deseja apagar seu usuário?"
                             delegate:(id<UIActionSheetDelegate>)self
                             cancelButtonTitle:@"Cancelar"
                             destructiveButtonTitle:@"Apagar"
                             otherButtonTitles:nil ];
    action2.tag = 2;
    [action2 showInView:self.view];
}

-(void)apagaUsuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_output", @"desc_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPUT];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPUT
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:ambienteAPI];
    NSString  *path= @"usuario/exclui";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario = [Usuario new];
    
    usuario = [Usuario carregarPreferenciasUsuario];
    
    [objectManager putObject:usuario path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(mappingResult != nil){

            NSLog(@"Apagando o usuário");
            
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (FBSession.activeSession.isOpen || FBSession.activeSession.state ||FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateCreatedOpening){
                
                [appDelegate closeSession];
            }
            
            [self performSegueWithIdentifier:@"SegueToLogout" sender:self];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];            

        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
         self.status = operation.HTTPRequestOperation.response.statusCode;
        
          if(self.status == 542){
              NSLog(@"Erro ao apagar usuário");
              UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Erro" message:@"Ocorreu um erro ao apagar o seu usuário. Por favor, tente novamente em alguns instantes." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [alerta show];
          }else{
              NSLog(@"FALHA GERAL - ApagaUsuario");
              [self apagaUsuario];
              NSLog(@"Error: %@", error);
          }
      }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinish];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinish];
}
- (void)scrollingFinish {
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
}

@end