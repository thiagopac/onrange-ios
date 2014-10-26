//
//  Usuario.h
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usuario : NSObject

@property (assign, nonatomic) NSInteger id_usuario;
@property (strong, nonatomic) NSString *nome_usuario;
@property (strong, nonatomic) NSString *sexo_usuario;
@property (strong, nonatomic) NSString *email_usuario;
@property (strong, nonatomic) NSString *facebook_usuario;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) BOOL matched;


@end
