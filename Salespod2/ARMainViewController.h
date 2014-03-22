//
//  ARMainViewController.h
//  Salespod2
//
//  Created by inin on 3/12/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARKit.h"
#import <MapKit/MapKit.h>
#import "MarkerView.h"

typedef void (^SuccessHandler)(NSDictionary *responseDict);
typedef void (^ErrorHandler)(NSError *error);


@interface ARMainViewController : UIViewController <ARLocationDelegate, ARDelegate, ARMarkerDelegate,MarkerViewDelegate>


@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) MKUserLocation *userLocation;

@end
