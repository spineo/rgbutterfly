//
//  GlobalSettings.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/12/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalSettings : NSObject


// TableView Constants
//
extern CGFloat const DEF_X_OFFSET;
extern CGFloat const DEF_Y_OFFSET;
extern CGFloat const DEF_NIL_CELL;
extern CGFloat const DEF_NIL_HEADER;
extern CGFloat const DEF_NIL_FOOTER;
extern CGFloat const DEF_NIL_WIDTH;
extern CGFloat const DEF_NIL_HEIGHT;
extern CGFloat const DEF_NIL_CONSTRAINT;

// Widget alignment related
//
extern CGFloat const DEF_HGT_ALIGN_FACTOR;
extern CGFloat const DEF_CORNER_RAD_FACTOR;

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
extern CGFloat const DEF_NAVBAR_X_OFFSET;

// Generic Defaults
//
extern CGFloat const DEF_FIELD_PADDING;
extern CGFloat const DEF_MD_FIELD_PADDING;
extern CGFloat const DEF_LG_FIELD_PADDING;
extern CGFloat const DEF_VLG_FIELD_PADDING;

extern CGFloat const DEF_CORNER_RADIUS;
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

// Match Num (i.e., UIImageViewController)
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

// UI Button
//
extern CGFloat const DEF_BUTTON_WIDTH;
extern CGFloat const DEF_BUTTON_HEIGHT;
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

extern int const DECR_ALG_BTN_TAG;
extern int const MATCH_BTN_TAG;
extern int const INCR_ALG_BTN_TAG;
extern int const DECR_TAP_BTN_TAG;
extern int const INCR_TAP_BTN_TAG;
extern int const ASSOC_BTN_TAG;

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

// Settings
//
extern int const SHAPE_BUTTON_TAG;
extern int const MATCH_NUM_TAG;
extern int const ADD_BRANDS_TAG;
extern int const MIX_RATIOS_TAG;

// Add Mix
//
extern int const CANCEL_BUTTON_TAG;

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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Keys
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern NSString * const PAINT_SWATCH_RO_KEY;
extern NSString * const MIX_ASSOC_RO_KEY;
extern NSString * const TAP_AREA_SIZE_KEY;
extern NSString * const SHAPE_GEOMETRY_KEY;
extern NSString * const MATCH_NUM_KEY;
extern NSString * const RGB_DISPLAY_KEY;
extern NSString * const ADD_BRANDS_KEY;
extern NSString * const MIX_RATIOS_KEY;
extern NSString * const ADD_MIX_FILTER_KEY;

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

// Core Data/Store
//
extern NSString * const CURR_STORE;
extern NSString * const PREV_STORE;
extern int const MIGRATE_STORE;

// NSManagedObject
//
extern NSString * const MATCH_ASSOCIATIONS;

// Missing mix name
//
extern NSString * const NO_MIX_NAME;

// Image Related
//
extern NSString * const DEF_IMAGE_NAME;

extern NSString * const IMAGE_LIB_NAME;
extern NSString * const PALETTE_IMAGE_NAME;
extern NSString * const RGB_IMAGE_NAME;
extern NSString * const BACK_BUTTON_IMAGE_NAME;
extern NSString * const SEARCH_IMAGE_NAME;
extern NSString * const ARROW_UP_IMAGE_NAME;
extern NSString * const ARROW_DOWN_IMAGE_NAME;

// Default listing type
//
extern NSString * const DEFAULT_LISTING_TYPE;


// Threshold brightness value under which a white border is drawn around the RGB image view
// (default border is black)
//
extern float const DEF_BORDER_THRESHOLD;

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
#define DARK_BG_COLOR      [UIColor blackColor]

// Colors (across the board)
//
#define CLEAR_COLOR        [UIColor clearColor]
#define LIGHT_YELLOW_COLOR [UIColor colorWithRed:242.0/255.0 green:255.0/255.0 blue:224.0/255.0 alpha:1.0]


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIFont related
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// UI Controller
//
#define TITLE_VIEW_FONT    [UIFont boldSystemFontOfSize:18]

// UITable cell font
//
#define TABLE_CELL_FONT    [UIFont systemFontOfSize:12]
#define TABLE_HEADER_FONT  [UIFont boldSystemFontOfSize:14]

// UITextField and UITextView font
//
#define TEXT_LABEL_FONT    [UIFont systemFontOfSize:12]
#define TEXT_FIELD_FONT    [UIFont systemFontOfSize:12]
#define PLACEHOLDER_FONT   [UIFont italicSystemFontOfSize:12]

// Image Tap Areas
//
#define TAP_AREA_FONT      [UIFont systemFontOfSize:10]

// Generic
//
#define SMALL_FONT         [UIFont systemFontOfSize:10]
#define LARGE_BOLD_FONT    [UIFont boldSystemFontOfSize:14]
#define ITALIC_FONT        [UIFont italicSystemFontOfSize:12]


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Entity independent properties
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+ (void)init;

@end
