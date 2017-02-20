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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ************************ IMPORTANT UPGRADE SETTINGS ***********************************
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSString * const APP_NAME       = @"AcrylicsColorPicker";
int const VERSION_TAG           = 1;

// Key references the value stored in NSUserDefaults
//
NSString * const DB_VERSION_KEY = @"DB_VERSION";

NSString * const MD5SUM_EXT     = @"md5";

NSString * const CURR_STORE     = @"AcrylicsColorPicker v4.0.63.sqlite";
NSString * const PREV_STORE     = @"AcrylicsColorPicker v4.0.63.sqlite";
int const MIGRATE_STORE         = 0;

// Disable Write-Ahead Logging (by default this is enabled)
//
int const DISABLE_WAL           = 1;

NSString * const LOCAL_PATH = @"/Users/stuartpineo/AppDevelopment/AcrylicsColorPicker";

// Upgrade the database from the local path copy or GitHub
//
int const FORCE_UPDATE_DB      = 0;

// GitHub related
//
NSString * const AUTHTOKEN_FILE = @"Authtoken";
NSString * const DB_REST_URL    = @"http://34.195.217.113:8080/job/ArchiveLatestDBUpdate/ws/databases/AcrylicsColorPicker";

NSString * const DB_FILE        = @"AcrylicsColorPicker v4.0.63.sqlite";
NSString * const DB_CONT_TYPE   = @"application/x-sqlite3";

NSString * const MD5_FILE       = @"AcrylicsColorPicker v4.0.63.md5";
NSString * const MD5_CONT_TYPE  = @"text/plain";

NSString * const VERSION_FILE   = @"version.txt";
NSString * const VER_CONT_TYPE  = @"text/plain";


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Keywords
//
NSString * const KEYW_PROC_SEPARATOR  = @";";
NSString * const KEYW_DISP_SEPARATOR  = @"; ";
NSString * const KEYW_COMPS_SEPARATOR = @", ";

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NIL constants
//
CGFloat const DEF_X_OFFSET          = 0.0;
CGFloat const DEF_Y_OFFSET          = 0.0;
CGFloat const DEF_NIL_CELL          = 0.0;
CGFloat const DEF_NIL_HEADER        = 0.0;
CGFloat const DEF_NIL_FOOTER        = 1.0;
CGFloat const DEF_NIL_WIDTH         = 0.0;
CGFloat const DEF_NIL_HEIGHT        = 0.0;
CGFloat const DEF_NIL_CONSTRAINT    = 0.0;
CGFloat const DEF_NIL_CORNER_RADIUS = 0.0;

// MIN constants (i.e., tableview header instead of zero) which prevents default setting
//
CGFloat const DEF_MIN_HEADER        = 1.0;

// Widget alignment related
//
CGFloat const DEF_HGT_ALIGN_FACTOR  = 2.0;
CGFloat const DEF_CORNER_RAD_FACTOR = 2.0;

// Used for embedded labels
//
CGFloat const DEF_RECT_INSET        = 2.0;
CGFloat const DEF_X_COORD           = 1.0;
CGFloat const DEF_Y_COORD           = 1.0;
CGFloat const DEF_BOTTOM_OFFSET     = 6.0;


// UI Label
//
CGFloat const DEF_LABEL_WIDTH       = 80.0;
CGFloat const DEF_LABEL_HEIGHT      = 24.0;

// Tap Area
//
CGFloat const DEF_TAP_AREA_SIZE     = 30.0;

// UI TextField/TextView
//
CGFloat const DEF_TEXTFIELD_HEIGHT  = 30.0;
CGFloat const DEF_SM_TXTFIELD_WIDTH = 60.0;
CGFloat const DEF_TEXTVIEW_HEIGHT   = 60.0;
CGFloat const DEF_SM_TEXTVIEW_HGT   = 44.0;
CGFloat const DEF_NAVBAR_X_OFFSET   = 10.0;

// Generic Defaults
//
CGFloat const DEF_FIELD_PADDING     = 5.0;
CGFloat const DEF_MD_FIELD_PADDING  = 10.0;
CGFloat const DEF_LG_FIELD_PADDING  = 15.0;
CGFloat const DEF_VLG_FIELD_PADDING = 20.0;

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

CGFloat const DEF_TBL_DIVIDER_HGT   = 5.0;

CGFloat const DEF_XSM_TBL_HDR_HGT   = 11.0;
CGFloat const DEF_SM_TBL_HDR_HEIGHT = 22.0;
CGFloat const DEF_TABLE_HDR_HEIGHT  = 33.0;
CGFloat const DEF_LG_TABLE_HDR_HGT  = 44.0;
CGFloat const DEF_VLG_TABLE_HDR_HGT = 55.0;

CGFloat const DEF_LG_TABLE_CELL_HGT = 66.0;
CGFloat const DEF_VLG_TBL_CELL_HGT  = 88.0;
CGFloat const DEF_XLG_TBL_CELL_HGT  = 110.0;
CGFloat const DEF_XXLG_TBL_CELL_HGT = 396.0;
CGFloat const DEF_TABLE_X_OFFSET    = 15.0;
CGFloat const DEF_CELL_EDIT_DISPL   = 22.0;

// UI PickerView
//
CGFloat const DEF_PICKER_ROW_HEIGHT = 50.0;
CGFloat const DEF_PICKER_HEIGHT     = 250.0;
CGFloat const DEF_PICKER_WIDTH      = 320.0;

CGFloat const DEF_COLLECTVIEW_INSET = 20.0;

// UIToolbar
//
CGFloat const DEF_TOOLBAR_HEIGHT    = 40.0;
CGFloat const DEF_TOOLBAR_WIDTH     = 320.0;

// UI Buttons
//
CGFloat const DEF_SM_BUTTON_WIDTH   = 30.0;
CGFloat const DEF_BUTTON_WIDTH      = 60.0;
CGFloat const DEF_LG_BUTTON_WIDTH  = 90.0;
CGFloat const DEF_BUTTON_HEIGHT     = 26.0;
CGFloat const DEF_LG_BUTTON_HEIGHT  = 40.0;
CGFloat const HIDE_BUTTON_WIDTH     = 1.0;

// Match Button widths
//
CGFloat const DECR_BUTTON_WIDTH     = 20.0;
CGFloat const SHOW_BUTTON_WIDTH     = 20.0;

// Image Actions
//
int const TAKE_PHOTO_ACTION   = 1;
int const SELECT_PHOTO_ACTION = 2;

// Tags
//
int const DEF_TAG_NUM    = 200;

// UI Button Tags
//
int const IMAGELIB_BTN_TAG     = 51;
int const PHOTO_BTN_TAG        = 52;
int const SEARCH_BTN_TAG       = 53;
int const LISTING_BTN_TAG      = 54;
int const RGB_BTN_TAG          = 55;

int const BACK_BTN_TAG         = 56;
int const EDIT_BTN_TAG         = 57;
int const SETTINGS_BTN_TAG     = 58;
int const SAVE_BTN_TAG         = 59;
int const VIEW_BTN_TAG         = 60;
int const DONE_BTN_TAG         = 61;
int const HOME_BTN_TAG         = 62;

int const DECR_ALG_BTN_TAG     = 71;
int const MATCH_BTN_TAG        = 72;
int const INCR_ALG_BTN_TAG     = 73;
int const DECR_TAP_BTN_TAG     = 74;
int const INCR_TAP_BTN_TAG     = 75;
int const ASSOC_BTN_TAG        = 76;

int const NAME_FIELD_TAG       = 81;
int const TYPE_FIELD_TAG       = 82;
int const COLOR_FIELD_TAG      = 83;
int const KEYW_FIELD_TAG       = 84;
int const DESC_FIELD_TAG       = 85;
int const SWATCH_PICKER_TAG    = 86;
int const COLOR_PICKER_TAG     = 87;
int const COLOR_BTN_TAG        = 88;
int const TYPE_BTN_TAG         = 89;
int const BRAND_FIELD_TAG      = 90;
int const BRAND_PICKER_TAG     = 91;
int const BRAND_BTN_TAG        = 92;
int const OTHER_FIELD_TAG      = 93;
int const BODY_FIELD_TAG       = 94;
int const BODY_PICKER_TAG      = 95;
int const BODY_BTN_TAG         = 96;
int const PIGMENT_FIELD_TAG    = 97;
int const PIGMENT_PICKER_TAG   = 98;
int const PIGMENT_BTN_TAG      = 99;
int const RATIOS_PICKER_TAG    = 100;
int const COVERAGE_FIELD_TAG   = 101;
int const COVERAGE_PICKER_TAG  = 102;
int const FLEXIBLE_SPACE_TAG   = 103;
int const FIXED_SPACE_TAG      = 104;

// Views Tags
//
int const VIEW_TAG             = 201;
int const TABLEVIEW_TAG        = 202;
int const TABLEVIEW_CELL_TAG   = 203;
int const SCROLLVIEW_TAG       = 204;
int const IMAGEVIEW_TAG        = 205;

// Settings
//
int const SHAPE_BUTTON_TAG    = 111;
int const MATCH_NUM_TAG       = 112;
int const ADD_BRANDS_TAG      = 113;
int const MIX_RATIOS_TAG      = 114;

// Add Mix
//
int const CANCEL_BUTTON_TAG   = 116;

// Init Controller
//
int const CONTINUE_BUTTON_TAG = 117;

int const MAX_TAG             = 120;


// Maximum Text field lengths (characters)
//
int const MAX_NAME_LEN  = 96;
int const MAX_KEYW_LEN  = 128;
int const MAX_DESC_LEN  = 128;
int const MAX_BRAND_LEN = 32;

// View Types
//
NSString * const MATCH_TYPE     = @"Match";
NSString * const ASSOC_TYPE     = @"Assoc";
NSString * const MIX_TYPE       = @"Mix";
NSString * const KEYWORDS_TYPE  = @"Keywords";
NSString * const COLORS_TYPE    = @"Colors";

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Keys
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
NSString * const DB_POLL_UPDATE_KEY  = @"DBPollUpdate";
NSString * const DB_FORCE_UPDATE_KEY = @"DBForceUpdate";
NSString * const PAINT_SWATCH_RO_KEY = @"SwatchesReadOnly";
NSString * const MIX_ASSOC_RO_KEY    = @"AssocReadOnly";
NSString * const TAP_AREA_SIZE_KEY   = @"TapAreaSize";
NSString * const SHAPE_GEOMETRY_KEY  = @"ShapeGeometry";
NSString * const MATCH_NUM_KEY       = @"MatchNum";
NSString * const RGB_DISPLAY_KEY     = @"RgbDisplay";
NSString * const MIX_RATIOS_KEY      = @"PaintMixRatios";
NSString * const MIX_ASSOC_COUNT_KEY = @"MixAssocCount";
NSString * const ADD_BRANDS_KEY      = @"PaintBrand";

// Activity (i.e., spinner) label indicator
//
NSString * const SPINNER_LABEL_PROC  = @"Processing the request...";
NSString * const SPINNER_LABEL_LOAD  = @"Loading the View...";

// Alerts related
//
NSString * const ALERTS_FILTER_KEY   = @"AlertsFilter";
NSString * const APP_INTRO_KEY       = @"AppIntroAlert";
NSString * const IMAGE_INTERACT_KEY  = @"ImageInteractAlert";
NSString * const TAP_COLLECT_KEY     = @"TapCollectAlert";

// Alerts Instructions
//
NSString * const APP_INTRO_INSTRUCTIONS = @"To get started click the top left 'picture' icon and either select a photo from your library or take a new one";
NSString * const INTERACT_INSTRUCTIONS = @"Single tap on the image selects a new area and single tap on any selected area deselects that area. Pressing the image for at least one second allows dragging a tap area and single press for one second reverts back to image scrolling.";
NSString * const TAP_COLLECT_INSTRUCTIONS = @"Tap on the first element of any row to switch between the RGB coloring and image rendering. Tap on any other row element to view the association.";

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
const int MATCH_STEPPER_DEF = 10;

// Max Match Num (i.e., UIImageViewController)
//
int const DEF_MAX_MATCH  = 100;
int const DEF_MATCH_NUM  = 10;
int const DEF_MIN_MATCH  = 5;
int const DEF_STEP_MATCH = 5;

// Tap/Drag Related
//
int const DEF_NUM_TAPS       = 1;
CGFloat const MIN_PRESS_DUR  = 0.5f;
CGFloat const ALLOWABLE_MOVE = 100.0f;
CGFloat const MIN_DRAG_DIFF  = 5.0;

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
NSString * const BACKGROUND_IMAGE_TITLE = @"butterfly-background-title-2.png";
NSString * const BACKGROUND_IMAGE       = @"butterfly-background-2.png";
NSString * const IMAGE_LIB_NAME         = @"photo 2.png";
NSString * const PALETTE_IMAGE_NAME     = @"Artist Palette.png";
NSString * const RGB_IMAGE_NAME         = @"rgb.png";
NSString * const BACK_BUTTON_IMAGE_NAME = @"arrow.png";
NSString * const SEARCH_IMAGE_NAME      = @"search.png";
NSString * const ARROW_UP_IMAGE_NAME    = @"arrow up.png";
NSString * const ARROW_DOWN_IMAGE_NAME  = @"arrow down.png";
NSString * const EMPTY_SQ_IMAGE_NAME    = @"square.png";
NSString * const CHECKBOX_SQ_IMAGE_NAME = @"CheckBox-1.png";

// Default listing type
//
NSString * const FULL_LISTING_TYPE     = @"Full Colors Listings";


// "About" section text
//
NSString * const ABOUT_TEXT = @"\nThis app aims to help users find potential acrylic "
"color paint matches associated with selected areas of a photo. It does this by applying a "
"selected 'match' algorithm against a database of reference paints and paint mixes.\n\n"
"The Reference Data:\n"
"The Paint Swatch Database is comprised of about 2,500 paint references and mixes "
"each of them created manually. For accuracy. 1 ml syringes were used to measure/dispense "
"the paint and cotton swabs to mix them (for this version, only two-color "
"mixes were created though app supports using a 'mix' as reference for a three-way or "
"multi-color mix)\n\n"
"The paint was applied on acid-free, triple-primed white canvas paper in generally thick layers "
"or 'Thick' as described in the canvas coverage property. Paint coverage might also be defined "
"as 'Thin' or 'Sparse' (usually as a result of using less paint and/or transparent or translucent  paints)\n\n"
"As the paint swatches sheets were created they were photographed. For lighting consistency, "
"this was done at the same time of day for each sheet and in a way that eliminated reflection "
"as much as possible. Photographed swatches were then entered manually using the app 'mix "
"association' feature and the individual properties of each swatch set appropriately.\n\n"

"The Match Methodology:\n"
"The user may apply seven algorithms to find one or more potential matches. Each algorithm "
"compares the tap area against the database of swatches to yield a difference (d). The "
"smaller the d value the better the match. For those curious the algorithms, based on RGB and/or HSB color properties, are as follows:\n"
"\nRGB only (default):\n"
"d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2)\n"
"\nHSB only:\n"
"d = sqrt((h2-h1)^2 + (s2-s1)^2 + (b2-b1)^2)\n"
"\nRGB and Hue:\n"
"d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2)\n"
"\nRGB + HSB:\n"
"d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2 + (s2-s1)^2 + (b2-b1)^2)\n"
"\nWeighted RGB:\n"
"d = ((r2-r1)*0.30)^2 + ((g2-g1)*0.59)^2 + ((b2-b1)*0.11)^2\n"
"\nWeighted RGB + HSB:\n"
"d = ((r2-r1)*0.30)^2 + ((g2-g1)*0.59)^2 + ((b2-b1)*0.11)^2 + (h2-h1)^2 + (s2-s1)^2 + (b2-b1)^2\n"
"\nHue only:\n"
"d = sqrt((h2-h1)^2)\n\n"
"Why seven? I found that though some of these algorithms (in particular the RGB method) consistently produce the best results others might perform better at different RGB/HSB ranges.\n";


// "Disclaimer" section text
//
NSString * const DISCLAIMER_TEXT = @"\nThis app attempts to find matching paint references "
"and/or mixes associated with a user selected area in a photo. It does this by "
"applying a user selected algorithm based on the RGB and/or HSB color properties. "
"In many cases the heuristic misses the mark or is unable to find a "
"suitable match against the database. My hope is to continue to improve that match "
"rate with future releases as a result of both refinements in the algorithm and "
"new paint references/mixes added to the database.\n\n"
"The results produced by this app are just guideliness that could be useful to the novice "
"artist. While I have attempted to capture, as carefully as possible, the real colors of "
"the reference paints and mixes, inaccuracies resulting from the paint mixing process "
"and/or photographic lighting are likely to exist (see 'The Reference Data' "
"in the 'About this App' section)\n\n"
"While most references are based on the Liquitex brand this does not mean I "
"endorse that brand. Furthermore, no external entity has financed "
"the development of this app. Reference colors or mixes linked "
"to any brand may not accurately represent that brand due to potential shortcomings "
"in the data capture methodologies.\n\n"
"Finally, this app grew out of my passion for art and programming. Since I am not a professional artist, photographer, or expert in color theory I had to first research and then implement (much through trial and error) the methods and algorithms used for this app. My hope is that this is just the first version of what might become a work in progress. I would like to hear from you on how I might improve it!\n";

// Feedback (Email)
//
NSString * const SUBJECT   = @"Feedback";
NSString * const BODY      = @"Please provide me feedback!";
NSString * const RECIPIENT = @"svpineo@gmail.com";

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

    [ManagedObjectUtils deleteDictionaryEntity:@"CanvasCoverage"];
    [ManagedObjectUtils insertFromDataFile:@"CanvasCoverage"];
    
    [ManagedObjectUtils deleteDictionaryEntity:@"AssociationType"];
    [ManagedObjectUtils insertFromDataFile:@"AssociationType"];

    
    // Update the version as needed
    //
    [ManagedObjectUtils updateVersions];
    
    
    // Create the data CSV files
    //
    //[ManagedObjectUtils createEntityCSVFiles];


    // NSUserDefaults intialization
    //
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // isRGB settings (false by default)
    //
    if ([userDefaults objectForKey:RGB_DISPLAY_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:RGB_DISPLAY_KEY];
    }
    
    // Alerts (on by default)
    //
    if ([userDefaults objectForKey:APP_INTRO_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:APP_INTRO_KEY];
    }
    if ([userDefaults objectForKey:IMAGE_INTERACT_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:IMAGE_INTERACT_KEY];
    }
    if ([userDefaults objectForKey:TAP_COLLECT_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:TAP_COLLECT_KEY];
    }
    
    [userDefaults synchronize];
}

@end
