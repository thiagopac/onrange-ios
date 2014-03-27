//
//  UsuariosCheckinHeaderView.h
//  Onrange
//
//  Created by Thiago Castro on 18/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBFlatButton.h"

@interface UsuariosCheckinHeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocalCheckins;
@property (strong, nonatomic) IBOutlet QBFlatButton *btCheckinLocal;

@end
