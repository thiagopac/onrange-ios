//
//  MappingProvider.m
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "MappingProvider.h"
#import "Usuario.h"
#import "Local.h"
#import "Checkin.h"

@implementation MappingProvider

+(RKMapping *)usuarioMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [mapping addAttributeMappingsFromArray:@[@"id_usuario", @"nome_usuario", @"sexo_usuario", @"email_usuario", @"facebook_usuario"]];
    return mapping;
}

+(RKMapping *)localMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Local class]];
    [mapping addAttributeMappingsFromArray:@[@"id_local", @"nome", @"latitude", @"longitude", @"qt_checkin", @"tipo_local"]];
    return mapping;
}

+(RKMapping *)checkinMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Checkin class]];
    [mapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @"id_checkin", @"checkin_vigente", @"id_checkin_anterior", @"id_local_anterior", @"id_output"]];
    return mapping;
}

@end