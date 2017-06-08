//
//  SettingsTableViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 5/9/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import "SettingsTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "AlertUtils.h"
#import "ButtonUtils.h"
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"
#import "AboutViewController.h"
#import "DisclaimerViewController.h"
#include "TargetConditionals.h"


@interface SettingsTableViewController ()

@property (nonatomic) CGFloat widgetHeight, widgetYOffset;
@property (nonatomic, strong) UISwitch *dbPollUpdateSwitch, *dbForceUpdateSwitch, *dbRestoreSwitch, *psReadOnlySwitch, *maReadOnlySwitch, *alertsFilterSwitch;
@property (nonatomic, strong) UILabel *aboutLabel, *disclaimerLabel, *feedbackLabel, *dbPollUpdateLabel, *dbForceUpdateLabel, *dbRestoreLabel, *psReadOnlyLabel, *maReadOnlyLabel, *tapSettingsLabel, *tapStepperLabel, *matchSettingsLabel, *matchStepperLabel, *rgbDisplayLabel, *mixRatiosLabel, *alertsFilterLabel;
@property (nonatomic) BOOL editFlag, dbPollUpdateFlag, dbForceUpdateFlag, dbRestoreFlag, swatchesReadOnly, assocsReadOnly, rgbDisplayFlag, alertsShow;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *labelText, *dbPollUpdateText, *dbPollUpdateOnText, *dbPollUpdateOffText, *dbForceUpdateText, *dbForceUpdateOnText, *dbForceUpdateOffText, *dbRestoreText, *dbRestoreOnText, *dbRestoreOffText, *psReadOnlyText, *psMakeReadOnlyLabel, *psMakeReadWriteLabel, *maReadOnlyText, *maMakeReadOnlyLabel, *maMakeReadWriteLabel, *shapeGeom, *shapeTitle, *rgbDisplayTrueText, *rgbDisplayText, *rgbDisplayFalseText, *rgbDisplayImage, *rgbDisplayTrueImage, *rgbDisplayFalseImage, *mixRatiosText, *alertsFilterText, *alertsNoneLabel, *alertsShowLabel;

// Match Swatch Filters (Generic and Coverage that is not 'Thick')
//
@property (nonatomic, strong) NSString *genFilterText, *covFilterText, *genFilterOffText, *covFilterOffText, *genFilterOnText, *covFilterOnText;
@property (nonatomic) BOOL genFilterFlag, covFilterFlag;
@property (nonatomic, strong) UISwitch *genFilterSwitch, *covFilterSwitch;
@property (nonatomic, strong) UILabel *genFilterLabel, *covFilterLabel;

@property (nonatomic) CGFloat tapAreaSize;
@property (nonatomic, strong) UIImageView *tapImageView;
@property (nonatomic, strong) UIStepper *tapAreaStepper, *matchNumStepper;
@property (nonatomic, strong) UIButton *shapeButton, *rgbDisplayButton;
@property (nonatomic, strong) UITextField *matchNumTextField, *mixRatiosTextField;
@property (nonatomic, strong) UITextView *mixRatiosTextView;
@property (nonatomic, strong) UIAlertController *noSaveAlert;
@property (nonatomic) int maxMatchNum;

// ListingType (picker) properties
//
@property (nonatomic) int typesPickerSelRow;
@property (nonatomic, strong) UITextField *listTypeName;
@property (nonatomic, strong) NSString *listType;
@property (nonatomic, strong) NSArray *listTypeNames;
@property (nonatomic, strong) UIPickerView *listTypesPicker;

// Share
//
@property (nonatomic, strong) UIActivityViewController *shareController;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// NSManagedObject
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation SettingsTableViewController

const int ABOUT_SECTION           = 0;
const int ABOUT_ROW               = 0;
const int DISCLAIMER_ROW          = 1;
const int FEEDBACK_ROW            = 2;
const int ABOUT_ROWS              = 3;

const int DB_UPDATE_SETTINGS      = 1;
const int POLL_DB_UPDATE_ROW      = 0;
const int FORCE_DB_UPDATE_ROW     = 1;
const int DB_UPDATE_SETTINGS_ROWS = 2;
    
const int DB_RESTORE_SETTINGS     = 2;
const int DB_RESTORE_ROWS         = 1;

const int READ_ONLY_SETTINGS      = 3;
const int PSWATCH_READ_ONLY_ROW   = 0;
const int MIXASSOC_READ_ONLY_ROW  = 1;
const int READ_ONLY_SETTINGS_ROWS = 2;

const int TAP_AREA_SETTINGS       = 4;
const int TAP_AREA_ROWS           = 1;

const int MATCH_FILTERS           = 5;
const int MATCH_NUM_ROW           = 0;
const int GEN_FILTER_ROW          = 1;
const int COV_FILTER_ROW          = 2;
const int MATCH_FILTERS_ROWS      = 3;

const int RGB_DISPLAY_SETTINGS    = 6;
const int RGB_DISPLAY_ROWS        = 1;

const int MIX_RATIOS_SETTINGS     = 7;
const int MIX_RATIOS_ROWS         = 1;

const int ALERTS_SETTINGS         = 8;
const int ALERTS_ROWS             = 1;

const int LIST_TYPE_SETTINGS      = 9;
const int LIST_TYPE_ROWS          = 1;

const int SETTINGS_MAX_SECTIONS   = 10;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self saveEnable:FALSE];

    _reuseCellIdentifier = @"SettingsTableCell";
    
    // NSUserDefaults
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // NSManagedObject
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context  = [self.appDelegate managedObjectContext];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // About, disclaimer, feedback sections
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _aboutLabel = [FieldUtils createLabel:@"About this App" xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:self.tableView.bounds.size.width height:DEF_VLG_TABLE_HDR_HGT];
    [_aboutLabel setFont:LG_TABLE_CELL_FONT];
    
    _disclaimerLabel = [FieldUtils createLabel:@"Disclaimer" xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:self.tableView.bounds.size.width height:DEF_VLG_TABLE_HDR_HGT];
    [_disclaimerLabel setFont:LG_TABLE_CELL_FONT];
    
    _feedbackLabel = [FieldUtils createLabel:@"Provide Feedback" xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:self.tableView.bounds.size.width height:DEF_VLG_TABLE_HDR_HGT];
    [_feedbackLabel setFont:LG_TABLE_CELL_FONT];

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Poll for DB Update Rows
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _dbPollUpdateText = @"db_poll_update_text";
    
    _dbPollUpdateOnText  = @"Perform Check for Database Update";
    _dbPollUpdateOffText = @"Do Not Check for Database Update ";
    
    // Default is 'Off'
    //
    if([_userDefaults boolForKey:DB_POLL_UPDATE_KEY] == FALSE || ![[[_userDefaults dictionaryRepresentation] allKeys] containsObject:DB_POLL_UPDATE_KEY]) {
        _dbPollUpdateFlag = FALSE;
        _labelText = _dbPollUpdateOffText;
        
        [_userDefaults setBool:_dbPollUpdateFlag forKey:DB_POLL_UPDATE_KEY];
        [_userDefaults setValue:_labelText forKey:_dbPollUpdateText];
        
    } else {
        _dbPollUpdateFlag = [_userDefaults boolForKey:DB_POLL_UPDATE_KEY];
        _labelText = [_userDefaults stringForKey:_dbPollUpdateText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _dbPollUpdateSwitch = [[UISwitch alloc] init];
    _widgetHeight = _dbPollUpdateSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_dbPollUpdateSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_dbPollUpdateSwitch setOn:_dbPollUpdateFlag];
    
    // Add the switch target
    //
    [_dbPollUpdateSwitch addTarget:self action:@selector(setDbPollUpdateSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _dbPollUpdateLabel   = [self createWidgetLabel:_labelText];

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Force DB Update Rows
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _dbForceUpdateText = @"db_force_update_text";
    
    _dbForceUpdateOnText  = @"Update Even if Versions are Unchanged ";
    _dbForceUpdateOffText = @"Do Not Perform a Force Database Update";
    
    if(! ([_userDefaults boolForKey:DB_FORCE_UPDATE_KEY] && [_userDefaults stringForKey:_dbForceUpdateText])) {
        _dbForceUpdateFlag = FALSE;
        _labelText = _dbForceUpdateOffText;
        
        [_userDefaults setBool:_dbForceUpdateFlag forKey:DB_FORCE_UPDATE_KEY];
        [_userDefaults setValue:_labelText forKey:_dbForceUpdateText];
        
    } else {
        _dbForceUpdateFlag = [_userDefaults boolForKey:DB_FORCE_UPDATE_KEY];
        _labelText = [_userDefaults stringForKey:_dbForceUpdateText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _dbForceUpdateSwitch = [[UISwitch alloc] init];
    _widgetHeight = _dbForceUpdateSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_dbForceUpdateSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_dbForceUpdateSwitch setOn:_dbForceUpdateFlag];
    
    // Add the switch target
    //
    [_dbForceUpdateSwitch addTarget:self action:@selector(setDbForceUpdateSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _dbForceUpdateLabel   = [self createWidgetLabel:_labelText];

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // DB Restore Rows
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _dbRestoreText = @"db_restore_text";
    
    _dbRestoreOffText = @"Keep the Current Database Snapshot";
    _dbRestoreOnText  = @"Restore to the Original Database";
    
    if ([_userDefaults boolForKey:DB_RESTORE_KEY] == FALSE) {
        _dbRestoreFlag = FALSE;
        _labelText = _dbRestoreOffText;
        
        [_userDefaults setBool:_dbRestoreFlag forKey:DB_RESTORE_KEY];
        [_userDefaults setValue:_labelText forKey:_dbRestoreText];
        
    } else {
        _dbRestoreFlag = [_userDefaults boolForKey:DB_RESTORE_KEY];
        _labelText = [_userDefaults stringForKey:_dbRestoreText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _dbRestoreSwitch = [[UISwitch alloc] init];
    _widgetHeight = _dbRestoreSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_dbRestoreSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_dbRestoreSwitch setOn:_dbRestoreFlag];
    
    // Add the switch target
    //
    [_dbRestoreSwitch addTarget:self action:@selector(setDbRestoreSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _dbRestoreLabel   = [self createWidgetLabel:_labelText];


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Swatches Read-Only Rows
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _psReadOnlyText = @"swatches_read_only_text";
    
    _psMakeReadOnlyLabel  = @"Paint Swatches are Read-Only ";
    _psMakeReadWriteLabel = @"Paint Swatches are Read/Write";
    
    if ([_userDefaults boolForKey:PAINT_SWATCH_RO_KEY] == TRUE) {
    //if(! ([_userDefaults boolForKey:PAINT_SWATCH_RO_KEY] &&
    //      [_userDefaults stringForKey:_psReadOnlyText])
    //   ) {
        _swatchesReadOnly = TRUE;
        _labelText = _psMakeReadOnlyLabel;
        
        [_userDefaults setBool:_swatchesReadOnly forKey:PAINT_SWATCH_RO_KEY];
        [_userDefaults setValue:_labelText forKey:_psReadOnlyText];
        
    } else {
        _swatchesReadOnly = [_userDefaults boolForKey:PAINT_SWATCH_RO_KEY];
        _labelText = [_userDefaults stringForKey:_psReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _psReadOnlySwitch = [[UISwitch alloc] init];
    _widgetHeight = _psReadOnlySwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_psReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_psReadOnlySwitch setOn:_swatchesReadOnly];
    
    // Add the switch target
    //
    [_psReadOnlySwitch addTarget:self action:@selector(setPSSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _psReadOnlyLabel   = [self createWidgetLabel:_labelText];
    
    if (ALL_FEATURES == 0)
        [_psReadOnlySwitch setEnabled:FALSE];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // MixAssociation Read-Only Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _maReadOnlyText = @"assoc_read_only_text";
    
    _maMakeReadOnlyLabel  = @"Mix Associations are Read-Only ";
    _maMakeReadWriteLabel = @"Mix Associations are Read/Write";
    
    _labelText = @"";
    if ([_userDefaults boolForKey:MIX_ASSOC_RO_KEY] == TRUE) {
    //if(! ([_userDefaults boolForKey:MIX_ASSOC_RO_KEY] &&
    //      [_userDefaults stringForKey:_maReadOnlyText])
    //   ) {
        _assocsReadOnly = TRUE;
        _labelText = _maMakeReadOnlyLabel;
        
        [_userDefaults setBool:_assocsReadOnly forKey:MIX_ASSOC_RO_KEY];
        [_userDefaults setValue:_labelText forKey:_maReadOnlyText];
        
    } else {
        _assocsReadOnly = [_userDefaults boolForKey:MIX_ASSOC_RO_KEY];
        _labelText = [_userDefaults stringForKey:_maReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _maReadOnlySwitch = [[UISwitch alloc] init];
    _widgetHeight = _maReadOnlySwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_maReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_maReadOnlySwitch setOn:_assocsReadOnly];
    
    // Add the switch target
    //
    [_maReadOnlySwitch addTarget:self action:@selector(setMASwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _maReadOnlyLabel   = [self createWidgetLabel:_labelText];
    
    if (ALL_FEATURES == 0)
        [_maReadOnlySwitch setEnabled:FALSE];

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tap Area Widgets
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    _tapSettingsLabel = [self createWidgetLabel:@"Change the Size/Shape of the Tap Areas"];
    
    // Sizing parameters
    //
    _tapAreaSize = [_userDefaults floatForKey:TAP_AREA_SIZE_KEY];
    if (! _tapAreaSize) {
        _tapAreaSize = DEF_TAP_AREA_SIZE;
        [_userDefaults setFloat:DEF_TAP_AREA_SIZE forKey:TAP_AREA_SIZE_KEY];
    }
    
    // UIStepper (change the size of the tapping area)
    //
    _tapAreaStepper = [[UIStepper alloc] init];

    [_tapAreaStepper setTintColor:LIGHT_TEXT_COLOR];
    [_tapAreaStepper addTarget:self action:@selector(tapAreaStepperPressed) forControlEvents:UIControlEventValueChanged];
    
    
    // Set min, max, step, and default values and wraps parameter
    //
    [_tapAreaStepper setMinimumValue:TAP_STEPPER_MIN];
    [_tapAreaStepper setMaximumValue:TAP_STEPPER_MAX];
    [_tapAreaStepper setStepValue:TAP_STEPPER_INC];
    [_tapAreaStepper setValue:_tapAreaSize];
    [_tapAreaStepper setWraps:NO];

    
    _tapImageView = [[UIImageView alloc] init];
    [_tapImageView setBackgroundColor:LIGHT_BG_COLOR];
    
    // Set the default
    //
    _shapeGeom = [_userDefaults stringForKey:SHAPE_GEOMETRY_KEY];
    if (! _shapeGeom) {
        _shapeGeom = SHAPE_CIRCLE_VALUE;
    }
    
    if ([_shapeGeom isEqualToString:SHAPE_CIRCLE_VALUE]) {
        [_tapImageView.layer setCornerRadius:_tapAreaSize / DEF_CORNER_RAD_FACTOR];
        [_tapImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        _shapeTitle = SHAPE_CIRCLE_VALUE;
        
    // Rectangle
    //
    } else {
        [_tapImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
        [_tapImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        _shapeTitle = SHAPE_RECT_VALUE;
    }
    [_tapImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
    _shapeButton = [ButtonUtils create3DButton:_shapeTitle tag:SHAPE_BUTTON_TAG];
    [_shapeButton addTarget:self action:@selector(changeShape) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Label displaying the value in the stepper
    //
    int size = (int)_tapAreaSize;
    _tapStepperLabel = [FieldUtils createLabel:[[NSString alloc] initWithFormat:@"%i", size]];
    [_tapStepperLabel setTextColor:DARK_TEXT_COLOR];
    [_tapStepperLabel setBackgroundColor:CLEAR_COLOR];
    [_tapStepperLabel setTextAlignment:NSTextAlignmentCenter];

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Match Num Filters
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _matchSettingsLabel = [self createWidgetLabel:@"Change the Number of Tap Area Matches"];
    
    _matchNumStepper = [[UIStepper alloc] init];
    [_matchNumStepper setTintColor: LIGHT_TEXT_COLOR];
    [_matchNumStepper addTarget:self action:@selector(matchNumStepperPressed) forControlEvents:UIControlEventValueChanged];
    
    _maxMatchNum = (int)[_userDefaults integerForKey:MATCH_NUM_KEY];
    if (! _maxMatchNum) {
        _maxMatchNum = MATCH_STEPPER_DEF;
    }
    
    // Set min, max, step, and default values and wraps parameter
    //
    [_matchNumStepper setMinimumValue:MATCH_STEPPER_MIN];
    [_matchNumStepper setMaximumValue:MATCH_STEPPER_MAX];
    [_matchNumStepper setStepValue:MATCH_STEPPER_INC];
    [_matchNumStepper setValue:_maxMatchNum];
    [_matchNumStepper setWraps:NO];
   
   
    _matchNumTextField = [FieldUtils createTextField:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum] tag:MATCH_NUM_TAG];
    [_matchNumTextField setAutoresizingMask:NO];
    [_matchNumTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_matchNumTextField setDelegate:self];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_TOOLBAR_WIDTH, DEF_TOOLBAR_HEIGHT)];
    [numberToolbar setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    [doneButton setTintColor:LIGHT_TEXT_COLOR];
    numberToolbar.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            doneButton];
    [numberToolbar sizeToFit];
    [_matchNumTextField setInputAccessoryView:numberToolbar];
    
    
    // Generics Filter Switch
    //
    _genFilterText = @"gen_filter_text";
    
    _genFilterOffText = @"Generic Swatches Not Filtered ";
    _genFilterOnText  = @"Generic Swatches Are Filtered";
    
    if ([_userDefaults boolForKey:GEN_FILTER_KEY] == TRUE) {
        _genFilterFlag = TRUE;
        _labelText = _genFilterOnText;
        
        [_userDefaults setBool:_genFilterFlag forKey:GEN_FILTER_KEY];
        [_userDefaults setValue:_labelText forKey:_genFilterText];
        
    } else {
        _genFilterFlag = [_userDefaults boolForKey:GEN_FILTER_KEY];
        _labelText = [_userDefaults stringForKey:_genFilterText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _genFilterSwitch = [[UISwitch alloc] init];
    _widgetHeight = _genFilterSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_genFilterSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_genFilterSwitch setOn:_genFilterFlag];
    
    // Add the switch target
    //
    [_genFilterSwitch addTarget:self action:@selector(setGenFilterSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _genFilterLabel   = [self createWidgetLabel:_labelText];


    // Coverage Filter Switch
    //
    _covFilterText = @"cov_filter_text";
    
    _covFilterOffText = @"Non-Thick Swatches Not Filtered ";
    _covFilterOnText  = @"Non-Thick Swatches Are Filtered";
    
    if ([_userDefaults boolForKey:COV_FILTER_KEY] == FALSE) {
        _covFilterFlag = FALSE;
        _labelText = _covFilterOffText;
        
        [_userDefaults setBool:_covFilterFlag forKey:COV_FILTER_KEY];
        [_userDefaults setValue:_labelText forKey:_covFilterText];
        
    } else {
        _covFilterFlag = [_userDefaults boolForKey:COV_FILTER_KEY];
        _labelText = [_userDefaults stringForKey:_covFilterText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _covFilterSwitch = [[UISwitch alloc] init];
    _widgetHeight = _covFilterSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_covFilterSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_covFilterSwitch setOn:_covFilterFlag];
    
    // Add the switch target
    //
    [_covFilterSwitch addTarget:self action:@selector(setCovFilterSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _covFilterLabel   = [self createWidgetLabel:_labelText];

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // RGB Display Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _rgbDisplayTrueText  = @"Swatch Displays the RGB Value";
    _rgbDisplayFalseText = @"Swatch Displays the Paint Image";
    _rgbDisplayTrueImage  = RGB_IMAGE_NAME;
    _rgbDisplayFalseImage = PALETTE_IMAGE_NAME;
    
    if(! [_userDefaults boolForKey:RGB_DISPLAY_KEY]) {
        _rgbDisplayFlag  = FALSE;
        _rgbDisplayText  = _rgbDisplayFalseText;
        _rgbDisplayImage = _rgbDisplayFalseImage;
       
        [_userDefaults setBool:_rgbDisplayFlag forKey:RGB_DISPLAY_KEY];
        
    } else {
        _rgbDisplayFlag = [_userDefaults boolForKey:RGB_DISPLAY_KEY];
        if (_rgbDisplayFlag == TRUE) {
            _rgbDisplayText  = _rgbDisplayTrueText;
            _rgbDisplayImage = _rgbDisplayTrueImage;
        } else {
            _rgbDisplayText  = _rgbDisplayFalseText;
            _rgbDisplayImage = _rgbDisplayFalseImage;
        }
    }
    
    // Create the button
    //
    _rgbDisplayButton = [[UIButton alloc] init];
    
    // Set the new image
    //
    UIImage *renderedImage = [UIImage imageNamed:_rgbDisplayImage];
    [_rgbDisplayButton setImage:renderedImage forState:UIControlStateNormal];
    [_rgbDisplayButton setBackgroundColor:LIGHT_BG_COLOR];
    [_rgbDisplayButton.layer setCornerRadius:DEF_CORNER_RADIUS];
    
    CGFloat cellHeight   = DEF_LG_TABLE_CELL_HGT;
    CGFloat buttonHeight = cellHeight - DEF_VLG_FIELD_PADDING;
    CGFloat yOffset      = (cellHeight - buttonHeight) / DEF_HGT_ALIGN_FACTOR;
    [_rgbDisplayButton setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, buttonHeight, buttonHeight)];

    // Add the UIButton target
    //
    [_rgbDisplayButton addTarget:self action:@selector(setRGBDisplayState) forControlEvents:UIControlEventTouchUpInside];
    
    _rgbDisplayLabel   = [self createWidgetLabel:_rgbDisplayText];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Mix Ratios Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _mixRatiosLabel = [self createWidgetLabel:@"Comma-separated mix ratios, new line per group"];
    
    _mixRatiosTextView = [FieldUtils createTextView:@"" tag:MIX_RATIOS_TAG];
    [_mixRatiosTextView setKeyboardType:UIKeyboardTypeDefault];
    [_mixRatiosTextView setDelegate:self];
    
    UIToolbar* doneKeyToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_TOOLBAR_WIDTH, DEF_TOOLBAR_HEIGHT)];
    [doneKeyToolbar setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *tvDoneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithTextView)];
    [tvDoneButton setTintColor:LIGHT_TEXT_COLOR];
    doneKeyToolbar.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            tvDoneButton];
    [doneKeyToolbar sizeToFit];
    [_mixRatiosTextView setInputAccessoryView:doneKeyToolbar];
    
    _mixRatiosText = [_userDefaults stringForKey:MIX_RATIOS_KEY];
    
    // Add a place holder if no text
    //
    if (! [_mixRatiosText isEqualToString:@""] && (_mixRatiosText != nil)) {
        [_mixRatiosTextView setText:_mixRatiosText];
    }
    
    if (ALL_FEATURES == 0)
        [_mixRatiosTextView setEditable:FALSE];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Alerts Filter Settings
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _alertsFilterText    = @"alerts_filter_text";
    
    _alertsNoneLabel = @"All Informational Alerts are Turned On";
    _alertsShowLabel = @"All Informational Alerts are Turned Off";
    
    BOOL imageInteractAlert = [_userDefaults boolForKey:IMAGE_INTERACT_KEY];
    BOOL tapCollectAlert    = [_userDefaults boolForKey:TAP_COLLECT_KEY];

    _labelText = @"";
    if (imageInteractAlert == TRUE && tapCollectAlert == TRUE) {
        _alertsShow = TRUE;
        _labelText  = _alertsNoneLabel;

    } else {
        _alertsShow = FALSE;
        _labelText  = _alertsShowLabel;
    }

    
    // Create the label and switch, set the last state or default values
    //
    _alertsFilterSwitch = [[UISwitch alloc] init];
    _widgetHeight = _alertsFilterSwitch.bounds.size.height;
    _widgetYOffset = (DEF_LG_TABLE_CELL_HGT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_alertsFilterSwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_alertsFilterSwitch setOn:_alertsShow];
    
    // Add the switch target
    //
    [_alertsFilterSwitch addTarget:self action:@selector(setAlertsFilterSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _alertsFilterLabel   = [self createWidgetLabel:_labelText];


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Create No Save alert
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _noSaveAlert = [AlertUtils createBlankAlert:@"Settings Not Saved" message:@"Continue without saving?"];
    
    UIAlertAction* YesButton = [UIAlertAction
                               actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    UIAlertAction* NoButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
    
    [_noSaveAlert addAction:NoButton];
    [_noSaveAlert addAction:YesButton];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Listing Type Selection
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Picker entities
    //
    // Set the default value for the textfield
    //
    _listType = [_userDefaults stringForKey:LISTING_TYPE];
    if ([_listType isEqualToString:@""] || _listType == nil) {
        _listType = MIX_LIST_TYPE;
    }

    // Query the order
    //
    id typeObj = [ManagedObjectUtils queryDictionaryByNameValue:@"ListingType" nameValue:_listType context:self.context];
    _typesPickerSelRow = [[typeObj order] intValue];
    _listTypeName  = [FieldUtils createTextField:_listType tag:LIST_TYPE_FIELD_TAG];
    CGFloat viewWidth = self.tableView.bounds.size.width;
    CGFloat fullTextFieldWidth = viewWidth - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;
    CGFloat textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / DEF_Y_OFFSET_DIVIDER;
    [_listTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_listTypeName setTextAlignment:NSTextAlignmentCenter];
    [_listTypeName setDelegate:self];
    
    _listTypeNames = [ManagedObjectUtils fetchDictNames:@"ListingType" context:self.context];

    _listTypesPicker = [self createPicker:LIST_TYPE_PICKER_TAG selectRow:_typesPickerSelRow action:@selector(listTypesSelection) textField:_listTypeName];

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Share
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Share to social media and other venues
    //
    NSURL *mainUrl         = [NSURL URLWithString:MAIN_SITE_URL];
    UIImage *mainImage     = [UIImage imageNamed:MAIN_IMAGE];
    
    _shareController = [[UIActivityViewController alloc] initWithActivityItems:@[DOCS_SYNOPSIS, mainUrl, mainImage] applicationActivities:nil];

    _shareController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                               UIActivityTypePrint,
                                               UIActivityTypeCopyToPasteboard,
                                               UIActivityTypeAssignToContact,
                                               UIActivityTypeSaveToCameraRoll,
                                               UIActivityTypePostToFlickr,
                                               UIActivityTypePostToVimeo,
                                               UIActivityTypePostToTencentWeibo,
                                               UIActivityTypeAirDrop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SETTINGS_MAX_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ABOUT_SECTION) {
        return ABOUT_ROWS;
        
    } else if (section == DB_UPDATE_SETTINGS) {
        if (_dbPollUpdateFlag == TRUE) {
            return DB_UPDATE_SETTINGS_ROWS;
        } else {
            return 1;
        }
    
    } else if (section == DB_RESTORE_SETTINGS) {
        return DB_RESTORE_ROWS;
        
    } else if (section == READ_ONLY_SETTINGS) {
        return READ_ONLY_SETTINGS_ROWS;
        
    } else if (section == TAP_AREA_SETTINGS) {
        return TAP_AREA_ROWS;
        
    } else if (section == MATCH_FILTERS) {
        return MATCH_FILTERS_ROWS;
        
    } else if (section == RGB_DISPLAY_SETTINGS) {
        return RGB_DISPLAY_ROWS;
        
    } else if (section == MIX_RATIOS_SETTINGS) {
        return MIX_RATIOS_ROWS;
        
    } else if (section == ALERTS_SETTINGS) {
        return ALERTS_ROWS;

    } else if (section == LIST_TYPE_SETTINGS) {
        return LIST_TYPE_ROWS;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == ABOUT_SECTION) {
        return DEF_VLG_TABLE_HDR_HGT;
        
    } else if (indexPath.section == MIX_RATIOS_SETTINGS) {
        return DEF_XLG_TBL_CELL_HGT;
        
    } else if ((indexPath.section == TAP_AREA_SETTINGS) ||
               (indexPath.section == MATCH_FILTERS && indexPath.row == MATCH_NUM_ROW)) {
        return DEF_VLG_TBL_CELL_HGT;
        
    } else {
        return DEF_LG_TABLE_CELL_HGT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DEF_TABLE_HDR_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr = @"";
    if (section == ABOUT_SECTION) {
        headerStr = @"About & Feedback";
        
    } else if (section == DB_UPDATE_SETTINGS) {
        headerStr = @"Database Update Settings";
        
    } else if (section == DB_RESTORE_SETTINGS) {
        headerStr = @"Database Restore Settings";

    } else if (section == READ_ONLY_SETTINGS) {
        headerStr = @"Read-Only Settings";
        
    } else if (section == TAP_AREA_SETTINGS) {
        headerStr = @"Tap Area Settings";
        
    } else if (section == MATCH_FILTERS) {
        headerStr = @"Match Filters";
        
    } else if (section == RGB_DISPLAY_SETTINGS) {
        headerStr = @"Paint/RGB Display";
        
    } else if (section == MIX_RATIOS_SETTINGS) {
        headerStr = @"Default Paint Mix Ratios";
        
    } else if (section == ALERTS_SETTINGS) {
        headerStr = @"Alerts Settings";

    } else if (section == LIST_TYPE_SETTINGS) {
        headerStr = @"Default List View";
    }
    
    return headerStr;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return DEF_NIL_FOOTER;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [[((UITableViewHeaderFooterView*) view) textLabel] setTextColor:LIGHT_TEXT_COLOR];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];
    [cell.contentView setBackgroundColor:DARK_BG_COLOR];
    [cell setBackgroundColor:DARK_BG_COLOR];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];

    [cell.textLabel setFont:TABLE_CELL_FONT];
    [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
    [cell.imageView setImage:nil];
    [cell.textLabel setText:@""];
    
    
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    
    if (indexPath.section == ABOUT_SECTION) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        if (indexPath.row == ABOUT_ROW) {
            [cell.contentView addSubview:_aboutLabel];
            
        } else if (indexPath.row == DISCLAIMER_ROW) {
            [cell.contentView addSubview:_disclaimerLabel];
        
        // Feedback row
        //
        } else {
            [cell.contentView addSubview:_feedbackLabel];
        }
        
    } else if (indexPath.section == DB_UPDATE_SETTINGS) {

        if (indexPath.row == POLL_DB_UPDATE_ROW) {
            [cell.contentView addSubview:_dbPollUpdateSwitch];
            [cell.contentView addSubview:_dbPollUpdateLabel];
            
        } else if ((indexPath.row == FORCE_DB_UPDATE_ROW) && (_dbPollUpdateFlag == TRUE)) {
            [cell.contentView addSubview:_dbForceUpdateSwitch];
            [cell.contentView addSubview:_dbForceUpdateLabel];
        }

    } else if (indexPath.section == DB_RESTORE_SETTINGS) {
            [cell.contentView addSubview:_dbRestoreSwitch];
            [cell.contentView addSubview:_dbRestoreLabel];

    } else if (indexPath.section == READ_ONLY_SETTINGS) {
    
        if (indexPath.row == PSWATCH_READ_ONLY_ROW) {
            [cell.contentView addSubview:_psReadOnlySwitch];
            [cell.contentView addSubview:_psReadOnlyLabel];
            
        } else if (indexPath.row == MIXASSOC_READ_ONLY_ROW) {
            [cell.contentView addSubview:_maReadOnlySwitch];
            [cell.contentView addSubview:_maReadOnlyLabel];
        }
        
    } else if (indexPath.section == TAP_AREA_SETTINGS) {
        [_tapSettingsLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_FIELD_PADDING, tableViewWidth, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_tapSettingsLabel];

        CGFloat yOffset = _tapSettingsLabel.bounds.size.height + DEF_MD_FIELD_PADDING;
        [_tapAreaStepper setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT)];
        [cell.contentView addSubview:_tapAreaStepper];
        
        CGFloat shapeXOffset = DEF_TABLE_X_OFFSET + _tapAreaStepper.bounds.size.width + DEF_LG_FIELD_PADDING;
        [_shapeButton setFrame:CGRectMake(shapeXOffset, yOffset, DEF_BUTTON_WIDTH, _tapAreaStepper.bounds.size.height)];
        [_shapeButton setBackgroundColor:CLEAR_COLOR];
        [_shapeButton setTitleColor:LIGHT_TEXT_COLOR forState:UIControlStateNormal];
        
        [_shapeButton.layer setMasksToBounds:YES];
        [_shapeButton.layer setCornerRadius:DEF_LG_CORNER_RADIUS];
        [_shapeButton.layer setBorderWidth:DEF_BORDER_WIDTH];
        [_shapeButton.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame            = _shapeButton.bounds;
        gradient.colors           = [NSArray arrayWithObjects:(id)[DARK_BG_COLOR CGColor], (id)[GRAY_BG_COLOR CGColor], nil];
        [_shapeButton.layer insertSublayer:gradient atIndex:0];
        
        [cell.contentView addSubview:_shapeButton];
        
        CGFloat imageViewXOffset = shapeXOffset + _shapeButton.bounds.size.width + DEF_LG_FIELD_PADDING;
        [_tapImageView setFrame:CGRectMake(imageViewXOffset, yOffset, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_tapImageView];
        
        [_tapStepperLabel setFrame:CGRectMake(imageViewXOffset, yOffset, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_tapStepperLabel];
        
    } else if (indexPath.section == MATCH_FILTERS) {
        if (indexPath.row == MATCH_NUM_ROW) {
            [_matchSettingsLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_FIELD_PADDING, tableViewWidth, DEF_LABEL_HEIGHT)];
            [cell.contentView addSubview:_matchSettingsLabel];
            
            CGFloat yOffset = _matchSettingsLabel.bounds.size.height + DEF_MD_FIELD_PADDING;
            [_matchNumStepper setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT)];
            [cell.contentView addSubview:_matchNumStepper];
            
            CGFloat shapeXOffset = DEF_TABLE_X_OFFSET + _matchNumStepper.bounds.size.width + DEF_LG_FIELD_PADDING;
            [_matchNumTextField setFrame:CGRectMake(shapeXOffset, yOffset, DEF_BUTTON_WIDTH, _matchNumStepper.bounds.size.height)];
            [cell.contentView addSubview:_matchNumTextField];
        
        } else if (indexPath.row == GEN_FILTER_ROW) {
            [cell.contentView addSubview:_genFilterSwitch];
            [cell.contentView addSubview:_genFilterLabel];
            
        } else if (indexPath.row == COV_FILTER_ROW) {
            [cell.contentView addSubview:_covFilterSwitch];
            [cell.contentView addSubview:_covFilterLabel];
        }
        
    } else if (indexPath.section == RGB_DISPLAY_SETTINGS) {
        [cell.contentView addSubview:_rgbDisplayButton];
        [cell.contentView addSubview:_rgbDisplayLabel];
        
    } else if (indexPath.section == MIX_RATIOS_SETTINGS) {
        [_mixRatiosLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_FIELD_PADDING, tableViewWidth, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_mixRatiosLabel];
        
        CGFloat yOffset = _mixRatiosLabel.bounds.size.height + DEF_MD_FIELD_PADDING;
        CGFloat width   = cell.bounds.size.width - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;
        [_mixRatiosTextView setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, width, DEF_TEXTVIEW_HEIGHT)];
        [cell.contentView addSubview:_mixRatiosTextView];
        
    } else if (indexPath.section == ALERTS_SETTINGS) {
        [cell.contentView addSubview:_alertsFilterSwitch];
        [cell.contentView addSubview:_alertsFilterLabel];

    } else if (indexPath.section == LIST_TYPE_SETTINGS) {
        [cell.contentView addSubview:_listTypeName];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == ABOUT_SECTION) {
        if (indexPath.row == ABOUT_ROW) {
            [self performSegueWithIdentifier:@"AboutSegue" sender:self];
            
        } else if (indexPath.row == DISCLAIMER_ROW) {
            [self performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
        
        // Feedback Section
        //
        } else {
            // This functionality not run on simulators
            //
            if (TARGET_OS_SIMULATOR) {
                UIAlertController *emailSendAlert = [AlertUtils createOkAlert:@"Provide Feedback Alert" message:@"This functionality is not enabled when running on simulators"];
                [self presentViewController:emailSendAlert animated:YES completion:nil];
            } else {
                [self showEmail];
            }
        }
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TextField/TextView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextField/TextView Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == MATCH_NUM_TAG) {
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:textField.text];

        if ([numbersOnly isSupersetOfSet:characterSetFromTextField]) {
            int newValue = [textField.text intValue];
            if (newValue > DEF_MAX_MATCH) {
                _maxMatchNum = DEF_MAX_MATCH;
                
            } else if (newValue < DEF_MIN_MATCH) {
                _maxMatchNum = DEF_MIN_MATCH;
                
            } else {
                _maxMatchNum = newValue;
            }
        }
        [textField setText:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum]];
        [_matchNumStepper setValue:(double)_maxMatchNum];

    // Picker listTypes text field
    //
    } else {
        _listType = textField.text;
    }
    [self saveEnable:TRUE];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _mixRatiosText = [GenericUtils removeSpaces:textView.text];
    [self saveEnable:TRUE];
}

-(BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Widget States and Save Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Widget States and Save Methods

-(void)doneWithNumberPad {
    [_matchNumTextField resignFirstResponder];
}

-(void)doneWithTextView {
    [_mixRatiosTextView resignFirstResponder];
}

- (void)setDbPollUpdateSwitchState:(id)sender {
    _dbPollUpdateFlag = [sender isOn];
    
    if (_dbPollUpdateFlag == TRUE) {
        _dbPollUpdateLabel = [self createWidgetLabel:_dbPollUpdateOnText];
        
    } else {
        _dbPollUpdateLabel = [self createWidgetLabel:_dbPollUpdateOffText];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)setDbForceUpdateSwitchState:(id)sender {
    _dbForceUpdateFlag = [sender isOn];
    
    if (_dbForceUpdateFlag == TRUE) {
        _dbForceUpdateLabel = [self createWidgetLabel:_dbForceUpdateOnText];
        
    } else {
        _dbForceUpdateLabel = [self createWidgetLabel:_dbForceUpdateOffText];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

    
- (void)setDbRestoreSwitchState:(id)sender {
    _dbRestoreFlag = [sender isOn];
    
    if (_dbRestoreFlag == TRUE) {
        _dbRestoreLabel = [self createWidgetLabel:_dbRestoreOnText];
        UIAlertController *restoreAlert = [AlertUtils createOkAlert:@"Database Restore Alert" message:@"Caution: You will lose any data added if you revert to the original snapshot (changes will take effect after turning off/on the phone)"];
        [self presentViewController:restoreAlert animated:YES completion:nil];
        
    } else {
        _dbRestoreLabel = [self createWidgetLabel:_dbRestoreOffText];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)setPSSwitchState:(id)sender {
    _swatchesReadOnly = [sender isOn];

    if (_swatchesReadOnly == TRUE) {
         _psReadOnlyLabel = [self createWidgetLabel:_psMakeReadOnlyLabel];
        
    } else {
        _psReadOnlyLabel = [self createWidgetLabel:_psMakeReadWriteLabel];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)setMASwitchState:(id)sender {
    _assocsReadOnly = [sender isOn];
    
    if (_assocsReadOnly == TRUE) {
        _maReadOnlyLabel = [self createWidgetLabel:_maMakeReadOnlyLabel];
        
    } else {
        _maReadOnlyLabel = [self createWidgetLabel:_maMakeReadWriteLabel];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)tapAreaStepperPressed {
    int size = (int)[_tapAreaStepper value];
    
    [_tapStepperLabel setText:[[NSString alloc] initWithFormat:@"%i", size]];
    
    _tapAreaSize           = (CGFloat)size;
    
    if ([_shapeGeom isEqualToString:SHAPE_CIRCLE_VALUE]) {
        [_tapImageView.layer setCornerRadius:_tapAreaSize / DEF_CORNER_RAD_FACTOR];
    } else {
        [_tapImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    }
    [self.tableView reloadData];
    [self saveEnable:TRUE];
}

- (void)changeShape {
    if ([_shapeButton.titleLabel.text isEqualToString:SHAPE_CIRCLE_VALUE]) {
        _shapeTitle = SHAPE_RECT_VALUE;
        _shapeGeom  = SHAPE_RECT_VALUE;
        [_tapImageView.layer setCornerRadius:DEF_CORNER_RADIUS];

    } else {
        _shapeTitle = SHAPE_CIRCLE_VALUE;
        _shapeGeom  = SHAPE_CIRCLE_VALUE;
        [_tapImageView.layer setCornerRadius:_tapAreaSize / DEF_CORNER_RAD_FACTOR];
    }
    [_shapeButton setTitle:_shapeTitle forState:UIControlStateNormal];
    [self saveEnable:TRUE];
}

- (void)setGenFilterSwitchState:(id)sender {
    _genFilterFlag = [sender isOn];
    
    if (_genFilterFlag == TRUE) {
        _genFilterLabel = [self createWidgetLabel:_genFilterOnText];
        
    } else {
        _genFilterLabel = [self createWidgetLabel:_genFilterOffText];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)setCovFilterSwitchState:(id)sender {
    _covFilterFlag = [sender isOn];
    
    if (_covFilterFlag == TRUE) {
        _covFilterLabel = [self createWidgetLabel:_covFilterOnText];
        
    } else {
        _covFilterLabel = [self createWidgetLabel:_covFilterOffText];
    }
    [self saveEnable:TRUE];
    [self.tableView reloadData];
}

- (void)matchNumStepperPressed {
    _maxMatchNum = (int)[_matchNumStepper value];
    
    [_matchNumTextField setText:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum]];
    [self saveEnable:TRUE];
}

- (void)setRGBDisplayState {
    if (_rgbDisplayFlag == FALSE) {
        _rgbDisplayFlag  = TRUE;
        _rgbDisplayText  = _rgbDisplayTrueText;
        _rgbDisplayImage = _rgbDisplayTrueImage;
        
    } else {
        _rgbDisplayFlag  = FALSE;
        _rgbDisplayText  = _rgbDisplayFalseText;
        _rgbDisplayImage = _rgbDisplayFalseImage;
    }
    
    // Re-set the image
    //
    UIImage *renderedImage = [UIImage imageNamed:_rgbDisplayImage];
    [_rgbDisplayButton setImage:renderedImage forState:UIControlStateNormal];

    [_rgbDisplayLabel setText:_rgbDisplayText];
    
    [self.tableView reloadData];
    [self saveEnable:TRUE];
}

- (void)setAlertsFilterSwitchState:(id)sender {
    _alertsShow = [sender isOn];
    
    if (_alertsShow == TRUE) {
        _alertsFilterLabel = [self createWidgetLabel:_alertsNoneLabel];
        
    } else {
        _alertsFilterLabel = [self createWidgetLabel:_alertsShowLabel];
    }
    [self.tableView reloadData];
    [self saveEnable:TRUE];
}

- (IBAction)save:(id)sender {
    
    // Perform any validations first
    //
    if ([self areValidRatios:_mixRatiosText]) {

        BOOL saveError = FALSE;
        
        [ManagedObjectUtils setEntityReadOnly:@"PaintSwatch" isReadOnly:_swatchesReadOnly context:self.context];
        [ManagedObjectUtils setEntityReadOnly:@"MixAssociation" isReadOnly:_assocsReadOnly context:self.context];

        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            saveError = TRUE;
        } else {
            NSLog(@"Settings save successful");
        }

        if (! saveError) {
            // DB Update Settings
            //
            [_userDefaults setBool:_dbPollUpdateFlag forKey:DB_POLL_UPDATE_KEY];
            [_userDefaults setValue:[_dbPollUpdateLabel text] forKey:_dbPollUpdateText];
            
            [_userDefaults setBool:_dbForceUpdateFlag forKey:DB_FORCE_UPDATE_KEY];
            [_userDefaults setValue:[_dbForceUpdateLabel text] forKey:_dbForceUpdateText];
            
            // DB Restore Settings
            //
            [_userDefaults setBool:_dbRestoreFlag forKey:DB_RESTORE_KEY];
            [_userDefaults setValue:[_dbRestoreLabel text] forKey:_dbRestoreText];
            

            // Read-Only Settings
            //
            [_userDefaults setBool:_swatchesReadOnly forKey:PAINT_SWATCH_RO_KEY];
            [_userDefaults setValue:[_psReadOnlyLabel text] forKey:_psReadOnlyText];
            
            [_userDefaults setBool:_assocsReadOnly forKey:MIX_ASSOC_RO_KEY];
            [_userDefaults setValue:[_maReadOnlyLabel text] forKey:_maReadOnlyText];
            
            // Tap Area Stepper Settings
            //
            [_userDefaults setFloat:_tapAreaSize forKey:TAP_AREA_SIZE_KEY];
            [_userDefaults setValue:_shapeGeom forKey:SHAPE_GEOMETRY_KEY];
            
            // Match Filters
            //
            [_userDefaults setInteger:_maxMatchNum forKey:MATCH_NUM_KEY];

            [_userDefaults setBool:_genFilterFlag forKey:GEN_FILTER_KEY];
            [_userDefaults setValue:[_genFilterLabel text] forKey:_genFilterText];
            
            [_userDefaults setBool:_covFilterFlag forKey:COV_FILTER_KEY];
            [_userDefaults setValue:[_covFilterLabel text] forKey:_covFilterText];
            
            // isRGB settings
            //
            [_userDefaults setBool:_rgbDisplayFlag forKey:RGB_DISPLAY_KEY];
            
            // Paint Mix Ratios
            //
            [_userDefaults setValue:_mixRatiosText forKey:MIX_RATIOS_KEY];
            
            // Add Mix Settings
            //
            [_userDefaults setBool:_alertsShow forKey:APP_INTRO_KEY];
            [_userDefaults setBool:_alertsShow forKey:IMAGE_INTERACT_KEY];
            [_userDefaults setBool:_alertsShow forKey:TAP_COLLECT_KEY];
            
            // List type
            //
            [_userDefaults setValue:_listType forKey:LISTING_TYPE];
            
            [_userDefaults synchronize];
            
            // Disable button?
            //
            if (_editFlag == TRUE) {
                [self saveEnable:FALSE];
            }
        }
        
    } else {
        [self presentViewController:[AlertUtils createOkAlert:@"Mix Ratios Incorrectly Formatted" message:@"Mix ratios must be colon-delimited, each pair comma-separated, and no blank lines"] animated:YES completion:nil];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Validation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Validation Methods

- (BOOL)areValidRatios:(NSString *)ratiosText {
    
    // Exit immediately if text is nil
    //
    NSArray *groupList  = [ratiosText componentsSeparatedByString:@"\n"];
    NSCharacterSet *fullSetOfChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,:"];

    for (NSString *group in groupList) {
        
        // Skip empty strings added
        //
        if ([group isEqualToString:@""]) {
            continue;
        }
        
        // Check that no invalid characters are being used
        //
        if (![[group stringByTrimmingCharactersInSet:fullSetOfChars] isEqualToString:@""]) {
            return FALSE;
        }
        
        NSArray *comps = [group componentsSeparatedByString:@","];
        for (NSString *ratiosPair in comps) {
            NSArray *ratios = [ratiosPair componentsSeparatedByString:@":"];
            
            int ratiosCount = (int)[ratios count];
            
            // Check that each component has only two numeric ratios
            //
            if (ratiosCount != 2) {
                return FALSE;
            }
        }
    }
    
    return TRUE;
}

- (void)saveEnable:(BOOL)saveFlag {
    _editFlag = saveFlag;
    [self.navigationItem.rightBarButtonItem setEnabled:saveFlag];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PickerView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - PickerView Methods

// The number of columns of data
//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
//
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return (long)[_listTypeNames count];
}

// Row height
//
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return DEF_PICKER_ROW_HEIGHT;
}

// The data to return for the row and component (column) that's being passed in
//
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_listTypeNames objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET,DEF_Y_OFFSET,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
    }
    
    [label setText:[_listTypeNames objectAtIndex:row]];
    [label setTextColor: LIGHT_TEXT_COLOR];
    [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    [label.layer setBorderWidth: DEF_BORDER_WIDTH];
    
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *listType = [_listTypeNames objectAtIndex:row];
    [_listTypeName setText:listType];
    _typesPickerSelRow = (int)row;
}

- (void)listTypesSelection {
    [_listTypeName setText:[_listTypeNames objectAtIndex:_typesPickerSelRow]];
    [_listTypesPicker selectRow:_typesPickerSelRow inComponent:0 animated:YES];
    [_listTypeName resignFirstResponder];
}

// Generic Picker method
//
- (UIPickerView *)createPicker:(int)pickerTag selectRow:(int)selectRow action:(SEL)action textField:(UITextField *)textField {
    UIPickerView *picker = [FieldUtils createPickerView:self.view.frame.size.width tag:pickerTag xOffset:DEF_X_OFFSET yOffset:DEF_TOOLBAR_HEIGHT];
    [picker setDataSource:self];
    [picker setDelegate:self];
    
    UIToolbar* pickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, picker.bounds.size.width, DEF_TOOLBAR_HEIGHT)];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:action];
    [doneButton setTintColor:LIGHT_TEXT_COLOR];
    
    [pickerToolbar setItems: @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton]];
    
    UIView *pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, picker.bounds.size.width, picker.bounds.size.height + DEF_TOOLBAR_HEIGHT)];
    [pickerParentView setBackgroundColor:DARK_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:picker];
    
    [textField setInputView:pickerParentView];
    
    // Need to prevent text from clearing
    
    [picker selectRow:selectRow inComponent:0 animated:YES];
    
    return picker;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Other Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Other Methods

- (UILabel *)createWidgetLabel:(NSString *)labelText {

    UILabel *widgetLabel = [FieldUtils createLabel:labelText xOffset:DEF_LG_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    CGFloat labelWidth   = widgetLabel.bounds.size.width + DEF_MD_FIELD_PADDING;
    CGFloat labelHeight  = widgetLabel.bounds.size.height;
    CGFloat labelYOffset = (DEF_LG_TABLE_CELL_HGT - labelHeight) / DEF_HGT_ALIGN_FACTOR;
    [widgetLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    [widgetLabel setFont:TEXT_LABEL_FONT];

    return widgetLabel;
}

- (void)showEmail {
    NSString *subject = SUBJECT;
    NSString *body    = BODY;
    NSArray *recipent = [NSArray arrayWithObject:RECIPIENT];
    
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:subject];
    [mailCompose setMessageBody:body isHTML:NO];
    [mailCompose setToRecipients:recipent];
    
    [self presentViewController:mailCompose animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Share documentation on Social Media and other venues
//
- (IBAction)share:(id)sender {
    [self presentViewController:_shareController animated:YES completion:nil];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods


// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *navigationViewController = [segue destinationViewController];

    // About Segue
    //
    if ([[segue identifier] isEqualToString:@"AboutSegue"]) {
        
        AboutViewController *aboutViewController = (AboutViewController *)([navigationViewController viewControllers][0]);
        
        [aboutViewController setShareController:_shareController];
    
    // Disclaimer Segue
    //
    } else {
        DisclaimerViewController *disclaimerViewController = (DisclaimerViewController *)([navigationViewController viewControllers][0]);
        
        [disclaimerViewController setShareController:_shareController];
    }
}


// Two exit points covered
// goBack (back arrow button) and
// goHome (home button)
//
- (IBAction)goBack:(id)sender {
    [self exitAction];
}

- (IBAction)goHome:(id)sender {
    [self exitAction];
}

// Check if a save is needed
//
- (void)exitAction {
    if (_editFlag == TRUE) {
        [self presentViewController:_noSaveAlert animated:YES completion:nil];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
