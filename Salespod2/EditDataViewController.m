//
//  EditDataViewController.m
//  Salespod2
//
//  Created by inin on 3/9/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import "EditDataViewController.h"
#import "MapPoint.h"
#import "MapView2Controller.h"
#import "LocalDB.h"



@interface EditDataViewController ()

@end

@implementation EditDataViewController

@synthesize currentAnotationView=_currentAnotationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.edAddress setDelegate:self];
    [self.edName setDelegate:self];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)savePress:(id)sender {

    
    ((MapPoint*)self.currentAnotationView.annotation).address=self.edAddress.text;
    
    ((MapPoint*)self.currentAnotationView.annotation).name=self.edName.text;
    
    [[LocalDB LocalDatabase] updateRecord:self.currentAnotationView.annotation];
    
    MKMapView* aView=(MKMapView*)[self.currentAnotationView superview];
    
    [aView deselectAnnotation:self.currentAnotationView.annotation animated:NO];
    
    [aView selectAnnotation:self.currentAnotationView.annotation animated:NO];
    
    
    [self dismissModalViewControllerAnimated:YES];
  

}

- (IBAction)cancelPress:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
