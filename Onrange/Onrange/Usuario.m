//
//  Usuario.m
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "Usuario.h"
#import "RestKit/RestKit.h"
#import "MappingProvider.h"
#import "ErroQB.h"
#import "IntroViewController.h"

@implementation Usuario


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeInteger:self.id_usuario forKey:@"id_usuario"];
    [encoder encodeObject:self.nome_usuario forKey:@"nome_usuario"];
    [encoder encodeObject:self.sobrenome_usuario forKey:@"sobrenome_usuario"];
    [encoder encodeObject:self.sexo_usuario forKey:@"sexo_usuario"];
    [encoder encodeObject:self.email_usuario forKey:@"email_usuario"];
    [encoder encodeObject:self.facebook_usuario forKey:@"facebook_usuario"];
    [encoder encodeObject:self.quickblox_usuario forKey:@"quickblox_usuario"];
    [encoder encodeObject:self.cidade_usuario forKey:@"cidade_usuario"];
    [encoder encodeObject:self.pais_usuario forKey:@"pais_usuario"];
    [encoder encodeObject:self.aniversario_usuario forKey:@"aniversario_usuario"];
    [encoder encodeObject:self.idioma_usuario forKey:@"idioma_usuario"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.id_usuario = [decoder decodeIntegerForKey:@"id_usuario"];
        self.nome_usuario = [decoder decodeObjectForKey:@"nome_usuario"];
        self.sobrenome_usuario = [decoder decodeObjectForKey:@"sobrenome_usuario"];
        self.sexo_usuario = [decoder decodeObjectForKey:@"sexo_usuario"];
        self.email_usuario = [decoder decodeObjectForKey:@"email_usuario"];
        self.facebook_usuario = [decoder decodeObjectForKey:@"facebook_usuario"];
        self.quickblox_usuario = [decoder decodeObjectForKey:@"quickblox_usuario"];
        self.cidade_usuario = [decoder decodeObjectForKey:@"cidade_usuario"];
        self.pais_usuario = [decoder decodeObjectForKey:@"pais_usuario"];
        self.aniversario_usuario = [decoder decodeObjectForKey:@"aniversario_usuario"];
        self.idioma_usuario = [decoder decodeObjectForKey:@"idioma_usuario"];
    }
    return self;
}

+ (void)salvarPreferenciasUsuario:(Usuario *)usuario{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:usuario];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:encodedObject forKey:@"usuario"];
    [def synchronize];
    
}

+ (Usuario *)carregarPreferenciasUsuario{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"usuario"];
    Usuario *usuario = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return usuario;
}

-(void)loginUsuario:(Usuario *)usuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"facebook_usuario", @"quickblox_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/login";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [objectManager postObject:usuario path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        Usuario *userLogged = [mappingResult firstObject];
        NSLog(@"Login efetuado na base Onrage");

        [Usuario salvarPreferenciasUsuario:userLogged];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:userLogged forKey:@"usuario"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"loginNotification" object:nil userInfo:userInfo];

    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 500) { //Usuário inexistente
            
            [self cadastraUsuarioNoQB:usuario];
            
        }else if(self.status == 501) { //Usuário bloqueado
            
            UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Aviso" message:@"Você está temporariamente impossibilitado de acessar o aplicativo por alguns problemas que vão contra a política de uso do Onrange. Se deseja ter seu acesso liberado novamente, por favor entre em contato pelo e-mail contato@onrange.com.br" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerta show];
            
        }else if(self.status == 530) { //Erro ao buscar usuario.
            
            [self loginUsuario:usuario];
            
        }else if(self.status == 546) { //Erro ao remover data de exclusao do usuario.
 
            [self loginUsuario:usuario];
            
        }else{
            
            if (error.code == -1009) { //erro de conexão com a internet
                
                NSLog(@"Codigo erro restkit: %ld",(long)error.code);
                
                UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Aviso" message:@"Você está sem conexão com a internet, tente novamente em alguns minutos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alerta show];
                
            }else{

                [self loginUsuario:usuario];
                
                NSLog(@"ERRO FATAL - loginUsuario - Erro: %ld",(long)self.status);
                NSLog(@"Error: %@", error);
                
            }
            
        }
        
    }];
}

-(void)loginUsuarioDelegate:(Usuario *)usuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"facebook_usuario", @"quickblox_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/login";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [objectManager postObject:usuario path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        Usuario *userLogged = [mappingResult firstObject];
        NSLog(@"Login efetuado na base Onrage");
        
        [Usuario salvarPreferenciasUsuario:userLogged];
        
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 500) { //Usuário inexistente
            
            [self cadastraUsuarioNoQB:usuario];
            
        }else if(self.status == 501) { //Usuário bloqueado
            
            UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Aviso" message:@"Você está temporariamente impossibilitado de acessar o aplicativo por alguns problemas que vão contra a política de uso do Onrange. Se deseja ter seu acesso liberado novamente, por favor entre em contato pelo e-mail contato@onrange.com.br" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerta show];
            
        }else if(self.status == 530) { //Erro ao buscar usuario.
            
            [self loginUsuario:usuario];
            
        }else if(self.status == 546) { //Erro ao remover data de exclusao do usuario.
            
            [self loginUsuario:usuario];
            
        }else{
            
            if (error.code == -1009) { //erro de conexão com a internet
                
                NSLog(@"Codigo erro restkit: %ld",(long)error.code);
                
                UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Aviso" message:@"Você está sem conexão com a internet, tente novamente em alguns minutos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alerta show];
                
            }else{
                
                [self loginUsuario:usuario];
                
                NSLog(@"ERRO FATAL - loginUsuarioDelegate - Erro: %ld",(long)self.status);
                NSLog(@"Error: %@", error);
                
            }
            
        }
        
    }];
}

-(void)adicionaUsuario:(Usuario *)usuario{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"facebook_usuario", @"quickblox_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Usuario class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"facebook_usuario", @"quickblox_usuario", @"nome_usuario", @"sobrenome_usuario", @"sexo_usuario", @"email_usuario", @"cidade_usuario", @"pais_usuario", @"aniversario_usuario", @"idioma_usuario"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Usuario class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"usuario/adicionausuario";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [objectManager postObject:usuario path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Cadastrado base Onrage");
        Usuario *userLogged = [mappingResult firstObject];
        
        [Usuario salvarPreferenciasUsuario:userLogged];
        
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
          
          self.status = operation.HTTPRequestOperation.response.statusCode;
          
          if(self.status == 509) { //Erro ao adicionar novo usuario
              NSLog(@"Erro na API: %ld",(long)self.status);
              [self adicionaUsuario:usuario];
          }else{
              NSLog(@"Erro na API: %ld",(long)self.status);
              NSLog(@"ERRO FATAL - adicionaUsuario");
              [self adicionaUsuario:usuario];
              NSLog(@"Error: %@", error);
              NSLog(@"Falha ao tentar enviar dados de login");
          }
          
      }];
}

-(void)cadastraUsuarioNoQB:(Usuario *)usuario{

    QBUUser *user = [QBUUser user];
    user.login = usuario.facebook_usuario;
    user.password = usuario.facebook_usuario;
    user.fullName = usuario.nome_usuario;
    user.email = usuario.email_usuario;
    user.facebookID = usuario.facebook_usuario;

    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        // session created
    
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            NSLog(@"Cadastrado base QuickBlox");
            
            //adicionando ao campo quickblox_usuario o ID que o quickblox acaba de me retornar
            usuario.quickblox_usuario = [NSString stringWithFormat:@"%ld",user.ID];
            
            [self adicionaUsuario:usuario];
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Erro ao cadastrar na base QuickBlox");
            NSLog(@"error: %@", response.error);
            
            [self adicionaUsuario:usuario];
            
            NSString *erroResponse = [NSString stringWithFormat:@"%@",[response.error.reasons objectForKey:@"errors"]];
            
            ErroQB *erroQB = [ErroQB new];
            erroQB.facebook_usuario = usuario.facebook_usuario;
            erroQB.erro = erroResponse;
            erroQB.funcao = @"adicionaUsuario";
            erroQB.plataforma = @"iOS";
            
            [erroQB adicionaErroQB:erroQB];

        }];
        
    }errorBlock:^(QBResponse *response) {
        NSLog(@"Erro ao criar sessão para cadastrar na base QuickBlox");
        NSLog(@"error: %@", response.error);
        
        [self adicionaUsuario:usuario];
        
        NSString *erroResponse = [NSString stringWithFormat:@"%@",[response.error.reasons objectForKey:@"errors"]];
        
        ErroQB *erroQB = [ErroQB new];
        erroQB.facebook_usuario = usuario.facebook_usuario;
        erroQB.erro = erroResponse;
        erroQB.funcao = @"criarSessao-adicionaUsuario";
        erroQB.plataforma = @"iOS";
        
        [erroQB adicionaErroQB:erroQB];
    }];
}

@end
