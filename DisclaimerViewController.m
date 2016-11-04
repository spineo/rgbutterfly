//
//  DisclaimerViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 11/3/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "GlobalSettings.h"

@interface DisclaimerViewController ()

@end

@implementation DisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextView *disclaimerTextView = [[UITextView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [disclaimerTextView setText:DISCLAIMER_TEXT];
    [disclaimerTextView setFont:LG_TEXT_FIELD_FONT];
    [disclaimerTextView setTextColor:LIGHT_TEXT_COLOR];
    [disclaimerTextView setBackgroundColor:DARK_BG_COLOR];
    [disclaimerTextView setUserInteractionEnabled:FALSE];
    
    [self.view addSubview:disclaimerTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation

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
