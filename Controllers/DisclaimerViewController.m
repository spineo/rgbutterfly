//
//  DisclaimerViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 11/3/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "GlobalSettings.h"
#import "StringObjectUtils.h"

@interface DisclaimerViewController ()

@end

@implementation DisclaimerViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextView *disclaimerTextView = [[UITextView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    NSMutableAttributedString *disclaimerText = [[NSMutableAttributedString alloc] initWithString:DISCLAIMER_TEXT];
    int disclaimerTextLen = (int)disclaimerText.length;
    
    [disclaimerText addAttribute:NSFontAttributeName value:VLG_TEXT_FIELD_FONT range:NSMakeRange(0, disclaimerTextLen)];
    [disclaimerText addAttribute:NSForegroundColorAttributeName value:LIGHT_TEXT_COLOR range:NSMakeRange(0, disclaimerTextLen)];
    
    // Link
    //
    NSRange urlMatch = [StringObjectUtils matchString:DISCLAIMER_TEXT toRegex:DOCS_SITE_PAT];
    [disclaimerText addAttribute:NSLinkAttributeName value:DOCS_SITE_URL range:urlMatch];
    [disclaimerText addAttribute:NSFontAttributeName value:VLARGE_ITALIC_FONT range:urlMatch];
    
    [disclaimerTextView setAttributedText:disclaimerText];
    [disclaimerTextView setBackgroundColor:DARK_BG_COLOR];
    [disclaimerTextView setScrollEnabled:TRUE];
    [disclaimerTextView setEditable:FALSE];
    [disclaimerTextView setContentOffset:CGPointMake(DEF_X_OFFSET, DEF_FIELD_PADDING) animated:YES];
    
    [self.view addSubview:disclaimerTextView];
}

// Share Documentation
//
- (IBAction)share:(id)sender {
     [self presentViewController:_shareController animated:YES completion:nil];
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
