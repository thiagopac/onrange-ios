//
//  ControleTeclado.h
//  deegate
//
//  Created by Ricardo Sette on 10/15/12.
//  Copyright (c) 2012 Ricardo Sette. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControleTecladoDelegate <NSObject>

-(NSArray *)inputsTextFieldAndTextViews;

@end

@interface ControleTeclado : NSObject

@property (nonatomic, weak)UIViewController<ControleTecladoDelegate>* delegate;

@end
