//
//  PhotoViewController.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "PhotoViewController.h"
#import "NetworkActivityIndicator.h"
#import "PhotoCache.h"

@interface PhotoViewController ()<UIScrollViewDelegate>

@property (weak,    nonatomic)  IBOutlet UIScrollView       *scrollView;
@property (strong,  nonatomic)  UIImageView                 *photoView;
@property (weak,    nonatomic)  IBOutlet UIBarButtonItem    *titleBarButtonItem;
@property (strong,  nonatomic)  UIPopoverController         *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong,  nonatomic)  NSString                    *identifier;
@end

@implementation PhotoViewController

- (UIImageView *)photoView
{
    if (!_photoView) _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _photoView;
}

- (void)setPhotoURL:(NSURL *)photoURL
{
    _photoURL = photoURL;
    [self resetPhoto];
}

- (void) setIdentifier:(NSString *)identifier
{
    _identifier = identifier;
}

- (void) setAppropriateZoomScale
{
    CGFloat widthZoomScale  = self.scrollView.bounds.size.width / self.photoView.image.size.width;
    CGFloat heightZoomScale = self.scrollView.bounds.size.height / self.photoView.image.size.height;
    self.scrollView.zoomScale = (widthZoomScale > heightZoomScale)? widthZoomScale:heightZoomScale;

}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setAppropriateZoomScale];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.photoView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.titleBarButtonItem.title = self.title;
    [self resetPhoto];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //self.photoView.image = nil;
}
- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)resetPhoto
{
    if (self.scrollView && self.photoURL) {
        self.scrollView.contentSize = CGSizeZero;
        self.photoView.image = nil;
        NSURL *photoURL = self.photoURL;
        
        dispatch_queue_t image_downloader = dispatch_queue_create("image downloader", NULL);
        dispatch_async(image_downloader, ^{
            [self.spinner startAnimating];
            NSData  *photoData;
            if([PhotoCache isIdentifierInCache:self.identifier]){
                photoData = [PhotoCache retrieveDataForIdentifier:self.identifier];
            }
            else{
                [NetworkActivityIndicator push];
                photoData  = [[NSData alloc] initWithContentsOfURL:self.photoURL];
                [NetworkActivityIndicator pop];
                [PhotoCache storeData:photoData withIdentifier:self.identifier];
            }
            // flickr can return NULL (NSObject)
            if(photoURL == self.photoURL)
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *photo      = [[UIImage alloc] initWithData:photoData];
                    if (photo) {
                                self.scrollView.zoomScale = 1.0;
                                self.scrollView.contentSize = photo.size;
                                self.photoView.image = photo;
                                self.photoView.frame = CGRectMake(0, 0, photo.size.width, photo.size.height);
                                [self setAppropriateZoomScale];
                                
                                }
                    [self.spinner stopAnimating];
                    });
        });
    }
}



@end
