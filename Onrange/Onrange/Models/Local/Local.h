//
//  Local.h
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface Local : NSObject

@property (nonatomic, assign) NSInteger id_local;
@property (nonatomic, strong) NSString *nome;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *qt_checkin;
@property (nonatomic, assign) NSInteger id_usuario;
@property (nonatomic, assign) NSInteger tipo_local;
@property (nonatomic, assign) NSInteger id_output;
@property (nonatomic, assign) BOOL destaque;
@property (nonatomic, strong) CLLocation *location;

- (id)initWithLocation:(CLLocation *)location nome:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude idLocal:(NSInteger)idLocal destaque:(BOOL)destaque qtCheckin:(NSString *)qtCheckin andTipoLocal:(NSInteger)tipoLocal;

@end
