//
//  PromoController.m
//  Onrange
//
//  Created by Thiago Castro on 11/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PromoController.h"
#import "MappingProvider.h"
#import <Restkit/RestKit.h>
#import "Promo.h"

#define CELL_CONTENT_WIDTH 320.0f

@interface PromoController (){
    NSString *ambienteAPI;
}

@end

@implementation PromoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
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
    
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;

   self.navigationController.navigationBar.topItem.title = @"•";
    
    CGSize maximumLabelSize = CGSizeMake(259, FLT_MAX);
    CGSize expectedLabelSize = [self.promo.descricao sizeWithFont:self.lblDescricao.font constrainedToSize:maximumLabelSize lineBreakMode:self.lblDescricao.lineBreakMode];
    CGRect newFrame = self.lblDescricao.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.lblDescricao.frame = newFrame;
    self.lblDescricao.text = self.promo.descricao;
    
    self.lblLocal.text = self.promo.local;
    self.lblNome.text = self.promo.nome;
    self.lblCodigoPromo.text = self.promo.codigo_promo;
    
    NSDateFormatter *dtf = [NSDateFormatter new];
    [dtf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date1 = [dtf dateFromString:[self.promo dt_inicio]];
    NSDate *date2 = [dtf dateFromString:[self.promo dt_fim]];
    
    dtf = [NSDateFormatter new];
    [dtf setDateFormat:@"dd/MM/yyyy"];
    
    NSString *inicioDDMMYYYY = [dtf stringFromDate:date1];
    NSString *fimDDMMYYYY = [dtf stringFromDate:date2];
    
    NSString *strInicio = inicioDDMMYYYY;
    NSString *strFim = fimDDMMYYYY;
    
    self.lblValidade.text = [NSString stringWithFormat:@"Este promo é válido de %@ até %@",strInicio,strFim];
    
    if (self.promo.dt_visualizacao == nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self marcaPromolido:self.promo];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        return 111;
        
    }else if (indexPath.row == 1)
    {
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:self.promo.descricao attributes:@{NSFontAttributeName: font}];
        
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){CELL_CONTENT_WIDTH, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        CGSize size = rect.size;

        return (ceilf(size.height)+22)*1;
    }else if (indexPath.row == 2) {
        return 62;
        
    }else{
        return 40;
    }
}

-(void)marcaPromolido:(Promo *)promo {
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_codigo_promo"]];

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Promo class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_output", @"desc_output"]];

    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Promo class] rootKeyPath:nil method:RKRequestMethodPUT];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPUT pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    NSURL *url = [NSURL URLWithString:ambienteAPI];
    NSString  *path= @"promo/marcapromovisualizado";

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];

    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;

    [objectManager putObject:promo path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        self.status = operation.HTTPRequestOperation.response.statusCode;

        if(mappingResult != nil){
            
            NSLog(@"Promo marcado como lido");
            
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        self.status = operation.HTTPRequestOperation.response.statusCode;
        
        if(self.status == 548){
            NSLog(@"Erro ao marcar promo visualizado.");
        }else{
            NSLog(@"FALHA GERAL - marcaPromoLido");
            [self marcaPromolido:self.promo];
            NSLog(@"Error: %@", error);
        }
    }];
}

@end
