//
//  Local.h
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Local : NSObject

@property (nonatomic, assign) NSInteger id_local;
@property (nonatomic, strong) NSString *nome;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *qt_checkin;
@property (nonatomic, assign) NSInteger id_usuario;
@property (nonatomic, assign) NSInteger tipo_local;
@property (nonatomic, assign) NSInteger id_output;


@end
