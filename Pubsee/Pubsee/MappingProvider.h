//
//  MappingProvider.h
//  Onrange
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restkit/restkit.h>

@interface MappingProvider : NSObject

+ (RKMapping *)usuarioMapping;
+ (RKMapping *)localMapping;
+ (RKMapping *)checkinMapping;

@end