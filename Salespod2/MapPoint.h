//
//  MapPoint.h
//  Salespod
//
//  Created by inin on 3/8/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapPoint : NSObject <MKAnnotation>

{
    
    NSString *_name;
    NSString *_address;
    NSString *_id;
    
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (copy) NSString *id;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *website;


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate aId:(NSString*)aId;

-(CLLocation*)location;

@end
