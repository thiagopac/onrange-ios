//
//  PontoLocal.m
//  Pubsee
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "PontoLocal.h"

@implementation PontoLocal

- (id)initWithCoordenada:(CLLocationCoordinate2D)coord titulo:(NSString*)titulo
{
    self = [super init];
    if (self) {
        _title = titulo;
        _coordinate = coord;
    }
    return self;
}
@end
