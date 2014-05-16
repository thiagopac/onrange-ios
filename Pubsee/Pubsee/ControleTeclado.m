//
//  ControleTeclado.m
//  deegate
//
//  Created by Ricardo Sette on 10/15/12.
//  Copyright (c) 2012 Ricardo Sette. All rights reserved.
//

#import "ControleTeclado.h"

@interface ControleTeclado()

@property (strong, nonatomic) IBOutlet UIToolbar *toolBarTeclado;
@property (strong, nonatomic) UIView *view;

@end

@implementation ControleTeclado

- (id)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:@"ControleTeclado" owner:self options:nil];
    }
    return self;
}

- (IBAction)done:(UIBarButtonItem *)sender {
    if ([[self delegate] respondsToSelector:@selector(view)]) {
		[[[self delegate]view] endEditing:NO];
	}
}

-(void)setDelegate:(UIViewController<ControleTecladoDelegate> *)delegate
{
    NSInteger indexTag = 876;
    for (id obj in [delegate inputsTextFieldAndTextViews]) {
        [obj setTag:++indexTag];
        [obj setInputAccessoryView:_toolBarTeclado];
    }
    _delegate = delegate;
}

@end
