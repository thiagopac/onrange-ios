//
//  PointLocais.h
//  Onrange
//
//  Created by Thiago Castro on 04/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PointLocais : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *qt_checkin;
@property (assign, nonatomic) NSInteger id_local;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (assign, nonatomic) int tipo_local;

//Tipos de local
//  1-Balada
//  2-Bar
//  3-Festa
//  4-Locais Públicos

//@property (nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithCoordenada:(CLLocationCoordinate2D)coord nome:(NSString*)aNome;

@end
