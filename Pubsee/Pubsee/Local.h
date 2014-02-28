//
//  Local.h
//  Pubsee
//
//  Created by Thiago Castro on 27/02/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Local : NSObject

@property (nonatomic, assign) NSInteger id_local;
@property (nonatomic, strong) NSString *nome;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@end
