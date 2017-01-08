//
//  InitViewController.m
//  PaintPicker
//
//  Created by Stuart Pineo on 1/8/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import "InitViewController.h"
#import "GlobalSettings.h"
#import "AlertUtils.h"
#import "HTTPUtils.h"
#import "GenericUtils.h"

@interface InitViewController ()

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL appIntroAlert, mixAssocUnfilter;
@property (nonatomic) int minAssocSize;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation InitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:TRUE];
    
    // Initialization
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
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
            UIAlertController *alert = [AlertUtils createOkAlert:@"No Network Connectivity Detected" message:@"This is needed for the database version check. Please verify your device settings"];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            BOOL dbForceUpdate          = [_userDefaults boolForKey:DB_FORCE_UPDATE_KEY];
            BOOL existsDbForceUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_FORCE_UPDATE_KEY];
            
            int updateStat = 0;
            NSString *updateMsg = @"A New Database Version was Detected";
            if (dbForceUpdate == TRUE || !existsDbForceUpdateKey) {
                updateStat = 2;
                updateMsg = @"A Force Update was Selected or new Deployment Detected";
                
                // Reset force update back to FALSE
                //
                [_userDefaults setBool:FALSE forKey:DB_FORCE_UPDATE_KEY];
                [_userDefaults synchronize];
                
            } else {
                updateStat = [GenericUtils checkForDBUpdate];
            }
            
            // New version detected
            //
            if (updateStat == 2) {
                UIAlertController *updateConfirm = [AlertUtils createBlankAlert:updateMsg message:@"Continue with the Database Update?"];
                
                UIAlertAction* YesButton = [UIAlertAction
                                            actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //[self startSpinner];
                                                NSString *errStr = [GenericUtils upgradeDB];
                                                
                                                //[self stopSpinner];
                                                
                                                
                                                UIAlertController *alert = [AlertUtils createOkAlert:@"Update Status" message:errStr];
                                                [self presentViewController:alert animated:YES completion:nil];

                                            }];
                
                UIAlertAction* NoButton = [UIAlertAction
                                           actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                           handler:nil];
                
                [updateConfirm addAction:NoButton];
                [updateConfirm addAction:YesButton];
                
                [self presentViewController:updateConfirm animated:YES completion:nil];

                
                // Failed update preparation
                //
            } else if (updateStat == 1) {
                UIAlertController *alert = [AlertUtils createOkAlert:@"Update Status" message:@"Failed Check for Updates"];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

- (IBAction)goViewController:(id)sender {
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
