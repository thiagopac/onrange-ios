//
//  Checkin.h
//  Onrange
//
//  Created by Thiago Castro on 18/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checkin : NSObject

@property (nonatomic, assign) NSInteger id_usuario;
@property (nonatomic, assign) NSInteger id_local;
@property (nonatomic, assign) NSInteger id_checkin;
@property (nonatomic, assign) BOOL checkin_vigente;
@property (nonatomic, assign) NSInteger id_checkin_anterior;
@property (nonatomic, assign) NSInteger id_local_anterior;
@property (nonatomic, assign) NSInteger id_output;

@end
