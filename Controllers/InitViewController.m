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
@property (nonatomic) BOOL dbRestoreFlag, mainViewHasLoaded;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// Buttons
//
@property (nonatomic, strong) UIButton *matchButton, *exploreButton, *takePhotoButton, *myPhotosButton, *topicsButton, *collectButton, *listButton;
@property (nonatomic, strong) UILabel *matchLabel, *exploreLabel, *takePhotoLabel, *myPhotosLabel, *topicsLabel, *collectLabel, *listLabel;
@property (nonatomic) CGFloat viewWidth, viewHeight, xCenter, ythird, xOffset, yOffset, width, height, labelWidth, labelXOffset, buttonWidth, buttonHeight;

// Collection types
//
@property (nonatomic, strong) NSString *collectionType;

// Re-initialize the buttons
//
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation InitViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Intialization/Cleanup Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image
    //
    [ColorUtils setBackgroundImage:BACKGROUND_IMAGE view:self.view];
    
    // Match Colors
    //
    _matchButton     = (UIButton *)[self.view viewWithTag:SUGGEST_BTN_TAG];
    _matchLabel      = (UILabel *)[self.view viewWithTag:MATCH_LABEL_TAG];
    _takePhotoButton = (UIButton *)[self.view viewWithTag:TAKE_PHOTO_BTN_TAG];
    _takePhotoLabel  = (UILabel *)[self.view viewWithTag:TAKE_LABEL_TAG];
    _myPhotosButton  = (UIButton *)[self.view viewWithTag:MY_PHOTOS_BTN_TAG];
    _myPhotosLabel   = (UILabel *)[self.view viewWithTag:VISIT_LABEL_TAG];
    
    // Explore Colors
    //
    _exploreButton   = (UIButton *)[self.view viewWithTag:EXPLORE_BTN_TAG];
    _exploreLabel    = (UILabel *)[self.view viewWithTag:EXPLORE_LABEL_TAG];
    _topicsButton    = (UIButton *)[self.view viewWithTag:TOPICS_BTN_TAG];
    _topicsLabel     = (UILabel *)[self.view viewWithTag:TOPICS_LABEL_TAG];
    _collectButton   = (UIButton *)[self.view viewWithTag:COLLECT_BTN_TAG];
    _collectLabel    = (UILabel *)[self.view viewWithTag:COLLECT_LABEL_TAG];
    _listButton      = (UIButton *)[self.view viewWithTag:LIST_BTN_TAG];
    _listLabel       = (UILabel *)[self.view viewWithTag:LIST_LABEL_TAG];

    
    // Initialization
    //
    _userDefaults  = [NSUserDefaults standardUserDefaults];
    
    
    // Look at what is currently in Settings
    //
    BOOL pollUpdate          = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
    BOOL existsPollUpdateKey = [[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY];
    
    if ((pollUpdate == FALSE) && existsPollUpdateKey && (_dbRestoreFlag == FALSE)) {
        [self continue];
    }
    
    _updateStat = NO_UPDATE;
    
    _mainViewHasLoaded = FALSE;
    
    self.view.autoresizesSubviews = NO;
    
    // Re-initialize the buttons
    //
    _tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self.view action:@selector(respondToTap)];
    [_tapRecognizer setNumberOfTapsRequired:DEF_NUM_TAPS];
    //[_tapRecognizer setDelegate:self];
}

- (void)viewDidLayoutSubviews {

    // Compute the view width
    //
    _viewWidth  = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _width  = DEF_BUTTON_WIDTH;
    _height = DEF_BUTTON_WIDTH;
    _xCenter = _viewWidth / 2.0;
    
    // Match Colors
    //
    _yOffset = _viewHeight * 0.20;
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
    _yOffset = _viewHeight * 0.50;
    [_exploreButton sizeToFit];
    _buttonWidth  = _exploreButton.bounds.size.width;
    _buttonHeight = _exploreButton.bounds.size.height;
    _xOffset     = _xCenter - (_buttonWidth / 2.0);
    [_exploreButton setFrame:CGRectMake(_xOffset, _yOffset, _buttonWidth, _buttonHeight)];
    _exploreLabel = [self resetLabel:_exploreLabel xOffset:_xOffset yOffset:_yOffset+_buttonHeight width:_buttonWidth];
    
    _xOffset = _xCenter - (_width * 2.0);
    [_topicsButton setFrame:CGRectMake(_xOffset, _yOffset, _width, _height)];
    _topicsLabel = [self resetLabel:_topicsLabel xOffset:_xOffset yOffset:_yOffset+_height width:_width];
    
    _xOffset = _xCenter - (_width * 0.5);
    [_collectButton setFrame:CGRectMake(_xOffset, _yOffset, _width, _height)];
    _collectLabel = [self resetLabel:_collectLabel xOffset:_xOffset yOffset:_yOffset+_height width:_width];
    
    _xOffset = _xCenter + _width;
    [_listButton setFrame:CGRectMake(_xOffset, _yOffset, _width, _height)];
    _listLabel = [self resetLabel:_listLabel xOffset:_xOffset yOffset:_yOffset+_height width:_width];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:TRUE];
    
    // Check for DB restore
    //
    _dbRestoreFlag           = [_userDefaults boolForKey:DB_RESTORE_KEY];

    
    // Remove subviews
    //
    [_updateLabel removeFromSuperview];
    

    // Match Colors
    //
    [self initMatchColors];
    
    // Explore Colors
    //
    [self initExploreColors];
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
    [_updateLabel setTextColor:LIGHT_TEXT_COLOR];
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
    //[_myPhotosButton setTitleColor:CLEAR_COLOR forState:UIControlStateNormal];
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
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Orientation Handling Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Orientation Handling Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);//choose portrait or landscape
}

- (BOOL)shouldAutorotate {
    return NO;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Label Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Label Methods

- (UILabel *)resetLabel:(UILabel *)label xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset width:(CGFloat)width {
    [label sizeToFit];
    CGFloat labelWidth   = label.bounds.size.width;
    CGFloat labelXOffset = xOffset + (width - labelWidth) / 2.0;
    
    [label setFrame:CGRectMake(labelXOffset, yOffset + DEF_FIELD_PADDING, label.bounds.size.width, label.bounds.size.height)];
    
    return label;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Button Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Button Methods

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
    //[self.view addSubview:_updateLabel];
    //[self startSpinner];
    //[self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
    [_exploreButton setAlpha:0.0];
    [_exploreLabel setAlpha:0.0];
    [_topicsButton setAlpha:1.0];
    [_topicsLabel setAlpha:1.0];
    [_collectButton setAlpha:1.0];
    [_collectLabel setAlpha:1.0];
    [_listButton setAlpha:1.0];
    [_listLabel setAlpha:1.0];
    
    [self initMatchColors];
}

- (IBAction)exploreTopics:(id)sender {
    _collectionType = KEYWORDS_TYPE;
    [self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}

- (IBAction)exploreCollections:(id)sender {
    _collectionType = MIX_LIST_TYPE;
    [self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}

- (IBAction)exploreLists:(id)sender {
    _collectionType = FULL_LISTING_TYPE;
    [self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods

- (IBAction)unwindToInitViewController:(UIStoryboardSegue *)segue {
    _mainViewHasLoaded = TRUE;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Camera/Photo Library
    //
    if ([[segue identifier] isEqualToString:@"InitToImagePickerSegue"]) {
        PickerViewController *pickerViewController = (PickerViewController *)[segue destinationViewController];
        [pickerViewController setImageAction:_imageAction];
    } else {
        UINavigationController *navigationViewController = [segue destinationViewController];
        MainViewController *mainViewController = (MainViewController *)([navigationViewController viewControllers][0]);
        [mainViewController setViewHasLoaded:_mainViewHasLoaded];
        [mainViewController setListingType:_collectionType];
    }
}

- (void)continue {
    //[self performSegueWithIdentifier:@"InitViewControllerSegue" sender:self];
}


@end
