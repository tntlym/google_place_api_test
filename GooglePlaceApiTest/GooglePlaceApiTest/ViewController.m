//
//  ViewController.m
//  GooglePlaceApiTest
//
//  Created by bluemol on 7/6/13.
//  Copyright (c) 2013 Doradori. All rights reserved.
//

#import "ViewController.h"

#define GOOGLE_PLACE_BASE_URL @"https://maps.googleapis.com/maps/api/place/nearbysearch/"
#define GOOGLE_API_KEY @"AIzaSyAtK3jGI1fZaf_ykuLnq1T3ZMJ440S4vYc"
#define RADIUS @"1000"
#define OUTPUT @"json"
#define SENSOR @"true"
#define TYPES @"restaurant"


@interface ViewController () {
    CLLocationManager *locMgr;
    NSString *location;
    
    IBOutlet UIButton *btn;
}

@end

@implementation ViewController

- (IBAction)btnSelected:(id)sender
{
    [self getCurrentLocation];
}

- (void)getCurrentLocation
{
    [locMgr startUpdatingLocation];
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
}

- (void) requestGooglePlaceApi
{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%@&radius=%@&types=%@&sensor=true&key=%@", location, RADIUS, TYPES, GOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc =  [locations lastObject];
    NSLog(@"x: %f y: %f", loc.coordinate.latitude, loc.coordinate.longitude);
    
    location = [[NSString alloc] initWithFormat:@"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
    
    if (loc != nil) {
        [locMgr stopUpdatingLocation];
        [self requestGooglePlaceApi];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Fail with error %@", error);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", [[NSBundle mainBundle] bundleIdentifier]);
    
    locMgr = [[CLLocationManager alloc] init];
    locMgr.delegate = self;
    locMgr.distanceFilter = kCLDistanceFilterNone;
    locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
