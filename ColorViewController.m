//
//  ColorViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 6/6/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import "ColorViewController.h"
#import "AppColorUtils.h"

@interface ColorViewController ()

@end

@implementation ColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[_paintSwatch name]];
    [self.view setBackgroundColor:[AppColorUtils colorFromSwatch:_paintSwatch]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (IBAction)goBack:(id)sender {
        [self dismissViewControllerAnimated:TRUE completion:nil];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
