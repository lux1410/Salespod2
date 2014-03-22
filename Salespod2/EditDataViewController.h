//
//  EditDataViewController.h
//  Salespod2
//
//  Created by inin on 3/9/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface EditDataViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *edName;
@property (strong, nonatomic) IBOutlet UITextField *edAddress;
@property MKAnnotationView* currentAnotationView;

@end
