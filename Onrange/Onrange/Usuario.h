//
//  Usuario.h
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Usuario : NSObject

@property (assign, nonatomic) NSInteger id_usuario;
@property (strong, nonatomic) NSString *nome_usuario;
@property (strong, nonatomic) NSString *sobrenome_usuario;
@property (strong, nonatomic) NSString *sexo_usuario;
@property (strong, nonatomic) NSString *email_usuario;
@property (strong, nonatomic) NSString *facebook_usuario;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) BOOL matched;
@property (strong, nonatomic) NSString *cidade_usuario;
@property (strong, nonatomic) NSString *pais_usuario;
@property (strong, nonatomic) NSString *aniversario_usuario;
@property (strong, nonatomic) NSString *idioma_usuario;

@property (assign, nonatomic) NSInteger status;

+(void)salvarPreferenciasUsuario:(Usuario *)usuario;
+(Usuario *)carregarPreferenciasUsuario;
-(void)loginUsuario:(Usuario *)usuario;
-(void)loginUsuarioDelegate:(Usuario *)usuario;
-(void)adicionaUsuario:(Usuario *)usuario;


@end