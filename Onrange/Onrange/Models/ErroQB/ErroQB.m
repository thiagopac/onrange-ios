//
//  ErroQB.m
//  Onrange
//
//  Created by Thiago Castro on 12/01/15.
//  Copyright (c) 2015 Thiago Castro. All rights reserved.
//

#import "ErroQB.h"
#import "RestKit.h"
#import "MappingProvider.h"

@implementation ErroQB{
    NSString *ambienteAPI;
}


-(void)adicionaErroQB:(ErroQB *)erroQB {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
	if ([def objectForKey:@"ambiente"] != nil) {
        NSString *ambiente = [def objectForKey:@"ambiente"];
        
        if ([ambiente isEqualToString:@"Produção"]) {
            ambienteAPI = API;
        }else if ([ambiente isEqualToString:@"Desenvolvimento"]){
            ambienteAPI = API_DEV;
        }else{
            ambienteAPI = API;
		}
    }else{
            ambienteAPI = API;
	}
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario", @"erro", @"funcao", @"plataforma"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[ErroQB class]];
    [responseMapping addAttributeMappingsFromArray:@[@"facebook_usuario", @"erro", @"funcao", @"plataforma"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[ErroQB class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:ambienteAPI];
    NSString  *path= @"erro/adicionaerroqb";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [objectManager postObject:erroQB path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Enviado erro QB para base Onrange");
        
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 559) { //Erro ao adicionar erro do QB.
            
            NSLog(@"Erro na API: %ld",self.status);
            [self adicionaErroQB:erroQB];
        }else{
            NSLog(@"Erro na API: %ld",self.status);
            NSLog(@"ERRO FATAL - adicionaErroQBdoUsuario");
            [self adicionaErroQB:erroQB];
            NSLog(@"Error: %@", error);
            NSLog(@"Falha ao tentar enviar dados de adicionar erro do QB");
        }
        
    }];
}

@end
