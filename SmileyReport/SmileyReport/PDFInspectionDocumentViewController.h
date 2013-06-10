//
//  PDFInspectionDocumentViewController.h
//  SmileyReport
//
//  Created by Corneliu on 6/9/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFInspectionDocumentViewController : UIViewController<UIWebViewDelegate, UIScrollViewDelegate>

- (void) setURL:(NSString *)documentURL;

@end
