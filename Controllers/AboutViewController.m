//
//  AboutViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 10/31/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "AboutViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextView *aboutTextView = [[UITextView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [aboutTextView setText:ABOUT_TEXT];
    [aboutTextView setFont:LG_TEXT_FIELD_FONT];
    [aboutTextView setTextColor:LIGHT_TEXT_COLOR];
    [aboutTextView setBackgroundColor:DARK_BG_COLOR];
    [aboutTextView setScrollEnabled:TRUE];
    [aboutTextView setEditable:FALSE];
    [aboutTextView setContentOffset:CGPointMake(DEF_X_OFFSET, DEF_FIELD_PADDING) animated:YES];
    
    UILabel *openSafariLabel = [FieldUtils createLabel:@"Open Web Docs in Safari" xOffset:DEF_X_OFFSET yOffset:DEF_Y_OFFSET];
    
    [self.view addSubview:aboutTextView];
    [self.view addSubview:openSafariLabel];
}

- (IBAction)openSafari:(id)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:DOCS_SITE];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:url options:@{}
           completionHandler:^(BOOL success) {
               NSLog(@"Open %@: %d",DOCS_SITE,success);
           }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

 /*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
