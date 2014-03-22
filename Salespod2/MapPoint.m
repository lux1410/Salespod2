//
//  MapPoint.m
//  Salespod
//
//  Created by inin on 3/8/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;
@synthesize id = _id;


-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate aId:(NSString*)aId  {
    if ((self = [super init])) {
        
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        _id=[aId copy];
        
        
        
    }
    return self;
}


-(NSString *)title {
    
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}


-(NSString *)subtitle {
    return _address;
}

-(CLLocation*)location{
    
    return [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
}

/*
- (NSString *)infoText {
	return [NSString stringWithFormat:@"Name:%@\nAddress:%@\nPhone:%@\nWeb:%@", _placeName, _address, _phoneNumber, _website];
}
*/


@end
