//
//  MarkerView.h
//  Around Me
//
//  Created by Jesus Magana on 7/17/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import <UIKit/UIKit.h>

//1
@class ARGeoCoordinate;
@protocol MarkerViewDelegate;

@interface MarkerView : UIView

//2
@property (nonatomic, strong) ARGeoCoordinate *coordinate;
@property (nonatomic, weak) id <MarkerViewDelegate> delegate;
@property (nonatomic) BOOL usesMetric;

//3
- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate;

@end

//4
@protocol MarkerViewDelegate <NSObject>

- (void)didTouchMarkerView:(MarkerView *)markerView;

@end