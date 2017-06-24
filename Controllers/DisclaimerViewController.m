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
#import "ColorUtils.h"

@interface DisclaimerViewController ()

@property (strong, nonatomic) UITextView *disclaimerTextView;
@property (strong, nonatomic) NSMutableAttributedString *disclaimerText;

@end

@implementation DisclaimerViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image
    //
    [ColorUtils setBackgroundImage:BG_IMAGE_NB_PORTRAIT view:self.view];

    _disclaimerTextView = [[UITextView alloc] initWithFrame:CGRectMake(DEF_MD_FIELD_PADDING, DEF_Y_OFFSET, self.view.bounds.size.width - DEF_MD_FIELD_PADDING, self.view.bounds.size.height)];
    
    _disclaimerText = [[NSMutableAttributedString alloc] initWithString:DISCLAIMER_TEXT];
    int disclaimerTextLen = (int)_disclaimerText.length;
    
    [_disclaimerText addAttribute:NSFontAttributeName value:DEF_LG_VIEW_FONT range:NSMakeRange(0, disclaimerTextLen)];
    [_disclaimerText addAttribute:NSForegroundColorAttributeName value:LIGHT_TEXT_COLOR range:NSMakeRange(0, disclaimerTextLen)];
    
    // Link
    //
    NSRange urlMatch = [StringObjectUtils matchString:DISCLAIMER_TEXT toRegex:DOCS_SITE_PAT];
    [_disclaimerText addAttribute:NSLinkAttributeName value:DOCS_SITE_URL range:urlMatch];
    [_disclaimerText addAttribute:NSFontAttributeName value:DEF_LG_IVIEW_FONT range:urlMatch];
    
    [_disclaimerTextView setAttributedText:_disclaimerText];
    [_disclaimerTextView setBackgroundColor:CLEAR_COLOR];
    [_disclaimerTextView setScrollEnabled:TRUE];
    [_disclaimerTextView setEditable:FALSE];
    [_disclaimerTextView setContentOffset:CGPointMake(DEF_X_OFFSET, DEF_FIELD_PADDING) animated:YES];
    
    [self.view addSubview:_disclaimerTextView];
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
