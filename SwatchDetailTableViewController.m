//
//  SwatchDetailTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 6/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "SwatchDetailTableViewController.h"
#import "AssocCollectionTableViewCell.h"
#import "AssocTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "ColorUtils.h"
#import "CoreDataUtils.h"
#import "ACPMixAssociationsDesc.h"
#import "ManagedObjectUtils.h"
#import "AppDelegate.h"
#import "GenericUtils.h"
#import "AlertUtils.h"

#import "MixAssociation.h"
#import "MixAssocSwatch.h"
#import "PaintSwatches.h"

#import "SwatchKeyword.h"
#import "Keyword.h"


@interface SwatchDetailTableViewController ()

@property (nonatomic, strong) NSDictionary *pickerViewDefaults;
@property (nonatomic, strong) UIImageView *swatchImageView;

@property (nonatomic, strong) UIAlertController *saveAlertController;
@property (nonatomic, strong) UIAlertAction *save, *delete;

// SwatchName and Reference Label and Name fields
//
@property (nonatomic, strong) UITextField *swatchName, *swatchTypeName, *subjColorName, *paintBrandName, *otherNameField, *bodyTypeName, *pigmentTypeName, *swatchKeyw;

@property (nonatomic, strong) NSString *nameEntered, *keywEntered, *descEntered, *colorSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *otherPlaceholder, *colorName, *nameHeader, *subjColorHeader, *swatchTypeHeader, *paintBrandHeader, *bodyTypeHeader, *pigmentTypeHeader, *keywHeader, *descHeader, *mixAssocHeader, *otherName;

// Subjective color related
//
@property (nonatomic, strong) UILabel *pickerAlertLabel;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *barButtonDone;

@property (nonatomic, strong) UIImageView *colorWheelView;

@property (nonatomic, strong) UIPickerView *subjColorPicker, *swatchTypesPicker, *paintBrandPicker, *bodyTypePicker, *pigmentTypePicker;

@property (nonatomic, strong) NSArray *subjColorNames, *swatchTypeNames, *paintBrandNames, *bodyTypeNames, *pigmentTypeNames;

@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData, *paintBrandData, *bodyTypeData, *pigmentTypeData;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIFont *placeholderFont, *currFont;
@property (nonatomic, strong) UIColor *subjColorValue;

@property (nonatomic) CGFloat tableViewWidth, doneColorButtonWidth, doneTypeButtonWidth, doneBrandButtonWidth, doneBodyButtonWidth, donePigmentButtonWidth, viewWidth, defXStartOffset, defYOffset, imageViewXOffset, imageViewWidth, imageViewHeight, swatchNameWidth, swatchTypeNameWidth, colorViewWidth, swatchLabelWidth, textFieldYOffset, colorTextFieldWidth, typeTextFieldWidth, brandTextFieldWidth, bodyTextFieldWidth, pigmentTextFieldWidth, doneColorButtonXOffset, doneTypeButtonXOffset, doneBrandButtonXOffset, doneBodyButtonXOffset, donePigmentButtonXOffset;

@property (nonatomic) int typesPickerSelRow, colorPickerSelRow, brandPickerSelRow, bodyPickerSelRow, pigmentPickerSelRow, collectViewSelRow;

@property (nonatomic, strong) NSMutableArray *colorArray, *paintSwatches;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

// Picker views
//
@property (nonatomic, strong) UIButton *doneColorButton, * doneTypeButton, *doneBrandButton, *doneBodyButton, *donePigmentButton;
@property (nonatomic) BOOL editFlag, colorPickerFlag, typesPickerFlag, brandPickerFlag, bodyPickerFlag, pigmentPickerFlag, isReadOnly, isShipped;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *keywordEntity, *swatchKeywordEntity;

@property (nonatomic, strong) NSString *reuseTableCellIdentifier, *reuseCollectionCellIdentifier;


@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Constants defaults
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int num_tableview_rows = 0;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@implementation SwatchDetailTableViewController


// Globals
//
const int DETAIL_NAME_SECTION    = 0;
const int DETAIL_COLOR_SECTION   = 1;
const int DETAIL_TYPES_SECTION   = 2;
const int DETAIL_BRAND_SECTION   = 3;
const int DETAIL_PIGMENT_SECTION = 4;
const int DETAIL_BODY_SECTION    = 5;
const int DETAIL_KEYW_SECTION    = 6;
const int DETAIL_DESC_SECTION    = 7;
const int DETAIL_MIX_SECTION     = 8;


const int DETAIL_MAX_SECTION     = 9;


#pragma mark - Initialization methods

-(void)loadView {
    [super loadView];
    
    _reuseTableCellIdentifier      = @"SwatchDetailCell";
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _keywordEntity       = [NSEntityDescription entityForName:@"Keyword"       inManagedObjectContext:self.context];
    _swatchKeywordEntity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:self.context];
    
    num_tableview_rows   = (int)[_mixAssocSwatches count];
    
    NSMutableArray *mixAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<num_tableview_rows; i++) {
        
        MixAssocSwatch *mixAssocSwatchObj = [_mixAssocSwatches objectAtIndex:i];
        MixAssociation *mixAssocObj = mixAssocSwatchObj.mix_association;
    
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
    
    
    // Default edit behaviour
    //
    _editFlag  = FALSE;
    
    // Other flags
    //
    _isShipped = [[_paintSwatch is_shipped] boolValue];

    
    // Table View Headers
    //
    _nameHeader        = @"Name";
    _subjColorHeader   = @"Subjective Color Selection";
    _swatchTypeHeader  = @"Swatch Type Selection";
    _paintBrandHeader  = @"Paint Brand Selection";
    _bodyTypeHeader    = @"Body Type Selection";
    _pigmentTypeHeader = @"Pigment Type Selection";
    _keywHeader        = @"Keywords";
    _descHeader        = @"Description";
    _mixAssocHeader    = @"Mix Associations";
    
    // Set the placeholders
    //
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Swatch Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Comma-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Swatch Description (max. %i chars) - ", MAX_DESC_LEN];
    _otherPlaceholder = [[NSString alloc] initWithFormat:@" - Other Paint Brand (max. of %i chars) - ", MAX_BRAND_LEN];

    
    // A few defaults
    //
    _imageViewWidth      = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight     = DEF_VLG_TBL_CELL_HGT;
    _typesPickerSelRow   = type_id         ? type_id       : 0;
    _colorPickerSelRow   = subj_color_id   ? subj_color_id : 0;
    _brandPickerSelRow   = brand_id        ? brand_id      : 0;
    _otherName           = brand_name      ? brand_name    : @"";
    _bodyPickerSelRow    = body_type_id    ? body_type_id  : 0;
    _pigmentPickerSelRow = pigment_type_id ? pigment_type_id : 0;
    
    _colorPickerFlag   = FALSE;
    _typesPickerFlag   = FALSE;
    _brandPickerFlag   = FALSE;
    _bodyPickerFlag    = FALSE;
    _pigmentPickerFlag = FALSE;


    // Offsets and Widths
    //
    _doneColorButtonWidth   = 1.0;
    _doneTypeButtonWidth    = 1.0;
    _doneBrandButtonWidth   = 1.0;
    _doneBodyButtonWidth    = 1.0;
    _donePigmentButtonWidth = 1.0;
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / 2;


    // Attributes
    //
    _nameEntered = [_paintSwatch name];

    
    // Picker entities
    //
    id typeObj = [ManagedObjectUtils queryDictionaryName:@"PaintSwatchType" entityId:_typesPickerSelRow context:self.context];
    NSString *typeName = [typeObj name];
    _swatchTypeName  = [FieldUtils createTextField:typeName tag:TYPE_FIELD_TAG];
    [_swatchTypeName setTextAlignment:NSTextAlignmentCenter];
    [_swatchTypeName setInputView: _swatchTypesPicker];
    [_swatchTypeName setDelegate:self];
    [self createSwatchTypePicker];

    id colorObj = [ManagedObjectUtils queryDictionaryName:@"SubjectiveColor" entityId:_colorPickerSelRow context:self.context];
    NSString *colorName = [colorObj name];
    _subjColorName = [FieldUtils createTextField:colorName tag:COLOR_FIELD_TAG];
    [_subjColorName setTextAlignment:NSTextAlignmentCenter];
    [_subjColorName setInputView: _subjColorPicker];
    [_subjColorName setDelegate:self];
    [self createColorPicker];
    
    id brandObj = [ManagedObjectUtils queryDictionaryName:@"PaintBrand" entityId:_brandPickerSelRow context:self.context];
    NSString *brandName = [brandObj name];
    _paintBrandName = [FieldUtils createTextField:brandName tag:BRAND_FIELD_TAG];
    [_paintBrandName setTextAlignment:NSTextAlignmentCenter];
    [_paintBrandName setInputView: _paintBrandPicker];
    [_paintBrandName setDelegate:self];
    [self createBrandPicker];
    
    _otherNameField = [FieldUtils createTextField:_otherName tag:OTHER_FIELD_TAG];
    [_otherNameField setTextAlignment:NSTextAlignmentCenter];
    [_otherNameField setDelegate:self];
    
    id bodyObj = [ManagedObjectUtils queryDictionaryName:@"BodyType" entityId:_bodyPickerSelRow context:self.context];
    NSString *bodyName = [bodyObj name];
    _bodyTypeName = [FieldUtils createTextField:bodyName tag:BODY_FIELD_TAG];
    [_bodyTypeName setTextAlignment:NSTextAlignmentCenter];
    [_bodyTypeName setInputView:_bodyTypePicker];
    [_bodyTypeName setDelegate:self];
    [self createBodyPicker];
    
    id pigmentObj = [ManagedObjectUtils queryDictionaryName:@"PigmentType" entityId:_pigmentPickerSelRow context:self.context];
    NSString *pigmentName = [pigmentObj name];
    _pigmentTypeName = [FieldUtils createTextField:pigmentName tag:PIGMENT_FIELD_TAG];
    [_pigmentTypeName setTextAlignment:NSTextAlignmentCenter];
    [_pigmentTypeName setInputView:_pigmentTypePicker];
    [_pigmentTypeName setDelegate:self];
    [self createPigmentPicker];
    
    
    NSSet *swatchKeywords = [_paintSwatch swatch_keyword];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (SwatchKeyword *swatch_keyword in swatchKeywords) {
        Keyword *keyword = [swatch_keyword keyword];
        [keywords addObject:[keyword name]];
    }
    _keywEntered = [keywords componentsJoinedByString:@", "];
    
    // Create the buttons
    //
    
    CGRect typeButtonFrame = CGRectMake(_doneTypeButtonXOffset, _textFieldYOffset, _doneTypeButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneTypeButton = [BarButtonUtils create3DButton:@"Done" tag:TYPE_BTN_TAG frame:typeButtonFrame];
    [_doneTypeButton addTarget:self action:@selector(swatchTypeSelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneTypeButton setHidden:TRUE];

    CGRect colorButtonFrame = CGRectMake(_doneColorButtonXOffset, _textFieldYOffset, _doneColorButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneColorButton = [BarButtonUtils create3DButton:@"Done" tag:COLOR_BTN_TAG frame:colorButtonFrame];
    [_doneColorButton addTarget:self action:@selector(colorSelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneColorButton setHidden:TRUE];
    
    CGRect brandButtonFrame = CGRectMake(_doneBrandButtonXOffset, _textFieldYOffset, _doneBrandButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneBrandButton = [BarButtonUtils create3DButton:@"Done" tag:BRAND_BTN_TAG frame:brandButtonFrame];
    [_doneBrandButton addTarget:self action:@selector(brandSelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneBrandButton setHidden:TRUE];
    
    CGRect bodyButtonFrame = CGRectMake(_doneBodyButtonXOffset, _textFieldYOffset, _doneBodyButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneBodyButton = [BarButtonUtils create3DButton:@"Done" tag:BODY_BTN_TAG frame:bodyButtonFrame];
    [_doneBodyButton addTarget:self action:@selector(bodySelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneBodyButton setHidden:TRUE];
    
    CGRect pigmentButtonFrame = CGRectMake(_donePigmentButtonXOffset, _textFieldYOffset, _donePigmentButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _donePigmentButton = [BarButtonUtils create3DButton:@"Done" tag:PIGMENT_BTN_TAG frame:pigmentButtonFrame];
    [_donePigmentButton addTarget:self action:@selector(pigmentSelection) forControlEvents:UIControlEventTouchUpInside];
    [_donePigmentButton setHidden:TRUE];
    
    _descEntered = [_paintSwatch desc] ? [_paintSwatch desc] : @"";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Edit Mode Button
    //
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
    [self makeTextFieldsNonEditable];
    
    // Swatch Detail Edit Button Alert Controller
    //
    _saveAlertController = [UIAlertController alertControllerWithTitle:@"Swatch Detail Edit"
                                                               message:@"Please select operation"
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    // Modified globally (i.e., enable/disable)
    //
    _save = [UIAlertAction actionWithTitle:@"Save Changes" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self saveData];
                                   }];
    
    _delete = [UIAlertAction actionWithTitle:@"Delete Swatch" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self deleteData];
                                                       
                                                   }];
    
    UIAlertAction *hide = [UIAlertAction actionWithTitle:@"Hide Swatch" style:UIAlertActionStyleDefault
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
    
    
    // Check if delete should be disabled (i.e., if PaintSwatch is referenced by any association)
    //
    int assoc_ct   = (int)[[ManagedObjectUtils queryEntityRelation:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"MixAssocSwatch" context:self.context] count];
    int match_ct = (int)[[ManagedObjectUtils queryEntityRelation:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"TapAreaSwatch" context:self.context] count];
    
    if ((assoc_ct > 0) || (match_ct > 0)) {
        [_delete setEnabled:FALSE];
    }
    
    [_save setEnabled:FALSE];
    
    // Adjust the layout with rotational changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFrameSizes)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
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
    
    // Global
    //
    CGFloat viewWidth  = self.tableView.bounds.size.width;
    
    // Text view widths
    //
    CGFloat fullTextFieldWidth = (viewWidth - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING;

    
    // Swatch Type
    //
    if (_typesPickerFlag == TRUE) {
        _doneTypeButtonWidth   = DEF_BUTTON_WIDTH;
        _typeTextFieldWidth = viewWidth - _doneTypeButtonWidth - (DEF_FIELD_PADDING * 2) - DEF_TABLE_X_OFFSET;
        
    } else {
        _doneTypeButtonWidth   = 1.0;
        _typeTextFieldWidth = fullTextFieldWidth;
    }
    
    // Subjective Color
    //
    if (_colorPickerFlag == TRUE) {
        _doneColorButtonWidth   = DEF_BUTTON_WIDTH;
        _colorTextFieldWidth = viewWidth - _imageViewWidth - _doneColorButtonWidth - (DEF_FIELD_PADDING * 2);
        
    } else {
        _doneColorButtonWidth   = 1.0;
        _colorTextFieldWidth = viewWidth - _imageViewWidth - (DEF_FIELD_PADDING * 2);
    }

    // Brand
    //
    if (_brandPickerFlag == TRUE) {
        _doneBrandButtonWidth   = DEF_BUTTON_WIDTH;
        _brandTextFieldWidth = viewWidth - _doneBrandButtonWidth - (DEF_FIELD_PADDING * 2) - DEF_TABLE_X_OFFSET;
        
    } else {
        _doneBrandButtonWidth   = 1.0;
        _brandTextFieldWidth = fullTextFieldWidth;
    }
    
    // Body
    //
    if (_bodyPickerFlag == TRUE) {
        _doneBodyButtonWidth   = DEF_BUTTON_WIDTH;
        _bodyTextFieldWidth = viewWidth - _doneBodyButtonWidth - (DEF_FIELD_PADDING * 2) - DEF_TABLE_X_OFFSET;
        
    } else {
        _doneBodyButtonWidth   = 1.0;
        _bodyTextFieldWidth = fullTextFieldWidth;
    }
    
    // Pigment
    //
    if (_pigmentPickerFlag == TRUE) {
        _donePigmentButtonWidth   = DEF_BUTTON_WIDTH;
        _pigmentTextFieldWidth = viewWidth - _donePigmentButtonWidth - (DEF_FIELD_PADDING * 2) - DEF_TABLE_X_OFFSET;
        
    } else {
        _donePigmentButtonWidth   = 1.0;
        _pigmentTextFieldWidth = fullTextFieldWidth;
    }

    
    [_subjColorName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _colorTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_swatchTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, _typeTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_paintBrandName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, _brandTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_bodyTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, _bodyTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_pigmentTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, _pigmentTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    
    _doneColorButtonXOffset  = _imageViewWidth + _colorTextFieldWidth + DEF_FIELD_PADDING;
    [_doneColorButton setFrame:CGRectMake(_doneColorButtonXOffset, _textFieldYOffset, _doneColorButtonWidth, DEF_TEXTFIELD_HEIGHT)];

    _doneTypeButtonXOffset  = DEF_TABLE_X_OFFSET + _typeTextFieldWidth + DEF_FIELD_PADDING;
    [_doneTypeButton setFrame:CGRectMake(_doneTypeButtonXOffset, _textFieldYOffset, _doneTypeButtonWidth, DEF_TEXTFIELD_HEIGHT)];
    
    _doneBrandButtonXOffset  = DEF_TABLE_X_OFFSET + _brandTextFieldWidth + DEF_FIELD_PADDING;
    [_doneBrandButton setFrame:CGRectMake(_doneBrandButtonXOffset, _textFieldYOffset, _doneBrandButtonWidth, DEF_TEXTFIELD_HEIGHT)];
    
    _doneBodyButtonXOffset  = DEF_TABLE_X_OFFSET + _bodyTextFieldWidth + DEF_FIELD_PADDING;
    [_doneBodyButton setFrame:CGRectMake(_doneBodyButtonXOffset, _textFieldYOffset, _doneBodyButtonWidth, DEF_TEXTFIELD_HEIGHT)];
    
    _donePigmentButtonXOffset  = DEF_TABLE_X_OFFSET + _pigmentTextFieldWidth + DEF_FIELD_PADDING;
    [_donePigmentButton setFrame:CGRectMake(_donePigmentButtonXOffset, _textFieldYOffset, _donePigmentButtonWidth, DEF_TEXTFIELD_HEIGHT)];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (num_tableview_rows > 0) {
        return DETAIL_MAX_SECTION;
    } else {
        return DETAIL_MAX_SECTION - 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ((section == DETAIL_BRAND_SECTION) && (_isShipped == TRUE)) {
        return 0;

    } else if ((
         (section == DETAIL_BRAND_SECTION)   ||
         (section == DETAIL_BODY_SECTION)    ||
         (section == DETAIL_PIGMENT_SECTION)
        ) && (![[_swatchTypeNames objectAtIndex:_typesPickerSelRow] isEqualToString:@"Reference"])) {
        return 0;
    
    } else if ((section == DETAIL_BRAND_SECTION) &&
               ([[_paintBrandNames objectAtIndex:_brandPickerSelRow] isEqualToString:@"Other"]) &&
               ((_editFlag == TRUE) || ![_otherName isEqualToString:@""])) {
        return 2;

    } else if (section <= DETAIL_DESC_SECTION) {
        if ((
             ((section == DETAIL_NAME_SECTION)  && [_nameEntered isEqualToString:@""]) ||
             ((section == DETAIL_KEYW_SECTION)  && [_keywEntered isEqualToString:@""]) ||
             ((section == DETAIL_DESC_SECTION)  && [_descEntered isEqualToString:@""])
             ) && (_editFlag == FALSE)) {
            return 0;
        } else {
            return 1;
        }

    } else if (section == DETAIL_MIX_SECTION) {
        return num_tableview_rows;

    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == DETAIL_MIX_SECTION) {
        return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
        
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section <= DETAIL_DESC_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseTableCellIdentifier forIndexPath:indexPath];
        
        // Global defaults
        //
        [cell setBackgroundColor:DARK_BG_COLOR];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [tableView setSeparatorColor:GRAY_BG_COLOR];
        [cell.imageView setImage:nil];
        [cell.textLabel setText:nil];
        [cell.textLabel setText:@""];

        // Set the widget frame sizes
        //
        [self setFrameSizes];
        
        // Remove dynamic text fields
        //
        [[cell.contentView viewWithTag:NAME_FIELD_TAG] removeFromSuperview];
        [[cell.contentView viewWithTag:KEYW_FIELD_TAG] removeFromSuperview];
        [[cell.contentView viewWithTag:DESC_FIELD_TAG] removeFromSuperview];
        
        
        // Name, and reference type
        //
        if (indexPath.section == DETAIL_NAME_SECTION) {

            // Create the name text field
            //
            UITextField *refName  = [FieldUtils createTextField:_nameEntered tag:NAME_FIELD_TAG];
            [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_nameEntered isEqualToString:@""]) {
                    [refName setPlaceholder:_namePlaceholder];
                }
                
                if (_isReadOnly == TRUE) {
                    [FieldUtils makeTextFieldNonEditable:refName content:_nameEntered border:TRUE];
                }
                
            } else {
                [FieldUtils makeTextFieldNonEditable:refName content:_nameEntered border:TRUE];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        
        // Subjective color field
        //
        } else if (indexPath.section == DETAIL_COLOR_SECTION) {
            [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
            [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
            [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
            cell.imageView.contentMode   = UIViewContentModeScaleAspectFill;
            cell.imageView.clipsToBounds = YES;
            cell.imageView.image = [ColorUtils renderRGB:_paintSwatch cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TEXTFIELD_HEIGHT];

            [cell.contentView addSubview:_subjColorName];
            [cell.contentView addSubview:_doneColorButton];
        
        // Swatch type field
        //
        } else if (indexPath.section == DETAIL_TYPES_SECTION) {
            [cell.contentView addSubview:_doneTypeButton];
            [cell.contentView addSubview:_swatchTypeName];
            
        // Paint Brand field
        //
        } else if (indexPath.section == DETAIL_BRAND_SECTION) {
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_doneBrandButton];
                [cell.contentView addSubview:_paintBrandName];
                
            } else {
                // Create the keyword text field
                //
                UITextField *otherNameField  = [FieldUtils createTextField:_otherName tag:OTHER_FIELD_TAG];
                [otherNameField setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
                [otherNameField setDelegate:self];
                [cell.contentView addSubview:otherNameField];
                
                if (_editFlag == TRUE) {
                    if ([_otherName isEqualToString:@""]) {
                        [otherNameField setPlaceholder:_otherPlaceholder];
                    }
                    
                } else {
                    [FieldUtils makeTextFieldNonEditable:otherNameField content:_otherName border:TRUE];
                }
                [cell setAccessoryType: UITableViewCellAccessoryNone];
            }
            
        // Body type field
        //
        } else if (indexPath.section == DETAIL_BODY_SECTION) {
            [cell.contentView addSubview:_doneBodyButton];
            [cell.contentView addSubview:_bodyTypeName];
            
        // Pigment type field
        //
        } else if (indexPath.section == DETAIL_PIGMENT_SECTION) {
            [cell.contentView addSubview:_donePigmentButton];
            [cell.contentView addSubview:_pigmentTypeName];
        
        // Keywords field
        //
        } else if (indexPath.section == DETAIL_KEYW_SECTION) {

            // Create the keyword text field
            //
            UITextField *refName  = [FieldUtils createTextField:_keywEntered tag:KEYW_FIELD_TAG];
            [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_keywEntered isEqualToString:@""]) {
                    [refName setPlaceholder:_keywPlaceholder];
                }
                
            } else {
                [FieldUtils makeTextFieldNonEditable:refName content:_keywEntered border:TRUE];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];

        // Description field
        //
        } else {
        
            // Create the description text field
            //
            UITextField *refName  = [FieldUtils createTextField:_descEntered tag:DESC_FIELD_TAG];
            [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            
            if (_editFlag == TRUE) {
                if ([_descEntered isEqualToString:@""]) {
                    [refName setPlaceholder:_descPlaceholder];
                }
                
            } else {
                [FieldUtils makeTextFieldNonEditable:refName content:_descEntered border:TRUE];
            }
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        }
        
        return cell;

    // Associations (if any) as rows of collection views
    //
    } else {
        AssocCollectionTableViewCell *custCell = (AssocCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        [custCell setBackgroundColor: DARK_BG_COLOR];
        
        if (! custCell) {
            custCell = [[AssocCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
        }
        
        MixAssocSwatch *mixAssocSwatchObj = [_mixAssocSwatches objectAtIndex:indexPath.row];
        MixAssociation *mixAssocObj = mixAssocSwatchObj.mix_association;
        NSString *mix_name = mixAssocObj.name;
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

        [custCell setAssocName:[[NSString alloc] initWithFormat:@"%@", mix_name]];
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
    if ((section == DETAIL_BRAND_SECTION) && (_isShipped == TRUE)) {
        return 0;

    } else if ((
         (section == DETAIL_BRAND_SECTION)   ||
         (section == DETAIL_BODY_SECTION)    ||
         (section == DETAIL_PIGMENT_SECTION)
         ) && (![[_swatchTypeNames objectAtIndex:_typesPickerSelRow] isEqualToString:@"Reference"])) {
        return DEF_NIL_HEADER;

    } else if ((
         ((section == DETAIL_NAME_SECTION)  && [_nameEntered isEqualToString:@""]) ||
         ((section == DETAIL_KEYW_SECTION)  && [_keywEntered isEqualToString:@""]) ||
         ((section == DETAIL_DESC_SECTION)  && [_descEntered isEqualToString:@""])
         ) && (_editFlag == FALSE)) {
        return DEF_NIL_HEADER;

    } else {
        return DEF_TABLE_HDR_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //
    [view setTintColor: DARK_TEXT_COLOR];
    
    // Text Color
    //
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor: LIGHT_TEXT_COLOR];
    [header.textLabel setFont: TABLE_HEADER_FONT];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    if (section == DETAIL_NAME_SECTION) {
        headerStr = _nameHeader;
        
    } else if (section == DETAIL_COLOR_SECTION) {
        headerStr = _subjColorHeader;
        
    } else if (section == DETAIL_TYPES_SECTION) {
        headerStr = _swatchTypeHeader;
        
    } else if (section == DETAIL_BRAND_SECTION) {
        headerStr = _paintBrandHeader;

    } else if (section == DETAIL_BODY_SECTION) {
        headerStr = _bodyTypeHeader;

    } else if (section == DETAIL_PIGMENT_SECTION) {
        headerStr = _pigmentTypeHeader;
        
    } else if (section == DETAIL_KEYW_SECTION) {
        headerStr = _keywHeader;
        
    } else if (section == DETAIL_DESC_SECTION) {
        headerStr = _descHeader;
        
    } else {
        headerStr = _mixAssocHeader;
    }

    return headerStr;
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
        [self presentViewController:_saveAlertController animated:YES completion:nil];
    } else {
        [self makeTextFieldsEditable];
    }
    
    [self.tableView reloadData];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Textfield Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITextField methods

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return YES;
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == TYPE_FIELD_TAG) {
        [_doneTypeButton setHidden:FALSE];
        _typesPickerFlag = TRUE;
        
    } else if (textField.tag == COLOR_FIELD_TAG) {
        [_doneColorButton setHidden:FALSE];
        _colorPickerFlag = TRUE;
        
    } else if (textField.tag == BRAND_FIELD_TAG) {
        [_doneBrandButton setHidden:FALSE];
        _brandPickerFlag = TRUE;
        
    } else if (textField.tag == BODY_FIELD_TAG) {
        [_doneBodyButton setHidden:FALSE];
        _bodyPickerFlag = TRUE;
        
    } else if (textField.tag == PIGMENT_FIELD_TAG) {
        [_donePigmentButton setHidden:FALSE];
        _pigmentPickerFlag = TRUE;
        
    } else {
        [_pickerAlertLabel setText:@""];
    }
    [self setFrameSizes];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [GenericUtils trimString:textField.text];
    
    if ((textField.tag == NAME_FIELD_TAG) && [textField.text isEqualToString:@""]) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
    
    } else if ((textField.tag == OTHER_FIELD_TAG) && [textField.text isEqualToString:@""] && (_brandPickerSelRow == 0)) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
    
        if (textField.tag == NAME_FIELD_TAG) {
            _nameEntered = textField.text;
        } else if (textField.tag == KEYW_FIELD_TAG) {
            _keywEntered = textField.text;
        } else if (textField.tag == DESC_FIELD_TAG) {
            _descEntered = textField.text;
        } else if (textField.tag == OTHER_FIELD_TAG) {
            _otherName   = textField.text;
        }
        
        [_save setEnabled:TRUE];
    }
    
    [textField resignFirstResponder];
    _typesPickerFlag   = FALSE;
    _colorPickerFlag   = FALSE;
    _brandPickerFlag   = FALSE;
    _bodyPickerFlag    = FALSE;
    _pigmentPickerFlag = FALSE;

    [self.tableView reloadData];
    
    [self setFrameSizes];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == NAME_FIELD_TAG && textField.text.length >= MAX_NAME_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_NAME_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == KEYW_FIELD_TAG && textField.text.length >= MAX_KEYW_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_KEYW_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == DESC_FIELD_TAG && textField.text.length >= MAX_DESC_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_DESC_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == OTHER_FIELD_TAG && textField.text.length >= MAX_BRAND_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_BRAND_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Picker Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIPickerView methods


// The number of columns of data
//
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
//
- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        return (long)[_swatchTypeNames count];
        
    } else if (pickerView.tag == COLOR_PICKER_TAG) {
        return (long)[_subjColorNames count];
        
    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        return (long)[_paintBrandNames count];
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        return (long)[_bodyTypeNames count];

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
    
    } else {
        return [_pigmentTypeNames objectAtIndex:row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel *label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
    }

    if (pickerView.tag == SWATCH_PICKER_TAG) {
        [label setText:[_swatchTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
        [_pickerAlertLabel setText:@"Single tap the type selection"];
        
    } else if (pickerView.tag == BRAND_PICKER_TAG) {
        [label setText:[_paintBrandNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
        [_pickerAlertLabel setText:@"Single tap the type selection"];
        
    } else if (pickerView.tag == BODY_PICKER_TAG) {
        [label setText:[_bodyTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
        [_pickerAlertLabel setText:@"Single tap the type selection"];
    
    } else if (pickerView.tag == PIGMENT_PICKER_TAG) {
        [label setText:[_pigmentTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
        [_pickerAlertLabel setText:@"Single tap the type selection"];
        
    } else {
        NSString *colorName = [_subjColorNames objectAtIndex:row];
        UIColor *backgroundColor = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
        
        [label setTextColor:[self setTextColor:colorName]];
        [label setBackgroundColor:backgroundColor];
        [label setText:[_subjColorNames objectAtIndex:row]];
    
        [_pickerAlertLabel setText:@"Single tap the color selection"];
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
        
    } else {
        [self setColorPickerValues:(int)row];
        [_paintSwatch setSubj_color_id:[NSNumber numberWithInt:[[[_subjColorData objectForKey:_colorSelected] valueForKey:@"id"] intValue]]];
    }
}

- (void)createSwatchTypePicker {
    _swatchTypesPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:SWATCH_PICKER_TAG];
    [self setSwatchTypeNames:[ManagedObjectUtils fetchDictNames:@"PaintSwatchType" context:self.context]];
    [_swatchTypesPicker setDataSource:self];
    [_swatchTypesPicker setDelegate:self];
    [_swatchTypesPicker selectRow:[[_paintSwatch type_id] intValue] inComponent:0 animated:YES];
    [_swatchTypeName setInputView: _swatchTypesPicker];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(swatchTypeSelection)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_swatchTypesPicker addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    
    //[_pickerAlertLabel setText:@"Single tap the type selection"];
}

- (void)createColorPicker {
    _subjColorPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:COLOR_PICKER_TAG];
    _subjColorData = [ManagedObjectUtils fetchSubjectiveColors:self.context];
    
    _subjColorNames  = [ManagedObjectUtils fetchDictNames:@"SubjectiveColor" context:self.context];

    [_subjColorPicker setDataSource:self];
    [_subjColorPicker setDelegate:self];
    [_subjColorName setInputView: _subjColorPicker];
    
    [self setColorPickerValues:[[_paintSwatch subj_color_id] intValue]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(colorSelection)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_subjColorPicker addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
}

- (void)createBrandPicker {
    _paintBrandPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:BRAND_PICKER_TAG];
    _paintBrandNames  = [ManagedObjectUtils fetchDictNames:@"PaintBrand" context:self.context];
    
    [_paintBrandPicker setDataSource:self];
    [_paintBrandPicker setDelegate:self];
    [_paintBrandName setInputView:_paintBrandPicker];
    [_paintBrandPicker selectRow:[[_paintSwatch paint_brand_id] intValue] inComponent:0 animated:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(brandSelection)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_paintBrandPicker addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
}

- (void)createBodyPicker {
    _bodyTypePicker = [FieldUtils createPickerView:self.view.frame.size.width tag:BODY_PICKER_TAG];
    _bodyTypeNames  = [ManagedObjectUtils fetchDictNames:@"BodyType" context:self.context];
    
    [_bodyTypePicker setDataSource:self];
    [_bodyTypePicker setDelegate:self];
    [_bodyTypeName setInputView:_bodyTypePicker];
    [_bodyTypePicker selectRow:[[_paintSwatch body_type_id] intValue] inComponent:0 animated:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(bodySelection)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_bodyTypePicker addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
}

- (void)createPigmentPicker {
    _pigmentTypePicker = [FieldUtils createPickerView:self.view.frame.size.width tag:PIGMENT_PICKER_TAG];
    _pigmentTypeNames  = [ManagedObjectUtils fetchDictNames:@"PigmentType" context:self.context];
    
    [_pigmentTypePicker setDataSource:self];
    [_pigmentTypePicker setDelegate:self];
    [_pigmentTypeName setInputView:_pigmentTypePicker];
    [_pigmentTypePicker selectRow:[[_paintSwatch pigment_type_id] intValue] inComponent:0 animated:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(pigmentSelection)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_pigmentTypePicker addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
}


- (void)swatchTypeSelection {
    [_pickerAlertLabel setText:@""];
    [_swatchTypeName resignFirstResponder];
    [_swatchTypesPicker removeFromSuperview];
    [_doneTypeButton setHidden:TRUE];
}

- (void)colorSelection {
    [_pickerAlertLabel setText:@""];
    [_subjColorName resignFirstResponder];
    [_subjColorPicker removeFromSuperview];
    [_doneColorButton setHidden:TRUE];
}

- (void)brandSelection {
    [_pickerAlertLabel setText:@""];
    [_paintBrandName resignFirstResponder];
    [_paintBrandPicker removeFromSuperview];
    [_doneBrandButton setHidden:TRUE];
}

- (void)bodySelection {
    [_pickerAlertLabel setText:@""];
    [_bodyTypeName resignFirstResponder];
    [_bodyTypePicker removeFromSuperview];
    [_doneBodyButton setHidden:TRUE];
}

- (void)pigmentSelection {
    [_pickerAlertLabel setText:@""];
    [_pigmentTypeName resignFirstResponder];
    [_pigmentTypePicker removeFromSuperview];
    [_donePigmentButton setHidden:TRUE];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// CollectionView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UICollectionView (and ScrollView) Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int index = (int)collectionView.tag;
    
    NSArray *collectionViewArray = self.colorArray[index];
    
    return [collectionViewArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    int index = (int)collectionView.tag;
    
    PaintSwatches *paintSwatch = [[self.colorArray objectAtIndex:index] objectAtIndex:indexPath.row];
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:[ColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight]];
    
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
//    int index = (int)collectionView.tag;
//    
//    _collectViewSelRow = index;
//    
//    [self performSegueWithIdentifier:@"DetailToAssocSegue" sender:self];
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
// TapRecognizer Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIGestureRecognizer methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return true;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Storyboard, Tap, and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation and Multi-purpose methods

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navigationViewController = [segue destinationViewController];
    AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
    
    [assocTableViewController setPaintSwatches:self.colorArray[_collectViewSelRow]];
    [assocTableViewController setSaveFlag:TRUE];
    [assocTableViewController setSourceViewName:@"SwatchDetail"];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General purpose methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (UIColor *)setTextColor:(NSString *)colorName {

    UIColor *textColor = DARK_TEXT_COLOR;
    if ([colorName isEqualToString:@"Black"] || [colorName isEqualToString:@"Blue"] ||
        [colorName isEqualToString:@"Brown"] || [colorName isEqualToString:@"Blue Violet"]) {
        textColor = LIGHT_TEXT_COLOR;
    }
    
    return textColor;
}

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
    NSMutableArray *keywords = [GenericUtils trimStrings:[_keywEntered componentsSeparatedByString:@","]];
    
    // Add subjective color if not 'Other'
    //
    NSString *subj_color = [_subjColorName text];
    if (![subj_color isEqualToString:@"Other"]) {
        [keywords addObject:subj_color];
    }
    
    for (NSString *keyword in keywords) {
        if ([keyword isEqualToString:@""]) {
            continue;
        }
        
        Keyword *kwObj = [ManagedObjectUtils queryKeyword:keyword context:self.context];
        if (kwObj == nil) {
            kwObj = [[Keyword alloc] initWithEntity:_keywordEntity insertIntoManagedObjectContext:self.context];
            [kwObj setName:keyword];
        }
        
        SwatchKeyword *swKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_paintSwatch.objectID relationName:@"paint_swatch" entityName:@"SwatchKeyword" context:self.context];
        
        if (swKwObj == nil) {
            swKwObj = [[SwatchKeyword alloc] initWithEntity:_swatchKeywordEntity insertIntoManagedObjectContext:self.context];
            [swKwObj setKeyword:kwObj];
            [swKwObj setPaint_swatch:(PaintSwatch *)_paintSwatch];

            [_paintSwatch addSwatch_keywordObject:swKwObj];
            [kwObj addSwatch_keywordObject:swKwObj];
        }
    }
    [_paintSwatch setName:_nameEntered];
    [_paintSwatch setDesc:_descEntered];
    
    if (_brandPickerSelRow == 0) {
        [_paintSwatch setPaint_brand_name:_otherName];
    } else {
        [_paintSwatch setPaint_brand_name:nil];
    }

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"Swatch Detail save" message:@"Error saving"];
        [self presentViewController:myAlert animated:YES completion:nil];
    } else {
        NSLog(@"Swatch Detail save successful");
        
        [_save setEnabled:FALSE];
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
        NSLog(@"Swatch Detail delete successful");
        
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
    _subjColorValue    = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:_colorSelected] valueForKey:@"hex"]];
    
    [_subjColorName setText:[_subjColorNames objectAtIndex:row]];
    [_subjColorName setTextColor:[self setTextColor:_colorSelected]];
    [_subjColorName setBackgroundColor:_subjColorValue];

    [_subjColorPicker selectRow:row inComponent:0 animated:YES];
}

- (void)makeTextFieldsEditable {
    [FieldUtils makeTextFieldEditable:_subjColorName content:@""];
    [FieldUtils makeTextFieldEditable:_swatchTypeName content:@""];
    [FieldUtils makeTextFieldEditable:_paintBrandName content:@""];
    [FieldUtils makeTextFieldEditable:_bodyTypeName content:@""];
    [FieldUtils makeTextFieldEditable:_pigmentTypeName content:@""];
}

- (void)makeTextFieldsNonEditable {
    [FieldUtils makeTextFieldNonEditable:_subjColorName content:@"" border:TRUE];
    [FieldUtils makeTextFieldNonEditable:_swatchTypeName content:@"" border:TRUE];
    [FieldUtils makeTextFieldNonEditable:_paintBrandName content:@"" border:TRUE];
    [FieldUtils makeTextFieldNonEditable:_bodyTypeName content:@"" border:TRUE];
    [FieldUtils makeTextFieldNonEditable:_pigmentTypeName content:@"" border:TRUE];
}

@end
