//
//  SettingsTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/9/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import "SettingsTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "AlertUtils.h"
#import "BarButtonUtils.h"
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"
#import "ColorUtils.h"

@interface SettingsTableViewController ()

@property (nonatomic) CGFloat widgetHeight, widgetYOffset;
@property (nonatomic, strong) UILabel *psReadOnlyLabel, *maReadOnlyLabel, *tapSettingsLabel, *tapStepperLabel, *matchSettingsLabel, *matchStepperLabel, *rgbDisplayLabel, *mixRatiosLabel;
@property (nonatomic, strong) UISwitch *psReadOnlySwitch, *maReadOnlySwitch;
@property (nonatomic) BOOL editFlag, swatchesReadOnly, assocsReadOnly, rgbDisplayFlag;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *psReadOnlyText, *psMakeReadOnlyLabel, *psMakeReadWriteLabel, *maReadOnlyText, *maMakeReadOnlyLabel, *maMakeReadWriteLabel, *shapeGeom, *shapeTitle, *rgbDisplayTrueText, *rgbDisplayText, *rgbDisplayFalseText, *rgbDisplayImage, *rgbDisplayTrueImage, *rgbDisplayFalseImage, *addBrandsText, *mixRatiosText;
@property (nonatomic) CGFloat tapAreaSize;
@property (nonatomic, strong) UIImageView *tapImageView;
@property (nonatomic, strong) UIStepper *tapAreaStepper, *matchNumStepper;
@property (nonatomic, strong) UIButton *shapeButton, *rgbDisplayButton;
@property (nonatomic, strong) UITextField *matchNumTextField, *addBrandsTextField, *mixRatiosTextField;
@property (nonatomic, strong) UITextView *mixRatiosTextView;
@property (nonatomic, strong) UIAlertController *noSaveAlert;
@property (nonatomic) int maxMatchNum;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// NSManagedObject
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation SettingsTableViewController


// Section 1: READ-ONLY Settings
//
const int READ_ONLY_SETTINGS      = 0;
const int PSWATCH_READ_ONLY_ROW   = 0;
const int MIXASSOC_READ_ONLY_ROW  = 1;
const int READ_ONLY_SETTINGS_ROWS = 2;

const int TAP_AREA_SETTINGS       = 1;
const int TAP_AREA_ROWS           = 1;

const int MATCH_NUM_SETTINGS      = 2;
const int MATCH_NUM_ROWS          = 1;

const int RGB_DISPLAY_SETTINGS    = 3;
const int RGB_DISPLAY_ROWS        = 1;

const int MIX_RATIOS_SETTINGS     = 4;
const int MIX_RATIOS_ROWS         = 1;

const int ADD_BRANDS_SETTINGS     = 5;
const int ADD_BRANDS_ROWS         = 1;

const int SETTINGS_MAX_SECTIONS   = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ColorUtils setNavBarGlaze:self.navigationController.navigationBar];
    
    _editFlag = FALSE;
    _reuseCellIdentifier = @"SettingsTableCell";
    
    // NSUserDefaults
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // NSManagedObject
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context  = [self.appDelegate managedObjectContext];


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Swatches Read-Only Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _psReadOnlyText = @"swatches_read_only_text";
    
    _psMakeReadOnlyLabel  = @"Paint Swatches set to Read-Only";
    _psMakeReadWriteLabel = @"Paint Swatches set to Read/Write";
    
    NSString *labelText;
    if(! ([_userDefaults boolForKey:PAINT_SWATCH_RO_KEY] &&
          [_userDefaults stringForKey:_psReadOnlyText])
       ) {
        _swatchesReadOnly = FALSE;
        labelText = _psMakeReadWriteLabel;
        
        [_userDefaults setBool:_swatchesReadOnly forKey:PAINT_SWATCH_RO_KEY];
        [_userDefaults setValue:labelText forKey:_psReadOnlyText];
        
    } else {
        _swatchesReadOnly = [_userDefaults boolForKey:PAINT_SWATCH_RO_KEY];
        labelText = [_userDefaults stringForKey:_psReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _psReadOnlySwitch = [[UISwitch alloc] init];
    _widgetHeight = _psReadOnlySwitch.bounds.size.height;
    _widgetYOffset = (DEF_TABLE_CELL_HEIGHT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_psReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_psReadOnlySwitch setOn:_swatchesReadOnly];
    
    // Add the switch target
    //
    [_psReadOnlySwitch addTarget:self action:@selector(setPSSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _psReadOnlyLabel   = [FieldUtils createLabel:labelText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    CGFloat labelWidth = _psReadOnlyLabel.bounds.size.width;
    CGFloat labelHeight = _psReadOnlyLabel.bounds.size.height;
    CGFloat labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / DEF_HGT_ALIGN_FACTOR;
    [_psReadOnlyLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // MixAssociation Read-Only Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _maReadOnlyText = @"assoc_read_only_text";
    
    _maMakeReadOnlyLabel  = @"Mix Associations set to Read-Only";
    _maMakeReadWriteLabel = @"Mix Associations set to Read/Write";
    
    labelText = @"";
    if(! ([_userDefaults boolForKey:MIX_ASSOC_RO_KEY] &&
          [_userDefaults stringForKey:_maReadOnlyText])
       ) {
        _assocsReadOnly = FALSE;
        labelText = _maMakeReadWriteLabel;
        
        [_userDefaults setBool:_assocsReadOnly forKey:MIX_ASSOC_RO_KEY];
        [_userDefaults setValue:labelText forKey:_maReadOnlyText];
        
    } else {
        _assocsReadOnly = [_userDefaults boolForKey:MIX_ASSOC_RO_KEY];
        labelText = [_userDefaults stringForKey:_maReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _maReadOnlySwitch = [[UISwitch alloc] init];
    _widgetHeight = _maReadOnlySwitch.bounds.size.height;
    _widgetYOffset = (DEF_TABLE_CELL_HEIGHT - _widgetHeight) / DEF_HGT_ALIGN_FACTOR;
    [_maReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _widgetYOffset, DEF_BUTTON_WIDTH, _widgetHeight)];
    [_maReadOnlySwitch setOn:_assocsReadOnly];
    
    // Add the switch target
    //
    [_maReadOnlySwitch addTarget:self action:@selector(setMASwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _maReadOnlyLabel   = [FieldUtils createLabel:labelText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    labelWidth = _maReadOnlyLabel.bounds.size.width;
    labelHeight = _maReadOnlyLabel.bounds.size.height;
    labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / DEF_HGT_ALIGN_FACTOR;
    [_maReadOnlyLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tap Area Widgets
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    _tapSettingsLabel = [FieldUtils createLabel:@"Change the Size/Shape of the Tap Area"];
    
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
    
    _shapeButton = [BarButtonUtils create3DButton:_shapeTitle tag:SHAPE_BUTTON_TAG];
    [_shapeButton addTarget:self action:@selector(changeShape) forControlEvents:UIControlEventTouchUpInside];
    
    // Label displaying the value in the stepper
    //
    int size = (int)_tapAreaSize;
    _tapStepperLabel = [FieldUtils createLabel:[[NSString alloc] initWithFormat:@"%i", size]];
    [_tapStepperLabel setTextColor:DARK_TEXT_COLOR];
    [_tapStepperLabel setBackgroundColor:CLEAR_COLOR];
    [_tapStepperLabel setTextAlignment:NSTextAlignmentCenter];

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Match Num Widgets
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _matchSettingsLabel = [FieldUtils createLabel:@"Change the Default Number of Tap Area matches"];
    
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

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // RGB Display Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _rgbDisplayTrueText  = @"Swatches Display RGB Values";
    _rgbDisplayFalseText = @"Swatches Display Paint Image";
    
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
    
    CGFloat cellHeight   = DEF_TABLE_CELL_HEIGHT;
    CGFloat buttonHeight = cellHeight - DEF_FIELD_PADDING;
    CGFloat yOffset      = (cellHeight - buttonHeight) / DEF_HGT_ALIGN_FACTOR;
    [_rgbDisplayButton setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, buttonHeight, buttonHeight)];

    // Add the UIButton target
    //
    [_rgbDisplayButton addTarget:self action:@selector(setRGBDisplayState) forControlEvents:UIControlEventTouchUpInside];
    
    _rgbDisplayLabel   = [FieldUtils createLabel:_rgbDisplayText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    labelWidth = _rgbDisplayLabel.bounds.size.width;
    labelHeight = _rgbDisplayLabel.bounds.size.height;
    labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / DEF_HGT_ALIGN_FACTOR;
    [_rgbDisplayLabel  setFrame:CGRectMake(cellHeight + DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING, labelYOffset, labelWidth, labelHeight)];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // New Brands Settings
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//    _addBrandsTextField = [FieldUtils createTextField:@"" tag:ADD_BRANDS_TAG];
//    [_addBrandsTextField setAutoresizingMask:NO];
//    [_addBrandsTextField setKeyboardType:UIKeyboardTypeDefault];
//    [_addBrandsTextField setDelegate:self];
//    
//    _addBrandsText = [_userDefaults stringForKey:ADD_BRANDS_KEY];
//    
//    // Add a place holder if no text
//    //
//    if (! [_addBrandsText isEqualToString:@""] && (_addBrandsText != nil)) {
//        [_addBrandsTextField setText:_addBrandsText];
//    } else {
//        [_addBrandsTextField setPlaceholder:@" -- Additional Comma-Separated Paint Brands --"];
//    }
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Mix Ratios Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _mixRatiosLabel = [FieldUtils createLabel:@"Comma-separated ratios, separate line per group"];
    
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
    
    [_noSaveAlert addAction:YesButton];
    [_noSaveAlert addAction:NoButton];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SETTINGS_MAX_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == READ_ONLY_SETTINGS) {
        return READ_ONLY_SETTINGS_ROWS;
        
    } else if (section == TAP_AREA_SETTINGS) {
        return TAP_AREA_ROWS;
        
    } else if (section == MATCH_NUM_SETTINGS) {
        return MATCH_NUM_ROWS;
        
    } else if (section == RGB_DISPLAY_SETTINGS) {
        return RGB_DISPLAY_ROWS;
        
    } else if (section == ADD_BRANDS_SETTINGS) {
        return ADD_BRANDS_ROWS;
        
    } else if (section == MIX_RATIOS_SETTINGS) {
        return MIX_RATIOS_ROWS;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == MIX_RATIOS_SETTINGS) {
        return DEF_XLG_TBL_CELL_HGT;
        
    } else if (indexPath.section == TAP_AREA_SETTINGS) {
        return DEF_VLG_TBL_CELL_HGT;
        
    } else if (indexPath.section == MATCH_NUM_SETTINGS) {
        return DEF_LG_TABLE_CELL_HGT;
        
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DEF_SM_TBL_HDR_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    if (section == READ_ONLY_SETTINGS) {
        headerStr = @"Read-Only";
        
    } else if (section == TAP_AREA_SETTINGS) {
        headerStr = @"Tap Area";
        
    } else if (section == MATCH_NUM_SETTINGS) {
        headerStr = @"Match Number";
        
    } else if (section == RGB_DISPLAY_SETTINGS) {
        headerStr = @"RGB Display";
        
    } else if (section == ADD_BRANDS_SETTINGS) {
        headerStr = @"Add Paint Brands";
        
    } else if (section == MIX_RATIOS_SETTINGS) {
        headerStr = @"Default Paint Mix Ratios";
    }
    return headerStr;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor:DARK_BG_COLOR];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];
    [cell.textLabel setFont:TABLE_CELL_FONT];
    [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
    [cell.imageView setImage:nil];
    [cell.textLabel setText:@""];
    
    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    
    if (indexPath.section == READ_ONLY_SETTINGS) {
    
        // Name, and reference type
        //
        if (indexPath.row == PSWATCH_READ_ONLY_ROW) {
            [cell.contentView addSubview:_psReadOnlySwitch];
            [cell.contentView addSubview:_psReadOnlyLabel];
            
        } else if (indexPath.row == MIXASSOC_READ_ONLY_ROW) {
            [cell.contentView addSubview:_maReadOnlySwitch];
            [cell.contentView addSubview:_maReadOnlyLabel];
        }
        
    } else if (indexPath.section == TAP_AREA_SETTINGS) {
        [_tapSettingsLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET, tableViewWidth, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_tapSettingsLabel];

        CGFloat yOffset = _tapSettingsLabel.bounds.size.height + DEF_FIELD_PADDING;
        [_tapAreaStepper setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT)];
        [cell.contentView addSubview:_tapAreaStepper];
        
        CGFloat shapeXOffset = DEF_TABLE_X_OFFSET + _tapAreaStepper.bounds.size.width + DEF_LG_FIELD_PADDING;
        [_shapeButton setFrame:CGRectMake(shapeXOffset, yOffset, DEF_BUTTON_WIDTH, _tapAreaStepper.bounds.size.height)];
        [_shapeButton setBackgroundColor:LIGHT_BG_COLOR];
        [cell.contentView addSubview:_shapeButton];
        
        CGFloat imageViewXOffset = shapeXOffset + _shapeButton.bounds.size.width + DEF_LG_FIELD_PADDING;
        [_tapImageView setFrame:CGRectMake(imageViewXOffset, yOffset, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_tapImageView];
        
        [_tapStepperLabel setFrame:CGRectMake(imageViewXOffset, yOffset, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_tapStepperLabel];
        
        
    } else if (indexPath.section == MATCH_NUM_SETTINGS) {
        [_matchSettingsLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET, tableViewWidth, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_matchSettingsLabel];
        
        CGFloat yOffset = _matchSettingsLabel.bounds.size.height + DEF_FIELD_PADDING;
        [_matchNumStepper setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT)];
        [cell.contentView addSubview:_matchNumStepper];
        
        CGFloat shapeXOffset = DEF_TABLE_X_OFFSET + _matchNumStepper.bounds.size.width + DEF_LG_FIELD_PADDING;
        [_matchNumTextField setFrame:CGRectMake(shapeXOffset, yOffset, DEF_BUTTON_WIDTH, _matchNumStepper.bounds.size.height)];
        [cell.contentView addSubview:_matchNumTextField];
        
    } else if (indexPath.section == RGB_DISPLAY_SETTINGS) {
        [cell.contentView addSubview:_rgbDisplayButton];
        [cell.contentView addSubview:_rgbDisplayLabel];
        
    } else if (indexPath.section == ADD_BRANDS_SETTINGS) {
        CGFloat yOffset = (cell.bounds.size.height - DEF_TEXTFIELD_HEIGHT) / DEF_HGT_ALIGN_FACTOR;
        CGFloat width   = cell.bounds.size.width - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;
        [_addBrandsTextField setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, width, DEF_TEXTFIELD_HEIGHT)];
        [cell.contentView addSubview:_addBrandsTextField];
        
    } else if (indexPath.section == MIX_RATIOS_SETTINGS) {
        [_mixRatiosLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET, tableViewWidth, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_mixRatiosLabel];
        
        CGFloat yOffset = _mixRatiosLabel.bounds.size.height + DEF_FIELD_PADDING;
        CGFloat width   = cell.bounds.size.width - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;
        [_mixRatiosTextView setFrame:CGRectMake(DEF_TABLE_X_OFFSET, yOffset, width, DEF_TEXTVIEW_HEIGHT)];
        [cell.contentView addSubview:_mixRatiosTextView];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
        
    } else if (textField.tag == ADD_BRANDS_TAG) {
        _addBrandsText = textField.text;
        
    }
    
    _editFlag = TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _mixRatiosText = [GenericUtils removeSpaces:textView.text];
}

-(BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Widget States and Save
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Widget States and Save

-(void)doneWithNumberPad {
    [_matchNumTextField resignFirstResponder];
}

-(void)doneWithTextView {
    [_mixRatiosTextView resignFirstResponder];
}

- (void)setPSSwitchState:(id)sender {
    _swatchesReadOnly = [sender isOn];

    if (_swatchesReadOnly == TRUE) {
        [_psReadOnlyLabel setText:_psMakeReadOnlyLabel];
        
    } else {
        [_psReadOnlyLabel setText:_psMakeReadWriteLabel];
    }
    _editFlag = TRUE;
}

- (void)setMASwitchState:(id)sender {
    _assocsReadOnly = [sender isOn];
    
    if (_assocsReadOnly == TRUE) {
        [_maReadOnlyLabel setText:_maMakeReadOnlyLabel];
        
    } else {
        [_maReadOnlyLabel setText:_maMakeReadWriteLabel];
    }
    _editFlag = TRUE;
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
    
    _editFlag = TRUE;
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
    
    _editFlag = TRUE;
}

- (void)matchNumStepperPressed {
    _maxMatchNum = (int)[_matchNumStepper value];
    
    [_matchNumTextField setText:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum]];
    
    _editFlag = TRUE;
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
    
    _editFlag = TRUE;
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
            
            // Match Num Stepper Settings
            //
            [_userDefaults setInteger:_maxMatchNum forKey:MATCH_NUM_KEY];
            
            // isRGB settings
            //
            [_userDefaults setBool:_rgbDisplayFlag forKey:RGB_DISPLAY_KEY];
            
            // Add Brands
            //
            [_userDefaults setValue:_addBrandsText forKey:ADD_BRANDS_KEY];
            
            // Paint Mix Ratios
            //
            [_userDefaults setValue:_mixRatiosText forKey:MIX_RATIOS_KEY];
            
            [_userDefaults synchronize];
            
            _editFlag = FALSE;
        }
        
    } else {
        [self presentViewController:[AlertUtils createOkAlert:@"Mix Ratios Incorrectly Formatted" message:@"Mix ratios must be colon-delimited, each pair comma-separated, and no blank lines"] animated:YES completion:nil];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Validation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Validation

- (BOOL)areValidRatios:(NSString *)ratiosText {
    
    NSArray *groupList  = [ratiosText componentsSeparatedByString:@"\n"];
    NSCharacterSet *fullSetOfChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,:"];
    for (NSString *group in groupList) {
        
        // Check that no empty string were added
        //
        if ([group isEqualToString:@""]) {
            return FALSE;
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation


/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBack:(id)sender {
    
    // Leaving without saving?
    //
    if (_editFlag == TRUE) {
        [self presentViewController:_noSaveAlert animated:YES completion:nil];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
