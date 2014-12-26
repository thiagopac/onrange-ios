//
//  PromoCaixaEntradaTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PromoCaixaEntradaTableViewController.h"
#import <Restkit/RestKit.h>
#import "SlideNavigationController.h"
#import "PromoTableViewCell.h"
#import "SVProgressHUD.h"
#import "MappingProvider.h"
#import "Promo.h"
#import "PromoController.h"


@interface PromoCaixaEntradaTableViewController (){
    int id_usuario;
}

@property (nonatomic, strong) NSMutableArray *arrPromos;

@end

@implementation PromoCaixaEntradaTableViewController

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    id_usuario = (int)[def integerForKey:@"id_usuario"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuAbriu:) name:MenuLeft object:nil];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(carregaPromos) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
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
    [self statusBarCustomizadaWithMsg:@"Carregando seu Onrange Club..."];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaPromos];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"Foi minimizado");
}

-(void)appWillTerminate:(NSNotification*)note
{
    NSLog(@"Foi fechado");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidBecomeActive:(NSNotification*)note
{
    NSLog(@"Foi aberto");
}

- (void)menuAbriu:(NSNotification *)notification {
    if([[SlideNavigationController sharedInstance] isMenuOpen]){
        self.tableView.scrollEnabled = NO;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

- (void)carregaPromos {
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider promoMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Promos" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@promo/listaPromosUsuario/%d",API,id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        self.arrPromos = [NSMutableArray arrayWithArray:mappingResult.array];
        
        if (self.arrPromos.count < 1) {
            [SVProgressHUD showErrorWithStatus:@"Sua caixa está vazia."];
            [self.notification dismissNotification];
        }
        [self.notification dismissNotification];
        [self contadorPromosNãoLidos];
        [self.tableView reloadData];
        [self.refreshControl performSelector:@selector(endRefreshing)];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 547) {
            NSLog(@"Erro ao buscar promos");
            [self carregaPromos]; //é preciso tentar novamente e implementar contador de tentativas
        }else{
            NSLog(@"ERRO FATAL - carregaPromos - Erro: %ld",self.status);
            [self carregaPromos];
            NSLog(@"Error: %@", error);
            
            [self.refreshControl performSelector:@selector(endRefreshing)];
            [self.notification dismissNotification];
        }
    }];
    
    [operation start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrPromos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PromoCell";
    PromoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Promo *promo = [self.arrPromos objectAtIndex:indexPath.row];
    cell.lblLocal.text = promo.local;
    cell.lblDescricao.text = promo.descricao;

    
    NSString *cor;
    
    NSDateFormatter *dtf = [NSDateFormatter new];
    [dtf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *date = [dtf dateFromString:[promo dt_promo]];

    dtf = [NSDateFormatter new];
    [dtf setDateFormat:@"dd/MM/yyyy"];

    NSString *criacaoDDMMYYYY = [dtf stringFromDate:date];
    
    cell.lblDataPromo.text = criacaoDDMMYYYY;
    
    [cell.lblLocal setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:16]];
    [cell.lblDescricao setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:11]];
    
    if (promo.dt_visualizacao == nil) { //NÃO-LIDO
        cell.lblLocal.textColor = [UIColor scrollViewTexturedBackgroundColor];
        cell.lblDescricao.textColor = [UIColor scrollViewTexturedBackgroundColor];
        
        cor = @"#75B8E5"; //AZUL - não lido
        
        cell.viewCorEstado.backgroundColor = [UIColor colorWithHexString:cor];
        
        return cell;
    }
    
    cell.lblLocal.textColor = [UIColor lightGrayColor];
    cell.lblDescricao.textColor = [UIColor lightGrayColor];
    
    cor = @"#C2CBD6"; //CINZA - lido
    cell.viewCorEstado.backgroundColor = [UIColor colorWithHexString:cor];
    
    return cell;
}

-(void)contadorPromosNãoLidos{

    int cont=0;
    
    for (int i=0; i<[self.arrPromos count]; i++) {
        Promo *promo = [self.arrPromos objectAtIndex:i];
        
        if (promo.dt_visualizacao == nil) {
            cont++;
        }
    }
    
    if (cont<1){
        NSString *strResumo = [NSString stringWithFormat:@"Você não tem nenhum promo não-lido"];
        [self.lblResumo setText:strResumo];
    }else if (cont<2){
        NSString *strResumo = [NSString stringWithFormat:@"Você tem %d promo não-lido",cont];
        [self.lblResumo setText:strResumo];
    }else if(cont>1){
        NSString *strResumo = [NSString stringWithFormat:@"Você tem %d promos não-lidos",cont];
        [self.lblResumo setText:strResumo];
    }
        

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PromoController *promoControler = [[self storyboard]instantiateViewControllerWithIdentifier:@"PromoController"];
    
    Promo *promo = [[self arrPromos]objectAtIndex:indexPath.row];
    [promoControler setPromo:promo];
    [[self navigationController]pushViewController:promoControler animated:YES];
}

@end
