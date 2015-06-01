//
//  Like.m
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "Like.h"
#import "RestKit/RestKit.h"
#import "MappingProvider.h"
#import "SVProgressHUD.h"

@implementation Like{
    NSString *ambienteAPI;
}

-(void)curtirUsuario:(Usuario *)usuario2 noLocal:(Local *)local comQBToken:(NSString *)qbtoken{
    
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
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario1",@"id_usuario2",@"id_local", @"qbtoken"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Like class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario1", @"id_usuario2", @"id_local", @"id_like", @"match"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Like class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    NSURL *url = [NSURL URLWithString:ambienteAPI];
    NSString  *path= @"like/adicionalike";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Usuario *usuario1 = [Usuario new];
    usuario1 = [Usuario carregarPreferenciasUsuario];
    
    Like *like= [Like new];
    
    like.id_usuario2 = usuario2.id_usuario;
    

    like.id_usuario1 = usuario1.id_usuario;
    like.id_local = local.id_local;
    like.qbtoken = qbtoken;
    
    [objectManager postObject:like path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        //O app só entrará aqui se for um código 200 de retorno
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        if(mappingResult != nil){
            NSLog(@"Dados de like enviados e recebidos com sucesso!");
            Like *likeefetuado = [mappingResult firstObject];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:likeefetuado forKey:@"like"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationSelecionado" object:nil userInfo:userInfo];
            
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        if(self.status == 521){
            NSLog(@"Erro ao buscar checkin do usuario de destino.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 522){
            NSLog(@"Usuario de destino realizou checkout.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [SVProgressHUD showErrorWithStatus:@"Erro. Esta pessoa deixou o local."];
        }else if(self.status == 523){
            NSLog(@"Erro ao verificar se ja existe like.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 524){
            NSLog(@"Erro ao curtir.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 525){
            NSLog(@"Erro ao verificar se houve match.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 526){
            NSLog(@"Erro ao buscar ID do QB do usuario 1.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
        }else if(self.status == 527){
            NSLog(@"Erro ao buscar ID do QB do usuario 2.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
        }else if(self.status == 528){
            NSLog(@"Erro ao criar match.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 529){
            NSLog(@"Erro ao descurtir.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else if(self.status == 543){
            NSLog(@"Erro ao criar chat no QB.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"curtirNotificationNaoSelecionado" object:nil userInfo:nil];
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
        }else{
            [self curtirUsuario:usuario2 noLocal:local comQBToken:qbtoken];
            NSLog(@"Error: %@", error);
            NSLog(@"Falha ao tentar enviar dados de like");
        }
        
    }];
}

@end