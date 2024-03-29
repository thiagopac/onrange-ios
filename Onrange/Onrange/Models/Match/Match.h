//
//  Match.h
//  Onrange
//
//  Created by Thiago Castro on 14/07/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Match : NSObject

@property (assign, nonatomic) NSInteger id_match;
@property (assign, nonatomic) NSInteger id_usuario;
@property (strong, nonatomic) NSString *nome_usuario;

@property (strong, nonatomic) NSString *facebook_usuario;
@property (strong, nonatomic) NSString *facebook_usuario2;

@property (strong, nonatomic) NSString *id_qb;
@property (strong, nonatomic) NSString *email_usuario;

@property (strong, nonatomic) NSString *qbtoken;
@property (strong, nonatomic) NSString *id_chat;

@property (assign, nonatomic) NSInteger id_output;
@property (strong, nonatomic) NSString *desc_output;

@end
