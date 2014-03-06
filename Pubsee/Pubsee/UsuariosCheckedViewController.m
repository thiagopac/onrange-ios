//
//  UsuariosCheckedViewController.m
//  Pubsee
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
                                              object:nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self carregaUsuarios];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    if (_annotation != nil) {
        id_local = _annotation.id_local;
    }else{
        id_local = _local.id_local;
    }
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
    
    Usuario *usuario = [_arrUsuarios objectAtIndex:[indexPath row]];

    [self configureCell:cell withUsuario:usuario];
    
    return cell;
}

- (void)configureCell:(UsuarioFotoCollectionCell *)cell withUsuario:(Usuario *)usuario {
        cell.userProfilePictureView.profileID = usuario.facebook_usuario;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
