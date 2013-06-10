//
//  SmileyReportViewController.m
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "SmileyReportViewController.h"
#import "ForesquareFetcher.h"
#import "FindSmileyFetcher.h"
#import "SmileyReportPlace.h"
#import "SmileyReportPlaceTableCell.h"
#import "SmileyFavoritesManager.h"
#import "RegionMonitor.h"
#import "NetworkActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_TABLE_CELL_SIZE 96
#define MIN_TABLE_CELL_SIZE 50
#define RADIUS_TO_SEARCH_IN 500
#define SETTINGS_KEY @"SmileyReportSettings"

@interface SmileyReportViewController ()
@property (weak, nonatomic) IBOutlet UIView*        topBarView;
@property (weak, nonatomic) IBOutlet UISwitch*      alertSwitchSettingsBar;
@property (weak, nonatomic) IBOutlet UISlider*      alertSliderSettingsBar;
@property (weak, nonatomic) IBOutlet UIButton*      redoSearchButton;
@property (weak, nonatomic) IBOutlet UIButton*      goToCurrentLocationButton;
@property (weak, nonatomic) IBOutlet UIView*        detailView;
@property (nonatomic)       BOOL                    detailViewFullSizeMode;
@property (weak, nonatomic) IBOutlet UIView*        detailViewHeader;
@property (weak, nonatomic) IBOutlet UILabel*       detailViewTitleLabel;
@property (strong, nonatomic)        UIButton*      favoritesButton;
@property (weak, nonatomic) IBOutlet UIView*        favoritesView;
@property (nonatomic)       BOOL                    favoritesViewFullSizeMode;
@property (weak, nonatomic) IBOutlet UIView*        favoritesViewHeader;
@property (weak, nonatomic) IBOutlet UITableView*   favoritesTableView;
@property (strong, nonatomic)        UIImageView*   cuteFlyingStar;
@property (strong, nonatomic)        UIButton*      settingsButton;
@property (weak, nonatomic) IBOutlet UIView*        settingsBarView;
@property (weak, nonatomic) IBOutlet UITableView*   placesTableView;
@property (weak, nonatomic) IBOutlet MKMapView*     mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* placeSearchActivityIndicator;
@property (strong, nonatomic) CLLocationManager*    locationManager;
@property (strong, nonatomic) NSMutableArray*       places;

@end

@implementation SmileyReportViewController

static NSString* reuseIdentifier = @"SmileyMapView";
static BOOL pushed = false;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self setupDetailView];
    [self setupTopBarView];
    [self setupFavoritesView];
    [self setupCuteFlyingStar];
    NSLog(@"View loading");
}
- (void)setupCuteFlyingStar
{
    self.cuteFlyingStar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites.png"]];
    [self.cuteFlyingStar setAlpha:0.7];
    self.cuteFlyingStar.frame  = CGRectMake(0, 0, 34, 34);
    self.cuteFlyingStar.hidden = YES;
    [self.view addSubview:self.cuteFlyingStar];

}
- (void) makeFlyingStarBlack
{
    [self.cuteFlyingStar setImage:[UIImage imageNamed:@"favorites.png"]];
    [self.cuteFlyingStar setAlpha:1];
}
- (void) makeFlyingStarWhite
{
    [self.cuteFlyingStar setImage: [UIImage imageNamed:@"favorites_on.png"]];
    [self.cuteFlyingStar setAlpha:1];
}
- (void)prepareForLocationUpdates
{
    self.locationManager = [[self class] sharedLocationManager];
    self.locationManager.delegate = self;//TODO do this on the storyboard
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    [RegionMonitor setLocationManager:self.locationManager];
    if([CLLocationManager locationServicesEnabled])
        [self.locationManager startUpdatingLocation];
}
- (void) setupTopBarView
{   // It's not allowed to have a toolbar with a searchbar in it, nor put 2 buttons in a searchbar without using hacks
    // Having a custom view is more clean...
    // [self.topBarView setClipsToBounds:YES];
    self.topBarView.layer.shadowOffset = CGSizeMake(0, -3);
    self.topBarView.layer.shadowRadius = 10;
    self.topBarView.layer.shadowOpacity = 0.5;
    
    self.favoritesButton = [[UIButton alloc] init];
    [self.favoritesButton setFrame:CGRectMake(5, 5, 44, 44)];
    UIImageView* favoritesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites.png"]];
    [favoritesImage setFrame:CGRectMake(6, 0, 32, 32)];
    [self.favoritesButton addSubview:favoritesImage];
    UITapGestureRecognizer *favoritesTappedGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoritesButtonTapped:)];
    [self.favoritesButton addGestureRecognizer:favoritesTappedGestureRecognizer];
    [self.topBarView addSubview:self.favoritesButton];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBackgroundImage:[UIImage imageNamed:@"searchBarBGImage.png"]];
    [searchBar setFrame:CGRectMake(55, 0, 205, 41)];
    [self.topBarView addSubview:searchBar];
    
    self.settingsButton = [[UIButton alloc] init];
    [self.settingsButton setFrame:CGRectMake(265, 5, 44, 44)];
    UIImageView* settingsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings.png"]];
    [settingsImage setFrame:CGRectMake(6, 0, 32, 32)];
    [self.settingsButton addSubview:settingsImage];
    UITapGestureRecognizer *settingsTappedGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsButtonTapped:)];
    [self.settingsButton addGestureRecognizer:settingsTappedGestureRecognizer];
    [self.topBarView addSubview:self.settingsButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"View will appear!");
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!pushed){
    [self prepareForLocationUpdates];
    [self prepareUserDefaultSettings];
    }
    pushed = !pushed;
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"loadInspectionDoc"]){
        if([sender isKindOfClass:[MKAnnotationView class]]){
            MKAnnotationView*aView = sender;
            NSArray* inspections = [aView.annotation performSelector:@selector(inspections)];
            NSString* lastInspectionDocumentURLString = inspections[0][@"doc_link"];
            [segue.destinationViewController performSelector:@selector(setURL:) withObject:lastInspectionDocumentURLString];
        }
    }
    
}


#pragma mark - mapView Delegate Methods

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if(view.rightCalloutAccessoryView == control){
        if([view.annotation respondsToSelector:@selector(inspections)]){
            NSArray* inspections = [view.annotation performSelector:@selector(inspections)];
            NSString* lastInspectionDocumentURL = (inspections[0])[@"doc_link"];
            NSURL *targetURL = [NSURL URLWithString:lastInspectionDocumentURL];
            [self performSegueWithIdentifier:@"loadInspectionDoc" sender:view];
            pushed = true;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.redoSearchButton.hidden = NO;
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // If it's our custom annotation
    if ([annotation isKindOfClass:[SmileyReportPlace class]])
    {
        SmileyReportPlace* smileyAnnotation = (SmileyReportPlace*) annotation;
        MKAnnotationView *anView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if(!anView){
            anView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            anView.canShowCallout             = YES;
            anView.leftCalloutAccessoryView   = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
            UIImageView* imgView              = (UIImageView*)anView.leftCalloutAccessoryView;
        }
        
        //reset image
        if([anView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]){
            UIImageView* imgView = (UIImageView*)anView.leftCalloutAccessoryView;
            if (smileyAnnotation.categoryIcon){
                [imgView setImage: smileyAnnotation.categoryIcon];
            }
            else{
                [imgView setImage:nil];
            }
        }
        
        //set appropriate pin image and add right callout button
        if(smileyAnnotation.report != nil && ![smileyAnnotation.report isEmpty]){
            int smileyValue = [[smileyAnnotation.report getLastInspection][@"smiley"] integerValue];
            NSString *imageName = [NSString stringWithFormat:@"Sm%dcs.png", smileyValue];
            anView.image = [UIImage imageNamed:imageName];
            anView.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        else{
            anView.image = [UIImage imageNamed:@"unknownPin.png"];
        }

        return anView;
    }
    
    return nil;
}

#pragma mark - mapView Helper Methods

- (void) updateMapViewToLocation:(CLLocationCoordinate2D) location
{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location, 700, 700) animated:YES];
}

- (void) retrieveNearbyPlaces:(CLLocationCoordinate2D) point
{
    [self retrieveNearbyPlaces:point withinRadius:@RADIUS_TO_SEARCH_IN];
}

- (void) retrieveNearbyPlaces:(CLLocationCoordinate2D) point withinRadius:(NSNumber*) radius
{
    dispatch_queue_t nearbyFetch = dispatch_queue_create("nearbyFetch", NULL);
    dispatch_async(nearbyFetch, ^{
        
        [NetworkActivityIndicator push];
        dispatch_sync(dispatch_get_main_queue(), ^{[self.placeSearchActivityIndicator startAnimating];
            self.detailViewTitleLabel.hidden = YES;});
        NSDictionary* result = [ForesquareFetcher searchInVicinityOf:point withRadius:radius];
        [NetworkActivityIndicator pop];
        
        self.places      = [[SmileyReportPlace MakeFromDictArray:result[@"venues"]] mutableCopy];
        for(SmileyReportPlace* place in self.places)
        {
            [NetworkActivityIndicator push];
            NSArray* results = [FindSmileyFetcher searchBySmileyReportPlace:place];
            dispatch_sync(dispatch_get_main_queue(), ^{[self.placeSearchActivityIndicator stopAnimating];
                self.detailViewTitleLabel.hidden = NO;
                self.detailViewTitleLabel.text = [NSString stringWithFormat:@"Found %d restaurants nearby.",[self.places count]];
            });
            [NetworkActivityIndicator pop];
            
            place.report = results[0];
            [RegionMonitor addAlertRegionForPlaces: @[place]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView addAnnotation:place];
                if(self.placesTableView.hidden)
                    self.placesTableView.hidden = NO;
                [self.placesTableView reloadData];
            });
        }
    });
}

- (IBAction)searchWithinRegion:(id)sender {
    self.placesTableView.hidden = YES;
    MKCoordinateRegion currentRegion = self.mapView.region;
    
    //determine the radius to search in, depending on the shown region on the map
    CLLocationCoordinate2D horizontalRadiusEndPoint = currentRegion.center;
    horizontalRadiusEndPoint.longitude += currentRegion.span.longitudeDelta/2.0;
    CLLocationCoordinate2D verticalRadiusEndPoint = currentRegion.center;
    verticalRadiusEndPoint.latitude += currentRegion.span.latitudeDelta/2.0;
    
    CLLocation* centerLocation             = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude
                                                                        longitude:self.mapView.region.center.longitude];
    CLLocation* horizontalEndPointLocation = [[CLLocation alloc] initWithLatitude:horizontalRadiusEndPoint.latitude
                                                                        longitude:horizontalRadiusEndPoint.longitude];
    CLLocation* verticalEndPointLocation   = [[CLLocation alloc] initWithLatitude:verticalRadiusEndPoint.latitude
                                                                        longitude:verticalRadiusEndPoint.longitude];
    
    NSNumber* radius = @(MAX([centerLocation distanceFromLocation:horizontalEndPointLocation],
                             [centerLocation distanceFromLocation:verticalEndPointLocation]));
    
    [self retrieveNearbyPlaces:currentRegion.center withinRadius: radius];
    self.redoSearchButton.hidden = YES;
    
}

# pragma mark - CLLocationManager Delegate Methods

+ (CLLocationManager*) sharedLocationManager
{
    static CLLocationManager* locationManager = nil;
    if(!locationManager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            locationManager = [[CLLocationManager alloc] init];
        });
    }
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location    = [locations lastObject];
    NSDate*     eventDate   = location.timestamp;
    NSTimeInterval howRecent= [eventDate timeIntervalSinceNow];
   // if (abs(howRecent) < 15.0 && location.horizontalAccuracy < 50) {
        NSLog(@"CHANGED LOCATION: latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        [self updateMapViewToLocation:location.coordinate];
        [self retrieveNearbyPlaces:location.coordinate];
  //  }
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate   = [NSDate date];
    notification.timeZone   = [NSTimeZone defaultTimeZone];
    notification.alertBody  = @"You just entered in a crappy resturant :(";
    notification.soundName  = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Heads up!" message:@"You just entered in a crappy resturant :(" delegate:nil cancelButtonTitle:@"Will swiftly exit, thanks!" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
//    NSLog(@"Exited region %@", region.identifier);
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate date];
//    notification.timeZone = [NSTimeZone defaultTimeZone];
//    notification.alertBody =[NSString stringWithFormat:@"Exited Region %@", region.identifier];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber = 1;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog([error description]);
}

#pragma mark UI Related Methods

- (void) setupDetailView
{
    self.placesTableView.delegate   = self;
    self.placesTableView.dataSource = self;
    [[self class] addDropShadowToView:self.detailView withOffset:CGSizeMake(-3, 0) radius:4 andAlpha:0.3];
    self.detailView.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
    self.detailViewFullSizeMode = NO;
    [self.placesTableView reloadData];
}

- (IBAction)headerDetailViewTapped:(id)sender {
    if(!self.placeSearchActivityIndicator.isAnimating){
    if(self.detailViewFullSizeMode == NO)
        [self expandView:self.detailView
       withCompleteBLock: ^(BOOL finished) { if(finished) self.detailViewFullSizeMode = YES;}];
    else
        [self minimizeView:self.detailView
         withCompleteBLock:^(BOOL finished) { if(finished) self.detailViewFullSizeMode = NO;}];
    }
}
- (IBAction)headerFavoritesViewTapped:(id)sender {

        if(self.favoritesViewFullSizeMode == NO)
            [self expandView:self.favoritesView
           withCompleteBLock: ^(BOOL finished) { if(finished) self.favoritesViewFullSizeMode = YES;}];
        else
            [self minimizeView:self.favoritesView
             withCompleteBLock:^(BOOL finished) { if(finished) self.favoritesViewFullSizeMode = NO;}];

}

- (void) expandView:(UIView*) view withCompleteBLock:(void (^) (BOOL)) completeBlock
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{view.center = CGPointMake(view.center.x, self.view.frame.size.height*0.7);}
                     completion:^(BOOL finished) { view.userInteractionEnabled = YES;
                                                   completeBlock(finished);}];
}

- (void) minimizeView:(UIView*) view withCompleteBLock:(void (^) (BOOL)) completeBlock
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{view.center = CGPointMake(view.center.x, self.view.frame.size.height); }
                     completion:^(BOOL finished)  { view.userInteractionEnabled = YES;
                                                    completeBlock(finished);}];
}

- (void) setupFavoritesView
{
    self.favoritesView.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
    self.favoritesViewFullSizeMode = NO;
    self.favoritesView.hidden = YES;
    [[self class] addDropShadowToView:self.favoritesView withOffset:CGSizeMake(-3, 0) radius:4 andAlpha:0.3];
}


#pragma mark Table View Delegate and Data Source Methods
//NOTE: Since we have two table views hooked up we need to distinguish between them
//      A side note: cell prototypes can not be reused from other UITableViews, the reuse identifier
//      is registered to each table view, not somewhere globally.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* places = tableView == self.placesTableView ? self.places : [SmileyFavoritesManager getFavoritesList];
    return [places count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
    if ([tableView isEqual:self.favoritesTableView]){
        result = UITableViewCellEditingStyleDelete;
    }
    return result;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if (editingStyle == UITableViewCellEditingStyleDelete){
        if (indexPath.row < [[SmileyFavoritesManager getFavoritesList] count]){
            SmileyReportPlace* selectedPlace = [SmileyFavoritesManager getFavoritesList][indexPath.row];
            [SmileyFavoritesManager removePlaceFromFavoritesList:selectedPlace];
            [self.favoritesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* places = tableView == self.placesTableView ? self.places : [SmileyFavoritesManager getFavoritesList];
    SmileyReportPlace* place = (SmileyReportPlace*)[places objectAtIndex:indexPath.row];
   
    if(tableView == self.placesTableView && self.detailViewFullSizeMode)
        [self performSelector:@selector(headerDetailViewTapped:) withObject:nil];
    if(tableView == self.favoritesTableView && self.favoritesViewFullSizeMode)
        [self performSelector:@selector(headerFavoritesViewTapped:) withObject:nil];
    
    [self updateMapViewToLocation:place.coordinate];
    [self.mapView selectAnnotation:place animated:YES];
    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSArray* places = tableView == self.placesTableView ? self.places : [SmileyFavoritesManager getFavoritesList];
     SmileyReport* temp = ((SmileyReportPlace*)[places objectAtIndex:indexPath.row]).report;
    if( temp != nil && ![temp isEmpty])
        return MAX_TABLE_CELL_SIZE;
    else
        return MIN_TABLE_CELL_SIZE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = tableView == self.placesTableView ? @"SmileyReportPlaceCell": @"SmileyReportFavoritesPlaceCell";
    NSArray* places          = tableView == self.placesTableView ? self.places : [SmileyFavoritesManager getFavoritesList];
    
    SmileyReportPlaceTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  //  SmileyReport* temp = ((SmileyReportPlace*)[self.places objectAtIndex:indexPath.row]).report;
    
    cell.title.text       = [places[indexPath.row] title];
    cell.subtitle.text    = [places[indexPath.row] subtitle];
    cell.inspections      = [places[indexPath.row] inspections];
    cell.thumbnail.image  = [places[indexPath.row] thumbnail];
    [cell.inspectionsCollectionView reloadData];
    //add custom accessory view
    if(tableView == self.placesTableView){
        UIButton *addToFavoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addToFavoritesButton.frame = CGRectMake(0, 0, 44, 44);
        UIImageView *favImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites.png"]];
        [favImage setAlpha:0.1];
        [addToFavoritesButton addSubview:favImage];
        [addToFavoritesButton addTarget:self
                             action:@selector(addPlaceToFavoritesButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addToFavoritesButton;
    }
    
    return cell;
}

- (IBAction) addPlaceToFavoritesButtonTapped:(id) sender
{
    UITableViewCell* cell = (UITableViewCell*)((UIButton*)sender).superview;
    int i = [self.placesTableView indexPathForCell:cell].row;
    [SmileyFavoritesManager addPlaceToFavoritesList:self.places[i]];
    self.cuteFlyingStar.center = [cell convertPoint:cell.accessoryView.center toView:nil];
    self.cuteFlyingStar.center = CGPointMake(self.cuteFlyingStar.center.x-5,self.cuteFlyingStar.center.y-22); // minor adjustments
    self.cuteFlyingStar.hidden = NO;
    [UIView animateWithDuration:1
                     animations:^{ self.cuteFlyingStar.center = CGPointMake(self.favoritesButton.center.x, self.favoritesButton.center.y-5);}
                     completion:^(BOOL finished) {
                         if(finished){
                             [self makeFlyingStarWhite];
                             [UIView animateWithDuration:0.5 animations:^{self.cuteFlyingStar.alpha = 0.1;}
                                              completion:^(BOOL finished) {
                             if (finished){
                                 self.cuteFlyingStar.hidden = YES;
                                 [self makeFlyingStarBlack];}
                            }];
                         }
                     }];
    //TODO: Should clear old places as you do searches
}
 
- (IBAction)goToCurrentUserLocation:(id)sender {
    [self updateMapViewToLocation:self.mapView.userLocation.location.coordinate];
}
# pragma mark TopBar Methods i.e. for Settings and Favorites Buttons

- (IBAction) favoritesButtonTapped:(UITapGestureRecognizer*) sender
{
   if(self.detailViewFullSizeMode)
       [self minimizeView:self.detailView withCompleteBLock:^(BOOL finished) {if(finished) self.detailViewFullSizeMode = NO;}];
   
    if(self.favoritesView.hidden){
        [self.favoritesTableView reloadData];
        [(UIImageView*)self.favoritesButton.subviews[0] setImage:[UIImage imageNamed:@"favorites_on.png"]];
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                                        [self.detailView setTransform: CGAffineTransformMakeScale(0.95, 0.95)];
                                        self.favoritesView.hidden = !self.favoritesView.hidden;
                                        self.favoritesView.alpha = abs(self.favoritesView.alpha - 1);}
                         completion:^(BOOL finished) {}];
   }
   else{
        [(UIImageView*)self.favoritesButton.subviews[0] setImage:[UIImage imageNamed:@"favorites.png"]];
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{[self.detailView setTransform: CGAffineTransformIdentity];
                                       self.favoritesView.alpha = abs(self.favoritesView.alpha - 1);
                                      [self minimizeView:self.favoritesView withCompleteBLock:^(BOOL finished) {if(finished) self.favoritesViewFullSizeMode = NO;}];}
                         completion:^(BOOL finished){
                             self.favoritesView.hidden = !self.favoritesView.hidden;
                         }];
   }
    
}

- (IBAction) settingsButtonTapped:(UITapGestureRecognizer*) sender
{
    self.settingsBarView.hidden = !self.settingsBarView.hidden;
    if(self.settingsBarView.hidden){
        [(UIImageView*)self.settingsButton.subviews[0] setImage:[UIImage imageNamed:@"settings.png"]];
    }else{
        [(UIImageView*)self.settingsButton.subviews[0] setImage:[UIImage imageNamed:@"settings_on.png"]];
    }
    float alert_value = [[self readUserDefaultSettingParameter:@"alertThreshold"] floatValue];
    if(alert_value == 0){
        self.alertSliderSettingsBar.enabled = NO;
        [self.alertSwitchSettingsBar setOn: NO];
        self.alertSliderSettingsBar.value   = 1;
    }
    else{
        self.alertSliderSettingsBar.enabled = YES;
        [self.alertSwitchSettingsBar setOn: YES];
        [self.alertSliderSettingsBar setValue: abs(alert_value-5)];
    }
}

# pragma mark User Settings Related Methods

- (void) prepareUserDefaultSettings
{
    NSNumber* userAlertThreshold = [self readUserDefaultSettingParameter:@"alertThreshold"];
    if(userAlertThreshold == nil){
        RegionMonitor.alertThreshold = @1;
         [self updateUserDefaultSettingParameter:@"alertThreshold" withValue:@1];
    }
    else{
        RegionMonitor.alertThreshold = userAlertThreshold;
    }
}

// There are no discrete step sliders in iOS.
// This is one way to achieve something similar.
- (IBAction)alertSliderChanged:(id)sender
{
    int sliderValue = lroundf(self.alertSliderSettingsBar.value);
    [self.alertSliderSettingsBar setValue:sliderValue animated:YES];
    [RegionMonitor setAlertThreshold:@(abs(sliderValue - 5))];//revers order
    [self updateUserDefaultSettingParameter:@"alertThreshold" withValue:@(abs(sliderValue-5))];
    [RegionMonitor clear];
    [RegionMonitor addAlertRegionForPlaces:self.places];
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch* alerts = (UISwitch*) sender;
    if(!alerts.isOn){
        [RegionMonitor clear];
        [RegionMonitor setAlertThreshold:@0]; //default for not enabled state
        [self updateUserDefaultSettingParameter:@"alertThreshold" withValue:@0];
        self.alertSliderSettingsBar.enabled = NO;
        [self.alertSliderSettingsBar setValue:1]; // 1 slider - 4 smiley
    }
    else{
        [RegionMonitor setAlertThreshold:@4]; //default for enabled state
        [RegionMonitor addAlertRegionForPlaces:self.places]; //redo a nearby search?
        [self updateUserDefaultSettingParameter:@"alertThreshold" withValue:@4];
        self.alertSliderSettingsBar.enabled = YES;
        [self.alertSliderSettingsBar setValue:1];
    }
}

//TODO Move things to an utils lib...
#pragma mark Various Utils

- (void) updateUserDefaultSettingParameter:(NSString*)param withValue:(NSNumber*) value
{
    NSMutableDictionary *mutableSettings = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY] mutableCopy];
    if (!mutableSettings)
        mutableSettings = [[NSMutableDictionary alloc] init];
    mutableSettings[param] = value;
    [[NSUserDefaults standardUserDefaults] setObject:mutableSettings forKey:SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) readUserDefaultSettingParameter:(NSString*)param
{
    NSDictionary *settings = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY] mutableCopy];
    if (!settings)
        return nil;
    return settings[param];
}

+ (void) addDropShadowToView:(UIView*) view withOffset:(CGSize) offset radius:(double)radius andAlpha:(double) alpha
{
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = alpha;
    
}

@end
