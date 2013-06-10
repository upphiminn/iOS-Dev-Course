//
//  PDFInspectionDocumentViewController.m
//  SmileyReport
//
//  Created by Corneliu on 6/9/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "PDFInspectionDocumentViewController.h"
#import "SmileyReportPlace.h"
#import "NetworkActivityIndicator.h"
#import <MapKit/MapKit.h>

@interface PDFInspectionDocumentViewController ()
@property (weak, nonatomic) IBOutlet UIWebView* webView;
@property (strong, nonatomic)        NSURL*     documentURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation PDFInspectionDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) setURL:(NSString *)documentURLString
{
    self.documentURL = [[NSURL alloc] initWithString:documentURLString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"searchBarBGImage.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.documentURL];
    
    //[[UIBarButtonItem appearance] setTintColor:[UIColor redColor]];
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.delegate = self;
}

-(void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [NetworkActivityIndicator push];
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.webView.scrollView setContentOffset:CGPointZero];
    [self.webView.scrollView setContentScaleFactor:10];
    [NetworkActivityIndicator pop];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
