//
//  MarkerView.m
//  Around Me
//
//  Created by Jesus Magana on 7/17/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import "MarkerView.h"
#import "ARGeoCoordinate.h"
#include <stdlib.h>

const float kWidth = 200.0f;
const float kHeight = 100.0f;
#define LABEL_HEIGHT            20
#define LABEL_MARGIN_TOP        5
#define LABEL_MARGIN_LEFT       55
#define DISCLOSURE_MARGIN_TOP   10
#define DISCLOSURE_MARGIN_LEFT  1

@interface MarkerView ()

@property (nonatomic, strong) UILabel *lblDistance;

@end

@implementation MarkerView{
    UIImage  *_bgImage;
    BOOL     _allowsCallout;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate {
	//1
	if((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, kHeight)])) {
        
		//2
		_coordinate = coordinate;
		_delegate = delegate;
        _usesMetric = YES;
        _allowsCallout = YES;
        
        if (coordinate.tipoLocal == 1) {
            _bgImage        = [UIImage imageNamed:@"ar_callout_vermelho.png"];
        }else if (coordinate.tipoLocal == 2) {
            _bgImage        = [UIImage imageNamed:@"ar_callout_amarelo.png"];
        }else if (coordinate.tipoLocal == 3) {
            _bgImage        = [UIImage imageNamed:@"ar_callout_verde.png"];
        }else{
            _bgImage        = [UIImage imageNamed:@"ar_callout_azul.png"];
        }
        
        UIImage *disclosureImage    = [UIImage imageNamed:@"ar_detalhes.png"];
        CGSize calloutSize          = _bgImage.size;
//        CGRect theFrame             = CGRectMake(0, 0, calloutSize.width, calloutSize.height);
        
		[self setUserInteractionEnabled:YES];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:_bgImage];
        [self addSubview:bgImageView];
        
        CGSize labelSize = CGSizeMake(calloutSize.width - (LABEL_MARGIN_TOP * 2), LABEL_HEIGHT);
        if(_allowsCallout){
            labelSize.width -= disclosureImage.size.width + (DISCLOSURE_MARGIN_TOP * 4);
        }
        
        //NOME DO LOCAL
        UILabel *titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN_LEFT, LABEL_MARGIN_TOP, labelSize.width, labelSize.height)];
        [titleLabel setBackgroundColor: [UIColor clearColor]];
        [titleLabel setTextColor:		[UIColor blackColor]];
        [titleLabel setTextAlignment:	NSTextAlignmentLeft];
        [titleLabel setFont:            [UIFont fontWithName:@"Helvetica" size:17.0]];
        [titleLabel setText:			[coordinate title]];
        [self addSubview:titleLabel];

        //QUANTIDADE DE PESSOAS
        UILabel *qtCheckin	= [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 50, 25)];
        [qtCheckin setBackgroundColor: [UIColor clearColor]];
        [qtCheckin setTextColor:		[UIColor whiteColor]];
        [qtCheckin setTextAlignment:	NSTextAlignmentCenter];
        [qtCheckin setFont:            [UIFont fontWithName:@"GillSans" size:30.0f]];
//        int r = arc4random_uniform(40); //numero aleatorio
        [qtCheckin setText:[coordinate qtCheckin]];
        [self addSubview:qtCheckin];
        
        //DISTANCIA
        _lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN_LEFT, LABEL_HEIGHT + LABEL_MARGIN_TOP, labelSize.width, labelSize.height)];
        [_lblDistance setBackgroundColor:    [UIColor clearColor]];
        [_lblDistance setTextColor:          [UIColor blackColor]];
        [_lblDistance setTextAlignment:      NSTextAlignmentLeft];
        [_lblDistance setFont:               [UIFont fontWithName:@"Helvetica" size:13.0]];
        if(_usesMetric == YES){
            [_lblDistance setText:[NSString stringWithFormat:@"%.2f km", [coordinate distanceFromOrigin]/1000.0f]];
        } else {
            [_lblDistance setText:[NSString stringWithFormat:@"%.2f mi", ([coordinate distanceFromOrigin]/1000.0f) * 0.621371]];
        }
        [self addSubview:_lblDistance];
        
        if(_allowsCallout){
            UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(calloutSize.width - disclosureImage.size.width - DISCLOSURE_MARGIN_LEFT, DISCLOSURE_MARGIN_TOP, disclosureImage.size.width, disclosureImage.size.height)];
            [disclosureImageView setImage:[UIImage imageNamed:@"ar_detalhes.png"]];
            [self addSubview:disclosureImageView];
        }
		
		[self setBackgroundColor:[UIColor clearColor]];
	}
    
	return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if(_usesMetric == YES){
        [_lblDistance setText:[NSString stringWithFormat:@"%.2f km", [[self coordinate] distanceFromOrigin]/1000.0f]];
    } else {
        [_lblDistance setText:[NSString stringWithFormat:@"%.2f mi", ([[self coordinate] distanceFromOrigin]/1000.0f) * 0.621371]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(_delegate && [_delegate conformsToProtocol:@protocol(MarkerViewDelegate)]) {
		[_delegate didTouchMarkerView:self];
	}
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect theFrame = CGRectMake(0, 0, _bgImage.size.width, _bgImage.size.height);
    if(CGRectContainsPoint(theFrame, point))
        return YES; // touched the view;
    
    return NO;
}

@end
