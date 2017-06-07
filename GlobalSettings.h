//
//  GlobalSettings.h
//  RGButterfly
//
//  Created by Stuart Pineo on 4/12/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalSettings : NSObject

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ************************ IMPORTANT RELEASE SETTINGS ***********************************
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern int const VERSION_TAG;
extern int const ALL_FEATURES;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ************************ IMPORTANT UPGRADE SETTINGS ***********************************
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// App Version and Core data/Store
//
extern NSString * const APP_NAME;

// This value goes in the version.txt
//
extern NSString * const DB_VERSION_KEY;

extern NSString * const VERS_FILE;
extern NSString * const MD5SUM_EXT;

extern NSString * const CURR_STORE;
extern NSString * const PREV_STORE;
extern int const MIGRATE_STORE;

// Disable Write-Ahead Logging (by default this is enabled)
//
extern int const DISABLE_WAL;

extern NSString * const LOCAL_PATH;

// Upgrade the database from the local path copy or GitHub
//
extern int const FORCE_UPDATE_DB;

// DB Update Statuses (referenced in the Init VC)
//
extern int const NO_UPDATE;
extern int const FAILED_CHECK;
extern int const DO_UPDATE;

// Small screen threshold (i.e., < iPhone 6)
//
extern CGFloat const SMALL_SCREEN_THRESHOLD;

// Jenkins related
//
extern NSString * const AUTHTOKEN_FILE;
extern NSString * const DB_ROOT_URL;
extern NSString * const DB_REST_URL;

extern NSString * const DB_FILE;
extern NSString * const DB_CONT_TYPE;

extern NSString * const MD5_FILE;
extern NSString * const MD5_CONT_TYPE;

extern NSString * const VERSION_FILE;
extern NSString * const VER_CONT_TYPE;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Keywords
//
extern NSString * const KEYW_PROC_SEPARATOR;
extern NSString * const KEYW_DISP_SEPARATOR;
extern NSString * const KEYW_COMPS_SEPARATOR;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NIL constants
//
extern CGFloat const DEF_X_OFFSET;
extern CGFloat const DEF_Y_OFFSET;
extern CGFloat const DEF_NIL_CELL;
extern CGFloat const DEF_NIL_HEADER;
extern CGFloat const DEF_NIL_FOOTER;
extern CGFloat const DEF_NIL_WIDTH;
extern CGFloat const DEF_NIL_HEIGHT;
extern CGFloat const DEF_NIL_CONSTRAINT;
extern CGFloat const DEF_NIL_CORNER_RADIUS;

// MIN constants (i.e., tableview header instead of zero) which prevents default setting
//
extern CGFloat const DEF_MIN_HEADER;

// Widget alignment related
//
extern CGFloat const DEF_HGT_ALIGN_FACTOR;
extern CGFloat const DEF_CORNER_RAD_FACTOR;
extern CGFloat const DEF_X_OFFSET_DIVIDER;
extern CGFloat const DEF_Y_OFFSET_DIVIDER;
extern CGFloat const DEF_CIRCLE_OFFSET_DIV;

// Used for embedded labels
//
extern CGFloat const DEF_RECT_INSET;
extern CGFloat const DEF_X_COORD;
extern CGFloat const DEF_Y_COORD;
extern CGFloat const DEF_BOTTOM_OFFSET;

// UI Label
//
extern CGFloat const DEF_LABEL_WIDTH;
extern CGFloat const DEF_LABEL_HEIGHT;

// Tap Area
//
extern CGFloat const DEF_TAP_AREA_SIZE;

// UI TextField/TextView
//
extern CGFloat const DEF_TEXTFIELD_HEIGHT;
extern CGFloat const DEF_SM_TXTFIELD_WIDTH;
extern CGFloat const DEF_TEXTVIEW_HEIGHT;
extern CGFloat const DEF_SM_TEXTVIEW_HGT;
extern CGFloat const DEF_NAVBAR_X_OFFSET;

// Generic Defaults
//
extern CGFloat const DEF_FIELD_PADDING;
extern CGFloat const DEF_MD_FIELD_PADDING;
extern CGFloat const DEF_LG_FIELD_PADDING;
extern CGFloat const DEF_VLG_FIELD_PADDING;
extern CGFloat const DEF_XLG_FIELD_PADDING;

extern CGFloat const DEF_CORNER_RADIUS;
extern CGFloat const DEF_LG_CORNER_RADIUS;
extern CGFloat const DEF_BORDER_WIDTH;
extern CGFloat const BORDER_WIDTH_NONE;
extern CGFloat const CORNER_RADIUS_NONE;

extern CGFloat const DEF_TBL_HDR_Y_OFFSET;
extern CGFloat const DEF_TABLE_CELL_HEIGHT;
extern CGFloat const DEF_TBL_DIVIDER_HGT;
extern CGFloat const DEF_SM_TABLE_CELL_HGT;
extern CGFloat const DEF_MD_TABLE_CELL_HGT;

extern CGFloat const DEF_XSM_TBL_HDR_HGT;
extern CGFloat const DEF_SM_TBL_HDR_HEIGHT;
extern CGFloat const DEF_TABLE_HDR_HEIGHT;
extern CGFloat const DEF_LG_TABLE_HDR_HGT;
extern CGFloat const DEF_VLG_TABLE_HDR_HGT;
extern CGFloat const DEF_XLG_TABLE_HDR_HGT;

extern CGFloat const DEF_LG_TABLE_CELL_HGT;
extern CGFloat const DEF_XLG_TBL_CELL_HGT;
extern CGFloat const DEF_VLG_TBL_CELL_HGT;
extern CGFloat const DEF_XXLG_TBL_CELL_HGT;
extern CGFloat const DEF_TABLE_X_OFFSET;
extern CGFloat const DEF_CELL_EDIT_DISPL;

// UI PickerView
//
extern CGFloat const DEF_PICKER_ROW_HEIGHT;
extern CGFloat const DEF_PICKER_HEIGHT;
extern CGFloat const DEF_PICKER_WIDTH;

extern CGFloat const DEF_COLLECTVIEW_INSET;

// UIToolbar
//
extern CGFloat const DEF_TOOLBAR_HEIGHT;
extern CGFloat const DEF_TOOLBAR_WIDTH;

// Match Num (i.e., ImageViewController)
//
extern int const DEF_MAX_MATCH;
extern int const DEF_MATCH_NUM;
extern int const DEF_MIN_MATCH;
extern int const DEF_STEP_MATCH;

// Tap Related
//
extern int const DEF_NUM_TAPS;
extern CGFloat const MIN_PRESS_DUR;
extern CGFloat const ALLOWABLE_MOVE;
extern CGFloat const MIN_DRAG_DIFF;

// UI Button
//
extern CGFloat const DEF_SM_BUTTON_WIDTH;
extern CGFloat const DEF_BUTTON_WIDTH;
extern CGFloat const DEF_LG_BUTTON_WIDTH;
extern CGFloat const DEF_BUTTON_HEIGHT;
extern CGFloat const DEF_LG_BUTTON_HEIGHT;
extern CGFloat const HIDE_BUTTON_WIDTH;

// Match Button widths
//
extern CGFloat const DECR_BUTTON_WIDTH;
extern CGFloat const SHOW_BUTTON_WIDTH;

// Image Actions
//
extern int const TAKE_PHOTO_ACTION;
extern int const SELECT_PHOTO_ACTION;


// Tags
//
extern int const DEF_TAG_NUM;

// UI Button Tags
//
extern int const IMAGELIB_BTN_TAG;
extern int const PHOTO_BTN_TAG;
extern int const SEARCH_BTN_TAG;
extern int const LISTING_BTN_TAG;
extern int const RGB_BTN_TAG;

extern int const BACK_BTN_TAG;
extern int const EDIT_BTN_TAG;
extern int const SETTINGS_BTN_TAG;
extern int const SAVE_BTN_TAG;
extern int const VIEW_BTN_TAG;
extern int const DONE_BTN_TAG;
extern int const HOME_BTN_TAG;
extern int const SHARE_BTN_TAG;

extern int const DECR_ALG_BTN_TAG;
extern int const MATCH_BTN_TAG;
extern int const INCR_ALG_BTN_TAG;
extern int const DECR_TAP_BTN_TAG;
extern int const INCR_TAP_BTN_TAG;
extern int const ASSOC_BTN_TAG;
extern int const SEARCH_BAR_TAG;

extern int const NAME_FIELD_TAG;
extern int const TYPE_FIELD_TAG;
extern int const COLOR_FIELD_TAG;
extern int const KEYW_FIELD_TAG;
extern int const DESC_FIELD_TAG;
extern int const SWATCH_PICKER_TAG;
extern int const COLOR_PICKER_TAG;
extern int const COLOR_BTN_TAG;
extern int const TYPE_BTN_TAG;
extern int const BRAND_FIELD_TAG;
extern int const BRAND_PICKER_TAG;
extern int const BRAND_BTN_TAG;
extern int const OTHER_FIELD_TAG;
extern int const BODY_FIELD_TAG;
extern int const BODY_PICKER_TAG;
extern int const BODY_BTN_TAG;
extern int const PIGMENT_FIELD_TAG;
extern int const PIGMENT_PICKER_TAG;
extern int const PIGMENT_BTN_TAG;
extern int const RATIOS_PICKER_TAG;
extern int const COVERAGE_FIELD_TAG;
extern int const COVERAGE_PICKER_TAG;
extern int const FLEXIBLE_SPACE_TAG;
extern int const FIXED_SPACE_TAG;

// Views Tags
//
extern int const VIEW_TAG;
extern int const TABLEVIEW_TAG;
extern int const TABLEVIEW_CELL_TAG;
extern int const SCROLLVIEW_TAG;
extern int const IMAGEVIEW_TAG;

// Settings
//
extern int const SHAPE_BUTTON_TAG;
extern int const MATCH_NUM_TAG;
extern int const ADD_BRANDS_TAG;
extern int const MIX_RATIOS_TAG;
extern int const LIST_TYPE_FIELD_TAG;
extern int const LIST_TYPE_PICKER_TAG;

// Add Mix
//
extern int const CANCEL_BUTTON_TAG;

// Init Controller
//
extern int const INIT_LABEL_TAG;
extern int const INIT_SPINNER_TAG;


// Max Tag used as reference to ensure all table view elements
// removed from superview (see MatchTableViewController for example)
//
extern int const MAX_TAG;

// Maximum Text field lengths (characters)
//
extern int const MAX_NAME_LEN;
extern int const MAX_KEYW_LEN;
extern int const MAX_DESC_LEN;
extern int const MAX_BRAND_LEN;

// View Types
//
extern NSString * const MATCH_TYPE;
extern NSString * const MIX_TYPE;
extern NSString * const ASSOC_TYPE;

extern NSString * const MIX_LIST_TYPE;
extern NSString * const MATCH_LIST_TYPE;
extern NSString * const FULL_LISTING_TYPE;
extern NSString * const KEYWORDS_TYPE;
extern NSString * const COLORS_TYPE;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Keys
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern NSString * const DB_POLL_UPDATE_KEY;
extern NSString * const DB_FORCE_UPDATE_KEY;
extern NSString * const DB_RESTORE_KEY;
extern NSString * const PAINT_SWATCH_RO_KEY;
extern NSString * const MIX_ASSOC_RO_KEY;
extern NSString * const TAP_AREA_SIZE_KEY;
extern NSString * const SHAPE_GEOMETRY_KEY;
extern NSString * const MATCH_NUM_KEY;
extern NSString * const GEN_FILTER_KEY;
extern NSString * const COV_FILTER_KEY;
extern NSString * const RGB_DISPLAY_KEY;
extern NSString * const MIX_RATIOS_KEY;
extern NSString * const MIX_ASSOC_COUNT_KEY;
extern NSString * const ADD_BRANDS_KEY;
extern NSString * const LISTING_TYPE;

// Activity (i.e., spinner) label indicator
//
extern NSString * const SPINNER_LABEL_PROC;
extern NSString * const SPINNER_LABEL_LOAD;

// Alerts related
//
extern NSString * const ALERTS_FILTER_KEY;
extern NSString * const APP_INTRO_KEY;
extern NSString * const IMAGE_INTERACT_KEY;
extern NSString * const TAP_COLLECT_KEY;

// Alerts Instructions
//
extern NSString * const APP_INTRO_INSTRUCTIONS;
extern NSString * const INTERACT_INSTRUCTIONS;
extern NSString * const TAP_COLLECT_INSTRUCTIONS;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Values
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
extern NSString * const SHAPE_CIRCLE_VALUE;
extern NSString * const SHAPE_RECT_VALUE;

// Tap Area Length
//
extern const int TAP_AREA_LENGTH;

// Tap Area Stepper
//
extern const int TAP_STEPPER_MIN;
extern const int TAP_STEPPER_MAX;
extern const int TAP_STEPPER_INC;

// Match Num Stepper
//
extern const int MATCH_STEPPER_MIN;
extern const int MATCH_STEPPER_MAX;
extern const int MATCH_STEPPER_INC;
extern const int MATCH_STEPPER_DEF;


// Alert Types
//
extern NSString * const NO_VALUE;
extern NSString * const NO_VALUE_MSG;
extern NSString * const NO_SAVE;
extern NSString * const NO_SAVE_MSG;
extern NSString * const SIZE_LIMIT;
extern NSString * const SIZE_LIMIT_MSG;
extern NSString * const ROW_LIMIT;
extern NSString * const ROW_LIMIT_MSG;
extern NSString * const VALUE_EXISTS;
extern NSString * const VALUE_EXISTS_MSG;


// NSManagedObject
//
extern NSString * const MATCH_ASSOCIATIONS;

// Missing mix name
//
extern NSString * const NO_MIX_NAME;

// Image Related
//
extern NSString * const BACKGROUND_IMAGE_TITLE;
extern NSString * const BACKGROUND_IMAGE;
extern NSString * const DEF_IMAGE_NAME;
extern NSString * const IMAGE_LIB_NAME;
extern NSString * const PALETTE_IMAGE_NAME;
extern NSString * const RGB_IMAGE_NAME;
extern NSString * const BACK_BUTTON_IMAGE_NAME;
extern NSString * const SEARCH_IMAGE_NAME;
extern NSString * const ARROW_UP_IMAGE_NAME;
extern NSString * const ARROW_DOWN_IMAGE_NAME;
extern NSString * const EMPTY_SQ_IMAGE_NAME;
extern NSString * const CHECKBOX_SQ_IMAGE_NAME;

// Default listing type
//
extern NSString * const FULL_LISTING_TYPE;

// "About" section text
//
extern NSString * const ABOUT_TEXT;
extern NSString * const ABOUT_RELEASE_FEATURES;
extern NSString * const ABOUT_PAT;
extern NSString * const ABOUT_URL;

// Documentation Site
//
extern NSString * const DOCS_IMAGE;
extern NSString * const MAIN_IMAGE;
extern NSString * const DOCS_SYNOPSIS;
extern NSString * const DOCS_SITE_URL;
extern NSString * const MAIN_SITE_URL;
extern NSString * const DOCS_SITE_PAT;

// "Disclaimer" section text
//
extern NSString * const DISCLAIMER_TEXT;

// Feedback (Email)
//
extern NSString * const SUBJECT;
extern NSString * const BODY;
extern NSString * const RECIPIENT;

// Threshold brightness value under which a white border is drawn around the RGB image view
// (default border is black)
//
extern float const DEF_BORDER_THRESHOLD;


// List of CSV tables (map to the Core Data Entities)
//
#define ENTITY_LIST @[@"PaintSwatch", @"Keyword", @"SwatchKeyword", @"TapAreaSwatch", @"TapAreaKeyword", @"TapArea", @"MatchAssocKeyword", @"MatchAssociation", @"MixAssocSwatch", @"MixAssocKeyword", @"MixAssociation"]


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIColor related
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Borders and Table Separators
//
#define LIGHT_BORDER_COLOR [UIColor colorWithRed:235.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define GRAY_BORDER_COLOR  [UIColor grayColor]
#define DARK_BORDER_COLOR  [UIColor blackColor]

// Text and tints
//
#define LIGHT_TEXT_COLOR   [UIColor colorWithRed:235.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define GRAY_TEXT_COLOR    [UIColor grayColor]
#define DARK_TEXT_COLOR    [UIColor blackColor]

// View backgrounds
//
#define LIGHT_BG_COLOR     [UIColor colorWithRed:235.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define GRAY_BG_COLOR      [UIColor grayColor]
#define DARK_GRAY_BG_COLOR [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0]
#define DARK_BG_COLOR      [UIColor blackColor]

// Colors (across the board)
//
#define CLEAR_COLOR        [UIColor clearColor]
#define LIGHT_YELLOW_COLOR [UIColor colorWithRed:242.0/255.0 green:255.0/255.0 blue:224.0/255.0 alpha:1.0]
#define WIDGET_GREEN_COLOR [UIColor colorWithRed:83.0/255.0  green:215.0/255.0 blue:105.0/255.0 alpha:1.0]
#define WIDGET_RED_COLOR   [UIColor colorWithRed:252.0/255.0 green:61.0/255.0  blue:57.0/255.0 alpha:1.0]


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIFont related
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// UI Controller
//
#define TITLE_VIEW_FONT     [UIFont boldSystemFontOfSize:18]

// UITable cell font
//
#define TABLE_CELL_FONT     [UIFont systemFontOfSize:12]
#define LG_TABLE_CELL_FONT  [UIFont systemFontOfSize:14]
#define TABLE_HEADER_FONT   [UIFont boldSystemFontOfSize:14]

// UITextField and UITextView font
//
#define TEXT_LABEL_FONT     [UIFont systemFontOfSize:12]
#define TEXT_FIELD_FONT     [UIFont systemFontOfSize:12]
#define PLACEHOLDER_FONT    [UIFont italicSystemFontOfSize:12]
#define LG_TEXT_FIELD_FONT  [UIFont systemFontOfSize:14]
#define VLG_TEXT_FIELD_FONT [UIFont systemFontOfSize:16]

// Image Tap Areas
//
#define TAP_AREA_FONT       [UIFont systemFontOfSize:10]
#define LG_TAP_AREA_FONT    [UIFont systemFontOfSize:12]

// Generic
//
#define SMALL_FONT          [UIFont systemFontOfSize:10]
#define LARGE_BOLD_FONT     [UIFont boldSystemFontOfSize:14]
#define ITALIC_FONT         [UIFont italicSystemFontOfSize:12]
#define LARGE_ITALIC_FONT   [UIFont italicSystemFontOfSize:14]
#define VLARGE_ITALIC_FONT  [UIFont italicSystemFontOfSize:16]


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Entity independent properties
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+ (void)init;

@end
