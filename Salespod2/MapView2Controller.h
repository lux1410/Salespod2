//
//  MapView2Controller.h
//  Salespod2
//
//  Created by inin on 3/9/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AWSS3/AWSS3.h>

#define kGOOGLE_API_KEY @"AIzaSyAz0yDhIeSrMja55n5zv383PbJUfbeumEE"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)




@interface MapView2Controller : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AmazonServiceRequestDelegate>

{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
    BOOL queryDone;
    
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) NSData *currentimageData;

@property (strong, nonatomic) IBOutlet UILabel *uploadLabel;
@property (strong, nonatomic) IBOutlet UIToolbar *chooseButton;


@property MKAnnotationView* currentAnotationView;
@property (strong, nonatomic) NSTimer *timer;

@end
