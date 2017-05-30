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
@property (nonatomic) BOOL dbRestoreFlag;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation InitViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Intialization/Cleanup Methods

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
    _userDefaults  = [NSUserDefaults standardUserDefaults];
    
    
    // Look at what is currently in Settings
    //
    BOOL pollUpdate          = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
    _dbRestoreFlag           = [_userDefaults boolForKey:DB_RESTORE_KEY];
    BOOL existsPollUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY];
    
    if ((pollUpdate == FALSE) && existsPollUpdateKey && (_dbRestoreFlag == FALSE)) {
        [self continue];
    }
    
    _updateStat = NO_UPDATE;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:TRUE];
    
    CGFloat labelYOffset = (self.view.bounds.size.height / DEF_Y_OFFSET_DIVIDER) - (DEF_LABEL_HEIGHT / DEF_Y_OFFSET_DIVIDER);
    _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, labelYOffset, self.view.bounds.size.width, DEF_LABEL_HEIGHT)];
    
    [_updateLabel setText:@""];
    [_updateLabel setFont:VLG_TEXT_FIELD_FONT];
    [_updateLabel setTextColor:LIGHT_TEXT_COLOR];
    [_updateLabel setBackgroundColor:CLEAR_COLOR];
    [_updateLabel setTextAlignment:NSTextAlignmentCenter];
    [_updateLabel setTag:INIT_LABEL_TAG];
    
    [self.view addSubview:_updateLabel];
    
    [self startSpinner];
    
    
    // Case 1: Starting with clean slate or reset content & settings, this can be done without user prompt
    //
    if ([_userDefaults objectForKey:DB_RESTORE_KEY] == nil) {
        NSString *errStr = [AppUtils initDBFromBundle:@"Initialization"];
        
        UIAlertController *alert = [AlertUtils createBlankAlert:@"Initialization Status" message:errStr];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [_updateLabel setText:SPINNER_LABEL_LOAD];
                                 [self continue];
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];

    // Case 2: User-triggered restore original database
    //
    } else if (_dbRestoreFlag == TRUE) {

        UIAlertController *updateConfirm = [AlertUtils createBlankAlert:@"Database Restore Alert" message:@"Caution: You will lose any data added if you revert to the original snapshot. Do you wish to continue?"];
        UIAlertAction* YesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        NSString *errStr = [AppUtils initDBFromBundle:@"Restore"];
                                        
                                        UIAlertController *alert = [AlertUtils createBlankAlert:@"Restore Status" message:errStr];
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
        
        // Revert back to FALSE default
        //
        [_userDefaults setBool:FALSE forKey:DB_RESTORE_KEY];

    // Case 3: REST API Updates
    //
    } else {
    
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
                    _updateStat = DO_UPDATE;
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
                if (_updateStat == DO_UPDATE) {
                    UIAlertController *updateConfirm = [AlertUtils createBlankAlert:updateMsg message:@"Continue with the Database Update?"];
                    UIAlertAction* YesButton = [UIAlertAction
                                                actionWithTitle:@"Yes"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    NSString *errStr = [AppUtils updateDBFromRemote];
                                
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
                } else if (_updateStat == FAILED_CHECK) {
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
        
        if (_updateStat == NO_UPDATE) {
            [_updateLabel setText:SPINNER_LABEL_LOAD];
            [self continue];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSpinner];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods

- (void)continue {
    [self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}


@end
