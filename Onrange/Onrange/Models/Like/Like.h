//
//  Like.h
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Usuario.h"
#import "Local.h"

@interface Like : NSObject

@property (nonatomic, assign) NSInteger id_usuario1;
@property (nonatomic, assign) NSInteger id_usuario2;
@property (nonatomic, assign) NSInteger id_local;
@property (nonatomic, assign) NSInteger id_like;
@property (nonatomic, assign) BOOL match;
@property (nonatomic, strong) NSString *qbtoken;

@property (assign, nonatomic) NSInteger status;

-(void)curtirUsuario:(Usuario *)usuario2 noLocal:(Local *)local comQBToken:(NSString *)qbtoken;

@end