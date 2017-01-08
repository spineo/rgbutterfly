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
#import "BarButtonUtils.h"

@interface InitViewController ()

// NSUserDefaults
//
@property (nonatomic, strong) UITextView *initialTextView;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) int updateStat;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation InitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [super viewDidAppear:TRUE];
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"butterfly-background.png"]]];
    
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
            //UIAlertController *alert = [AlertUtils createOkAlert:@"No Network Connectivity Detected" message:@"This is needed for the database version check. Please verify your device settings"];
            //[self presentViewController:alert animated:YES completion:nil];
            [_initialTextView setText:@"No Network Connectivity Detected. This is needed for the database version check. Please verify your device settings"];
            
        } else {
            BOOL dbForceUpdate          = [_userDefaults boolForKey:DB_FORCE_UPDATE_KEY];
            BOOL existsDbForceUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_FORCE_UPDATE_KEY];
            
            //int updateStat = 0;
            NSString *updateMsg = @"A New Database Version was Detected";
            if (dbForceUpdate == TRUE || !existsDbForceUpdateKey) {
                _updateStat = 2;
                updateMsg = @"A Force Update was Selected or new Deployment Detected";
                
                // Reset force update back to FALSE
                //
                [_userDefaults setBool:FALSE forKey:DB_FORCE_UPDATE_KEY];
                [_userDefaults synchronize];
                
            } else {
                _updateStat = [GenericUtils checkForDBUpdate];
            }
            
            // New version detected
            //
            if (_updateStat == 2) {
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
            } else if (_updateStat == 1) {
                UIAlertController *alert = [AlertUtils createOkAlert:@"Update Status" message:@"Failed Check for Updates"];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    
    if (_updateStat == 0) {
        [self continue];
        
    } else {
        CGFloat buttonXOffset = (self.view.bounds.size.width / 2.0) - (DEF_LG_BUTTON_WIDTH / 2.0);
        CGFloat buttonYOffset = (self.view.bounds.size.height / 2.0) - (DEF_LG_BUTTON_HEIGHT / 2.0);
        CGRect colorButtonFrame = CGRectMake(buttonXOffset, buttonYOffset, DEF_LG_BUTTON_WIDTH, DEF_LG_BUTTON_HEIGHT);
        
        _continueButton = [BarButtonUtils create3DButton:@"Continue" tag:CONTINUE_BUTTON_TAG frame:colorButtonFrame];
        [_continueButton.titleLabel setFont:VLG_TEXT_FIELD_FONT];
        [_continueButton setTintColor:DARK_TEXT_COLOR];
        [_continueButton setBackgroundColor:WIDGET_GREEN_COLOR];
        [_continueButton addTarget:self action:@selector(continue) forControlEvents:UIControlEventTouchUpInside];
        
        _initialTextView = [[UITextView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, self.view.bounds.size.width, buttonYOffset)];
        
        [_initialTextView setText:@""];
        [_initialTextView setFont:VLG_TEXT_FIELD_FONT];
        [_initialTextView setTextColor:LIGHT_TEXT_COLOR];
        [_initialTextView setBackgroundColor:DARK_BG_COLOR];
        [_initialTextView setScrollEnabled:FALSE];
        [_initialTextView setEditable:FALSE];
        [_initialTextView setContentOffset:CGPointMake(DEF_X_OFFSET, DEF_FIELD_PADDING) animated:YES];
        
        [self.view addSubview:_continueButton];
        [self.view addSubview:_initialTextView];
    }
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
