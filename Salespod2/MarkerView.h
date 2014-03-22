//
//  MarkerView.h
//  Around Me
//
//  Created by inin on 3/12/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import <Foundation/Foundation.h>

//1
@class ARGeoCoordinate;
@protocol MarkerViewDelegate;

@interface MarkerView : UIView

//2
@property (nonatomic, strong) ARGeoCoordinate *coordinate;
@property (nonatomic, weak) id <MarkerViewDelegate> delegate;

//3
- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate;

@end

//4
@protocol MarkerViewDelegate <NSObject>

- (void)didTouchMarkerView:(MarkerView *)markerView;

@end

