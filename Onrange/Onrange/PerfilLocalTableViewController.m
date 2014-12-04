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
    int id_usuario;
    NSInteger id_local;
    NSString *nome_local;
    NSString *qt_checkin;
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
    }else if(self.local){
        id_local = self.local.id_local;
        nome_local = self.local.nome;
        qt_checkin = self.local.qt_checkin;
        latitude = self.local.latitude;
        longitude = self.local.longitude;
    }
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    self.lblNomeLocal.text = nome_local;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    id_usuario = (int)[def integerForKey:@"id_usuario"];
    
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Checkin"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString *path= @"checkin/adicionacheckin";
    
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
                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  ConfirmaCheckinViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaCheckinViewController"];
                                  vc.strNomeLocal = nome_local;
                                  [self presentViewController:vc animated:YES completion:nil];
                                  [self.view setNeedsLayout];
                                  
                                  self.usuarioEstaNoLocal = YES;
                                  
                                  [self.btnCheckin setImage:imgCheckout forState:UIControlStateNormal];
                                  
                              }else if(checkinefetuado.id_output == 2){
                                  [self alert:@"Ocorreu um erro na tentativa de efetuar checkin. Tente novamente em alguns segundos":@"Erro"];
                                  [SVProgressHUD dismiss];
                              }else if(checkinefetuado.id_output == 3){
                                  [self alert:@"O tempo mínimo para fazer um novo checkin é de 5 minutos":@"Erro"];
                                  [SVProgressHUD dismiss];
                              }else{
                                  NSLog(@"Ocorreu um erro ao efetuar o checkin");
                                  [SVProgressHUD dismiss];
                              }
                          }else{
                              NSLog(@"Falha ao tentar fazer checkin");
                              [SVProgressHUD dismiss];
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Erro 404");
                          [self fazCheckin];
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de checkin");
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
                                                                                           keyPath:@"Checkout"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString *path= @"checkin/fazcheckout";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = id_usuario;
    
    [objectManager putObject:checkin
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                              NSLog(@"Dados de checkout enviados e recebidos com sucesso!");
                              Checkin *checkoutefetuado = [mappingResult firstObject];
                              [SVProgressHUD dismiss];
                              [SVProgressHUD showSuccessWithStatus:@"Checkout efetuado!"];
                              if (checkoutefetuado.id_output == 1) {
                                  self.usuarioEstaNoLocal = NO;
                                  
                                  [self.btnCheckin setImage:imgCheckin forState:UIControlStateNormal];

                              }else if(checkoutefetuado.id_output == 2){
                                  [self alert:@"Ocorreu um erro na tentativa de efetuar checkout. Tente novamente em alguns segundos":@"Erro"];
                                  [SVProgressHUD dismiss];
                              }else{
                                  NSLog(@"Ocorreu um erro ao efetuar o checkout");
                                  [SVProgressHUD dismiss];
                              }
                          }else{
                              NSLog(@"Falha ao tentar fazer checkout");
                              [SVProgressHUD dismiss];
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Erro 404");
                          [self fazCheckout];
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de checkout");
                          [SVProgressHUD dismiss];
                      }];
}

- (void)carregaUsuarios {
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider usuarioMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Usuarios" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d/MF/%d",API,(int)id_local,(int)id_usuario]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        
        for (int i=0; i<[self.arrUsuarios count]; i++) {
            Usuario *usuario = [self.arrUsuarios objectAtIndex:i];
            
            if (usuario.id_usuario == id_usuario) {
                NSLog(@"O usuário está no local");
                self.usuarioEstaNoLocal = YES;
                [self.btnCheckin setImage:imgCheckout forState:UIControlStateNormal];
            }
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Erro 404");
        [self carregaUsuarios];
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
