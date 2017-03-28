//
//  WebViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 3/28/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
