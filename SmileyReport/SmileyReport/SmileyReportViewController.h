//
//  SmileyReportViewController.h
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SmileyReportViewController : UIViewController <MKMapViewDelegate,
                                                          CLLocationManagerDelegate,
                                                          UITableViewDataSource,
                                                          UITableViewDelegate>

@end
