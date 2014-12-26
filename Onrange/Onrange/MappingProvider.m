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
#import "Like.h"
#import "Match.h"
#import "Promo.h"

@implementation MappingProvider

+(RKMapping *)usuarioMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [mapping addAttributeMappingsFromArray:@[@"id_usuario", @"nome_usuario", @"sexo_usuario", @"email_usuario", @"facebook_usuario", @"liked", @"matched"]];
    return mapping;
}

+(RKMapping *)localMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Local class]];
    [mapping addAttributeMappingsFromArray:@[@"id_local", @"nome", @"latitude", @"longitude", @"qt_checkin",@"tipo_local",@"destaque",@"id_usuario",@"id_output"]];
    return mapping;
}

+(RKMapping *)checkinMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Checkin class]];
    [mapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @"id_checkin", @"checkin_vigente", @"id_checkin_anterior", @"id_local_anterior", @"id_output"]];
    return mapping;
}

+(RKMapping *)likeMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Like class]];
    [mapping addAttributeMappingsFromArray:@[@"id_usuario1", @"id_usuario2", @"id_local", @"id_like", @"match",@"id_output", @"chat", @"qbtoken"]];
    return mapping;
}

+(RKMapping *)matchMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Match class]];
    [mapping addAttributeMappingsFromArray:@[@"id_match", @"id_usuario", @"nome_usuario", @"facebook_usuario", @"id_qb", @"email_usuario", @"chat", @"qbtoken"]];
    return mapping;
}

+(RKMapping *)promoMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Promo class]];
    [mapping addAttributeMappingsFromArray:@[@"id_promo", @"local", @"nome", @"descricao", @"dt_inicio", @"dt_fim", @"lote", @"codigo_promo", @"dt_utilizacao",@"dt_promo", @"dt_visualizacao",@"id_codigo_promo",@"nao_lido"]];
    return mapping;
}

@end
