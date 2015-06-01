//
//  PointLocais.m
//  Onrange
//
//  Created by Thiago Castro on 04/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PointLocais.h"

@implementation PointLocais

- (id)initWithCoordenada:(CLLocationCoordinate2D)coord nome:(NSString*)aNome
{
    self = [super init];
    if (self) {
        _title = aNome;
        _coordinate = coord;
    }
    return self;
}

@end
