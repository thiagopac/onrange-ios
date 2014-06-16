//
//  UsuariosCheckinHeaderView.h
//  Onrange
//
//  Created by Thiago Castro on 18/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsuariosCheckinHeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UIButton *btCheckinLocal;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocal;
@property (strong, nonatomic) IBOutlet UILabel *lblQtPessoas;

@end
