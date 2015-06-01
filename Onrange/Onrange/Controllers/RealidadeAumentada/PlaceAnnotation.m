//
//  PlaceAnnotation.m
//  Around Me
//
//  Created by Jesus Magana on 7/17/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "Local.h"

@interface PlaceAnnotation ()
@property (nonatomic, strong) Local *local;
@end

@implementation PlaceAnnotation

- (id)initWithLocal:(Local *)local {
	if((self = [super init])) {
		_local = local;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	return [_local location].coordinate;
}

- (NSString *)nome {
	return [_local nome];
}

- (NSString *)qtCheckin {
    return [_local qt_checkin];
}

@end
