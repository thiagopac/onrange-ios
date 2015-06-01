//
//  ConfirmaAdicaoViewController.h
//  Onrange
//
//  Created by Thiago Castro on 16/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmaAdicaoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnFechar;
- (IBAction)btnFechar:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeLocal;
@property (strong, nonatomic) NSString *strNomeLocal;
@end
