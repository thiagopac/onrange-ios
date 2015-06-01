//
//  PromoController.h
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promo.h"

@interface PromoController : UITableViewController

@property (strong, nonatomic) Promo *promo;
@property (strong, nonatomic) IBOutlet UILabel *lblLocal;
@property (strong, nonatomic) IBOutlet UILabel *lblValidade;
@property (strong, nonatomic) IBOutlet UILabel *lblNome;
@property (strong, nonatomic) IBOutlet UILabel *lblDescricao;
@property (strong, nonatomic) IBOutlet UILabel *lblCodigoPromo;
@property (assign, nonatomic) NSInteger status;

@end
