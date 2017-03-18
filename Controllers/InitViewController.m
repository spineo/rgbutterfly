//
//  InitViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 1/8/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import "InitViewController.h"
#import "GlobalSettings.h"
#import "AlertUtils.h"
#import "HTTPUtils.h"
#import "AppUtils.h"
#import "BarButtonUtils.h"
#import "ColorUtils.h"

@interface InitViewController ()

// NSUserDefaults
//

@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation InitViewController

- (void)startSpinner {
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setTag:INIT_SPINNER_TAG];
    
    [_spinner setCenter:self.view.center];
    [_spinner setHidesWhenStopped:YES];
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
}

- (void)stopSpinner {
    [_spinner stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image
    //
    [ColorUtils setBackgroundImage:BACKGROUND_IMAGE_TITLE view:self.view];
    
    // Initialization
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Look at what is currently in Settings
    //
    BOOL pollUpdate          = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
    BOOL existsPollUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY];
    
    if ((pollUpdate == FALSE) && existsPollUpdateKey) {
        [self continue];
    }
    
    _updateStat = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:TRUE];
    
    CGFloat labelYOffset = (self.view.bounds.size.height / 2.0) - (DEF_LABEL_HEIGHT / 2.0);
    _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, labelYOffset, self.view.bounds.size.width, DEF_LABEL_HEIGHT)];
    
    [_updateLabel setText:@""];
    [_updateLabel setFont:VLG_TEXT_FIELD_FONT];
    [_updateLabel setTextColor:LIGHT_TEXT_COLOR];
    [_updateLabel setBackgroundColor:CLEAR_COLOR];
    [_updateLabel setTextAlignment:NSTextAlignmentCenter];
    [_updateLabel setTag:INIT_LABEL_TAG];
    
    [self.view addSubview:_updateLabel];
    
    [self startSpinner];
    
    // Look at what is currently in Settings
    //
    BOOL pollUpdate          = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
    BOOL existsPollUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY];
    
    // Update the database?
    //
    if (pollUpdate == TRUE || !existsPollUpdateKey) {
        
        // Check if there is a network connection
        //
        if ([HTTPUtils networkIsReachable] == FALSE) {
            UIAlertController *alert = [AlertUtils createBlankAlert:@"No Network Connectivity Detected" message:@"This is needed for the database version check. Please verify your device settings"];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [_updateLabel setText:SPINNER_LABEL_LOAD];
                                     
                                     [self continue];
                                 }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            BOOL dbForceUpdate          = [_userDefaults boolForKey:DB_FORCE_UPDATE_KEY];
            BOOL existsDbForceUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_FORCE_UPDATE_KEY];
    
            NSString *updateMsg = @"A New Database Version was Detected";
            if (dbForceUpdate == TRUE || !existsDbForceUpdateKey) {
                _updateStat = 2;
                updateMsg = @"A Force Update was Selected or new Deployment Detected";
                
                // Reset force update back to FALSE
                //
                [_userDefaults setBool:FALSE forKey:DB_FORCE_UPDATE_KEY];
                [_userDefaults synchronize];
                
            } else {
                _updateStat = [AppUtils checkForDBUpdate];
            }
            
            // New version detected
            //
            if (_updateStat == 2) {
                UIAlertController *updateConfirm = [AlertUtils createBlankAlert:updateMsg message:@"Continue with the Database Update?"];
                UIAlertAction* YesButton = [UIAlertAction
                                            actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                NSString *errStr = [AppUtils updateDB];
                            
                                                UIAlertController *alert = [AlertUtils createBlankAlert:@"Update Status" message:errStr];
                                                UIAlertAction* ok = [UIAlertAction
                                                                           actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {
                                                                               [_updateLabel setText:SPINNER_LABEL_LOAD];
                                                                               [self continue];
                                                                           }];
                                                [alert addAction:ok];
                                                
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }];
                
                UIAlertAction* NoButton = [UIAlertAction
                                           actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [_updateLabel setText:SPINNER_LABEL_LOAD];
                                               [self continue];
                                           }];
                
                [updateConfirm addAction:NoButton];
                [updateConfirm addAction:YesButton];
                
                [self presentViewController:updateConfirm animated:YES completion:^{
                    [_updateLabel setText:SPINNER_LABEL_PROC];
                }];

                
            // Failed update preparation
            //
            } else if (_updateStat == 1) {
                UIAlertController *alert = [AlertUtils createBlankAlert:@"Update Status" message:@"Failed Check for Updates"];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [_updateLabel setText:SPINNER_LABEL_LOAD];
                                         [self continue];
                                     }];
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    
    if (_updateStat == 0) {
        [_updateLabel setText:SPINNER_LABEL_LOAD];
        [self continue];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSpinner];
}

- (void)continue {
    [self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
    //UINavigationController *navigationViewController = [segue destinationViewController];
    //ViewController *viewController = (ViewController *)([navigationViewController viewControllers][0]);
}
 */


@end
