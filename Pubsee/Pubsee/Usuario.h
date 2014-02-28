//
//  Usuario.h
//  Pubsee
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usuario : NSObject

@property (assign, nonatomic) NSInteger id_usuario;
@property (strong, nonatomic) NSString *nome;
@property (strong, nonatomic) NSString *sexo;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *id_facebook;

@end
