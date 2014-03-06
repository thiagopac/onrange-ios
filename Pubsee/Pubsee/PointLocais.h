//
//  PointLocais.h
//  Pubsee
//
//  Created by Thiago Castro on 04/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PointLocais : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (assign, nonatomic) NSInteger id_local;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

//@property (nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithCoordenada:(CLLocationCoordinate2D)coord nome:(NSString*)aNome;

@end
