//
//  SwatchDetailTableViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 6/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "SwatchDetailTableViewController.h"
#import "CustomCollectionTableViewCell.h"
#import "AssocTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "AppColorUtils.h"
#import "ColorUtils.h"
#import "ManagedObjectUtils.h"
#import "AppDelegate.h"
#import "GenericUtils.h"
#import "AlertUtils.h"
#import "PickerUtils.h"
#import "MainViewController.h"

#import "MixAssociation.h"
#import "MixAssocSwatch.h"
#import "PaintSwatches.h"

#import "SwatchKeyword.h"
#import "Keyword.h"
#import "ColorViewController.h"


@interface SwatchDetailTableViewController ()

@property (nonatomic, strong) NSDictionary *pickerViewDefaults;
@property (nonatomic, strong) UIImageView *swatchImageView;

@property (nonatomic, strong) UIAlertController *saveAlertController;
@property (nonatomic, strong) UIAlertAction *save, *delete;


// SwatchName and Reference Label and Name fields
//
@property (nonatomic, strong) UITextField *swatchName, *swatchTypeName, *subjColorName, *paintBrandName, *otherNameField, *pigmentTypeName, *bodyTypeName, *coverageName, *swatchKeyw;

@property (nonatomic, strong) UIBarButtonItem *isFavoriteTextButton, *myFavoriteButton;

@property (nonatomic, strong) NSString *nameEntered, *keywEntered, *descEntered, *colorSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *otherPlaceholder, *colorName, *defNameHeader, *nameHeader, *subjColorHeader, *propsHeader, *swatchTypeHeader, *paintBrandHeader, *pigmentTypeHeader,  *bodyTypeHeader, *canvasCoverageHeader, *keywHeader, *commentsHeader, *refsHeader, *mixAssocHeader, *matchAssocHeader, *otherName, *isFavoriteText;

// Subjective color related
//
@property (nonatomic, strong) UIPickerView *subjColorPicker, *swatchTypesPicker, *paintBrandPicker, *pigmentTypePicker, *bodyTypePicker, *coveragePicker;

@property (nonatomic, strong) NSArray *subjColorNames, *swatchTypeNames, *paintBrandNames, *pigmentTypeNames, *bodyTypeNames, *coverageNames;

@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData, *paintBrandData, *pigmentTypeData, *bodyTypeData, *canvasCoverageData;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIColor *subjColorValue;

@property (nonatomic) CGFloat imageViewXOffset, imageViewWidth, imageViewHeight, textFieldYOffset, colorTextFieldWidth;

@property (nonatomic) int typesPickerSelRow, colorPickerSelRow, brandPickerSelRow, pigmentPickerSelRow, bodyPickerSelRow, coveragePickerSelRow, collectViewSelRow;

@property (nonatomic, strong) NSMutableArray *colorArray, *paintSwatches;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;


@property (nonatomic) BOOL editFlag, colorPickerFlag, typesPickerFlag, brandPickerFlag, pigmentPickerFlag, bodyPickerFlag, coveragePickerFlag, isReadOnly, isShipped, isFavorite;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *keywordEntity, *swatchKeywordEntity;


// PaintSwatches
//
@property (nonatomic, strong) PaintSwatches *selPaintSwatch;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Constants defaults
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int NUM_TABLEVIEW_ROWS = 0;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@implementation SwatchDetailTableViewController


// Globals
//
int DETAIL_NAME_SECTION     = 0;
int DETAIL_COLOR_SECTION    = 1;
int DETAIL_PROPS_SECTION    = 2;
int DETAIL_TYPES_SECTION    = 3;
int DETAIL_BRAND_SECTION    = 4;
int DETAIL_PIGMENT_SECTION  = 5;
int DETAIL_BODY_SECTION     = 6;
int DETAIL_COVERAGE_SECTION = 7;
int DETAIL_KEYW_SECTION     = 8;
int DETAIL_DESC_SECTION     = 9;
int DETAIL_REF_SECTION      = 10;
int DETAIL_ASSOC_SECTION    = 11;

const int DETAIL_MAX_SECTION      = 12;

NSString *DETAIL_REUSE_CELL_IDENTIFIER = @"SwatchDetailCell";

// Add to Favorites button
//
const int ADD_FAVORITE_BTN_INDEX = 0;
const int MY_FAVORITE_BTN_INDEX  = 3;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

-(void)loadView {
    [super loadView];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _keywordEntity       = [NSEntityDescription entityForName:@"Keyword"       inManagedObjectContext:self.context];
    _swatchKeywordEntity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:self.context];
    
    NUM_TABLEVIEW_ROWS   = (int)[_mixAssocSwatches count];
    
    NSMutableArray *mixAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<NUM_TABLEVIEW_ROWS; i++) {
        
        MixAssocSwatch *mixAssocSwatchObj = [_mixAssocSwatches objectAtIndex:i];
        MixAssociation *mixAssocObj = [mixAssocSwatchObj mix_association];
    
        NSMutableArray *swatch_ids = [ManagedObjectUtils queryMixAssocSwatches:mixAssocObj.objectID context:self.context];

        int num_collectionview_cells = (int)[swatch_ids count];

        NSMutableArray *paintSwatches = [NSMutableArray arrayWithCapacity:num_collectionview_cells];
        
        for (int j=0; j<num_collectionview_cells; j++) {
            MixAssocSwatch *mixAssocSwatchObj = [swatch_ids objectAtIndex:j];
            PaintSwatches *swatchObj = (PaintSwatches *)mixAssocSwatchObj.paint_swatch;
            
            [paintSwatches addObject:swatchObj];
        }
        [mixAssociationIds addObject:paintSwatches];
    }
    
    self.colorArray = [NSMutableArray arrayWithArray:mixAssociationIds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image
    //
    [ColorUtils setBackgroundImage:BG_IMAGE_NB_PORTRAIT view:self.view];

    //[self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithData:[_paintSwatch image_thumb]]]];


    // TableView defaults
    //
    _imageViewXOffset  = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    
    // Initialize
    //
    int type_id          = [[_paintSwatch type_id] intValue];
    int subj_color_id    = [[_paintSwatch subj_color_id] intValue];
    
    int brand_id         = [[_paintSwatch paint_brand_id] intValue];
    NSString *brand_name = [_paintSwatch paint_brand_name];
    
    int body_type_id     = [[_paintSwatch body_type_id] intValue];
    int pigment_type_id  = [[_paintSwatch pigment_type_id] intValue];
    
    int coverage_id      = [[_paintSwatch coverage_id] intValue];
    
    
    // Default edit behaviour
    //
    _editFlag  = FALSE;

    
    // Other flags
    //
    _isShipped  = [[_paintSwatch is_shipped] boolValue];

    
    // Is Favorite Button
    //
    _isFavorite = [[_paintSwatch is_favorite] boolValue];
    _isFavoriteTextButton = [self.toolbarItems objectAtIndex:ADD_FAVORITE_BTN_INDEX];
    [_isFavoriteTextButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            DEF_MD_ITALIC_FONT, NSFontAttributeName,
            DEF_TEXT_COLOR, NSForegroundColorAttributeName,
            nil] forState:UIControlStateNormal];
    
    _myFavoriteButton = [self.toolbarItems objectAtIndex:MY_FAVORITE_BTN_INDEX];
    [_myFavoriteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   DEF_MD_ITALIC_FONT, NSFontAttributeName,
                                                   DEF_TEXT_COLOR, NSForegroundColorAttributeName,
                                                   nil] forState:UIControlStateNormal];
    
    [self setIsFavoriteText];

    
    // NSUserDefaults
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Table View Headers
    //
    _defNameHeader        = @"Thumbnail and Color Name";
    _subjColorHeader      = @"My Color Group";
    _propsHeader          = @"Hue-Based Category";
    _swatchTypeHeader     = @"Association Type";
    _paintBrandHeader     = @"Paint Brand";
    _bodyTypeHeader       = @"Body Type";
    _pigmentTypeHeader    = @"Pigment Type";
    _canvasCoverageHeader = @"Canvas Coverage Thickness";
    _keywHeader           = @"My Topics";
    _commentsHeader       = @"Comments";
    _refsHeader           = @"Reference Colors (Mix Types Only)";
    _mixAssocHeader       = @"Collections Containing this Color";
    _matchAssocHeader     = @"My Matches";

    
    // Set the placeholders
    //
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Color Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = @" - Semicolon-sep. topics, comma-sep. comps - ";
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Comments (max. %i chars) - ", MAX_DESC_LEN];
    _otherPlaceholder = [[NSString alloc] initWithFormat:@" - Other Paint Brand (max. of %i chars) - ", MAX_BRAND_LEN];

    
    // A few defaults
    //
    _imageViewWidth       = DEF_CELL_HEIGHT;
    _imageViewHeight      = DEF_CELL_HEIGHT;
    _typesPickerSelRow    = type_id         ? type_id         : 0;
    _colorPickerSelRow    = subj_color_id   ? subj_color_id   : 0;
    _brandPickerSelRow    = brand_id        ? brand_id        : 0;
    _otherName            = brand_name      ? brand_name      : @"";
    _bodyPickerSelRow     = body_type_id    ? body_type_id    : 0;
    _pigmentPickerSelRow  = pigment_type_id ? pigment_type_id : 0;
    _coveragePickerSelRow = coverage_id     ? coverage_id     : 0;

    
    _colorPickerFlag    = FALSE;
    _typesPickerFlag    = FALSE;
    _brandPickerFlag    = FALSE;
    _bodyPickerFlag     = FALSE;
    _pigmentPickerFlag  = FALSE;
    _coveragePickerFlag = FALSE;


    // Offsets and Widths
    //
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / DEF_Y_OFFSET_DIVIDER;


    // Attributes
    //
    _nameEntered = [_paintSwatch name];


    // Picker entities
    //
    id typeObj = [ManagedObjectUtils queryDictionaryName:@"PaintSwatchType" entityId:_typesPickerSelRow context:self.context];
    NSString *typeName = [typeObj name];
    _swatchTypeName  = [FieldUtils createTextField:typeName tag:TYPE_FIELD_TAG];
    [_swatchTypeName setTextAlignment:NSTextAlignmentCenter];
    [_swatchTypeName setDelegate:self];
    _swatchTypeNames = [ManagedObjectUtils fetchDictNames:@"PaintSwatchType" context:self.context];
    _swatchTypesPicker = [self createPicker:SWATCH_PICKER_TAG selectRow:[[_paintSwatch type_id] intValue] action:@selector(typesSelection) textField:_swatchTypeName];

    id colorObj = [ManagedObjectUtils queryDictionaryName:@"SubjectiveColor" entityId:_colorPickerSelRow context:self.context];
    NSString *colorName = [colorObj name];
    _subjColorName = [FieldUtils createTextField:colorName tag:COLOR_FIELD_TAG];
    [_subjColorName setTextAlignment:NSTextAlignmentCenter];
    [_subjColorName setDelegate:self];
    _subjColorNames  = [ManagedObjectUtils fetchDictNames:@"SubjectiveColor" context:self.context];
    _subjColorData = [ManagedObjectUtils fetchSubjectiveColors:self.context];
    _subjColorPicker = [self createPicker:COLOR_PICKER_TAG selectRow:[[_paintSwatch subj_color_id] intValue] action:@selector(colorSelection) textField:_subjColorName];
    
    id brandObj = [ManagedObjectUtils queryDictionaryName:@"PaintBrand" entityId:_brandPickerSelRow context:self.context];
    NSString *brandName = [brandObj name];
    _paintBrandName = [FieldUtils createTextField:brandName tag:BRAND_FIELD_TAG];
    [_paintBrandName setTextAlignment:NSTextAlignmentCenter];
    [_paintBrandName setDelegate:self];
    _paintBrandNames  = [ManagedObjectUtils fetchDictNames:@"PaintBrand" context:self.context];
    _paintBrandPicker = [self createPicker:BRAND_PICKER_TAG selectRow:[[_paintSwatch paint_brand_id] intValue] action:@selector(brandSelection) textField:_paintBrandName];
    
    _otherNameField = [FieldUtils createTextField:_otherName tag:OTHER_FIELD_TAG];
    [_otherNameField setTextAlignment:NSTextAlignmentCenter];
    [_otherNameField setDelegate:self];
    
    id bodyObj = [ManagedObjectUtils queryDictionaryName:@"BodyType" entityId:_bodyPickerSelRow context:self.context];
    NSString *bodyName = [bodyObj name];
    _bodyTypeName = [FieldUtils createTextField:bodyName tag:BODY_FIELD_TAG];
    [_bodyTypeName setTextAlignment:NSTextAlignmentCenter];
    [_bodyTypeName setDelegate:self];
    _bodyTypeNames  = [ManagedObjectUtils fetchDictNames:@"BodyType" context:self.context];
    _bodyTypePicker = [self createPicker:BODY_PICKER_TAG selectRow:[[_paintSwatch body_type_id] intValue] action:@selector(bodySelection) textField:_bodyTypeName];
    
    id pigmentObj = [ManagedObjectUtils queryDictionaryName:@"PigmentType" entityId:_pigmentPickerSelRow context:self.context];
    NSString *pigmentName = [pigmentObj name];
    _pigmentTypeName = [FieldUtils createTextField:pigmentName tag:PIGMENT_FIELD_TAG];
    [_pigmentTypeName setTextAlignment:NSTextAlignmentCenter];
    [_pigmentTypeName setDelegate:self];
    _pigmentTypeNames  = [ManagedObjectUtils fetchDictNames:@"PigmentType" context:self.context];
    _pigmentTypePicker = [self createPicker:PIGMENT_PICKER_TAG selectRow:[[_paintSwatch pigment_type_id] intValue] action:@selector(pigmentSelection) textField:_pigmentTypeName];
    
    id coverageObj = [ManagedObjectUtils queryDictionaryName:@"CanvasCoverage" entityId:_coveragePickerSelRow context:self.context];
    NSString *coverageName = [coverageObj name];
    _coverageName = [FieldUtils createTextField:coverageName tag:COVERAGE_FIELD_TAG];
    [_coverageName setTextAlignment:NSTextAlignmentCenter];
    [_coverageName setDelegate:self];
    _coverageNames  = [ManagedObjectUtils fetchDictNames:@"CanvasCoverage" context:self.context];
    _coveragePicker = [self createPicker:COVERAGE_PICKER_TAG selectRow:[[_paintSwatch coverage_id] intValue] action:@selector(coverageSelection) textField:_coverageName];
    
    NSSet *swatchKeywords = [_paintSwatch swatch_keyword];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (SwatchKeyword *swatch_keyword in swatchKeywords) {
        Keyword *keyword = [swatch_keyword keyword];
        [keywords addObject:[keyword name]];
    }
    _keywEntered = [keywords componentsJoinedByString:KEYW_DISP_SEPARATOR];
    
    
    _descEntered = [_paintSwatch desc] ? [_paintSwatch desc] : @"";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Edit Mode Button
    //
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes: @{NSForegroundColorAttributeName:DEF_TEXT_COLOR, NSFontAttributeName:DEF_MD_ITALIC_FONT} forState:UIControlStateNormal];

    // All Features?
    //
    //if (ALL_FEATURES == 0)
    //    [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
    
    
    [self makeTextFieldsNonEditable];
    
    // Swatch Detail Edit Button Alert Controller
    //
    _saveAlertController = [UIAlertController alertControllerWithTitle:@"Color Detail Edit"
                                                               message:@"Please select operation"
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    // Modified globally (i.e., enable/disable)
    //
    _save = [UIAlertAction actionWithTitle:@"Save Changes" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self saveData];
                                   }];
    
    _delete = [UIAlertAction actionWithTitle:@"Delete Color" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self deleteData];
                                                       
                                                   }];
    
    UIAlertAction *hide = [UIAlertAction actionWithTitle:@"Hide Color" style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [self hideSwatch];
                                     }];
    
    UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_saveAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_saveAlertController addAction:_save];
    [_saveAlertController addAction:_delete];
    
    // ***** Will activate this for next release (if really needed) *****
    //
    [_saveAlertController addAction:hide];
    [hide setEnabled:FALSE];
    
    [_saveAlertController addAction:discard];
    
    // Change the default blue
    //
    //[_saveAlertController.view setTintColor:DEF_ALERT_TEXT_COLOR];

    
    // Check if delete should be disabled (i.e., if PaintSwatch is referenced by any association)
    //
    int assoc_ct   = (int)[[ManagedObjectUtils queryEntityRelation:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"MixAssocSwatch" context:self.context] count];
    int match_ct = (int)[[ManagedObjectUtils queryEntityRelation:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"TapAreaSwatch" context:self.context] count];
    
    if ((assoc_ct > 0) || (match_ct > 0)) {
        [_delete setEnabled:FALSE];
    }
    
    [_save setEnabled:FALSE];
    
    // Initialize a tap gesture recognizer to segue into a Color View
    //
    _tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(respondToTap:)];
    [_tapRecognizer setNumberOfTapsRequired:DEF_NUM_TAPS];
    
    // Adjust the layout with rotational changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFrameSizes)
        name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavTitle];

    if([_userDefaults boolForKey:TAP_NOTE_KEY] == TRUE) {
        _nameHeader = @"Thumbnail (Tap to Expand) and Name";
    } else {
        _nameHeader = _defNameHeader;
    }
    NUM_TABLEVIEW_ROWS   = (int)[_mixAssocSwatches count];

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    _isReadOnly = FALSE;

    BOOL is_readonly = [[_paintSwatch is_readonly] boolValue];
    _isReadOnly = _isShipped ? _isShipped : is_readonly;
    
    if (_isReadOnly == TRUE) {
        [_delete setEnabled:FALSE];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)setFrameSizes {

    // Text view widths
    //
    CGFloat viewWidth = self.tableView.bounds.size.width;
    CGFloat fullTextFieldWidth = viewWidth - DEF_MD_FIELD_PADDING;
    CGFloat xOffset = DEF_FIELD_PADDING;
    
    //_colorTextFieldWidth = viewWidth - _imageViewWidth - DEF_MD_FIELD_PADDING;

    //[_subjColorName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _colorTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_subjColorName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_swatchTypeName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_paintBrandName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_bodyTypeName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_pigmentTypeName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_coverageName setFrame:CGRectMake(xOffset, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DETAIL_MAX_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == DETAIL_ASSOC_SECTION) {
        return NUM_TABLEVIEW_ROWS;
        
    } else if ((section == DETAIL_REF_SECTION) && (_refPaintSwatch != nil) && (_mixPaintSwatch != nil)) {
            return 2;

    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == DETAIL_ASSOC_SECTION) {
        return DEF_CELL_HEIGHT + DEF_FIELD_PADDING + DEF_FIELD_INSET;
        
    } else if (indexPath.section == DETAIL_NAME_SECTION) {
        return DEF_VLG_TBL_CELL_HGT;
        
    } else if (indexPath.section == DETAIL_KEYW_SECTION) {
        return DEF_LG_TABLE_CELL_HGT;
        
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    //[tableView setSeparatorColor:GRAY_BG_COLOR];
    
    if (indexPath.section < DETAIL_ASSOC_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAIL_REUSE_CELL_IDENTIFIER forIndexPath:indexPath];
        
        // Global defaults
        //
        [cell setBackgroundColor:DEF_BG_COLOR];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.imageView setImage:nil];
        [cell.textLabel setText:@""];
        [cell.contentView setBackgroundColor:DEF_BG_COLOR];


        // Set the widget frame sizes
        //
        [self setFrameSizes];
        
        // Remove dynamic text fields
        //
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UITextField class]] || [subview isKindOfClass:[UITextView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        // Name, and reference type
        //
        if (indexPath.section == DETAIL_NAME_SECTION) {
            [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
            [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
            [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
            cell.imageView.contentMode   = UIViewContentModeScaleAspectFill;
            cell.imageView.clipsToBounds = YES;

            CGFloat imageViewWidth   = DEF_CELL_HEIGHT;
            CGFloat textFieldYOffset = (imageViewWidth - DEF_TEXTVIEW_HEIGHT) / DEF_Y_OFFSET_DIVIDER;
            
            cell.imageView.image = [AppColorUtils renderSwatch:_paintSwatch cellWidth:imageViewWidth cellHeight:imageViewWidth context:self.context isRGB:0];
            
            [cell.imageView addGestureRecognizer:_tapRecognizer];
            [cell.imageView setUserInteractionEnabled:YES];
            
            CGFloat refNameWidth = self.tableView.bounds.size.width - imageViewWidth - DEF_SM_TABLE_CELL_HGT;
            UITextView *refName  = [FieldUtils createTextView:_nameEntered tag:NAME_FIELD_TAG];
            [refName setFrame:CGRectMake(imageViewWidth + DEF_XLG_FIELD_PADDING, textFieldYOffset, refNameWidth, DEF_TEXTVIEW_HEIGHT)];
            [refName setDelegate:self];

            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_nameEntered isEqualToString:@""]) {
                    [refName setText:_namePlaceholder];
                }
                
                if (_isReadOnly == TRUE || ALL_FEATURES == 0) {
                    [FieldUtils makeTextViewNonEditable:refName content:_nameEntered border:FALSE];
                }
                
            } else {
                [FieldUtils makeTextViewNonEditable:refName content:_nameEntered border:FALSE];
                [refName setBackgroundColor:CLEAR_COLOR];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        
        // Subjective color field
        //
        } else if (indexPath.section == DETAIL_COLOR_SECTION) {
            //[cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
            //[cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
            //[cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
            //cell.imageView.contentMode   = UIViewContentModeScaleAspectFill;
            //cell.imageView.clipsToBounds = YES;
            //cell.imageView.image = [AppColorUtils renderRGB:_paintSwatch cellWidth:DEF_MD_TABLE_CELL_HGT cellHeight:DEF_TEXTFIELD_HEIGHT];

            [cell.contentView addSubview:_subjColorName];
            
        } else if (indexPath.section == DETAIL_PROPS_SECTION) {
            NSString *colorName = [AppColorUtils colorCategoryFromHue:_paintSwatch];
            [cell.textLabel setText:colorName];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell.textLabel setFont:DEF_LABEL_FONT];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
        // Swatch type field
        //
        } else if (indexPath.section == DETAIL_TYPES_SECTION) {
            [cell.contentView addSubview:_swatchTypeName];
            if (ALL_FEATURES == 0) {
                [FieldUtils makeTextFieldNonEditable:_swatchTypeName content:[_swatchTypeName text] border:FALSE];
            }
            
        // Paint Brand field
        //
        } else if (indexPath.section == DETAIL_BRAND_SECTION) {
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_paintBrandName];
                if (ALL_FEATURES == 0) {
                    [FieldUtils makeTextFieldNonEditable:_paintBrandName content:[_paintBrandName text] border:FALSE];
                }
                
            } else {

                UITextField *otherNameField  = [FieldUtils createTextField:_otherName tag:OTHER_FIELD_TAG];
                [otherNameField setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
                [otherNameField setDelegate:self];
                [cell.contentView addSubview:otherNameField];
                
                if (_editFlag == TRUE) {
                    if ([_otherName isEqualToString:@""]) {
                        [otherNameField setPlaceholder:_otherPlaceholder];
                    }
                    
                } else {
                    [FieldUtils makeTextFieldNonEditable:otherNameField content:_otherName border:FALSE];
                }
                [cell setAccessoryType: UITableViewCellAccessoryNone];
            }
            
        // Body type field
        //
        } else if (indexPath.section == DETAIL_BODY_SECTION) {
            [cell.contentView addSubview:_bodyTypeName];
            if (ALL_FEATURES == 0) {
                [FieldUtils makeTextFieldNonEditable:_bodyTypeName content:[_bodyTypeName text] border:FALSE];
            }
            
        // Pigment type field
        //
        } else if (indexPath.section == DETAIL_PIGMENT_SECTION) {
            [cell.contentView addSubview:_pigmentTypeName];
            if (ALL_FEATURES == 0) {
                [FieldUtils makeTextFieldNonEditable:_pigmentTypeName content:[_pigmentTypeName text] border:FALSE];
            }
            
        // Canvas Coverage field
        //
        } else if (indexPath.section == DETAIL_COVERAGE_SECTION) {
            [cell.contentView addSubview:_coverageName];
            if (ALL_FEATURES == 0) {
                [FieldUtils makeTextFieldNonEditable:_coverageName content:[_coverageName text] border:FALSE];
            }
        
        // Keywords field
        //
        } else if (indexPath.section == DETAIL_KEYW_SECTION) {
            UITextView *refName  = [FieldUtils createTextView:_keywEntered tag:KEYW_FIELD_TAG];
            CGFloat yOffset = (DEF_LG_TABLE_CELL_HGT - DEF_TEXTVIEW_HEIGHT) / DEF_Y_OFFSET_DIVIDER;
            [refName setFrame:CGRectMake(DEF_FIELD_PADDING, yOffset, self.tableView.bounds.size.width - DEF_MD_FIELD_PADDING, DEF_TEXTVIEW_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_keywEntered isEqualToString:@""]) {
                    [refName setText:_keywPlaceholder];
                }
                
            } else {
                [FieldUtils makeTextViewNonEditable:refName content:_keywEntered border:FALSE];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];

        // Comments/Description field
        //
        } else if (indexPath.section == DETAIL_DESC_SECTION) {
        
            // Create the description/comments text field
            //
            UITextField *refName  = [FieldUtils createTextField:_descEntered tag:DESC_FIELD_TAG];
            [refName setFrame:CGRectMake(DEF_FIELD_PADDING, _textFieldYOffset, self.tableView.bounds.size.width - DEF_MD_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_descEntered isEqualToString:@""]) {
                    [refName setPlaceholder:_descPlaceholder];
                }
                
            } else {
                [FieldUtils makeTextFieldNonEditable:refName content:_descEntered border:FALSE];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        
        } else if (indexPath.section == DETAIL_REF_SECTION) {
            [cell setBackgroundColor:DEF_BG_COLOR];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            if ((_refPaintSwatch != nil) && (_mixPaintSwatch != nil)) {
                [cell.imageView setFrame:CGRectMake(DEF_FIELD_PADDING, DEF_Y_OFFSET, cell.bounds.size.height, cell.bounds.size.height)];
                [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
                [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
                [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
                
                [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
                [cell.imageView setClipsToBounds:YES];
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell.textLabel setFont:TABLE_CELL_FONT];
                [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
                
                if (indexPath.row == 0) {
                    [cell.imageView setImage:[AppColorUtils renderSwatch:_refPaintSwatch cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height context:self.context isRGB:nil]];
                    [cell.textLabel setText:[_refPaintSwatch name]];

                } else {
                    // Detail Mix Section
                    //
                    [cell.imageView setImage:[AppColorUtils renderSwatch:_mixPaintSwatch cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height context:self.context isRGB:nil]];
                    [cell.textLabel setText:[_mixPaintSwatch name]];
                }
            } else {
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                [cell.textLabel setFont:DEF_LABEL_FONT];
                if ([[_swatchTypeName text] isEqualToString:@"MixAssoc"]) {
                    [cell.textLabel setText:@"Not Shown in this Context"];
                } else {
                    [cell.textLabel setText:@"Not Applicable"];
                }
            }
        }
        
        return cell;

    // Associations (if any) as rows of collection views
    //
    } else {
        CustomCollectionTableViewCell *custCell = (CustomCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        [custCell setBackgroundColor:DEF_BG_COLOR];
        
        if (! custCell) {
            custCell = [[CustomCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier cellHeight:DEF_CELL_HEIGHT collectViewInset:DEF_FIELD_INSET padding:DEF_CELL_PADDING backgroundColor:DEF_BG_COLOR];
        }
        
        MixAssocSwatch *mixAssocSwatchObj = [_mixAssocSwatches objectAtIndex:indexPath.row];
        MixAssociation *mixAssocObj = [mixAssocSwatchObj mix_association];
        NSString *mix_name = [mixAssocObj name];
        if (mix_name == nil) {
            mix_name = NO_MIX_NAME;
        }
        
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"^- Include Mix .*"
                                      options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange searchedRange = NSMakeRange(0, [mix_name length]);
        
        if(error != nil) {
            NSLog(@"Error: %@", error);
            
        } else {
            NSArray *matches = [regex matchesInString:mix_name options:NSMatchingAnchored range:searchedRange];
            if ([matches count] > 0) {
                PaintSwatches *ref = [[self.colorArray objectAtIndex:indexPath.row] objectAtIndex:0];
                PaintSwatches *mix = [[self.colorArray objectAtIndex:indexPath.row] objectAtIndex:1];
                
                mix_name = [[NSString alloc] initWithFormat:@"%@ and %@ Mix", ref.name, mix.name];
            }
        }

        NSString *mixName = [[NSString alloc] initWithFormat:@"%@", mix_name];
        [custCell addLabel:[FieldUtils createLabel:mixName xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:custCell.contentView.bounds.size.width height:DEF_LABEL_HEIGHT]];
        [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
        NSInteger index = custCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
        return custCell;
    }
}

// Delegated to the collection view
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((
         (section == DETAIL_BRAND_SECTION)   ||
         (section == DETAIL_BODY_SECTION)    ||
         (section == DETAIL_PIGMENT_SECTION) ||
         (section == DETAIL_BRAND_SECTION)
         ) && (![[_swatchTypeNames objectAtIndex:_typesPickerSelRow] isEqualToString:@"Reference"])) {
        return DEF_NIL_HEADER;
        
    } else if ((section == DETAIL_COVERAGE_SECTION)
               && ([[_swatchTypeNames objectAtIndex:_typesPickerSelRow] isEqualToString:@"Generic"])) {
        return DEF_NIL_HEADER;

    } else if ((
         ((section == DETAIL_NAME_SECTION)  && [_nameEntered isEqualToString:@""]) ||
         ((section == DETAIL_KEYW_SECTION)  && [_keywEntered isEqualToString:@""]) ||
         ((section == DETAIL_DESC_SECTION)  && [_descEntered isEqualToString:@""])
         ) && (_editFlag == FALSE)) {
        return DEF_NIL_HEADER;
        
    } else if ((section == DETAIL_REF_SECTION) && ((_refPaintSwatch == nil) || (_mixPaintSwatch == nil))) {
        return DEF_NIL_HEADER;
        
    // For now, hide this
    //
    } else if (section == DETAIL_PROPS_SECTION) {
        return DEF_NIL_HEADER;

    } else {
        return DEF_TABLE_HDR_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //
    [view setTintColor:CLEAR_COLOR];

    
    // Text Color and Size
    //
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    [header.textLabel setTextColor:LIGHT_TEXT_COLOR];
    [header.textLabel setFont:DEF_TBL_HEADER_FONT];
    
//    if (section == DETAIL_PROPS_SECTION) {
//        [header.textLabel setFont:ITALIC_FONT];
//    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *headerStr;
    if (section == DETAIL_NAME_SECTION) {
        headerStr = _nameHeader;
    } else if (section == DETAIL_COLOR_SECTION) {
        //NSString *colorName = [AppColorUtils colorCategoryFromHue:_paintSwatch];
        headerStr = _subjColorHeader;
        //headerStr = [[NSString alloc] initWithFormat:@"%@ (Hue: %@)", _subjColorHeader, colorName];
        
    } else if (section == DETAIL_PROPS_SECTION) {
        headerStr = _propsHeader;
//        headerStr = [[NSString alloc] initWithFormat:@"RGB=%i,%i,%i HSB=%.02f,%.02f,%.02f", [[_paintSwatch red] intValue], [[_paintSwatch green] intValue], [[_paintSwatch blue] intValue], [[_paintSwatch hue] floatValue], [[_paintSwatch saturation] floatValue], [[_paintSwatch brightness] floatValue]];
        
    } else if (section == DETAIL_TYPES_SECTION) {
        headerStr = _swatchTypeHeader;
        
    } else if (section == DETAIL_BRAND_SECTION) {
        headerStr = _paintBrandHeader;
        
    } else if (section == DETAIL_BODY_SECTION) {
        headerStr = _bodyTypeHeader;
        
    } else if (section == DETAIL_PIGMENT_SECTION) {
        headerStr = _pigmentTypeHeader;
        
    } else if (section == DETAIL_COVERAGE_SECTION) {
        headerStr = _canvasCoverageHeader;
        
    } else if (section == DETAIL_KEYW_SECTION) {
        headerStr = _keywHeader;
        
    } else if (section == DETAIL_DESC_SECTION) {
        headerStr = _commentsHeader;
        
    } else if (section == DETAIL_REF_SECTION) {
        headerStr = _refsHeader;
        
    } else {
        headerStr = _mixAssocHeader;
    }


    return [headerStr uppercaseString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == DETAIL_REF_SECTION)
        && (_refPaintSwatch != nil) && (_mixPaintSwatch != nil)) {
        if (indexPath.row == 0) {
            _selPaintSwatch = _refPaintSwatch;
        } else {
            _selPaintSwatch = _mixPaintSwatch;
        }
        [self performSegueWithIdentifier:@"DetailToRefSegue" sender:self];
    }
}

// Only the field contents can be edited
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// flag is 1 after pressing the 'Edit' button
//
- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];
    
    _editFlag = flag;
    
    if (_editFlag == FALSE) {
        [self makeTextFieldsNonEditable];
        if (([_save isEnabled] == TRUE) || ([_delete isEnabled] == TRUE)) {
            [self presentViewController:_saveAlertController animated:YES completion:nil];
        }
    } else {
        [self makeTextFieldsEditable];
    }
    
    [self.tableView reloadData];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Textfield Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextField Methods

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return YES;
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == TYPE_FIELD_TAG) {
        _typesPickerFlag = TRUE;
        
    } else if (textField.tag == COLOR_FIELD_TAG) {
        _colorPickerFlag = TRUE;
        
    } else if (textField.tag == BRAND_FIELD_TAG) {
        _brandPickerFlag = TRUE;
        
    } else if (textField.tag == BODY_FIELD_TAG) {
        _bodyPickerFlag = TRUE;
        
    } else if (textField.tag == PIGMENT_FIELD_TAG) {
        _pigmentPickerFlag = TRUE;
        
    } else if (textField.tag == COVERAGE_FIELD_TAG) {
        _coveragePickerFlag = TRUE;
    }
    [self setFrameSizes];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [GenericUtils trimString:textField.text];
    
    if ((textField.tag == OTHER_FIELD_TAG) && [textField.text isEqualToString:@""] && (_brandPickerSelRow == 0)) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        if (textField.tag == DESC_FIELD_TAG) {
            _descEntered = textField.text;
        } else if (textField.tag == OTHER_FIELD_TAG) {
            _otherName   = textField.text;
        }
        
        [_save setEnabled:TRUE];
    }
    
    [textField resignFirstResponder];
    _typesPickerFlag    = FALSE;
    _colorPickerFlag    = FALSE;
    _brandPickerFlag    = FALSE;
    _bodyPickerFlag     = FALSE;
    _pigmentPickerFlag  = FALSE;
    _coveragePickerFlag = FALSE;

    [self.tableView reloadData];
    
    [self setFrameSizes];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == DESC_FIELD_TAG && textField.text.length >= MAX_DESC_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert:MAX_DESC_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == OTHER_FIELD_TAG && textField.text.length >= MAX_BRAND_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert:MAX_BRAND_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TextView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextView Methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag == NAME_FIELD_TAG) {
        [textView setText:[GenericUtils trimString:[textView text]]];
        if ([textView.text isEqualToString:@""]) {
            UIAlertController *myAlert = [AlertUtils noValueAlert];
            [self presentViewController:myAlert animated:YES completion:nil];
        }
        _nameEntered = [textView text];

    } else if (textView.tag == KEYW_FIELD_TAG) {
        if ([[textView text] isEqualToString:_keywPlaceholder]) {
            [textView setText:@""];
        }
        _keywEntered = [textView text];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.tag == NAME_FIELD_TAG) {
        _nameEntered = [textView text];

    } else if (textView.tag == KEYW_FIELD_TAG) {
        _keywEntered = [textView text];
    }
    [_save setEnabled:TRUE];
}

-(BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

// Disable the return button for newlines (resignFirstResponder instead_
//
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        return (long)[_swatchTypeNames count];
        
    } else if (pickerView.tag == COLOR_PICKER_TAG) {
        return (long)[_subjColorNames count];
        
    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        return (long)[_paintBrandNames count];
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        return (long)[_bodyTypeNames count];

    } else if (pickerView.tag == COVERAGE_PICKER_TAG) {
        return (long)[_coverageNames count];

    } else {
        return (long)[_pigmentTypeNames count];
    }
}

// Row height
//
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return DEF_PICKER_ROW_HEIGHT;
}

// The data to return for the row and component (column) that's being passed in
//
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        return [_swatchTypeNames objectAtIndex:row];
        
    } else if (pickerView.tag == COLOR_PICKER_TAG) {
        return [_subjColorNames objectAtIndex:row];
    
    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        return [_paintBrandNames objectAtIndex:row];
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        return [_bodyTypeNames objectAtIndex:row];
    
    } else if (pickerView.tag == COVERAGE_PICKER_TAG) {
        return [_coverageNames objectAtIndex:row];
        
    } else {
        return [_pigmentTypeNames objectAtIndex:row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel *label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET,DEF_Y_OFFSET,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
    }
    
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        [label setText:[_swatchTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];

    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        [label setText:[_paintBrandNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        [label setText:[_bodyTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
    
    } else if (pickerView.tag == PIGMENT_PICKER_TAG) {
        [label setText:[_pigmentTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];

    } else if (pickerView.tag == COVERAGE_PICKER_TAG) {
        [label setText:[_coverageNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];

    } else {
        NSString *colorName = [_subjColorNames objectAtIndex:row];
        UIColor *backgroundColor = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
        
        [label setTextColor:[ColorUtils setBestColorContrast:colorName darkColor:DARK_TEXT_COLOR lightColor:LIGHT_TEXT_COLOR]];
        [label setBackgroundColor:backgroundColor];
        [label setText:[_subjColorNames objectAtIndex:row]];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        NSString *swatchType = [_swatchTypeNames objectAtIndex:row];
        [_swatchTypeName setText:swatchType];
        [_paintSwatch setType_id:[NSNumber numberWithInteger:row]];
        _typesPickerSelRow = (int)row;
        
    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        NSString *paintBrand = [_paintBrandNames objectAtIndex:row];
        [_paintBrandName setText:paintBrand];
        [_paintSwatch setPaint_brand_id:[NSNumber numberWithInteger:row]];
        _brandPickerSelRow = (int)row;
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        NSString *bodyType = [_bodyTypeNames objectAtIndex:row];
        [_bodyTypeName setText:bodyType];
        [_paintSwatch setBody_type_id:[NSNumber numberWithInteger:row]];
        
    } else if (pickerView.tag == PIGMENT_PICKER_TAG) {
        NSString *pigmentType = [_pigmentTypeNames objectAtIndex:row];
        [_pigmentTypeName setText:pigmentType];
        [_paintSwatch setPigment_type_id:[NSNumber numberWithInteger:row]];

    } else if (pickerView.tag == COVERAGE_PICKER_TAG) {
        NSString *coverageType = [_coverageNames objectAtIndex:row];
        [_coverageName setText:coverageType];
        [_paintSwatch setCoverage_id:[NSNumber numberWithInteger:row]];

    } else {
        [self setColorPickerValues:(int)row];
        [_paintSwatch setSubj_color_id:[NSNumber numberWithInt:[[[_subjColorData objectForKey:_colorSelected] valueForKey:@"id"] intValue]]];
    }
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
    [pickerParentView setBackgroundColor:DEF_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:picker];
    
    [textField setInputView:pickerParentView];
    
    // Need to prevent text from clearing
    
    [picker selectRow:selectRow inComponent:0 animated:YES];
    
    return picker;
}

// Generic picker selection
//
- (void)typesSelection {
    int row = [[_paintSwatch type_id] intValue];
    [_swatchTypeName setText:[_swatchTypeNames objectAtIndex:row]];
    [_swatchTypesPicker selectRow:row inComponent:0 animated:YES];
    [_swatchTypeName resignFirstResponder];
}

- (void)colorSelection {
    int row = [[_paintSwatch subj_color_id] intValue];
    [_subjColorName setText:[_subjColorNames objectAtIndex:row]];
    [_subjColorPicker selectRow:row inComponent:0 animated:YES];
    [_subjColorName resignFirstResponder];
}

- (void)brandSelection {
    int row = [[_paintSwatch paint_brand_id] intValue];
    [_paintBrandName setText:[_paintBrandNames objectAtIndex:row]];
    [_paintBrandPicker selectRow:row inComponent:0 animated:YES];
    [_paintBrandName resignFirstResponder];
}

- (void)bodySelection {
    int row = [[_paintSwatch body_type_id] intValue];
    [_bodyTypeName setText:[_bodyTypeNames objectAtIndex:row]];
    [_bodyTypePicker selectRow:row inComponent:0 animated:YES];
    [_bodyTypeName resignFirstResponder];
}

- (void)coverageSelection {
    int row = [[_paintSwatch coverage_id] intValue];
    [_coverageName setText:[_coverageNames objectAtIndex:row]];
    [_coveragePicker selectRow:row inComponent:0 animated:YES];
    [_coverageName resignFirstResponder];
}

- (void)pigmentSelection {
    int row = [[_paintSwatch pigment_type_id] intValue];
    [_pigmentTypeName setText:[_pigmentTypeNames objectAtIndex:row]];
    [_pigmentTypePicker selectRow:row inComponent:0 animated:YES];
    [_pigmentTypeName resignFirstResponder];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// CollectionView and ScrollView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - CollectionView and ScrollView Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int index = (int)collectionView.tag;
    
    NSArray *collectionViewArray = [self.colorArray objectAtIndex:index];
    
    return [collectionViewArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    int index = (int)collectionView.tag;
    
    PaintSwatches *paintSwatch = [[self.colorArray objectAtIndex:index] objectAtIndex:indexPath.row];
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:[AppColorUtils renderSwatch:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight context:self.context isRGB:nil]];
    
    [swatchImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    [swatchImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    [swatchImageView.layer setCornerRadius: DEF_CORNER_RADIUS];
    [swatchImageView setContentMode: UIViewContentModeScaleAspectFill];
    [swatchImageView setClipsToBounds: YES];
    [swatchImageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
    
    cell.backgroundView = swatchImageView;
    
    return cell;
}

// Do not want to create a never ending circular navigation so making this collection non-selectable
// In order to view relations, the View Controller selection/search in the home page will be used
//
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int)collectionView.tag;
    _collectViewSelRow = index;
    
    [self performSegueWithIdentifier:@"DetailToAssocSegue" sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;

    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *reusableview = nil;
//    
//    if (kind == UICollectionElementKindSectionHeader) {
//        
//        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectionHeaderCellIdentifier forIndexPath:indexPath];
//        
//        //headerView.usernameLabel.text = @"hello";
//        
//        reusableview = headerView;
//    }
//    
//    return reusableview;
//}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GestureRecognizer Method
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - GestureRecognizer Method

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return true;
}

- (void)respondToTap:(id)sender {
    [self performSegueWithIdentifier:@"ColorViewSegue" sender:self];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation and Other Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation and Other Methods

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //
    UINavigationController *navigationViewController = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"DetailToAssocSegue"]) {
        AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
        
        [assocTableViewController setPaintSwatches:self.colorArray[_collectViewSelRow]];
        [assocTableViewController setMixAssociation:[[_mixAssocSwatches objectAtIndex:_collectViewSelRow] mix_association]];
        [assocTableViewController setSaveFlag:TRUE];
        [assocTableViewController setSourceViewName:@"SwatchDetail"];
        
    } else if ([[segue identifier] isEqualToString:@"ColorViewSegue"]) {
        ColorViewController *colorViewController = (ColorViewController *)([navigationViewController viewControllers][0]);
        
        [colorViewController setPaintSwatch:_paintSwatch];
        
        // User should now be aware of this behavior so don't show any longer
        //
        _nameHeader = _defNameHeader;
        [_userDefaults setBool:FALSE forKey:TAP_NOTE_KEY];

    } else if ([[segue identifier] isEqualToString:@"DetailToRefSegue"]) {
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        [swatchDetailTableViewController setPaintSwatch:_selPaintSwatch];
        
    } else if ([[segue identifier] isEqualToString:@"DetailToFavoritesSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        MainViewController *mainViewController = (MainViewController *)([navigationViewController viewControllers][0]);
        [mainViewController setListingType:FULL_LISTING_TYPE];
        [mainViewController setIsLandscape:FALSE];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General purpose methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


- (IBAction)goBack:(id)sender {
    [super dismissViewControllerAnimated:YES completion:NULL];
}

- (void)saveData {

    // Delete all  associations first and then add them back in (the cascade delete rules should
    // automatically delete the SwatchKeyword)
    //
    [ManagedObjectUtils deleteSwatchKeywords:_paintSwatch context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_keywEntered componentsSeparatedByString:KEYW_PROC_SEPARATOR]];
    
    for (NSString *keyword in keywords) {
        if ([keyword isEqualToString:@""]) {
            continue;
        }
        
        Keyword *kwObj = [ManagedObjectUtils queryKeyword:keyword context:self.context];
        if (kwObj == nil) {
            kwObj = [[Keyword alloc] initWithEntity:_keywordEntity insertIntoManagedObjectContext:self.context];
            [kwObj setName:keyword];
            [kwObj setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
        }
        
        SwatchKeyword *swKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"SwatchKeyword" context:self.context];
        
        if (swKwObj == nil) {
            swKwObj = [[SwatchKeyword alloc] initWithEntity:_swatchKeywordEntity insertIntoManagedObjectContext:self.context];
            [swKwObj setKeyword:kwObj];
            [swKwObj setPaint_swatch:(PaintSwatch *)_paintSwatch];
            [swKwObj setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];

            [_paintSwatch addSwatch_keywordObject:swKwObj];
            [kwObj addSwatch_keywordObject:swKwObj];
        }
    }
    [_paintSwatch setName:_nameEntered];
    [_paintSwatch setDesc:_descEntered];
    [_paintSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
    [_paintSwatch setIs_favorite:[NSNumber numberWithBool:_isFavorite]];
    
    if (_brandPickerSelRow == 0) {
        [_paintSwatch setPaint_brand_name:_otherName];
    } else {
        [_paintSwatch setPaint_brand_name:nil];
    }
    
    // Generally these would be associated with this PaintSwatch
    //
    [ManagedObjectUtils deleteOrphanPaintSwatchKeywords:self.context];

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"Color Detail Save" message:@"Error Saving"];
        [self presentViewController:myAlert animated:YES completion:nil];
    } else {
        NSLog(@"Color Detail Save Successful");
        
        [_save setEnabled:FALSE];
    }
}

- (void)saveFavorite {
    [_paintSwatch setIs_favorite:[NSNumber numberWithBool:_isFavorite]];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"Add/Remove Favorite" message:@"Error Saving"];
        [self presentViewController:myAlert animated:YES completion:nil];
    } else {
        NSLog(@"Add/Remove Favorite Successful");
    }
}

- (void)deleteData {
    
    // Only left relation since this is an orphan PaintSwatch
    //
    [ManagedObjectUtils deleteSwatchKeywords:_paintSwatch context:self.context];

    
    [self.context deleteObject:_paintSwatch];
    

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error deleting context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Color Delete Successful");
        
        [super dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)hideSwatch {
    
    // Set the is_visible flag
    //
    [_paintSwatch setIs_hidden:[NSNumber numberWithBool:TRUE]];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error deleting context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Swatch hide successful");
        
        [super dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)setColorPickerValues:(int)row {
    _colorSelected = [_subjColorNames objectAtIndex:row];
    [_subjColorName setText:[_subjColorNames objectAtIndex:row]];
    _subjColorValue = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:_colorSelected] valueForKey:@"hex"]];
    [_subjColorName setTextColor:[ColorUtils setBestColorContrast:_colorSelected darkColor:DARK_TEXT_COLOR lightColor:LIGHT_TEXT_COLOR]];
    [_subjColorName setBackgroundColor:_subjColorValue];
    [_subjColorPicker selectRow:row inComponent:0 animated:YES];
}

- (void)makeTextFieldsEditable {
    [FieldUtils makeTextFieldEditable:_subjColorName content:@""];
    [FieldUtils makeTextFieldEditable:_swatchTypeName content:@""];
    [FieldUtils makeTextFieldEditable:_paintBrandName content:@""];
    [FieldUtils makeTextFieldEditable:_bodyTypeName content:@""];
    [FieldUtils makeTextFieldEditable:_pigmentTypeName content:@""];
    [FieldUtils makeTextFieldEditable:_coverageName content:@""];
}

- (void)makeTextFieldsNonEditable {
    [FieldUtils makeTextFieldNonEditable:_subjColorName content:@"" border:FALSE];
    [FieldUtils makeTextFieldNonEditable:_swatchTypeName content:@"" border:FALSE];
    [FieldUtils makeTextFieldNonEditable:_paintBrandName content:@"" border:FALSE];
    [FieldUtils makeTextFieldNonEditable:_bodyTypeName content:@"" border:FALSE];
    [FieldUtils makeTextFieldNonEditable:_pigmentTypeName content:@"" border:FALSE];
    [FieldUtils makeTextFieldNonEditable:_coverageName content:@"" border:FALSE];
}

// Is Favorite
//
- (IBAction)addFavorite:(id)sender {
    if (_isFavorite == TRUE)
        _isFavorite = FALSE;
    else
        _isFavorite = TRUE;
    
    [self setIsFavoriteText];
    [self saveFavorite];
}

- (void)setIsFavoriteText {
    if (_isFavorite == TRUE) {
        [_isFavoriteTextButton setTitle:@"Remove Favorite"];
    } else {
        // Explicitly set in case nil
        //
        _isFavorite = FALSE;
        [_isFavoriteTextButton setTitle:@"Add Favorite"];
    }
    [self setNavTitle];
}

// Go to My Favorites
//
- (IBAction)myFavorites:(id)sender {
    if ((_isFavorite == TRUE) || ([ManagedObjectUtils fetchIsFavoriteCount:self.context] > 0)) {
        [self performSegueWithIdentifier:@"DetailToFavoritesSegue" sender:self];
    } else {
        UIAlertController *alert = [AlertUtils createOkAlert:@"My Favorites is Empty!" message:@"You currently don't have any favorites saved. Try adding this color."];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (IBAction)help:(id)sender {
    UIAlertController *alert = [AlertUtils createInfoAlert:@"Usage Tips:" message:DETAIL_INSTRUCTIONS];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)setNavTitle {
    NSString *modTitle;
    if ([[_swatchTypeName text] isEqualToString:@"MixAssoc"]) {
        modTitle = @"Mix";
    } else if ([[_swatchTypeName text] isEqualToString:@"GenericPaint"]) {
        modTitle = @"Generic Paint";
    } else {
        modTitle = [_swatchTypeName text];
    }
    
    NSString *title = [GenericUtils trimString:[[NSString alloc] initWithFormat:@" %@ Detail", modTitle]];
    
    // Compute the max available size for the Nav bar title
    //
    CGFloat mainViewWidth     = self.view.bounds.size.width;
    
    CGFloat assumedButtonWidth = DEF_SM_BUTTON_WIDTH;
    
    CGFloat buttonWidths  = assumedButtonWidth * DEF_X_OFFSET_DIVIDER;
    CGFloat buttonOffsets = buttonWidths / DEF_X_OFFSET_DIVIDER;
    
    // Estimate the width with extra offset
    //
    CGFloat navBarAvailTitleWidth = mainViewWidth - (buttonWidths + buttonOffsets);
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:DEF_TEXT_COLOR,
        NSFontAttributeName:DEF_MD_ITALIC_FONT}];
    
    UILabel *titleLabel = [FieldUtils createLabel:title];
    [titleLabel setAttributedText:attrTitle];
    [titleLabel sizeToFit];
    //[titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:CLEAR_COLOR];
    
    UIImageView *starImageView;
    CGFloat starImageViewWidth = DEF_NIL_WIDTH;
    
    CGFloat xOffset = ((navBarAvailTitleWidth - titleLabel.bounds.size.width) / DEF_X_OFFSET_DIVIDER) - DEF_VLG_FIELD_PADDING;
    
    if (_isFavorite == TRUE) {

        starImageViewWidth = titleLabel.bounds.size.height;
        starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:STAR_ICON_NAME]];
        
        xOffset = xOffset - ((starImageViewWidth + DEF_FIELD_PADDING) / DEF_X_OFFSET_DIVIDER);
        
        [starImageView setFrame:CGRectMake(xOffset, DEF_Y_OFFSET, starImageViewWidth, starImageViewWidth)];
        
        xOffset = xOffset + starImageViewWidth + DEF_FIELD_PADDING;
    }
    [titleLabel setFrame:CGRectMake(xOffset, DEF_Y_OFFSET, navBarAvailTitleWidth - xOffset, titleLabel.bounds.size.height)];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, navBarAvailTitleWidth, titleLabel.bounds.size.height)];
    [titleView addSubview:starImageView];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
}



@end
