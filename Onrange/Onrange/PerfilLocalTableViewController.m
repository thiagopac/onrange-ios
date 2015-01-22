//
//  PerfilLocalTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 22/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PerfilLocalTableViewController.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Usuario.h"
#import "Checkin.h"
#import "ConfirmaCheckinViewController.h"
#import "UsuariosCheckedViewController.h"
#import <SVProgressHUD.h>

@interface PerfilLocalTableViewController (){
    Usuario *usuarioDispositivo;
    NSInteger id_local;
    NSString *nome_local;
    NSString *qt_checkin;
    BOOL destaque;
    NSString *latitude;
    NSString *longitude;
    float deltaLatFor1px;
    CLLocationCoordinate2D center;
    UIImage *imgCheckin;
    UIImage *imgCheckout;
}

@property (nonatomic, strong) NSMutableArray *arrUsuarios;
@property (nonatomic, assign) bool usuarioEstaNoLocal;

@end

@implementation PerfilLocalTableViewController

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
    
    if (_annotation) {
        id_local = _annotation.id_local;
        nome_local = _annotation.title;
        qt_checkin = _annotation.qt_checkin;
        latitude = _annotation.latitude;
        longitude = _annotation.longitude;
        destaque = _annotation.destaque;
    }else if(self.local){
        id_local = self.local.id_local;
        nome_local = self.local.nome;
        qt_checkin = self.local.qt_checkin;
        latitude = self.local.latitude;
        longitude = self.local.longitude;
        destaque = self.local.destaque;
    }
    
    if (destaque == NO) {
        
        CGRect newFrame = self.tableView.tableHeaderView.frame;
        newFrame.size.height = newFrame.size.height -60;
        self.tableView.tableHeaderView.frame = newFrame;
        
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
        [self.lblDestaque removeFromSuperview];
        self.imgStar.hidden = YES;
        
        CGRect frame = self.lblNomeLocal.frame;
        frame.origin.y= self.lblNomeLocal.frame.origin.y;
        frame.origin.x= 18;
        self.lblNomeLocal.frame = frame;
        
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    self.lblNomeLocal.text = nome_local;
    
    usuarioDispositivo = [Usuario carregarPreferenciasUsuario];
    
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [latitude doubleValue];
    theCoordinate.longitude = [longitude doubleValue];
    
    CLLocationCoordinate2D startCoord = theCoordinate;
    
    center = startCoord;
    
    MKCoordinateRegion adjustedRegion = [self.mapLocal regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 400, 400)];
    [self.mapLocal setRegion:adjustedRegion animated:YES];
    
    PointLocais *point = [[PointLocais alloc]initWithCoordenada:startCoord nome:nil];
    [self.mapLocal addAnnotation:point];
    
    CLLocationCoordinate2D referencePosition = [_mapLocal convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapLocal];
    CLLocationCoordinate2D referencePosition2 = [_mapLocal convertPoint:CGPointMake(0, 100) toCoordinateFromView:_mapLocal];
    deltaLatFor1px = (referencePosition2.latitude - referencePosition.latitude)/100;
    
    imgCheckin = [UIImage imageNamed:@"btn_checkin"];
    imgCheckout = [UIImage imageNamed:@"btn_checkout"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = self.tableView.contentOffset.y;
    if (y<0) {
        //we moved y pixels down, how much latitude is that ?
        double deltaLat = y * deltaLatFor1px;
        //Move the center coordinate accordingly
        CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(center.latitude-deltaLat/50, center.longitude);
        _mapLocal.centerCoordinate = newCenter;
        _mapLocal.frame = CGRectMake(0, 160, 320, -160+y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
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
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @" eckin", @"checkin_vigente", @"id_checkin_anterior", @"id_local_anterior", @"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Checkin class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString *path= @"checkin/adicionacheckin";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = usuarioDispositivo.id_usuario;
    checkin.id_local = id_local;
    
    [objectManager postObject:checkin path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          
      self.status = operation.HTTPRequestOperation.response.statusCode;

      Checkin *checkinefetuado = [mappingResult firstObject];
      [SVProgressHUD dismiss];

      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      ConfirmaCheckinViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaCheckinViewController"];
      vc.strNomeLocal = nome_local;
      [self presentViewController:vc animated:YES completion:nil];
      [self.view setNeedsLayout];
      
      self.usuarioEstaNoLocal = YES;
      
      [self.btnCheckin setImage:imgCheckout forState:UIControlStateNormal];

    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
      self.status = operation.HTTPRequestOperation.response.statusCode;
      
      if(self.status == 516) { //Checkin anterior em menos de 5 minutos
         [self alert:@"Você deve aguardar alguns minutos para fazer checkin novamente.":@"Erro"];
      }else if(self.status == 517) { //Erro ao fazer checkin
          [self fazCheckin];
      }else{
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPUT pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString *path= @"checkin/fazcheckout";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = usuarioDispositivo.id_usuario;
    
    [objectManager putObject:checkin path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
      NSLog(@"Dados de checkout enviados e recebidos com sucesso!");
      [SVProgressHUD dismiss];
      [SVProgressHUD showSuccessWithStatus:@"Checkout efetuado!"];

          self.usuarioEstaNoLocal = NO;
          
          [self.btnCheckin setImage:imgCheckin forState:UIControlStateNormal];

      }
      failure:^(RKObjectRequestOperation *operation, NSError *error) {
          
          self.status = operation.HTTPRequestOperation.response.statusCode;
          
          if(self.status == 532) { //Erro ao buscar checkin.
              NSLog(@"Erro na API: %ld",self.status);
              [self fazCheckout];
          }else if(self.status == 533) { //Erro ao fazer checkout.
              NSLog(@"Erro na API: %ld",self.status);
              [self fazCheckout];
              [SVProgressHUD dismiss];
          }else{
              NSLog(@"ERRO FATAL - fazCheckout");
              NSLog(@"Erro na API: %ld",self.status);
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
      }];
}

- (void)carregaUsuarios {
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider usuarioMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:nil statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d/MF/%d",API,(int)id_local,(int)usuarioDispositivo.id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        
        for (int i=0; i<[self.arrUsuarios count]; i++) {
            Usuario *usuario = [self.arrUsuarios objectAtIndex:i];
            
            if (usuario.id_usuario == usuarioDispositivo.id_usuario) {
                NSLog(@"O usuário está no local");
                self.usuarioEstaNoLocal = YES;
                [self.btnCheckin setImage:imgCheckout forState:UIControlStateNormal];
            }
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 531) { //Erro na listagem de usuarios.
            NSLog(@"Erro %ld",self.status);
            [self carregaUsuarios];
        }else{
            NSLog(@"Erro %ld",self.status);
            [self alert:@"Erro ao carregar usuários no local. Tente novamente em alguns minutos.":@"Erro"];
        }
    
        NSLog(@"ERROR: %@", error);

    }];
    
    [operation start];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UsuariosCheckedViewController *usuariosCheckedVC = [[self storyboard]instantiateViewControllerWithIdentifier:@"UsuariosCheckedViewController"];
    
    if (_annotation) {
        [usuariosCheckedVC setAnnotation:self.annotation];
    }else{
        [usuariosCheckedVC setLocal:self.local];
    }
    
    if ([qt_checkin intValue]> 0) {
        [[self navigationController]pushViewController:usuariosCheckedVC animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"quemEstaCell"];
        
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13];
        
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        [self.btnCheckin setImage:imgCheckin forState:UIControlStateNormal];
        
        [self carregaUsuarios];
        if ([qt_checkin intValue] == 0) {
           cell.textLabel.text = @"Ninguém no local";
        }else if([qt_checkin intValue] == 1){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ pessoas no local",qt_checkin];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }else{
            cell.textLabel.text = [NSString stringWithFormat:@"%@ pessoas no local",qt_checkin];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    
    return cell;
}

- (IBAction)btnCheckin:(id)sender {
    if (self.usuarioEstaNoLocal == YES){
        UIActionSheet* actionCheckout = [[UIActionSheet alloc]
                                         initWithTitle:[NSString stringWithFormat:@"Confirmar checkout em %@?", nome_local]
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
@end
