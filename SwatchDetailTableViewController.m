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
#import "ACPMixAssociationsDesc.h"
#import "ManagedObjectUtils.h"
#import "AppDelegate.h"
#import "GenericUtils.h"
#import "AlertUtils.h"
#import "PickerUtils.h"

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
@property (nonatomic, strong) UIPickerView *subjColorPicker, *swatchTypesPicker, *paintBrandPicker, *bodyTypePicker, *pigmentTypePicker;

@property (nonatomic, strong) NSArray *subjColorNames, *swatchTypeNames, *paintBrandNames, *bodyTypeNames, *pigmentTypeNames;

@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData, *paintBrandData, *bodyTypeData, *pigmentTypeData;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIColor *subjColorValue;

@property (nonatomic) CGFloat imageViewXOffset, imageViewWidth, imageViewHeight, textFieldYOffset, colorTextFieldWidth;

@property (nonatomic) int typesPickerSelRow, colorPickerSelRow, brandPickerSelRow, bodyPickerSelRow, pigmentPickerSelRow, collectViewSelRow;

@property (nonatomic, strong) NSMutableArray *colorArray, *paintSwatches;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;


@property (nonatomic) BOOL editFlag, colorPickerFlag, typesPickerFlag, brandPickerFlag, bodyPickerFlag, pigmentPickerFlag, isReadOnly, isShipped;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *keywordEntity, *swatchKeywordEntity;


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
int DETAIL_NAME_SECTION    = 0;
int DETAIL_COLOR_SECTION   = 1;
int DETAIL_TYPES_SECTION   = 2;
int DETAIL_BRAND_SECTION   = 3;
int DETAIL_PIGMENT_SECTION = 4;
int DETAIL_BODY_SECTION    = 5;
int DETAIL_KEYW_SECTION    = 6;
int DETAIL_DESC_SECTION    = 7;
int DETAIL_MIX_SECTION     = 8;

int DETAIL_MAX_SECTION     = 9;

NSString *DETAIL_REUSE_CELL_IDENTIFIER = @"SwatchDetailCell";


#pragma mark - Initialization methods

-(void)loadView {
    [super loadView];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
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

    [ColorUtils setNavBarGlaze:self.navigationController.navigationBar];
    
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
    _typesPickerSelRow   = type_id         ? type_id         : 0;
    _colorPickerSelRow   = subj_color_id   ? subj_color_id   : 0;
    _brandPickerSelRow   = brand_id        ? brand_id        : 0;
    _otherName           = brand_name      ? brand_name      : @"";
    _bodyPickerSelRow    = body_type_id    ? body_type_id    : 0;
    _pigmentPickerSelRow = pigment_type_id ? pigment_type_id : 0;
    
    _colorPickerFlag   = FALSE;
    _typesPickerFlag   = FALSE;
    _brandPickerFlag   = FALSE;
    _bodyPickerFlag    = FALSE;
    _pigmentPickerFlag = FALSE;


    // Offsets and Widths
    //
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
    
    NSSet *swatchKeywords = [_paintSwatch swatch_keyword];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (SwatchKeyword *swatch_keyword in swatchKeywords) {
        Keyword *keyword = [swatch_keyword keyword];
        [keywords addObject:[keyword name]];
    }
    _keywEntered = [keywords componentsJoinedByString:@", "];
    
    
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

    // Text view widths
    //
    CGFloat viewWidth = self.tableView.bounds.size.width;
    CGFloat fullTextFieldWidth = viewWidth - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;
    
    _colorTextFieldWidth = viewWidth - _imageViewWidth - (DEF_FIELD_PADDING * 2);

    [_subjColorName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _colorTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_swatchTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_paintBrandName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_bodyTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_pigmentTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (NUM_TABLEVIEW_ROWS > 0) {
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
        return NUM_TABLEVIEW_ROWS;

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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAIL_REUSE_CELL_IDENTIFIER forIndexPath:indexPath];
        
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
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                [subview removeFromSuperview];
            }
        }
        
        
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
        
        // Swatch type field
        //
        } else if (indexPath.section == DETAIL_TYPES_SECTION) {
            [cell.contentView addSubview:_swatchTypeName];
            
        // Paint Brand field
        //
        } else if (indexPath.section == DETAIL_BRAND_SECTION) {
            if (indexPath.row == 0) {
                [cell.contentView addSubview:_paintBrandName];
                
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
                    [FieldUtils makeTextFieldNonEditable:otherNameField content:_otherName border:TRUE];
                }
                [cell setAccessoryType: UITableViewCellAccessoryNone];
            }
            
        // Body type field
        //
        } else if (indexPath.section == DETAIL_BODY_SECTION) {
            [cell.contentView addSubview:_bodyTypeName];
            
        // Pigment type field
        //
        } else if (indexPath.section == DETAIL_PIGMENT_SECTION) {
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

#pragma mark - UITextField methods

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
        
    } else {
        NSString *colorName = [_subjColorNames objectAtIndex:row];
        UIColor *backgroundColor = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
        
        [label setTextColor:[ColorUtils setBestColorContrast:colorName]];
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
    [pickerParentView setBackgroundColor:DARK_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:picker];
    
    [textField setInputView:pickerParentView];
    
    // Need to prevent text from clearing
    
    [picker selectRow:selectRow inComponent:0 animated:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:action];
    tapRecognizer.numberOfTapsRequired = DEF_NUM_TAPS;
    [picker addGestureRecognizer:tapRecognizer];
    [tapRecognizer setDelegate:self];
    
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

- (void)pigmentSelection {
    int row = [[_paintSwatch pigment_type_id] intValue];
    [_pigmentTypeName setText:[_pigmentTypeNames objectAtIndex:row]];
    [_pigmentTypePicker selectRow:row inComponent:0 animated:YES];
    [_pigmentTypeName resignFirstResponder];
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
    
    NSArray *collectionViewArray = [self.colorArray objectAtIndex:index];
    
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
    [assocTableViewController setMixAssociation:[[_mixAssocSwatches objectAtIndex:_collectViewSelRow] mix_association]];
    [assocTableViewController setSaveFlag:TRUE];
    [assocTableViewController setSourceViewName:@"SwatchDetail"];
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
    NSMutableArray *keywords = [GenericUtils trimStrings:[_keywEntered componentsSeparatedByString:@","]];
    
    // Add subjective color if not 'Other'
    //
//    NSString *subj_color = [_subjColorName text];
//    if (![subj_color isEqualToString:@"Other"]) {
//        [keywords addObject:subj_color];
//    }
    
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
    [_subjColorName setTextColor:[ColorUtils setBestColorContrast:_colorSelected]];
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
