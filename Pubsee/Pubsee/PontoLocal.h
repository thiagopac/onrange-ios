//
//  PontoLocal.h
//  Pubsee
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PontoLocal : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithCoordenada:(CLLocationCoordinate2D)coord titulo:(NSString*)titulo;

@end
