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

@interface UsuariosCheckedViewController (){
    NSInteger id_local;
    NSString *nome_local;
    NSString *qt_checkin;
}

@property (nonatomic, strong) NSMutableArray *arrUsuarios;

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

-(void)viewWillAppear:(BOOL)animated{

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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d",API,id_local]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        [self.collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_arrUsuarios count];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UsuarioFotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fotoCell" forIndexPath:indexPath];
    
    Usuario *usuario = [_arrUsuarios objectAtIndex:[indexPath item]];

    [self configureCell:cell withUsuario:usuario];

    
    return cell;
}

- (void)configureCell:(UsuarioFotoCollectionCell *)cell withUsuario:(Usuario *)usuario {
    cell.userProfilePictureView.profileID = usuario.facebook_usuario;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UsuariosCheckinHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        NSString *nomeLocalCheckins = [NSString stringWithFormat:@"%@ [ %@ ]",nome_local,qt_checkin];
        headerView.lblNomeLocalCheckins.text = nomeLocalCheckins;
    
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

- (IBAction)btCheckinLocal:(UIButton *)sender {
    UIActionSheet* action = [[UIActionSheet alloc]
                             initWithTitle:[NSString stringWithFormat:@"Confirmar checkin em %@?", nome_local]
                             delegate:(id<UIActionSheetDelegate>)self
                             cancelButtonTitle:@"Não"
                             destructiveButtonTitle:nil
                             otherButtonTitles:@"Sim",nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: // Sim
            NSLog(@"Fez checkin!");
            break;
        case 1: // Não
            break;
    }
}

@end
