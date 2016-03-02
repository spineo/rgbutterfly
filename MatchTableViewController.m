//
//  MatchTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 8/25/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "MatchTableViewController.h"
#import "SwatchDetailTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "BarButtonUtils.h"
#import "ColorUtils.h"
#import "MatchAlgorithms.h"
//#import "PaintSwatchesDiff.h"
#import "AlertUtils.h"
#import "StringObjectUtils.h"
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"


@interface MatchTableViewController ()

@property (nonatomic) BOOL isRGB, textReturn;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *nameEntered, *keywEntered, *descEntered, *colorSelected, *typeSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *colorPlaceholder, *typePlaceholder, *colorName;
@property (nonatomic, strong) UIColor *subjColorValue;
@property (nonatomic) CGFloat textFieldYOffset, refNameWidth, imageViewWidth, imageViewHeight, imageViewXOffset, imageViewYOffset, matchImageViewWidth, matchImageViewHeight, tableViewWidth, doneButtonWidth, selTextFieldWidth, doneButtonXOffset;
@property (nonatomic) BOOL editFlag;
@property (nonatomic) int selectedRow, dbSwatchesCount, maxRowLimit, colorPickerSelRow, typesPickerSelRow;
@property (nonatomic, strong) NSMutableArray *matchedSwatches;
@property (nonatomic, strong) NSArray *matchAlgorithms;

// Picker views
//
@property (nonatomic, strong) UITextField *swatchTypeName, *subjColorName;
//@property (nonatomic, strong) UIPickerView *subjColorPicker, *swatchTypesPicker;
//@property (nonatomic, strong) NSArray *subjColorNames, *swatchTypeNames;
@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
//@property (nonatomic, strong) UIView *subjColorPickerView, *swatchTypesPickerView;
//@property (nonatomic, strong) UIButton *doneColorButton, * doneTypeButton;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity;

@end

@implementation MatchTableViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Constants defaults
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Table sections
//
const int IMAGE_SECTION = 0;
const int DIV1_SECTION  = 1;
const int MATCH_SECTION = 2;
const int DIV2_SECTION  = 3;
const int NAME_SECTION  = 4;
const int KEYW_SECTION  = 5;
const int DESC_SECTION  = 6;
//const int COLOR_SECTION = 7;
//const int TYPES_SECTION = 8;

const int MAX_SECTION   = 7;


// Table views tags
//
const int ALG_TAG    = 2;
const int TYPE_TAG   = 4;
const int IMAGE_TAG  = 6;
//const int COLLBL_TAG = 7;
//const int COLTXT_TAG = 8;
//const int COLSEL_TAG = 9;
//const int TYPLBL_TAG = 11;
//const int TYPTXT_TAG = 12;
//const int TYPSEL_TAG = 13;
//const int TYPBTN_TAG = 14;

const int MAX_TAG     = 6;


- (void)viewDidLoad {
    [super viewDidLoad];

    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // Initialize the PaintSwatch entity
    //
    _paintSwatchEntity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:self.context];
    
    
    _isRGB    = FALSE;
    _editFlag = FALSE;
    _reuseCellIdentifier = @"MatchTableCell";
    

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tableview defaults
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _imageViewXOffset     = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewYOffset     = DEF_Y_OFFSET;
    _imageViewWidth       = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight      = DEF_VLG_TBL_CELL_HGT;
    _matchImageViewWidth  = DEF_TABLE_CELL_HEIGHT;
    _matchImageViewHeight = DEF_TABLE_CELL_HEIGHT;
    

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // TextField Setup
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    _textReturn       = FALSE;
    _nameEntered      = @"";
    _keywEntered      = @"";
    _descEntered      = @"";
    
    // Offsets and Widths
    //
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / 2;
    _doneButtonWidth  = 1.0;

    
    // Set the placeholders
    //
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Selection Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Comma-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Selection Description (max. %i chars) - ", MAX_DESC_LEN];
    _colorPlaceholder = @" - Subjective Color - ";
    _typePlaceholder  = @" - Swatch Type - ";
    
    _dbSwatchesCount  = (int)[_dbPaintSwatches count];

    _maxRowLimit = (_dbSwatchesCount > DEF_MAX_MATCH) ? DEF_MAX_MATCH : _dbSwatchesCount;


    // Match algorithms
    //
    _matchAlgorithms = [GlobalSettings getMatchAlgorithms];
    _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];

    // Color wheel data
    //
//    _subjColorData   = [GlobalSettings getSubjColorData];
//    _subjColorNames  = [ManagedObjectUtils fetchDictNames:@"SubjectiveColor" context:self.context];
//
//    // Swatch types
//    //
//    _swatchTypeNames = [GlobalSettings getSwatchTypes];
//
//    // Subjective color picker
//    //
//    _colorPickerSelRow = _selPaintSwatch.subj_color_id ? _selPaintSwatch.subj_color_id : 0;
//    _typesPickerSelRow = _selPaintSwatch.type_id       ? _selPaintSwatch.type_id       : 0;
//    
//    _colorSelected     = [_subjColorNames  objectAtIndex:_colorPickerSelRow];
//    _colorName         = [_subjColorNames  objectAtIndex:_colorPickerSelRow];
//    _subjColorValue    = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:_colorName] valueForKey:@"hex"]];
//    _typeSelected      = [_swatchTypeNames objectAtIndex:_typesPickerSelRow];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
}

- (void)viewDidAppear:(BOOL)animated {

    // Reset some widths and offset per rotation
    //
    [self resizeSelFieldAndDone:_doneButtonWidth];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    return MAX_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //
    if ((
         ((section == NAME_SECTION)  && [_nameEntered  isEqualToString:@""]) ||
         ((section == KEYW_SECTION)  && [_keywEntered  isEqualToString:@""]) ||
         ((section == DESC_SECTION)  && [_descEntered  isEqualToString:@""])
//         ((section == COLOR_SECTION) && _colorPickerSelRow == 0) ||
//         ((section == TYPES_SECTION) && _typesPickerSelRow == 0)
         ) && (_editFlag == FALSE)) {
        return 0;
    } else if (section != MATCH_SECTION) {
        return 1;
    } else {
        return [_matchedSwatches count] - 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == IMAGE_SECTION) {
        return DEF_VLG_TBL_CELL_HGT + DEF_FIELD_PADDING;
        
    } else if (indexPath.section == NAME_SECTION) {
        return DEF_SM_TABLE_CELL_HGT;
        
    } else if (indexPath.section == DIV1_SECTION || indexPath.section == DIV2_SECTION) {
        return DEF_TBL_DIVIDER_HGT;
    }
    return DEF_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor: DARK_BG_COLOR];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor: GRAY_BG_COLOR];
    [cell.textLabel.layer setBorderWidth: BORDER_WIDTH_NONE];
    [cell.textLabel setBackgroundColor: DARK_BG_COLOR];
    [cell.textLabel setText:@""];
    cell.imageView.image = nil;
    
//    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    
    // Remove the tags
    //
    for (int tag=1; tag<=MAX_TAG; tag++) {
        [[cell.contentView viewWithTag:tag] removeFromSuperview];
    }

    // Set up the image name and match method fields
    //
    if (indexPath.section == NAME_SECTION) {
        if (_editFlag == FALSE) {
            [cell.textLabel setText:[[NSString alloc] initWithFormat:@" %@", _nameEntered]];
            [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
            [cell.textLabel setFont: TABLE_CELL_FONT];
            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.textLabel.numberOfLines = 0;
            
            [cell.textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
            [cell.textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
            [cell.textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];

        } else {
            
            // Create the image name text field
            //
            UITextField *refName  = [FieldUtils createTextField:_nameEntered tag:NAME_FIELD_TAG];
            [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [refName setDelegate:self];
            [cell.contentView addSubview:refName];
            [cell.textLabel setText:@""];
            
            if ([_nameEntered isEqualToString:@""]) {
                [refName setPlaceholder: _namePlaceholder];
            }
        }

        [cell setAccessoryType: UITableViewCellAccessoryNone];
    
    // Set up the keywords and match type fields
    //
    } else if (indexPath.section == KEYW_SECTION) {
        if (_editFlag == FALSE) {
            [cell.textLabel setText:[[NSString alloc] initWithFormat:@" %@", _keywEntered]];
            [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
            [cell.textLabel setFont: TABLE_CELL_FONT];
            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.textLabel.numberOfLines = 0;
            
            //[cell.textLabel setBackgroundColor:_grayBgColor];
            [cell.textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
            [cell.textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
            [cell.textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];

        } else {
            
            // Create the keywords text field
            //
            UITextField *keywords  = [FieldUtils createTextField:_keywEntered tag:KEYW_FIELD_TAG];
            [keywords setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [keywords setDelegate:self];
            [cell.contentView addSubview:keywords];
            [cell.textLabel setText:@""];
            
            if ([_keywEntered isEqualToString:@""]) {
                [keywords setPlaceholder: _keywPlaceholder];
            }
        }
        
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        
    
    // Set up the description field
    //
    } else if (indexPath.section == DESC_SECTION) {
        if (_editFlag == FALSE) {
            [cell.textLabel setText:[[NSString alloc] initWithFormat:@" %@", _descEntered]];
            [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
            [cell.textLabel setFont: TABLE_CELL_FONT];
            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.textLabel.numberOfLines = 0;
    
            [cell.textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
            [cell.textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
            [cell.textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];

        } else {
            
            // Create the description text field
            //
            UITextField *description  = [FieldUtils createTextField:_descEntered tag:DESC_FIELD_TAG];
            [description setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
            [description setDelegate:self];
            [cell.contentView addSubview:description];
            [cell.textLabel setText:@""];
            
            if ([_descEntered isEqualToString:@""]) {
                [description setPlaceholder: _descPlaceholder];
            }
        }
        
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        
    } else if (indexPath.section == IMAGE_SECTION) {
        
        if (_isRGB == FALSE) {
            cell.imageView.image = [ColorUtils renderPaint:_selPaintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
        } else {
            cell.imageView.image = [ColorUtils renderRGB:_selPaintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
        }
        
        // Tag the first reference image
        //
        cell.imageView.image = [ColorUtils drawTapAreaLabel:cell.imageView.image count:_currTapSection];
        [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds: YES];
        [cell.imageView setFrame:CGRectMake(_imageViewXOffset, _imageViewYOffset, _imageViewWidth, _imageViewHeight)];
        
        // Compute the xpt
        //
        CGFloat xpt = CGPointFromString(_selPaintSwatch.coord_pt).x - _imageViewWidth;
        xpt = (xpt < 0.0) ? 0.0 : xpt;
        
        CGFloat xAxisLimit = _referenceImage.size.width - (_imageViewWidth * 2);
        xpt = (xpt > xAxisLimit) ? xAxisLimit : xpt;
        
        // Compute the ypt
        //
        CGFloat ypt = CGPointFromString(_selPaintSwatch.coord_pt).y - _imageViewHeight / 2;
        ypt = (ypt < 0.0) ? 0.0 : ypt;
        
        CGFloat yAxisLimit = _referenceImage.size.height - _imageViewHeight;
        ypt = (ypt > yAxisLimit) ? yAxisLimit : ypt;

    
        UIImage *croppedImage = [ColorUtils cropImage:_referenceImage frame:CGRectMake(xpt, ypt, _imageViewWidth * 2, _imageViewHeight)];
        UIImageView *croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
        [croppedImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
        [croppedImageView.layer setCornerRadius: DEF_CORNER_RADIUS];
        [croppedImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];

        [croppedImageView setContentMode: UIViewContentModeScaleAspectFit];
        [croppedImageView setClipsToBounds: YES];
        CGFloat croppedImageXOffset = _imageViewXOffset + _imageViewWidth + DEF_FIELD_PADDING;
        [croppedImageView setFrame:CGRectMake(croppedImageXOffset, _imageViewYOffset + 2.0, _imageViewWidth * 2, _imageViewHeight)];
        [croppedImageView setTag:IMAGE_TAG];
        
        [cell.contentView addSubview:croppedImageView];
        
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        
    } else if (indexPath.section == MATCH_SECTION) {

        PaintSwatches *paintSwatch = [_matchedSwatches objectAtIndex:indexPath.row + 1];
        
        if (_isRGB == FALSE) {
            cell.imageView.image = [ColorUtils renderPaint:paintSwatch cellWidth:_matchImageViewWidth cellHeight:_matchImageViewHeight];
        } else {
            cell.imageView.image = [ColorUtils renderRGB:paintSwatch cellWidth:_matchImageViewWidth cellHeight:_matchImageViewHeight];
        }
        
        // Tag the first reference image
        //
        [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds: YES];
        [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _matchImageViewWidth, _matchImageViewHeight)];
        
        [cell.textLabel setFont: TABLE_CELL_FONT];
        [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
        [cell.textLabel setText: paintSwatch.name];
        
        if (_editFlag == TRUE) {
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        } else {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        }
        
//    } else if (indexPath.section == COLOR_SECTION) {
//        cell.imageView.image = [ColorUtils renderRGB:_selPaintSwatch cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TEXTFIELD_HEIGHT];
//        [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
//        [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
//        [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
//        
//        if (_editFlag == FALSE) {
//            [cell.textLabel setText: @""];
//
//            UILabel *textLabel = [[UILabel alloc] init];
//            [textLabel setText:_colorSelected];
//            [textLabel setTextColor:[self setTextColor:_colorName]];
//            [textLabel setBackgroundColor:_subjColorValue];
//            [textLabel setTextAlignment:NSTextAlignmentCenter];
//            [textLabel setTag:COLLBL_TAG];
//            [textLabel setFont: TEXT_FIELD_FONT];
//            [textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
//            [textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
//            [textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];
//            
//            [textLabel setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, (self.tableView.bounds.size.width - _imageViewWidth) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
//            
//            [cell.contentView addSubview:textLabel];
//
//        } else {
//            
//            // Create the subjective color picker text field
//            //
//            _colorSelected = [_subjColorNames objectAtIndex:_colorPickerSelRow];
//            _subjColorName  = [FieldUtils createTextField:_colorSelected tag:COLTXT_TAG];
//            
//            [self resizeSelFieldAndDone:DEF_BUTTON_WIDTH];
//            
//            // Create the textfield
//            //
//            [_subjColorName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _selTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
//            
//            // Create the button
//            //
//            CGRect buttonFrame = CGRectMake(_doneButtonXOffset, _textFieldYOffset, _doneButtonWidth, DEF_TEXTFIELD_HEIGHT);
//            _doneColorButton = [BarButtonUtils create3DButton:@"Done" tag: COLOR_BTN_TAG frame: buttonFrame];
//
//            [_doneColorButton addTarget:self action:@selector(colorSelection) forControlEvents:UIControlEventTouchUpInside];
//            [_doneColorButton setHidden:TRUE];
//            
//            if (_colorName && _subjColorValue) {
//                [_subjColorName setTextColor:[self setTextColor:_colorName]];
//                [_subjColorName setBackgroundColor:_subjColorValue];
//            }
//            [_subjColorName setDelegate:self];
//            [cell.contentView addSubview:_subjColorName];
//            [cell.contentView addSubview:_doneColorButton];
//            [cell.textLabel setText:@""];
//
//            [_subjColorName setTextAlignment:NSTextAlignmentCenter];
//            [_subjColorName setInputView: _subjColorPicker];
//            
//            // Create the subjective color picker
//            //
//            [self createColorPicker];
//        }
//        
//        [cell setAccessoryType: UITableViewCellAccessoryNone];
//
//    } else if (indexPath.section == TYPES_SECTION) {
//        
//        if (_editFlag == FALSE) {
//            [cell.textLabel setText: @""];
//            
//            UILabel *textLabel = [[UILabel alloc] init];
//            [textLabel setText:_typeSelected];
//            [textLabel setTextColor: LIGHT_TEXT_COLOR];
//
//            [textLabel setTextAlignment:NSTextAlignmentCenter];
//            [textLabel setTag:TYPLBL_TAG];
//            [textLabel setFont: TEXT_FIELD_FONT];
//            
//            [textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
//            [textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
//            [textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];
//            
//            [textLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
//            
//            [cell.contentView addSubview:textLabel];
//            
//            
//        } else {
//            
//            // Create the subjective color picker text field
//            //
//            _typeSelected = [GlobalSettings getSwatchType:_typesPickerSelRow];
//            _swatchTypeName  = [FieldUtils createTextField:_typeSelected tag:TYPTXT_TAG];
//
//            [self resizeSelFieldAndDone:DEF_BUTTON_WIDTH];
//
//            // Create the button
//            //
//            CGRect buttonFrame = CGRectMake(_doneButtonXOffset, _textFieldYOffset, _doneButtonWidth, DEF_TEXTFIELD_HEIGHT);
//            _doneTypeButton = [BarButtonUtils create3DButton:@"Done" tag: TYPBTN_TAG frame: buttonFrame];
//            [_doneTypeButton addTarget:self action:@selector(swatchTypeSelection) forControlEvents:UIControlEventTouchUpInside];
//            [_doneTypeButton setHidden:TRUE];
//            
//            [_swatchTypeName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _selTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
//        
//            [_swatchTypeName setDelegate:self];
//            [cell.contentView addSubview:_swatchTypeName];
//            [cell.contentView addSubview:_doneTypeButton];
//
//            [cell.textLabel setText:@""];
//            
//            [_swatchTypeName setTextAlignment:NSTextAlignmentCenter];
//            [_swatchTypeName setInputView: _swatchTypesPicker];
//            
//            // Create the swatch Type picker
//            //
//            [self createSwatchTypePicker];
//        }
    }
        
    [cell setAccessoryType: UITableViewCellAccessoryNone];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = (int)indexPath.row;
    if (indexPath.section == MATCH_SECTION) {
        [self performSegueWithIdentifier:@"ShowSwatchDetailSegue" sender:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MATCH_SECTION) {
        return YES;
    } else {
        return NO;
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MATCH_SECTION) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MATCH_SECTION) {
        return YES;
    } else {
        return NO;
    }
}

// flag is 1 after pressing the 'Edit' button
//
- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];

    _editFlag = flag;
    
    [self.tableView reloadData];
}

// Header sections
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == NAME_SECTION) {
        if ((_editFlag == FALSE) && [_nameEntered isEqualToString:@""]) {
            return 0.0;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == KEYW_SECTION) {
        if ((_editFlag == FALSE) && [_keywEntered isEqualToString:@""]) {
            return 0.0;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == DESC_SECTION) {
        if ((_editFlag == FALSE) && [_descEntered isEqualToString:@""]) {
            return 0.0;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }

//    } else if (section == COLOR_SECTION) {
//        if ((_editFlag == FALSE) && (_colorPickerSelRow == 0)) {
//            return 0.0;
//        } else {
//            return DEF_TABLE_HDR_HEIGHT;
//        }
//
//    } else if (section == TYPES_SECTION) {
//        if ((_editFlag == FALSE) && (_typesPickerSelRow == 0)) {
//            return 0.0;
//        } else {
//            return DEF_TABLE_HDR_HEIGHT;
//        }
        
    } else if (section == DIV1_SECTION || section == DIV2_SECTION) {
        return 0.0;

    } else {
        return DEF_TABLE_HDR_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    //
    [view setTintColor: DARK_TEXT_COLOR];
    
    // Text Color
    //
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor: LIGHT_TEXT_COLOR];
    [header.contentView setBackgroundColor: DARK_BG_COLOR];
    [header.textLabel setFont: TABLE_HEADER_FONT];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    if (section == NAME_SECTION) {
        headerStr = @"Image Name";
        
    } else if (section == KEYW_SECTION) {
        headerStr = @"Keywords";

    } else if (section == DESC_SECTION) {
        headerStr = @"Description";
        
    } else if (section == IMAGE_SECTION) {
        headerStr = @"Reference Images";
//    
//    } else if (section == COLOR_SECTION) {
//        headerStr = @"Subjective Color Selection";
//        
//    } else if (section == TYPES_SECTION) {
//        headerStr = @"Swatch Type Selection";
        
    } else if (section == MATCH_SECTION) {
        headerStr = [[NSString alloc] initWithFormat:@"Matches (Type Method: %@)", [_matchAlgorithms objectAtIndex:_matchAlgIndex]];
    }
    
    return headerStr;
}

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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    int fromIndex = (int)fromIndexPath.row + 1;
    int toIndex   = (int)toIndexPath.row + 1;
    
    // 2 takes into account the first "swatch" item
    //
    if ((fromIndex != toIndex) && [_matchedSwatches count] > 2) {
        PaintSwatches *fromSwatch = [_matchedSwatches objectAtIndex:fromIndex];
        
        [_matchedSwatches removeObjectAtIndex:fromIndex];
        [_matchedSwatches insertObject:fromSwatch atIndex:toIndex];

        [self.tableView reloadData];
    }
}

#pragma mark - UITextField Delegate Methods

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UITextField Delegates
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if (textField.tag == COLTXT_TAG) {
//        [_doneColorButton setHidden:FALSE];
//
//    } else if (textField.tag == TYPTXT_TAG) {
//        [_doneTypeButton setHidden:FALSE];
//    };
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        [AlertUtils noValueAlert];
        
    } else {
        _textReturn  = TRUE;
    }
    
    if ((textField.tag == NAME_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _nameEntered = textField.text;
    } else if ((textField.tag == KEYW_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _keywEntered = textField.text;
    } else if ((textField.tag == DESC_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _descEntered = textField.text;
//    } else if (textField.tag == COLTXT_TAG) {
//        _colorSelected = textField.text;
//    } else if (textField.tag == TYPTXT_TAG) {
//        _typeSelected = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == NAME_FIELD_TAG && textField.text.length >= MAX_NAME_LEN && range.length == 0) {
        [AlertUtils sizeLimitAlert: MAX_NAME_LEN];
        return NO;
    } else if (textField.tag == KEYW_FIELD_TAG && textField.text.length >= MAX_KEYW_LEN && range.length == 0) {
        [AlertUtils sizeLimitAlert: MAX_KEYW_LEN];
        return NO;
    } else if (textField.tag == DESC_FIELD_TAG && textField.text.length >= MAX_DESC_LEN && range.length == 0) {
        [AlertUtils sizeLimitAlert: MAX_DESC_LEN];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UIPickerView methods

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Picker Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// The number of columns of data
//
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
//
//- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (pickerView.tag == TYPSEL_TAG) {
//        return (long)[_swatchTypeNames count];
//    } else {
//        return (long)[_subjColorNames  count];
//    }
//}
//
//// Row height
////
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return DEF_PICKER_ROW_HEIGHT;
//}
//
//// The data to return for the row and component (column) that's being passed in
////
//- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (pickerView.tag == TYPSEL_TAG) {
//        return [_swatchTypeNames objectAtIndex:row];
//    } else {
//        return [_subjColorNames  objectAtIndex:row];
//    }
//}
//
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    
//    UILabel *label = (UILabel*)view;
//    if (label == nil) {
//        label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
//    }
//    
//    if (pickerView.tag == TYPSEL_TAG) {
//        [label setText:[_swatchTypeNames objectAtIndex:row]];
//        [label setTextColor: LIGHT_TEXT_COLOR];
//        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
//        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
//
//    } else {
//        NSString *colorName = [_subjColorNames objectAtIndex:row];
//        UIColor *subjColorValue = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
//        
//        [label setTextColor:[self setTextColor:colorName]];
//        [label setBackgroundColor:subjColorValue];
//        [label setText:[_subjColorNames objectAtIndex:row]];
//    }
//    [label setTextAlignment:NSTextAlignmentCenter];
//    
//    return label;
//}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if (pickerView.tag == TYPSEL_TAG) {
//        NSString *swatchType = [_swatchTypeNames objectAtIndex:row];
//        [_swatchTypeName setText:swatchType];
//        [_selPaintSwatch setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:swatchType]]];
//        [self setTypesPickerSelRow: (int)row];
//        
//    } else {
//        _colorName = [_subjColorNames objectAtIndex:row];
//        _subjColorValue = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:_colorName] valueForKey:@"hex"]];
//        
//        [_subjColorName setText:[_subjColorNames objectAtIndex:row]];
//        [_subjColorName setTextColor:[self setTextColor:_colorName]];
//        [_subjColorName setBackgroundColor:_subjColorValue];
//        [_selPaintSwatch setSubj_color_id:[NSNumber numberWithInt:[GlobalSettings getSubjColorId:_colorName]]];
//        [self setColorPickerSelRow: (int)row];
//    }
//}
//
//- (void)createColorPicker {
//    _subjColorPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:COLSEL_TAG];
//    
//    [_subjColorPicker setDataSource:self];
//    [_subjColorPicker setDelegate:self];
//    [_subjColorPicker selectRow:_colorPickerSelRow inComponent:0 animated:YES];
//    [_subjColorName setInputView: _subjColorPicker];
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
//                                             initWithTarget:self action:@selector(colorSelection)];
//    tapRecognizer.numberOfTapsRequired = 1;
//    [_subjColorPicker addGestureRecognizer:tapRecognizer];
//    tapRecognizer.delegate = self;
//}
//
//- (void)createSwatchTypePicker {
//    _swatchTypesPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:TYPSEL_TAG];
//
//    [_swatchTypesPicker setDataSource:self];
//    [_swatchTypesPicker setDelegate:self];
//    [_swatchTypesPicker selectRow:_typesPickerSelRow inComponent:0 animated:YES];
//    [_swatchTypeName setInputView: _swatchTypesPicker];
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
//                                             initWithTarget:self action:@selector(swatchTypeSelection)];
//    tapRecognizer.numberOfTapsRequired = 1;
//    [_swatchTypesPicker addGestureRecognizer:tapRecognizer];
//    tapRecognizer.delegate = self;
//}
//
//- (void)colorSelection {
//    [_subjColorName resignFirstResponder];
//    [_subjColorPicker removeFromSuperview];
//    [_doneColorButton setHidden:TRUE];
//}
//
//- (void)swatchTypeSelection {
//    [_swatchTypeName resignFirstResponder];
//    [_swatchTypesPicker removeFromSuperview];
//    [_doneTypeButton setHidden:TRUE];
//}

- (UIColor *)setTextColor:(NSString *)colorName {
    
    UIColor *textColor = DARK_TEXT_COLOR;
    if ([colorName isEqualToString:@"Black"] || [colorName isEqualToString:@"Blue"] ||
        [colorName isEqualToString:@"Brown"] || [colorName isEqualToString:@"Blue Violet"]) {
        textColor = LIGHT_TEXT_COLOR;
    }
    
    return textColor;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TapRecognizer Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIGestureRecognizer methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return true;
}

#pragma mark - BarButton Methods

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIBarButton actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (IBAction)changeButtonRendering:(id)sender {
    _isRGB = [BarButtonUtils changeButtonRendering:_isRGB refTag: RGB_BTN_TAG toolBarItems:self.toolbarItems];
    [self.tableView reloadData];
}

- (IBAction)decrMatchAlgorithm:(id)sender {
    
    _matchAlgIndex--;
    
    if (_matchAlgIndex < 0) {
        _matchAlgIndex = (int)[_matchAlgorithms count] - 1;
    }
    
    // Re-run the comparison algorithm
    //
    _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    
    [self.tableView reloadData];
}


- (IBAction)incrMatchAlgorithm:(id)sender {

    _matchAlgIndex++;
    
    if (_matchAlgIndex >= [_matchAlgorithms count]) {
        _matchAlgIndex = 0;
    }
    
    // Re-run the comparison algorithm
    //
    _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];

    [self.tableView reloadData];
}

- (IBAction)removeTableRows:(id)sender {
    if (_maxMatchNum > 1) {
        [_matchedSwatches removeLastObject];
        _maxMatchNum--;

        [self.tableView reloadData];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:TRUE];
        
    }
    
    if (_maxMatchNum <= 1) {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (IBAction)addTableRows:(id)sender {
    if (_maxMatchNum < _maxRowLimit) {
        _maxMatchNum++;
 
        // Re-run the comparison algorithm
        //
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    
        [self.tableView reloadData];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:TRUE];
        
    } else {
        [AlertUtils rowLimitAlert: _maxRowLimit];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

#pragma mark - General purpose methods

- (void)resizeSelFieldAndDone:(CGFloat)doneWidth {
    _tableViewWidth     = self.tableView.bounds.size.width;
    _doneButtonWidth    = doneWidth;
    _selTextFieldWidth  = _tableViewWidth - _imageViewWidth - _doneButtonWidth - (DEF_FIELD_PADDING * 2);
    _doneButtonXOffset  = _imageViewWidth + _selTextFieldWidth + DEF_FIELD_PADDING;
}


#pragma mark - Navigation/Save


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ShowSwatchDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        int index = _selectedRow + 1;
        [swatchDetailTableViewController setPaintSwatch:[_matchedSwatches objectAtIndex:index]];
    }
}


- (IBAction)save:(id)sender {
}


@end
