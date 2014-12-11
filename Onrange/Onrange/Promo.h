//
//  Promo.h
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Promo : NSObject

@property (nonatomic, assign) NSInteger id_promo;
@property (nonatomic, strong) NSString *local;
@property (nonatomic, strong) NSString *nome;
@property (nonatomic, strong) NSString *descricao;
@property (nonatomic, strong) NSString *dt_inicio;
@property (nonatomic, strong) NSString *dt_fim;
@property (nonatomic, assign) NSInteger lote;
@property (nonatomic, strong) NSString *codigo_promo;
@property (nonatomic, strong) NSString *dt_utilizacao;
@property (nonatomic, strong) NSString *dt_visualizacao;

@end


//NSDateFormatter *dtf = [NSDateFormatter new];
//[dtf setDateFormat:@"yyyy-MM-dd"];
//
//NSDate *date = [dtf dateFromString:[msgget criacao]];
//
//dtf = [NSDateFormatter new];
//[dtf setDateFormat:@"dd/MM/yyyy"];
//
//NSString *criacaoDDMMYYYY = [dtf stringFromDate:date];
//cell.lblCriacao.text = criacaoDDMMYYYY;