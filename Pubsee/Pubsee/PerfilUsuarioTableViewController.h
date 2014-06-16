//
//  PerfilUsuarioTableViewController.h
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Usuario.h"
#import <FacebookSDK.h>

@interface PerfilUsuarioTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet FBProfilePictureView *imgProfileUsuario;
@property (strong, nonatomic) Usuario *usuario;

@property (strong, nonatomic) IBOutlet UILabel *lblNomeUsuario;
@property (strong, nonatomic) IBOutlet UIButton *btnCurtirUsuario;

- (IBAction)btnCurtirUsuario:(id)sender;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCurtir;

@end
