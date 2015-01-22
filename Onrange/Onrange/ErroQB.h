//
//  ErroQB.h
//  Onrange
//
//  Created by Thiago Castro on 12/01/15.
//  Copyright (c) 2015 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErroQB : NSObject

@property (strong, nonatomic) NSString *facebook_usuario;
@property (strong, nonatomic) NSString *erro;
@property (strong, nonatomic) NSString *funcao;
@property (strong, nonatomic) NSString *plataforma;

@property (assign, nonatomic) NSInteger status;

-(void)adicionaErroQB:(ErroQB *)erroQB;

@end
