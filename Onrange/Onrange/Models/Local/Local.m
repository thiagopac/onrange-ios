//
//  Local.m
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "Local.h"

@implementation Local

- (id)initWithLocation:(CLLocation *)location nome:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude idLocal:(NSInteger)idLocal destaque:(BOOL)destaque qtCheckin:(NSString *)qtCheckin andTipoLocal:(NSInteger)tipoLocal{
    if((self = [super init])) {
        _location = location;
        _nome = name;
        _latitude = latitude;
        _longitude = longitude;
        _id_local = idLocal;
        _destaque = destaque;
        _qt_checkin = qtCheckin;
        _tipo_local = tipoLocal;

    }
    return self;
}

@end