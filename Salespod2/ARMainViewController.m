//
//  ARMainViewController.m
//  Salespod2
//
//  Created by inin on 3/12/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import "ARMainViewController.h"
#import "MapPoint.h"
#import "MapView2Controller.h"


const int kInfoViewTag = 1001;
NSString * const apiURL = @"https://maps.googleapis.com/maps/api/place/";
NSString * const kPhoneKey = @"formatted_phone_number";
NSString * const kWebsiteKey = @"website";



@interface ARMainViewController ()
@property (nonatomic, strong) AugmentedRealityController *arController;
@property (nonatomic, strong) NSMutableArray *geoLocations;
@property (nonatomic, strong) SuccessHandler successHandler;
@property (nonatomic, strong) ErrorHandler errorHandler;
@end

@implementation ARMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Camera", @"Camera");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!_arController) {
        _arController = [[AugmentedRealityController alloc] initWithView:[self view] parentViewController:self withDelgate:self];
    }
    
    [_arController setMinimumScaleFactor:0.5];
    [_arController setScaleViewsBasedOnDistance:YES];
    [_arController setRotateViewsBasedOnPerspective:YES];
    [_arController setDebugMode:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didUpdateHeading:(CLHeading *)newHeading {
    
}

-(void)didUpdateLocation:(CLLocation *)newLocation {
    
}

-(void)didUpdateOrientation:(UIDeviceOrientation)orientation {
    
}


- (void)didTapMarker:(ARGeoCoordinate *)coordinate {
}

- (NSMutableArray *)geoLocations {
    if(!_geoLocations) {
		[self generateGeoLocations];
	}
	return _geoLocations;
}

- (void)generateGeoLocations {
	//1
	[self setGeoLocations:[NSMutableArray arrayWithCapacity:[_locations count]]];
    
   /*[_locations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
       [(MapPoint*)obj1 location]
   }]
    */
    
    //2
	for(MapPoint *place in _locations) {
		//3
		ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:[place location] locationTitle:[place name]];
		//4
		[coordinate calibrateUsingOrigin:[_userLocation location]];
        
		MarkerView *markerView = [[MarkerView alloc] initWithCoordinate:coordinate delegate:self];
        [coordinate setDisplayView:markerView];
        
		//5
		[_arController addCoordinate:coordinate];
		[_geoLocations addObject:coordinate];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self geoLocations];
}

- (void)didTouchMarkerView:(MarkerView *)markerView {
	
    
    ARGeoCoordinate *tappedCoordinate = [markerView coordinate];
	CLLocation *location = [tappedCoordinate geoLocation];
	
	int index = [_locations indexOfObjectPassingTest:^(id obj, NSUInteger index, BOOL *stop) {
		return [[obj location] isEqual:location];
	}];
	
	/*if(index != NSNotFound) {
		MapPoint *tappedPlace = [_locations objectAtIndex:index];
		[self loadDetailInformation:tappedPlace successHanlder:^(NSDictionary *response) {
			NSLog(@"Response: %@", response);
            NSDictionary *resultDict = [response objectForKey:@"result"];
			[tappedPlace setPhoneNumber:[resultDict objectForKey:kPhoneKey]];
			[tappedPlace setWebsite:[resultDict objectForKey:kWebsiteKey]];
			[self showInfoViewForPlace:tappedPlace];
		} errorHandler:^(NSError *error) {
			NSLog(@"Error: %@", error);
		}];
	}*/
}

- (void)loadDetailInformation:(MapPoint *)location successHanlder:(SuccessHandler)handler errorHandler:(ErrorHandler)errorHandler {
	//_responseData = nil;
	_successHandler = handler;
	_errorHandler = errorHandler;
	
	NSMutableString *uri = [NSMutableString stringWithString:apiURL];
/*	[uri appendFormat:@"details/json?reference=%@&sensor=true&key=%@", [location reference], kGOOGLE_API_KEY];*/
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"GET"];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	NSLog(@"Starting connection: %@ for request: %@", connection, request);
}


- (void)showInfoViewForPlace:(MapPoint *)place {

	CGRect frame = [[self view] frame];
	UITextView *infoView = [[UITextView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, frame.size.width - 100.0f, frame.size.height - 100.0f)];
	[infoView setCenter:[[self view] center]];
	[infoView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	//[infoView setText:[place infoText]];
    [infoView setText:[place subtitle]];
    
	[infoView setTag:kInfoViewTag];
	[infoView setEditable:NO];
	[[self view] addSubview:infoView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UIView *infoView = [[self view] viewWithTag:kInfoViewTag];
	
	[infoView removeFromSuperview];
}

- (IBAction)donePress:(id)sender {

[self dismissModalViewControllerAnimated:YES]; 
}



@end
