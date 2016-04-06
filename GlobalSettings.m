//
//  GlobalSettings.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/12/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "GlobalSettings.h"
#import "CoreDataUtils.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"


CGFloat const DEF_X_OFFSET          = 0.0;
CGFloat const DEF_Y_OFFSET          = 0.0;
CGFloat const DEF_NIL_CELL          = 0.0;
CGFloat const DEF_NIL_HEADER        = 0.0;
CGFloat const DEF_NIL_WIDTH         = 0.0;
CGFloat const DEF_NIL_HEIGHT        = 0.0;
CGFloat const DEF_LABEL_WIDTH       = 80.0;

// UI TextField/TextView
//
CGFloat const DEF_TEXTFIELD_HEIGHT  = 30.0;
CGFloat const DEF_SM_TXTFIELD_WIDTH = 60.0;
CGFloat const DEF_TEXTVIEW_HEIGHT   = 60.0;

CGFloat const DEF_LABEL_HEIGHT      = 24.0;

// Generic Defaults
//
CGFloat const DEF_FIELD_PADDING     = 5.0;
CGFloat const DEF_CORNER_RADIUS     = 5.0;
CGFloat const DEF_BORDER_WIDTH      = 1.0;
CGFloat const BORDER_WIDTH_NONE     = 0.0;
CGFloat const CORNER_RADIUS_NONE    = 0.0;

// UI Tables and Cells
//
CGFloat const DEF_TABLE_CELL_HEIGHT = 44.0;
CGFloat const DEF_SM_TABLE_CELL_HGT = 33.0;
CGFloat const DEF_MD_TABLE_CELL_HGT = 55.0;
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
CGFloat const DEF_PICKER_HEIGHT     = 300.0;
CGFloat const DEF_COLLECTVIEW_INSET = 20.0;

// UI Buttons
//
CGFloat const DEF_BUTTON_WIDTH      = 60.0;
CGFloat const DEF_BUTTON_HEIGHT     = 26.0;
CGFloat const HIDE_BUTTON_WIDTH     = 1.0;

// Max Match Num (i.e., UIImageViewController)
//
int const DEF_MAX_MATCH  = 100;
int const DEF_MATCH_NUM  = 20;
int const DEF_MIN_MATCH  = 5;
int const DEF_STEP_MATCH = 5;

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

const int NAME_FIELD_TAG    = 81;
const int TYPE_FIELD_TAG    = 82;
const int COLOR_FIELD_TAG   = 83;
const int KEYW_FIELD_TAG    = 84;
const int DESC_FIELD_TAG    = 85;
const int SWATCH_PICKER_TAG = 86;
const int COLOR_PICKER_TAG  = 87;
const int COLOR_BTN_TAG     = 88;
const int TYPE_BTN_TAG      = 89;

const int MAX_TAG           = 100;


// Maximum Text field lengths (characters)
//
const int MAX_NAME_LEN = 64;
const int MAX_KEYW_LEN = 128;
const int MAX_DESC_LEN = 128;


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
NSString * const CURR_STORE = @"AcrylicsColorPicker v4.0.61.sqlite";
NSString * const PREV_STORE = @"AcrylicsColorPicker v4.0.61.sqlite";
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
    int count = [ManagedObjectUtils fetchCount:@"GlobalSetting"];
    
    if (count == 0) {
        [CoreDataUtils initGlobalSettings];
    }
    
    count = [ManagedObjectUtils fetchCount:@"SubjectiveColor"];
    if (count == 0) {
        [ManagedObjectUtils insertSubjectiveColors];
    }
    
    count = [ManagedObjectUtils fetchCount:@"PaintSwatchType"];
    if (count == 0) {
        [ManagedObjectUtils insertPaintSwatchTypes];
    }

    count = [ManagedObjectUtils fetchCount:@"MatchAlgorithm"];
    if (count == 0) {
        [ManagedObjectUtils insertMatchAlgorithms];
    }
}

#pragma mark - Swatch Dictionaries and Arrays

+ (NSDictionary *)getSwatchIds {
    return @{
        @"unknown"      : @"0",
        @"reference"    : @"1",
        @"mixassoc"     : @"2",
        @"matchassoc"   : @"3",
        @"derived"      : @"4",
    };
}

+ (NSArray *)getSwatchTypes {
    return @[
        @"Unknown",
        @"Reference",
        @"MixAssoc",
        @"MatchAssoc",
        @"Derived",
    ];
}

+ (int)getSwatchId:(NSString *)key {
    return [[[self getSwatchIds] valueForKey:[key lowercaseString]] intValue];
}

+ (NSString *)getSwatchType:(int)typeId {
    return [[self getSwatchTypes] objectAtIndex:typeId];
}

+ (NSString *)paletteImageName {
    return @"Artist Palette.png";
}

+ (NSString *)rgbImageName {
    return @"rgb.png";
}

+ (NSString *)backButtonImageName {
    return @"arrow.png";
}

+ (NSString *)tapMeImageName {
    return @"question.png";
}

+ (NSString *)searchImageName {
    return @"search.png";
}

+ (NSString *)arrowUpImageName {
    return @"arrow up.png";
}

+ (NSString *)arrowDownImageName {
    return @"arrow down.png";
}

+ (NSString *)getDefaultListingType {
    return @"Default";
}

// Image Names
//
+ (NSDictionary *)getImageNames {
    return @{
        @"colorwheel" : @"colorwheel.png",
    };
}


// Subjective Color Picker View Data
// Keys are the color names and values
// are hex values
//
+ (NSDictionary *)getSubjColorData {
    return @{
        @"Black"         : @{ @"hex" : @"#000000",
                              @"id"  : @"20",
                              },
        @"Blue"          : @{ @"hex" : @"#0000FF",
                              @"id"  : @"13",
                              },
        @"Blue Green"    : @{ @"hex" : @"#00FFCC",
                              @"id"  : @"12",
                              },
        @"Blue Violet"   : @{ @"hex" : @"#6600FF",
                              @"id"  : @"14",
                              },
        @"Brown"         : @{ @"hex" : @"#663300",
                              @"id"  : @"6",
                              },
        @"Copper"        : @{ @"hex" : @"#C87533",
                              @"id"  : @"5",
                              },
        @"Gold"          : @{ @"hex" : @"#FFD700",
                              @"id"  : @"8",
                              },
        @"Green"         : @{ @"hex" : @"#339900",
                              @"id"  : @"11",
                              },
        @"Grey"          : @{ @"hex" : @"#D3D3D3",
                              @"id"  : @"19",
                              },
        @"Orange"        : @{ @"hex" : @"#FF6600",
                              @"id"  : @"4",
                              },
        @"Pink"          : @{ @"hex" : @"#FFC0CB",
                              @"id"  : @"1",
                              },
        @"Red"           : @{ @"hex" : @"#FF0000",
                              @"id"  : @"2",
                              },
        @"Red Orange"    : @{ @"hex" : @"#FF3300",
                              @"id"  : @"3",
                              },
        @"Red Violet"    : @{ @"hex" : @"#FF00FF",
                              @"id"  : @"16",
                              },
        @"Silver"        : @{ @"hex" : @"#C0C0C0",
                              @"id"  : @"18",
                              },
        @"Violet"        : @{ @"hex" : @"#9900FF",
                              @"id"  : @"15",
                              },
        @"White"         : @{ @"hex" : @"#FFFFFF",
                              @"id"  : @"17",
                              },
        @"Yellow"        : @{ @"hex" : @"#FFFF00",
                              @"id"  : @"9",
                              },
        @"Yellow Green"  : @{ @"hex" : @"#CCFF00",
                              @"id"  : @"10",
                              },
        @"Yellow Orange" : @{ @"hex" : @"#FFCC00",
                              @"id"  : @"7",
                              },
        @"Other"         : @{ @"hex" : @"#FFFFFF",
                              @"id"  : @"0",
                              },
        
    };
}

+ (int)getSubjColorId:(NSString *)key {
    return [[[[self getSubjColorData] objectForKey:key] valueForKey:@"id"] intValue];
}

+ (NSArray *)getColorWheel {
    return @[
      @"Other",
      @"Pink",
      @"Red",
      @"Red Orange",
      @"Orange",
      @"Copper",
      @"Brown",
      @"Yellow Orange",
      @"Gold",
      @"Yellow",
      @"Yellow Green",
      @"Green",
      @"Blue Green",
      @"Blue",
      @"Blue Violet",
      @"Violet",
      @"Red Violet",
      @"White",
      @"Silver",
      @"Grey",
      @"Black",
    ];
}

+ (NSString *)getColorName:(int)subjColorId {
    return [[self getColorWheel] objectAtIndex:subjColorId];
}

@end
