//
//  PromoTableViewCell.h
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblLocal;
@property (strong, nonatomic) IBOutlet UILabel *lblDescricao;
@property (strong, nonatomic) IBOutlet UILabel *lblDataPromo;
@property (strong, nonatomic) IBOutlet UIView *viewCorEstado;

@end
