//
//  GlobalSettings.m
//  RGButterfly
//
//  Created by Stuart Pineo on 4/12/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "GlobalSettings.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"
#import "AppDelegate.h"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ************************ IMPORTANT RELEASE SETTINGS ***********************************
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int const ALL_FEATURES          = 0;
int const VERSION_TAG           = 1;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ************************ IMPORTANT UPGRADE SETTINGS ***********************************
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSString * const APP_NAME       = @"RGButterfly";


// Key references the value stored in NSUserDefaults
//
NSString * const DB_VERSION_KEY = @"DB_VERSION";

NSString * const MD5SUM_EXT     = @"md5";

NSString * const CURR_STORE     = @"RGButterfly_v4.0.63.sqlite";
NSString * const PREV_STORE     = @"RGButterfly_v4.0.63.sqlite";
int const MIGRATE_STORE         = 0;

// Cleanup orphans
//
int const CLEANUP               = 1;


// Disable Write-Ahead Logging (by default this is enabled)
//
int const DISABLE_WAL           = 1;

NSString * const LOCAL_PATH = @"./";

// Upgrade the database from the local path copy or GitHub
//
int const FORCE_UPDATE_DB       = 0;

// DB Update Statuses (referenced in the Init VC)
//
int const NO_UPDATE             = 0;
int const FAILED_CHECK          = 1;
int const DO_UPDATE             = 2;

// Small screen threshold (i.e., < iPhone 6)
//
CGFloat const SMALL_SCREEN_THRESHOLD = 375.0;

// Jenkins related
//
NSString * const AUTHTOKEN_FILE = @"Authtoken";
NSString * const DB_ROOT_URL    = @"http://34.195.217.113:8080/";
NSString * const DB_REST_URL    = @"http://34.195.217.113:8080/job/ArchiveLatestDBUpdate/ws/databases/RGButterfly";

NSString * const DB_FILE        = @"RGButterfly_v4.0.63.sqlite";
NSString * const DB_CONT_TYPE   = @"application/x-sqlite3";

NSString * const MD5_FILE       = @"RGButterfly_v4.0.63.md5";
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
CGFloat const DEF_NIL_INSET         = 0.0;
CGFloat const DEF_NIL_CONSTRAINT    = 0.0;
CGFloat const DEF_NIL_CORNER_RADIUS = 0.0;

// MIN constants (i.e., tableview header instead of zero) which prevents default setting
//
CGFloat const DEF_MIN_HEADER        = 1.0;

// Widget alignment related
//
CGFloat const DEF_HGT_ALIGN_FACTOR  = 2.0;
CGFloat const DEF_CORNER_RAD_FACTOR = 2.0;
CGFloat const DEF_X_OFFSET_DIVIDER  = 2.0;
CGFloat const DEF_Y_OFFSET_DIVIDER  = 2.0;
CGFloat const DEF_CIRCLE_OFFSET_DIV = 3.3;

// Used for embedded labels
//
CGFloat const DEF_RECT_INSET        = 2.0;
CGFloat const DEF_X_COORD           = 1.0;
CGFloat const DEF_Y_COORD           = 1.0;
CGFloat const DEF_BOTTOM_OFFSET     = 6.0;

// Custom cell
//
CGFloat const DEF_CELL_HEIGHT       = 72.0;
CGFloat const DEF_FIELD_INSET       = 25.0;
CGFloat const DEF_CELL_PADDING      = 5.0;

// UI Label
//
CGFloat const DEF_LABEL_WIDTH       = 80.0;
CGFloat const DEF_LABEL_HEIGHT      = 24.0;

// Tap Area
//
CGFloat const DEF_TAP_AREA_SIZE     = 32.0;

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
CGFloat const DEF_XLG_FIELD_PADDING = 25.0;

//CGFloat const DEF_CORNER_RADIUS     = 5.0;
CGFloat const DEF_CORNER_RADIUS     = 2.0;
CGFloat const DEF_LG_CORNER_RADIUS  = 15.0;
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

// UIToolbar
//
CGFloat const DEF_TOOLBAR_HEIGHT    = 40.0;
CGFloat const DEF_TOOLBAR_WIDTH     = 320.0;

// UI Buttons
//
CGFloat const DEF_SM_BUTTON_WIDTH   = 30.0;
CGFloat const DEF_BUTTON_WIDTH      = 60.0;
CGFloat const DEF_LG_BUTTON_WIDTH   = 90.0;
CGFloat const DEF_BUTTON_HEIGHT     = 26.0;
CGFloat const DEF_LG_BUTTON_HEIGHT  = 40.0;
CGFloat const HIDE_BUTTON_WIDTH     = 1.0;

// Match Button widths
//
CGFloat const DECR_BUTTON_WIDTH     = 20.0;
CGFloat const SHOW_BUTTON_WIDTH     = 20.0;

// Magnifier/Crosshair width
//
CGFloat const MAGNIFIER_WIDTH       = 100.0;
CGFloat const MAGNIFIER_RADIUS      = 50.0;
CGFloat const MAGNIFIER_BORDER      = 2.0;
CGFloat const MAG_XHAIR_FRACTION    = 0.08;
CGFloat const MAG_THUMB_FRACTION    = 0.10;

// iPhone Plus Width
//
CGFloat const IPHONE_PLUS_WIDTH     = 414.0;

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
int const SHARE_BTN_TAG        = 63;

int const DECR_ALG_BTN_TAG     = 71;
int const MATCH_BTN_TAG        = 72;
int const INCR_ALG_BTN_TAG     = 73;
int const DECR_TAP_BTN_TAG     = 74;
int const INCR_TAP_BTN_TAG     = 75;
int const ASSOC_BTN_TAG        = 76;
int const SEARCH_BAR_TAG       = 77;

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
int const FAVORITES_BTN_TAG    = 105;
int const MY_FAVORITES_TAG     = 106;
int const HELP_BTN_TAG         = 107;

// Views Tags
//
int const VIEW_TAG             = 201;
int const TABLEVIEW_TAG        = 202;
int const TABLEVIEW_CELL_TAG   = 203;
int const SCROLLVIEW_TAG       = 204;
int const IMAGEVIEW_TAG        = 205;

// Settings
//
int const SHAPE_BUTTON_TAG     = 111;
int const MATCH_NUM_TAG        = 112;
int const ADD_BRANDS_TAG       = 113;
int const MIX_RATIOS_TAG       = 114;
int const LIST_TYPE_FIELD_TAG  = 115;
int const LIST_TYPE_PICKER_TAG = 116;

// Add Mix
//
int const CANCEL_BUTTON_TAG   = 121;

// Init Controller
//
int const INIT_LABEL_TAG      = 301;
int const INIT_SPINNER_TAG    = 302;

int const SUGGEST_BTN_TAG     = 311;
int const EXPLORE_BTN_TAG     = 312;
int const TAKE_PHOTO_BTN_TAG  = 313;
int const MY_PHOTOS_BTN_TAG   = 314;
int const TOPICS_BTN_TAG      = 315;
int const COLLECT_BTN_TAG     = 316;
int const LIST_BTN_TAG        = 317;
int const MATCHED_BTN_TAG     = 318;
int const GROUPS_BTN_TAG      = 319;

int const MATCH_LABEL_TAG     = 321;
int const TAKE_LABEL_TAG      = 322;
int const VISIT_LABEL_TAG     = 323;
int const TOPICS_LABEL_TAG    = 324;
int const COLLECT_LABEL_TAG   = 325;
int const LIST_LABEL_TAG      = 326;
int const EXPLORE_LABEL_TAG   = 327;
int const MATCHED_LABEL_TAG   = 328;
int const GROUPS_LABEL_TAG    = 329;

int const ABOUT_BTN_TAG       = 331;
int const SETTINGS2_BTN_TAG   = 332;

int const MAX_TAG             = 1000;


// Maximum Text field lengths (characters)
//
int const MAX_NAME_LEN  = 96;
int const MAX_KEYW_LEN  = 128;
int const MAX_DESC_LEN  = 128;
int const MAX_BRAND_LEN = 32;

// View Types
//
NSString * const ASSOC_TYPE        = @"Assoc";
NSString * const MIX_TYPE          = @"Mix";
NSString * const MATCH_TYPE        = @"Match";

// Listing Types
//
NSString * const MIX_LIST_TYPE     = @"Color Associations";
NSString * const MATCH_LIST_TYPE   = @"Match Associations";
NSString * const FULL_LISTING_TYPE = @"Individual Colors";
NSString * const KEYWORDS_TYPE     = @"Keywords Listing";
NSString * const COLORS_TYPE       = @"Subjective Colors";

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSUserDefaults Keys
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
NSString * const DB_POLL_UPDATE_KEY  = @"DBPollUpdate";
NSString * const DB_FORCE_UPDATE_KEY = @"DBForceUpdate";
NSString * const DB_RESTORE_KEY      = @"DBRestore";
NSString * const PAINT_SWATCH_RO_KEY = @"SwatchesReadOnly";
NSString * const MIX_ASSOC_RO_KEY    = @"AssocReadOnly";
NSString * const TAP_AREA_SIZE_KEY   = @"TapAreaSize";
NSString * const SHAPE_GEOMETRY_KEY  = @"ShapeGeometry";
NSString * const MATCH_NUM_KEY       = @"MatchNum";
NSString * const GEN_FILTER_KEY      = @"GenericsFilterKey";
NSString * const COV_FILTER_KEY      = @"CoverageFilterKey";
NSString * const RGB_DISPLAY_KEY     = @"RgbDisplay";
NSString * const MIX_RATIOS_KEY      = @"PaintMixRatios";
NSString * const MIX_ASSOC_COUNT_KEY = @"MixAssocCount";
NSString * const ADD_BRANDS_KEY      = @"PaintBrand";
NSString * const LISTING_TYPE        = @"ListingType";


// Activity (i.e., spinner) label indicator
//
NSString * const SPINNER_LABEL_PROC  = @"Processing the Request...";
NSString * const SPINNER_LABEL_LOAD  = @"Loading the View...";

// Alerts related
//
NSString * const ALERTS_FILTER_KEY   = @"AlertsFilter";
NSString * const TAP_NOTE_KEY        = @"TapNoteKey";

// Alerts Instructions
//
NSString * const MAIN_COLLECT_INSTRUCTIONS = @"Click on any row to view the details. Note that search words assume start of the line so you might try adding the prefix '*' to broaden the results.";
NSString * const MAIN_TOPICS_INSTRUCTIONS = @"Topics that you add in the detailed view show up here. You can associate multiple topics with a color and/or more than one color with a topic.";
NSString * const MAIN_LIST_INSTRUCTIONS = @"This view provides the quickest access to the thousands of colors as well as your list of favorites. Use the filter, search, and/or alphabet index to narrow down the list!";
NSString * const MAIN_GROUP_INSTRUCTIONS = @"This view provides a subjective color-wheel-like grouping of colors. The detailed view allows you to change the default selection associated with any of the colors.";
NSString * const INTERACT_INSTRUCTIONS = @"Tap on any area of the photo to create a match association (tap on that same area to remove it). Drag any area while using the magnifier to zero in on your color. Tap on any of the bottom rows to view the details.";
NSString * const MATCH_INSTRUCTIONS = @"Press any row while scrolling to compare colors. Bottom arrows circle between tap areas (tapping the 'Areas' button switches to 'Match' mode which enables changing matching method).";
NSString * const DETAIL_INSTRUCTIONS = @"Tap 'Add Favorites' to keep track of your favorite colors and 'Edit' to create/remove topics, add comments, and/or change the color group. The star icon bottom-right gets you to your favorites listing.";

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Customization
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSString * const DEF_ATTRIBUTED_FONT = @"Baskerville-Italic";

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
const int TAP_STEPPER_MIN = 24;
const int TAP_STEPPER_MAX = 36;
const int TAP_STEPPER_INC = 4;

// Match Num Stepper
//
const int MATCH_STEPPER_MIN = 5;
const int MATCH_STEPPER_MAX = 60;
const int MATCH_STEPPER_INC = 5;
const int MATCH_STEPPER_DEF = 20;

// Max Match Num (i.e., ImageViewController)
//
int const DEF_MAX_MATCH  = 80;
int const DEF_MATCH_NUM  = 20;
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
NSString * const DEF_IMAGE_NAME = @"My Color Matches";


// Image Names
//
NSString * const BG_IMAGE_PORTRAIT      = @"jgpineo_background_fade_portrait.jpg";
NSString * const BG_IMAGE_LANDSCAPE     = @"jgpineo_background_fade_landscape.jpg";
NSString * const BG_IMAGE_NB_PORTRAIT   = @"jgpineo_background_noborder_fade_portrait.jpg";
NSString * const IMAGE_LIB_NAME         = @"photo 2.png";
NSString * const PALETTE_IMAGE_NAME     = @"Artist Palette.png";
NSString * const RGB_IMAGE_NAME         = @"rgb.png";
NSString * const BACK_BUTTON_IMAGE_NAME = @"arrow.png";
NSString * const SEARCH_IMAGE_NAME      = @"search.png";
NSString * const ARROW_UP_IMAGE_NAME    = @"arrow up.png";
NSString * const ARROW_DOWN_IMAGE_NAME  = @"arrow down.png";
NSString * const EMPTY_SQ_IMAGE_NAME    = @"square.png";
NSString * const CHECKBOX_SQ_IMAGE_NAME = @"CheckBox-1.png";
NSString * const STAR_ICON_NAME         = @"star-icon.png";


// "About" section text (NSMutableAttributedString use for rich text)
//
NSString * const ABOUT_TEXT = @"\nThe main purpose of this App is to suggest matching paint colors for areas of a photo. Please visit the RGButterfly website for more information about this App.\n\nTo get started, click on either the Match Colors or Explore Colors titles on the main view.\n\nOn most views, a help button (bottom-right question icon) can be tapped to obtain usage tips.\n\n";

NSString * const ABOUT_RELEASE_FEATURES = @"Note: This initial release comes with a number of features and much of the editing functionality disabled. This will hopefully help with the usability.\n\n";


// URL is place on the 'About' Text (might want to compute the offset/length programmatically)
//
NSString * const ABOUT_PAT   = @"RGButterfly";
NSString * const ABOUT_URL   = @"http://rgbutterfly.com/";
NSString * const MATCH_PAT   = @"Match Colors";
NSString * const EXPLORE_PAT = @"Explore Colors";

// Documentation Site/Share
//
NSString * const MAIN_IMAGE    = @"main-image.png";
NSString * const DOCS_SYNOPSIS = @"The iPhone App to Suggest Matching Paint Colors";
NSString * const DOCS_SITE_URL = @"http://rgbutterfly.com/";
NSString * const MAIN_SITE_URL = @"http://rgbutterfly.com/";
NSString * const DOCS_SITE_PAT = @"RGButterfly";


// "Disclaimer" section text
//
NSString * const DISCLAIMER_TEXT = @"This App suggests matching colors associated with areas in a photo by applying an algorithm based on the RGB and/or HSB color properties.\n\n\
The results produced by this App are just guideliness. While I have attempted to capture, as carefully and consistently as possible, the paints true colors, inaccuracies and inconsistencies resulting from the paint mixing and photographic process are inevitable.\n\n\
Most references are based on the Liquitex Heavy-Body Acrylics brand since, as a hobbyist, that is the brand I use the most. Rendered colors associated with this or any other brand may not accurately represent the intended colors due to the above inconsitencies thus I highly recommend test-applying the actual reference paints or mixes before using them.\n\n\
Please visit the RGButterfly site for more information about this App.\n\n";


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

// Init called by the MainViewController (App entry point)
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
    
    [ManagedObjectUtils deleteDictionaryEntity:@"ListingType"];
    [ManagedObjectUtils insertFromDataFile:@"ListingType"];

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // One-time cleanup
    //
    //[ManagedObjectUtils setMixAssocTypeId:context];
    //[ManagedObjectUtils setSwatchCoverageId:context];
    
    // Load Generic Associations (read the directory)
    //
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^Generic.*.txt$"
        options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *path = [[NSBundle mainBundle] resourcePath];

    
    NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    while (file = [filesEnumerator nextObject]) {
        NSUInteger match = [regex numberOfMatchesInString:file
                                                  options:0
                                                    range:NSMakeRange(0, [file length])];
        
        if (match) {
            NSString *assocName = [[file lastPathComponent] stringByDeletingPathExtension];
            if (! [ManagedObjectUtils instanceExists:context entityName:@"MixAssociation" name:assocName]) {
                    [ManagedObjectUtils bulkLoadGenericAssociation:assocName];
            }
        }
    }

    
    // Perform cleanup (most of these should be already handled by the controllers)
    //
    if (CLEANUP == 1) {
        [ManagedObjectUtils deleteChildlessMixAssoc:context];
        [ManagedObjectUtils deleteChildlessMatchAssoc:context];
        [ManagedObjectUtils deleteOrphanMixAssocSwatches:context];
        [ManagedObjectUtils deleteOrphanPaintSwatches:context];
        [ManagedObjectUtils deleteOrphanPaintSwatchKeywords:context];
    }


    // Update the version as needed
    //
    [ManagedObjectUtils updateVersions];
    
    
    // Create the data CSV files
    //
    //[ManagedObjectUtils createEntityCSVFiles];


    // NSUserDefaults intialization
    //
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // DB Poll Update
    //
    if ([userDefaults objectForKey:DB_POLL_UPDATE_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:DB_POLL_UPDATE_KEY];
    }
    
    // DB Restore Settings
    //
    if ([userDefaults objectForKey:DB_RESTORE_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:DB_RESTORE_KEY];
    }
    
    // Paint Swatches/Mix Associations Read-Only by default
    //
    if ([userDefaults objectForKey:PAINT_SWATCH_RO_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:PAINT_SWATCH_RO_KEY];
        [ManagedObjectUtils setEntityReadOnly:@"PaintSwatch" isReadOnly:TRUE context:context];
    }
    
    if ([userDefaults objectForKey:MIX_ASSOC_RO_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:MIX_ASSOC_RO_KEY];
        [ManagedObjectUtils setEntityReadOnly:@"MixAssociation" isReadOnly:TRUE context:context];
    }
    
    // isRGB Settings (false by default)
    //
    if ([userDefaults objectForKey:RGB_DISPLAY_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:RGB_DISPLAY_KEY];
    }
    
    // Initialize the Match Swatch Filters Keys to TRUE/FALSE if not set
    //
   if ([userDefaults objectForKey:GEN_FILTER_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:GEN_FILTER_KEY];
   }
    
    if ([userDefaults objectForKey:COV_FILTER_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:COV_FILTER_KEY];
    }
    
    // Alerts (on by default)
    //
    // Main alerts switch
    //
    if ([userDefaults objectForKey:ALERTS_FILTER_KEY] == nil) {
        [userDefaults setBool:FALSE forKey:ALERTS_FILTER_KEY];
    }
    
    if ([userDefaults objectForKey:LISTING_TYPE] == nil) {
        [userDefaults setValue:MATCH_LIST_TYPE forKey:LISTING_TYPE];
    }
    
    if ([userDefaults objectForKey:TAP_NOTE_KEY] == nil) {
        [userDefaults setBool:TRUE forKey:TAP_NOTE_KEY];
    }
    
    [userDefaults synchronize];
}

@end
