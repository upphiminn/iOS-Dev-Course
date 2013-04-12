//
//  PhotoViewController.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()<UIScrollViewDelegate>

@property (weak,    nonatomic)  IBOutlet UIScrollView       *scrollView;
@property (strong,  nonatomic)  UIImageView                 *photoView;
@property (weak,    nonatomic)  IBOutlet UIBarButtonItem    *titleBarButtonItem;
@property (strong,  nonatomic)  UIPopoverController         *urlPopover;

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
- (void) setAppropriateZoomScale
{
    CGFloat widthZoomScale  = self.scrollView.bounds.size.width / self.photoView.image.size.width;
    CGFloat heightZoomScale = self.scrollView.bounds.size.height / self.photoView.image.size.height;
    self.scrollView.minimumZoomScale = (widthZoomScale > heightZoomScale)? widthZoomScale:heightZoomScale;
    [self.scrollView zoomToRect:self.photoView.bounds animated:NO];

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
    [self resetPhoto];
    self.titleBarButtonItem.title = self.title;
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)resetPhoto
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.photoView.image = nil;
        
        NSData  *photoData  = [[NSData alloc] initWithContentsOfURL:self.photoURL];
        UIImage *photo      = [[UIImage alloc] initWithData:photoData];
        // flickr can return NULL (NSObject)
        if (photo) {
            [self setAppropriateZoomScale];
            self.scrollView.contentSize = photo.size;
            self.photoView.image = photo;
            self.photoView.frame = CGRectMake(0, 0, photo.size.width, photo.size.height);
     

        }
    }
}



@end
