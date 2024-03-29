//
//  PerfilUsuarioViewController.h
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Usuario.h"
#import <FacebookSDK.h>
#import "Local.h"
#import "CSAnimationView.h"

@interface PerfilUsuarioViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imgFotoUsuario;

@property (strong, nonatomic) Usuario *usuario;
@property (strong, nonatomic) Local *local;
@property (strong, nonatomic) NSString *QBUser;
@property (strong, nonatomic) NSString *QBPassword;

@property (strong, nonatomic) IBOutlet UILabel *lblNomeUsuario;
@property (assign, nonatomic) NSUInteger ID_QB1;
@property (assign, nonatomic) NSUInteger ID_QB2;
@property (strong, nonatomic) IBOutlet UIButton *btnCurtirUsuario;

- (IBAction)btnCurtirUsuario:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@property (assign, nonatomic) NSInteger status;
@property (strong, nonatomic) IBOutlet UIView *viewColoredHeader;


@end