//
//  GlobalSettings.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/12/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "GlobalSettings.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"


CGFloat const DEF_X_OFFSET          = 0.0;
CGFloat const DEF_Y_OFFSET          = 0.0;
CGFloat const DEF_NIL_CELL          = 0.0;
CGFloat const DEF_NIL_HEADER        = 0.0;
CGFloat const DEF_NIL_WIDTH         = 0.0;
CGFloat const DEF_NIL_HEIGHT        = 0.0;
CGFloat const DEF_NIL_CONSTRAINT    = 0.0;
CGFloat const DEF_LABEL_WIDTH       = 80.0;

// Tap Area
//
CGFloat const DEF_TAP_AREA_SIZE     = 30.0;


// UI TextField/TextView
//
CGFloat const DEF_TEXTFIELD_HEIGHT  = 30.0;
CGFloat const DEF_SM_TXTFIELD_WIDTH = 60.0;
CGFloat const DEF_TEXTVIEW_HEIGHT   = 60.0;

CGFloat const DEF_LABEL_HEIGHT      = 24.0;

// Generic Defaults
//
CGFloat const DEF_FIELD_PADDING     = 5.0;
CGFloat const DEF_MD_FIELD_PADDING  = 10.0;
CGFloat const DEF_LG_FIELD_PADDING  = 15.0;
CGFloat const DEF_CORNER_RADIUS     = 5.0;
CGFloat const DEF_BORDER_WIDTH      = 1.0;
CGFloat const BORDER_WIDTH_NONE     = 0.0;
CGFloat const CORNER_RADIUS_NONE    = 0.0;

// UI Tables and Cells
//
CGFloat const DEF_TBL_HDR_Y_OFFSET  = 1.0;
CGFloat const DEF_TABLE_CELL_HEIGHT = 44.0;
CGFloat const DEF_SM_TABLE_CELL_HGT = 33.0;
CGFloat const DEF_MD_TABLE_CELL_HGT = 55.0;
CGFloat const DEF_XSM_TBL_HDR_HGT   = 11.0;
CGFloat const DEF_SM_TBL_HDR_HEIGHT = 22.0;
CGFloat const DEF_TBL_DIVIDER_HGT   = 5.0;
CGFloat const DEF_TABLE_HDR_HEIGHT  = 33.0;
CGFloat const DEF_LG_TABLE_CELL_HGT = 66.0;
CGFloat const DEF_VLG_TBL_CELL_HGT  = 88.0;
CGFloat const DEF_XLG_TBL_CELL_HGT  = 198.0;
CGFloat const DEF_XXLG_TBL_CELL_HGT = 396.0;
CGFloat const DEF_TABLE_X_OFFSET    = 15.0;
CGFloat const DEF_CELL_EDIT_DISPL   = 22.0;

CGFloat const DEF_PICKER_ROW_HEIGHT = 50.0;
CGFloat const DEF_PICKER_HEIGHT     = 250.0;
CGFloat const DEF_COLLECTVIEW_INSET = 20.0;

// UI Buttons
//
CGFloat const DEF_BUTTON_WIDTH      = 60.0;
CGFloat const DEF_BUTTON_HEIGHT     = 26.0;
CGFloat const HIDE_BUTTON_WIDTH     = 1.0;

// Match Button widths
//
CGFloat const DECR_BUTTON_WIDTH     = 20.0;
CGFloat const SHOW_BUTTON_WIDTH     = 20.0;


// Tags
//
int const DEF_TAG_NUM    = 200;

// UI Button Tags
//
int const IMAGELIB_BTN_TAG = 51;
int const PHOTO_BTN_TAG    = 52;
int const SEARCH_BTN_TAG   = 53;
int const LISTING_BTN_TAG  = 54;
int const RGB_BTN_TAG      = 55;

int const BACK_BTN_TAG     = 56;
int const EDIT_BTN_TAG     = 57;
int const SETTINGS_BTN_TAG = 58;
int const SAVE_BTN_TAG     = 59;
int const VIEW_BTN_TAG     = 60;
int const DONE_BTN_TAG     = 61;
int const HOME_BTN_TAG     = 62;

int const DECR_ALG_BTN_TAG = 71;
int const MATCH_BTN_TAG    = 72;
int const INCR_ALG_BTN_TAG = 73;
int const DECR_TAP_BTN_TAG = 74;
int const INCR_TAP_BTN_TAG = 75;

const int NAME_FIELD_TAG     = 81;
const int TYPE_FIELD_TAG     = 82;
const int COLOR_FIELD_TAG    = 83;
const int KEYW_FIELD_TAG     = 84;
const int DESC_FIELD_TAG     = 85;
const int SWATCH_PICKER_TAG  = 86;
const int COLOR_PICKER_TAG   = 87;
const int COLOR_BTN_TAG      = 88;
const int TYPE_BTN_TAG       = 89;
const int BRAND_FIELD_TAG    = 90;
const int BRAND_PICKER_TAG   = 91;
const int BRAND_BTN_TAG      = 92;
const int OTHER_FIELD_TAG    = 93;
const int BODY_FIELD_TAG     = 94;
const int BODY_PICKER_TAG    = 95;
const int BODY_BTN_TAG       = 96;
const int PIGMENT_FIELD_TAG  = 97;
const int PIGMENT_PICKER_TAG = 98;
const int PIGMENT_BTN_TAG    = 99;

// Settings
//
const int SHAPE_BUTTON_TAG   = 101;
const int MATCH_NUM_TAG      = 102;
const int ADD_BRANDS_TAG     = 103;

const int MAX_TAG            = 120;


// Maximum Text field lengths (characters)
//
const int MAX_NAME_LEN  = 64;
const int MAX_KEYW_LEN  = 128;
const int MAX_DESC_LEN  = 128;
const int MAX_BRAND_LEN = 32;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Keys
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
NSString * const PAINT_SWATCH_RO_KEY = @"SwatchesReadOnly";
NSString * const MIX_ASSOC_RO_KEY    = @"AssocReadOnly";
NSString * const TAP_AREA_SIZE_KEY   = @"TapAreaSize";
NSString * const SHAPE_GEOMETRY_KEY  = @"ShapeGeometry";
NSString * const MATCH_NUM_KEY       = @"MatchNum";
NSString * const RGB_DISPLAY_KEY     = @"RgbDisplay";
NSString * const ADD_BRANDS_KEY      = @"PaintBrand";

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Values
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
NSString * const SHAPE_CIRCLE_VALUE  = @"Circle";
NSString * const SHAPE_RECT_VALUE    = @"Rect";

// Tap Area Length
//
const int TAP_AREA_LENGTH = 32;

// Tap Area Stepper
//
const int TAP_STEPPER_MIN = 20;
const int TAP_STEPPER_MAX = 44;
const int TAP_STEPPER_INC = 4;

// Match Num Stepper
//
const int MATCH_STEPPER_MIN = 5;
const int MATCH_STEPPER_MAX = 100;
const int MATCH_STEPPER_INC = 5;
const int MATCH_STEPPER_DEF = 20;

// Max Match Num (i.e., UIImageViewController)
//
int const DEF_MAX_MATCH  = 100;
int const DEF_MATCH_NUM  = 20;
int const DEF_MIN_MATCH  = 5;
int const DEF_STEP_MATCH = 5;

// Tap Related
//
int const DEF_NUM_TAPS       = 1;
CGFloat const MIN_PRESS_DUR  = 1.0f;
CGFloat const ALLOWABLE_MOVE = 100.0f;

// Alert Types
//
NSString * const NO_VALUE         = @"No Value";
NSString * const NO_VALUE_MSG     = @"Please enter a value for this field.";

NSString * const NO_SAVE          = @"Not Saved";
NSString * const NO_SAVE_MSG      = @"Please save first.";

NSString * const SIZE_LIMIT       = @"Size Limit";
NSString * const SIZE_LIMIT_MSG   = @"Value entered has reached the size limit of %i for this field.";

NSString * const ROW_LIMIT        = @"Row Limit";
NSString * const ROW_LIMIT_MSG    = @"The maximum row limit of %i has been reached.";

NSString * const VALUE_EXISTS     = @"Value Exists";
NSString * const VALUE_EXISTS_MSG = @"Value already exists.";

// Core data/Store
//
NSString * const CURR_STORE = @"AcrylicsColorPicker v4.0.63.sqlite";
NSString * const PREV_STORE = @"AcrylicsColorPicker v4.0.63.sqlite";
int const MIGRATE_STORE = 0;


// NSManagedObject entities
//
NSString * const MATCH_ASSOCIATIONS = @"MatchAssociation";


// Missing MixName
//
NSString * const NO_MIX_NAME    = @"No Mix Name";


// Image Related
//
NSString * const DEF_IMAGE_NAME = @"Reference Image";


// Image Names
//
NSString * const PALETTE_IMAGE_NAME     = @"Artist Palette.png";
NSString * const RGB_IMAGE_NAME         = @"rgb.png";
NSString * const BACK_BUTTON_IMAGE_NAME = @"arrow.png";
NSString * const SEARCH_IMAGE_NAME      = @"search.png";
NSString * const ARROW_UP_IMAGE_NAME    = @"arrow up.png";
NSString * const ARROW_DOWN_IMAGE_NAME  = @"arrow down.png";

// Default listing type
//
NSString * const DEFAULT_LISTING_TYPE  = @"Default";


// Threshold brightness value under which a white border is drawn around the RGB image view
// (default border is black)
//
float const DEF_BORDER_THRESHOLD = 0.34;


@implementation GlobalSettings

#pragma mark - Init method

static NSDictionary *swatchTypes;

// Init called by the ViewController (App entry point)
//
+ (void)init {
    // Refresh the dictionary tables
    //
    [ManagedObjectUtils deleteDictionaryEntity:@"SubjectiveColor"];
    [ManagedObjectUtils insertSubjectiveColors];

    [ManagedObjectUtils deleteDictionaryEntity:@"PaintSwatchType"];
    [ManagedObjectUtils insertFromDataFile:@"PaintSwatchType"];

    [ManagedObjectUtils deleteDictionaryEntity:@"MatchAlgorithm"];
    [ManagedObjectUtils insertFromDataFile:@"MatchAlgorithm"];
    
    [ManagedObjectUtils deleteDictionaryEntity:@"PaintBrand"];
    [ManagedObjectUtils insertFromDataFile:@"PaintBrand"];
    
    [ManagedObjectUtils deleteDictionaryEntity:@"PigmentType"];
    [ManagedObjectUtils insertFromDataFile:@"PigmentType"];
    
    [ManagedObjectUtils deleteDictionaryEntity:@"BodyType"];
    [ManagedObjectUtils insertFromDataFile:@"BodyType"];


    // NSUserDefaults intialization
    //
    // isRGB settings
    //
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:RGB_DISPLAY_KEY];
}

@end
