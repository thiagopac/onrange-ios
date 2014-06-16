//
//  PerfilUsuarioTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PerfilUsuarioTableViewController.h"

@interface PerfilUsuarioTableViewController ()

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
    self.imgProfileUsuario.profileID = self.usuario.facebook_usuario;
    self.lblNomeUsuario.text = self.usuario.nome_usuario;
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationController.navigationBar.topItem.title = @"•";
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if ([def integerForKey:@"id_usuario"] == self.usuario.id_usuario) {
        self.cellCurtir.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCurtirUsuario:(id)sender {
}
@end
