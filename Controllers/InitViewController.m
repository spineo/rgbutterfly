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
#import "PickerViewController.h"
#import "MainViewController.h"

@interface InitViewController ()

@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL dbRestoreFlag, photoContext, mainViewHasLoaded;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// Buttons
//
@property (nonatomic, strong) UIButton *matchButton, *exploreButton, *takePhotoButton, *myPhotosButton, *topicsButton, *collectButton, *listButton, *matchedButton, *groupsButton, *aboutButton, *settingsButton;
@property (nonatomic, strong) UILabel *matchLabel, *exploreLabel, *takePhotoLabel, *myPhotosLabel, *topicsLabel, *collectLabel, *listLabel, *matchedLabel, *groupsLabel;
@property (nonatomic) CGFloat viewWidth, viewHeight, xCenter, ythird, xOffset, yOffset, exploreYOffset, width, height, labelWidth, labelXOffset, buttonWidth, buttonHeight;

// Collection types
//
@property (nonatomic, strong) NSString *collectionType;

// Re-initialize the buttons
//
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

// Orientation
//
@property (nonatomic) BOOL isLandscape;

@end

@implementation InitViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Intialization/Cleanup Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the default font
    //
    [self setFontFamily:@"Baskerville-Italic" forView:self.view andSubViews:YES];

    
    // Match Colors
    //
    _matchButton      = (UIButton *)[self.view viewWithTag:SUGGEST_BTN_TAG];
    _matchLabel       = (UILabel *)[self.view viewWithTag:MATCH_LABEL_TAG];
    _takePhotoButton  = (UIButton *)[self.view viewWithTag:TAKE_PHOTO_BTN_TAG];
    _takePhotoLabel   = (UILabel *)[self.view viewWithTag:TAKE_LABEL_TAG];
    _myPhotosButton   = (UIButton *)[self.view viewWithTag:MY_PHOTOS_BTN_TAG];
    _myPhotosLabel    = (UILabel *)[self.view viewWithTag:VISIT_LABEL_TAG];
    
    // Explore Colors
    //
    _exploreButton    = (UIButton *)[self.view viewWithTag:EXPLORE_BTN_TAG];
    _exploreLabel     = (UILabel *)[self.view viewWithTag:EXPLORE_LABEL_TAG];
    _topicsButton     = (UIButton *)[self.view viewWithTag:TOPICS_BTN_TAG];
    _topicsLabel      = (UILabel *)[self.view viewWithTag:TOPICS_LABEL_TAG];
    _collectButton    = (UIButton *)[self.view viewWithTag:COLLECT_BTN_TAG];
    _collectLabel     = (UILabel *)[self.view viewWithTag:COLLECT_LABEL_TAG];
    _listButton       = (UIButton *)[self.view viewWithTag:LIST_BTN_TAG];
    _listLabel        = (UILabel *)[self.view viewWithTag:LIST_LABEL_TAG];
    _matchedButton    = (UIButton *)[self.view viewWithTag:MATCHED_BTN_TAG];
    _matchedLabel     = (UILabel *)[self.view viewWithTag:MATCHED_LABEL_TAG];
    _groupsButton     = (UIButton *)[self.view viewWithTag:GROUPS_BTN_TAG];
    _groupsLabel      = (UILabel *)[self.view viewWithTag:GROUPS_LABEL_TAG];
    
    // About/Settings
    //
    _aboutButton     = (UIButton *)[self.view viewWithTag:ABOUT_BTN_TAG];
    _settingsButton  = (UIButton *)[self.view viewWithTag:SETTINGS2_BTN_TAG];
    

    
    // Initialization
    //
    _userDefaults   = [NSUserDefaults standardUserDefaults];

    
    // Check for DB restore
    //
    _dbRestoreFlag           = [_userDefaults boolForKey:DB_RESTORE_KEY];
    
    
    self.view.autoresizesSubviews = NO;
    
    // Re-initialize the buttons
    //
    _tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(respondToTap)];
    [_tapRecognizer setNumberOfTapsRequired:DEF_NUM_TAPS];
    [self.view addGestureRecognizer:_tapRecognizer];
    
    
    // Look at what is currently in Settings
    //
    BOOL pollUpdate          = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
    BOOL existsPollUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY];
    
    if ((pollUpdate == FALSE) && existsPollUpdateKey && (_dbRestoreFlag == FALSE)) {
        [self continue];
    }
    
    _updateStat = NO_UPDATE;
    
    _photoContext      = FALSE;
    _mainViewHasLoaded = FALSE;
}

- (void)viewWillLayoutSubviews {
    [self setOrientationLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:TRUE];
    
    
    // Remove subviews
    //
    [_updateLabel removeFromSuperview];
    

    // Match Colors
    //
    if (_photoContext == FALSE) {
        [self initMatchColors];
    }
    
    // Explore Colors
    //
    if (_mainViewHasLoaded == FALSE) {
        [self initExploreColors];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:TRUE];
    
    // Remove subviews
    //
    //[_updateLabel removeFromSuperview];
    
    CGFloat labelYOffset = (self.view.bounds.size.height / DEF_Y_OFFSET_DIVIDER) - (DEF_LABEL_HEIGHT / DEF_Y_OFFSET_DIVIDER);
    _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, labelYOffset, self.view.bounds.size.width, DEF_LABEL_HEIGHT)];
    
    [_updateLabel setText:@""];
    [_updateLabel setFont:VLG_TEXT_FIELD_FONT];
    [_updateLabel setTextColor:DEF_TEXT_COLOR];
    [_updateLabel setBackgroundColor:CLEAR_COLOR];
    [_updateLabel setTextAlignment:NSTextAlignmentCenter];
    [_updateLabel setTag:INIT_LABEL_TAG];
    
    //[self.view addSubview:_updateLabel];
    //[self startSpinner];
    
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
        _dbRestoreFlag = FALSE;
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == 1) {
            _isLandscape = FALSE;
        } else {
            _isLandscape = TRUE;
        }
        [self setOrientationLayout];
        
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)setOrientationLayout {
    
    // Compute the view width
    //
    _viewWidth  = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _width  = DEF_BUTTON_WIDTH;
    _height = DEF_BUTTON_WIDTH;
    _xCenter = _viewWidth / DEF_X_OFFSET_DIVIDER;
    
    CGFloat aboutButtonXOffset, aboutButtonYOffset, settingsButtonXOffset, settingsButtonYOffset, exploreButtonsYOffset, collectButtonXOffset, collectButtonYOffset, groupsButtonXOffset, groupsButtonYOffset;
    
    NSString *backgroundImage;
    
    // Set the background image
    //
    if (_isLandscape == TRUE) {
        backgroundImage       = BG_IMAGE_LANDSCAPE;
        
        aboutButtonXOffset    = _viewWidth  * 0.88;
        aboutButtonYOffset    = _viewHeight * 0.10;
        
        settingsButtonXOffset = _viewWidth  * 0.87;
        settingsButtonYOffset = _viewHeight * 0.81;
        
        exploreButtonsYOffset = _viewHeight * 0.50;
        
        collectButtonYOffset  = exploreButtonsYOffset;
        collectButtonXOffset  = _xCenter - (_width * 3.5);
        
        groupsButtonYOffset   = exploreButtonsYOffset;
        groupsButtonXOffset   = _xCenter + (_width * 2.5);

        
    } else {
        backgroundImage       = BG_IMAGE_PORTRAIT;
        
        aboutButtonXOffset    = _viewWidth  * 0.83;
        aboutButtonYOffset    = _viewHeight * 0.08;
        
        settingsButtonXOffset = _viewWidth  * 0.81;
        settingsButtonYOffset = _viewHeight * 0.86;
        
        exploreButtonsYOffset = _viewHeight * 0.45;
        
        collectButtonYOffset  = _viewHeight * 0.67;
        collectButtonXOffset  = _xCenter - (_width * 1.5);
        
        groupsButtonXOffset   = _xCenter + (_width * 0.33);
        groupsButtonYOffset   = _viewHeight * 0.67;
    }
    
    // Background Image
    //
    [ColorUtils setBackgroundImage:backgroundImage view:self.view];
    
    // About button
    //
    _buttonWidth  = _aboutButton.bounds.size.width;
    _buttonHeight = _aboutButton.bounds.size.height;
    [_aboutButton setFrame:CGRectMake(aboutButtonXOffset, aboutButtonYOffset, _buttonWidth, _buttonHeight)];
    
    // Match Colors
    //
    _yOffset = _viewHeight * 0.15;
    [_matchButton sizeToFit];
    _buttonWidth  = _matchButton.bounds.size.width;
    _buttonHeight = _matchButton.bounds.size.height;
    _xOffset     = _xCenter - (_buttonWidth / 2.0);
    [_matchButton setFrame:CGRectMake(_xOffset, _yOffset, _buttonWidth, _buttonHeight)];
    _matchLabel = [self resetLabel:_matchLabel xOffset:_xOffset yOffset:_yOffset+_buttonHeight width:_buttonWidth];
    
    _xOffset = _xCenter - (_width * 1.33);
    [_takePhotoButton setFrame:CGRectMake(_xOffset, _yOffset, _width, _height)];
    _takePhotoLabel = [self resetLabel:_takePhotoLabel xOffset:_xOffset yOffset:_yOffset+_height width:_width];
    
    _xOffset = _xCenter + (_width * 0.33);
    [_myPhotosButton setFrame:CGRectMake(_xOffset, _yOffset, _width, _height)];
    _myPhotosLabel = [self resetLabel:_myPhotosLabel xOffset:_xOffset yOffset:_yOffset+_height width:_width];
    
    
    // Explore Colors
    //
    _exploreYOffset = _viewHeight * 0.55;
    [_exploreButton sizeToFit];
    _buttonWidth  = _exploreButton.bounds.size.width;
    _buttonHeight = _exploreButton.bounds.size.height;
    _xOffset     = _xCenter - (_buttonWidth / 2.0);
    [_exploreButton setFrame:CGRectMake(_xOffset, _exploreYOffset, _buttonWidth, _buttonHeight)];
    _exploreLabel = [self resetLabel:_exploreLabel xOffset:_xOffset yOffset:_exploreYOffset+_buttonHeight width:_buttonWidth];
    
    _xOffset = _xCenter - (_width * 2.0);
    [_topicsButton setFrame:CGRectMake(_xOffset, exploreButtonsYOffset, _width, _height)];
    _topicsLabel = [self resetLabel:_topicsLabel xOffset:_xOffset yOffset:exploreButtonsYOffset+_height width:_width];
    
    _xOffset = _xCenter - (_width * 0.5);
    [_matchedButton setFrame:CGRectMake(_xOffset, exploreButtonsYOffset, _width, _height)];
    _matchedLabel = [self resetLabel:_matchedLabel xOffset:_xOffset yOffset:exploreButtonsYOffset+_height width:_width];
    
    _xOffset = _xCenter + _width;
    [_listButton setFrame:CGRectMake(_xOffset, exploreButtonsYOffset, _width, _height)];
    _listLabel = [self resetLabel:_listLabel xOffset:_xOffset yOffset:exploreButtonsYOffset+_height width:_width];
    
    // Bottom buttons
    //
    [_collectButton setFrame:CGRectMake(collectButtonXOffset, collectButtonYOffset, _width, _height)];
    _collectLabel = [self resetLabel:_collectLabel xOffset:collectButtonXOffset yOffset:collectButtonYOffset+_height width:_width];
    
    [_groupsButton setFrame:CGRectMake(groupsButtonXOffset, groupsButtonYOffset, _width, _height)];
    _groupsLabel = [self resetLabel:_groupsLabel xOffset:groupsButtonXOffset yOffset:groupsButtonYOffset+_height width:_width];
    
    // Settings button
    //
    _buttonWidth  = _settingsButton.bounds.size.width;
    _buttonHeight = _settingsButton.bounds.size.height;
    [_settingsButton setFrame:CGRectMake(settingsButtonXOffset, settingsButtonYOffset, _buttonWidth, _buttonHeight)];
    
    self.view.hidden = NO;
}

- (void)startSpinner {
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setTag:INIT_SPINNER_TAG];
        
    [_spinner setHidesWhenStopped:YES];
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
}

- (void)stopSpinner {
    [_spinner stopAnimating];
}

- (void)respondToTap {
    // Match Colors
    //
    [self initMatchColors];

    // Explore Colors
    //
    [self initExploreColors];
}

- (void)initMatchColors {
    // Change  buttons visibility
    //
    [_matchButton setAlpha:1.0];
    [_matchLabel setAlpha:1.0];
    [_takePhotoButton setAlpha:0.0];
    [_takePhotoLabel setAlpha:0.0];
    [_myPhotosButton setAlpha:0.0];
    [_myPhotosLabel setAlpha:0.0];
}

- (void)initExploreColors {
    // Change buttons visibility
    //
    [_exploreButton setAlpha:1.0];
    [_exploreLabel setAlpha:1.0];
    [_topicsButton setAlpha:0.0];
    [_topicsLabel setAlpha:0.0];
    [_collectButton setAlpha:0.0];
    [_collectLabel setAlpha:0.0];
    [_listButton setAlpha:0.0];
    [_listLabel setAlpha:0.0];
    [_matchedButton setAlpha:0.0];
    [_matchedLabel setAlpha:0.0];
    [_groupsButton setAlpha:0.0];
    [_groupsLabel setAlpha:0.0];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Label/Button Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Label/Button Methods

- (UILabel *)resetLabel:(UILabel *)label xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset width:(CGFloat)width {
    [label sizeToFit];
    CGFloat labelWidth   = label.bounds.size.width;
    CGFloat labelXOffset = xOffset + (width - labelWidth) / 2.0;
    
    [label setFrame:CGRectMake(labelXOffset, yOffset + DEF_FIELD_PADDING, label.bounds.size.width, label.bounds.size.height)];
    
    return label;
}

- (IBAction)matchColors:(id)sender {
    [_matchButton setAlpha:0.0];
    [_matchLabel setAlpha:0.0];
    [_takePhotoButton setAlpha:1.0];
    [_takePhotoLabel setAlpha:1.0];
    [_myPhotosButton setAlpha:1.0];
    [_myPhotosLabel setAlpha:1.0];

    [self initExploreColors];
}

- (IBAction)takePhoto:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:[AlertUtils createOkAlert:@"Error" message:@"Device has no camera"] animated:YES completion:nil];
        
    } else {
        [self setImageAction:TAKE_PHOTO_ACTION];
        
        NSLog(@"Image picker segue");
        [self performSegueWithIdentifier:@"InitToImagePickerSegue" sender:self];
    }
}

- (IBAction)myPhotos:(id)sender {
    [self setImageAction:SELECT_PHOTO_ACTION];
    [self performSegueWithIdentifier:@"InitToImagePickerSegue" sender:self];
}

- (IBAction)exploreColors:(id)sender {
    [_exploreButton setAlpha:0.0];
    [_exploreLabel setAlpha:0.0];
    [_topicsButton setAlpha:1.0];
    [_topicsLabel setAlpha:1.0];
    [_collectButton setAlpha:1.0];
    [_collectLabel setAlpha:1.0];
    [_listButton setAlpha:1.0];
    [_listLabel setAlpha:1.0];
    [_matchedButton setAlpha:1.0];
    [_matchedLabel setAlpha:1.0];
    [_groupsButton setAlpha:1.0];
    [_groupsLabel setAlpha:1.0];
    
    [self initMatchColors];
}

- (IBAction)exploreTopics:(id)sender {
    [self performSegue:KEYWORDS_TYPE];
    [_spinner setCenter:_topicsButton.center];
}

- (IBAction)exploreCollections:(id)sender {
    [self performSegue:MIX_LIST_TYPE];
    [_spinner setCenter:_collectButton.center];
}

- (IBAction)exploreLists:(id)sender {
    [self performSegue:FULL_LISTING_TYPE];
    [_spinner setCenter:_listButton.center];
}

- (IBAction)myMatchedColors:(id)sender {
    [self performSegue:MATCH_LIST_TYPE];
    [_spinner setCenter:_matchedButton.center];
}

- (IBAction)groupByColors:(id)sender {
    [self performSegue:COLORS_TYPE];
    [_spinner setCenter:_groupsButton.center];
}

- (void)performSegue:(NSString *)listType {
    _collectionType = listType;
    [self performSegueWithIdentifier:@"InitToMainSegue" sender:self];
}

- (IBAction)about:(id)sender {
        [self performSegueWithIdentifier:@"InitToAboutSegue" sender:self];
}

- (IBAction)settings:(id)sender {
        [self performSegueWithIdentifier:@"InitToSettingsSegue" sender:self];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Font Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Font Methods
- (void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily size:[[lbl font] pointSize]]];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods

- (IBAction)unwindFromPhotoToInitViewController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindToInitViewController:(UIStoryboardSegue *)segue {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Camera/Photo Library
    //
    if ([[segue identifier] isEqualToString:@"InitToImagePickerSegue"]) {
        PickerViewController *pickerViewController = (PickerViewController *)[segue destinationViewController];
        [pickerViewController setImageAction:_imageAction];
        _photoContext = TRUE;
        
    } else if ([[segue identifier] isEqualToString:@"InitToMainSegue"]) {
        [self.view addSubview:_updateLabel];
        [self startSpinner];
        
        UINavigationController *navigationViewController = [segue destinationViewController];
        MainViewController *mainViewController = (MainViewController *)([navigationViewController viewControllers][0]);
        [mainViewController setListingType:_collectionType];
        _mainViewHasLoaded = TRUE;
    }
}

- (void)continue {
    //[self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}


@end
