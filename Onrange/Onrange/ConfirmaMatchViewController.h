//
//  ConfirmaMatchViewController.h
//  Onrange
//
//  Created by Thiago Castro on 15/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmaMatchViewController : UIViewController
@property (strong, nonatomic) NSString *strNomeUsuario;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeUsuario;
- (IBAction)btnFechar:(id)sender;

@end
