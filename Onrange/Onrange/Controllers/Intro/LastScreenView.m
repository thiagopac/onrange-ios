//
//  LastScreenView.m
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import "LastScreenView.h"

@implementation LastScreenView


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (IBAction)btnTermosDeUso:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://onrange.com.br/termosdeuso"]];
}
@end
