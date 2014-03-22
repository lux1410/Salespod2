//
//  MapView2Controller.m
//  Salespod2
//
//  Created by inin on 3/9/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import "MapView2Controller.h"
#import "MapPoint.h"
#import "LocalDB.h"
#import "EditDataViewController.h"
#import "ARMainViewController.h"
#import <AWSRuntime/AWSRuntime.h>

#define ACCESS_KEY_ID          @"AKIAIR2D7MHQJPUNTAJA"
#define SECRET_KEY             @"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"
#define PICTURE_BUCKET         @"lux-bucket"


@interface MapView2Controller ()



@end

@implementation MapView2Controller

@synthesize currentAnotationView=_currentAnotationView;
@synthesize s3 = _s3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"MapView", @"MapView");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.mapView.delegate=self;
    
    [self.mapView setShowsUserLocation:YES];
    
    locationManager=[[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    
    firstLaunch=YES;
    
    // Initial the S3 Client.
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] ;
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    // Create the picture bucket.
    S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[self pictureBucket] andRegion:[S3Region USWest2]];
    S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
    if(createBucketResponse.error != nil)
    {
        NSLog(@"Error: %@", createBucketResponse.error);
    }

    
    
    
    
}

-(NSString *)pictureBucket
{
    return [[NSString stringWithFormat:@"%@-%@", PICTURE_BUCKET, ACCESS_KEY_ID] lowercaseString];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation     *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if (!queryDone)
    {
       
    queryDone=YES;
        
    [manager stopUpdatingLocation];
        
    [self updateRegion:newLocation];
    
    [self queryGooglePlaces:nil aroundLocation:newLocation];
        
        
    }
}

-(void)updateRegion:(CLLocation*)curLocation{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([curLocation coordinate],1000,1000);
    [_mapView setRegion:region animated:YES];

}



-(void)queryGooglePlaces:(NSString *) googleType aroundLocation:(CLLocation*)curLocation{
    
    currLocation=curLocation;
    
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%i&sensor=true&key=%@", curLocation.coordinate.latitude, curLocation.coordinate.longitude, 1000, kGOOGLE_API_KEY];
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    
    dispatch_async(kBgQueue,^{
        
        NSData* data=[NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        
        
    });
    
}





-(void) fetchedData:(NSData*)responseData{
    
    if (responseData) {
        
    
    
    NSError* error;
    NSDictionary* json=[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray* places=[json objectForKey:@"results"];
    
    
    [self plotPositions:places];
    
    NSLog(@"Google Data: %@",places);
    }
    else
    {
        
        [self plotPositions:nil];

        //[self showAlertMessage:@"Faild to get Google data!" withTitle:@"Error"];
        
        
    }
}

-(void)plotPositions:(NSArray*)data{
    
        
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    
   if (data)
   {
    
    for (int i=0; i<[data count]; i++) {
        
        NSDictionary* place=[data objectAtIndex:i];
        
        NSString* aId=[place objectForKey:@"id"];
        
        NSDictionary* geo=[place objectForKey:@"geometry"];
        
        NSDictionary* loc=[geo objectForKey:@"location"];
        
        NSString* name=[place objectForKey:@"name"];
        
        NSString* vicinity=[place objectForKey:@"vicinity"];
        
        CLLocationCoordinate2D placeCoord;
        
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        MapPoint* placeObject=[[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord aId:aId ];
               
        
        
        [[LocalDB LocalDatabase] insertRecord:placeObject];
        
        
        [self.mapView addAnnotation:placeObject];
        
        
        
        
    }
   }
    else
    {
      NSMutableArray* arr=[[LocalDB LocalDatabase] getPlacesFromDB:currLocation];
        
        
        for (MapPoint* placeObject in arr) {
            [self.mapView addAnnotation:placeObject];
        }
        
    }
    
}



/*
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    //Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    
    MKMapRect mRect=self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint=MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint=MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    currenDist=MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    currentCentre=self.mapView.centerCoordinate;
    
    
    
    
}*/

#pragma mark - MKMapViewDelegate methods.
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    //Zoom back to the user location after adding a new set of annotations.
    //Get the center point of the visible map.
    
 /*   CLLocationCoordinate2D centre = [mapView centerCoordinate];
    MKCoordinateRegion region;
    
    
    //If this is the first launch of the app, then set the center point of the map to the user's location.
    if (firstLaunch) {
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
        firstLaunch=NO;
    }else {
        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    
    
    [mapView setRegion:region animated:YES];
   */ 
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    
    static NSString* identifier=@"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]){
        
        MKPinAnnotationView* annotationView=(MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView==nil) {
            annotationView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            annotationView.annotation=annotation;
        }
        
        annotationView.enabled=YES;
        annotationView.canShowCallout=YES;
        annotationView.animatesDrop=YES;
        
        
        
        return  annotationView;
        
        
    }
    
    return nil;
    
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    
    if ([view.annotation isKindOfClass:[MapPoint class]])
    {
        
         self.currentAnotationView=view;
         self.editButton.enabled=YES;
        
    }
}



-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    
    
    if ([view.annotation isKindOfClass:[MapPoint class]])
    {
        self.currentAnotationView=nil;
        self.editButton.enabled=NO;
    }
}




- (IBAction)refreshPress:(id)sender {
    
      
    queryDone=NO;
    [locationManager startUpdatingLocation];
    
}


- (IBAction)editPress:(id)sender {
    
    
    /*ARMainViewController *viewController2 = [[ARMainViewController alloc] initWithNibName:@"ARMainViewController" bundle:nil];
    
    
    viewController2.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [viewController2 setLocations:[NSMutableArray arrayWithCapacity:[self.mapView.annotations count]]];
       
    [viewController2 setUserLocation:self.mapView.userLocation];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            
            [viewController2.locations addObject:annotation];
            
        }
    }

    
    
    
    [self presentModalViewController:viewController2 animated:YES];
    
    */
    
    
    
    /////
    
    UIViewController *viewController2 = [[EditDataViewController alloc] initWithNibName:@"EditDataViewController" bundle:nil];
    
    
    viewController2.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    
    
    
    [self presentModalViewController:viewController2 animated:YES];
    
    
    EditDataViewController* ev=(EditDataViewController*)viewController2;
    
    ev.edAddress.text=((MapPoint*)self.currentAnotationView.annotation).address;
    ev.edName.text=((MapPoint*)self.currentAnotationView.annotation).name;
    
    ev.currentAnotationView=self.currentAnotationView;
    
     
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEditButton:nil];
    [self setUploadLabel:nil];
    [self setChooseButton:nil];
    [super viewDidUnload];
}

- (IBAction)photoPress:(UIBarButtonItem*)sender {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init] ;
    
    
    if (sender.tag==1) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    
       
    imagePicker.delegate = self;
   
    
    [self presentModalViewController:imagePicker animated:YES];


}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Convert the image to JPEG data.
    self.currentimageData = UIImageJPEGRepresentation(image, 1.0);
    
    UIImage *jpg=[UIImage imageWithData:self.currentimageData];
    UIImageWriteToSavedPhotosAlbum(jpg,nil,nil,nil);
    
   [picker dismissModalViewControllerAnimated:YES]; 
     
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Photo name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Photo name";
    [alertTextField becomeFirstResponder];
    
    [alert show];
    
      
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    if (buttonIndex==1)
    {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(toggleLabelAlpha) userInfo:nil repeats:YES];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        [self processGrandCentralDispatchUpload:self.currentimageData withPhotoName:alertTextField.text];
        

    }
    
}

- (void)toggleLabelAlpha {
    
    [self.uploadLabel setHidden:(!self.uploadLabel.hidden)];
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData withPhotoName:(NSString*)photoName
{
    
    if ([photoName length]==0) {
        photoName=@"photo";
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:photoName
                                                                  inBucket:[self pictureBucket]];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
               
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.timer invalidate];
            [self.uploadLabel setHidden:YES];
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}


- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] ;
    [alertView show];
}





@end
