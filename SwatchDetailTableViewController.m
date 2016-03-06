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

// SwatchName and Reference Label and Name fields
//
@property (nonatomic, strong) UITextField *swatchName, *swatchTypeName, *subjColorName, *swatchKeywords, *swatchDesc;

@property (nonatomic, strong) NSString *reuseCellIdentifier, *nameEntered, *keywEntered, *descEntered, *colorSelected, *typeSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *colorPlaceholder, *typePlaceholder, *colorName;

// Subjective color related
//
@property (nonatomic, strong) UILabel *pickerAlertLabel;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *barButtonDone;

@property (nonatomic, strong) UIImageView *colorWheelView;

@property (nonatomic, strong) UIPickerView *subjColorPicker, *swatchTypesPicker;

@property (nonatomic, strong) NSArray *subjColorNames, *swatchTypeNames;

@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIActionSheet *pickerActionSheet;

@property (nonatomic, strong) UIFont *placeholderFont, *currFont;
@property (nonatomic, strong) UIColor *subjColorValue;

@property (nonatomic) CGFloat tableViewWidth, doneColorButtonWidth, doneTypeButtonWidth, viewWidth, defXStartOffset, defYOffset, imageViewXOffset, imageViewWidth, imageViewHeight, swatchNameWidth, swatchTypeNameWidth, colorViewWidth, swatchLabelWidth, textFieldYOffset, colorTextFieldWidth, typeTextFieldWidth, doneColorButtonXOffset, doneTypeButtonXOffset;

@property (nonatomic) int swatchTypeSelectedRow, typesPickerSelRow, colorPickerSelRow, collectViewSelRow;

@property (nonatomic, strong) NSMutableArray *colorArray, *paintSwatches;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

// Picker views
//
@property (nonatomic, strong) UIButton *doneColorButton, * doneTypeButton;
@property (nonatomic) BOOL colorPickerFlag, typesPickerFlag;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *keywordEntity, *swatchKeywordEntity;

@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Constants defaults
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NSString * const REUSE_IDENTIFIER = @"SwatchDetailCell";
const int num_core_sections  = 5;
int num_tableview_rows = 0;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@implementation SwatchDetailTableViewController

static NSString * const reuseIdentifier = @"CollectionPrototypeCell";

// Globals
//
const int NUM_SECTIONS          = 6;

const int DETAIL_NAME_SECTION   = 0;
const int DETAIL_COLOR_SECTION  = 1;
const int DETAIL_TYPES_SECTION  = 2;
const int DETAIL_KEYW_SECTION   = 3;
const int DETAIL_DESC_SECTION   = 4;
const int DETAIL_MIX_SECTION    = 5;


#pragma mark Initialization methods

-(void)loadView {
    [super loadView];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _keywordEntity       = [NSEntityDescription entityForName:@"Keyword"       inManagedObjectContext:self.context];
    _swatchKeywordEntity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:self.context];
    
    num_tableview_rows = (int)[_mixAssocSwatches count];
    
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
    int type_id       = [[_paintSwatch type_id] intValue];
    int subj_color_id = [[_paintSwatch subj_color_id] intValue];

    
    // A few defaults
    //
    _imageViewWidth    = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight   = DEF_VLG_TBL_CELL_HGT;
    _typesPickerSelRow = type_id       ? type_id       : 0;
    _colorPickerSelRow = subj_color_id ? subj_color_id : 0;
    
    _colorPickerFlag   = FALSE;
    _typesPickerFlag   = FALSE;


    // Offsets and Widths
    //
    _doneColorButtonWidth  = 1.0;
    _doneTypeButtonWidth   = 1.0;
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / 2;

    // Instantiate the widgets
    //
    _swatchName  = [FieldUtils createTextField:_paintSwatch.name tag: NAME_FIELD_TAG];
    [_swatchName setDelegate:self];

    
    // Swatch Type
    //
    NSString *typeName = [GlobalSettings getSwatchType:_typesPickerSelRow];
    _swatchTypeName  = [FieldUtils createTextField:typeName tag: TYPE_FIELD_TAG];
    [_swatchTypeName setTextAlignment:NSTextAlignmentCenter];
    [_swatchTypeName setInputView: _swatchTypesPicker];
    [_swatchTypeName setDelegate:self];
    [self createSwatchTypePicker];

    NSString *colorName = [GlobalSettings getColorName:_colorPickerSelRow];
    _subjColorName = [FieldUtils createTextField:colorName tag: COLOR_FIELD_TAG];
    [_subjColorName setTextAlignment:NSTextAlignmentCenter];
    [_subjColorName setInputView: _subjColorPicker];
    [_subjColorName setDelegate:self];
    [self createColorPicker];
    
    NSSet *swatchKeywords = _paintSwatch.swatch_keyword;
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (SwatchKeyword *swatch_keyword in swatchKeywords) {
        Keyword *keyword = swatch_keyword.keyword;
        [keywords addObject:keyword.name];
    }
    
    // Create the buttons
    //
    CGRect colorButtonFrame = CGRectMake(_doneColorButtonXOffset, _textFieldYOffset, _doneColorButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneColorButton = [BarButtonUtils create3DButton:@"Done" tag: COLOR_BTN_TAG frame:colorButtonFrame];
    
    [_doneColorButton addTarget:self action:@selector(colorSelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneColorButton setHidden:TRUE];
    
    CGRect typeButtonFrame = CGRectMake(_doneTypeButtonXOffset, _textFieldYOffset, _doneTypeButtonWidth, DEF_TEXTFIELD_HEIGHT);
    _doneTypeButton = [BarButtonUtils create3DButton:@"Done" tag: TYPE_BTN_TAG frame:typeButtonFrame];
    [_doneTypeButton addTarget:self action:@selector(swatchTypeSelection) forControlEvents:UIControlEventTouchUpInside];
    [_doneTypeButton setHidden:TRUE];
    
    _swatchKeywords = [FieldUtils createTextField:[keywords componentsJoinedByString:@", "] tag: KEYW_FIELD_TAG];
    [_swatchKeywords setDelegate: self];

    _swatchDesc = [FieldUtils createTextField:_paintSwatch.desc tag: DESC_FIELD_TAG];
    [_swatchDesc setDelegate: self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Edit Mode Button
    //
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
    [self.editButtonItem setAction:@selector(editAction:)];
    [self setTextFieldsAttributes:LIGHT_TEXT_COLOR bgColor:DARK_BG_COLOR isEnabled:FALSE];
    
    
    // Adjust the layout with rotational changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFrameSizes)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
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

    [_swatchName      setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];


    // Subjective Color
    //
    if (_colorPickerFlag == TRUE) {
        _doneColorButtonWidth   = DEF_BUTTON_WIDTH;
        _colorTextFieldWidth = viewWidth - _imageViewWidth - _doneColorButtonWidth - (DEF_FIELD_PADDING * 2);
        
    } else {
        _doneColorButtonWidth   = 1.0;
        _colorTextFieldWidth = viewWidth - _imageViewWidth - (DEF_FIELD_PADDING * 2);
        
    }
    
    // Swatch Type
    //
    if (_typesPickerFlag == TRUE) {
        _doneTypeButtonWidth   = DEF_BUTTON_WIDTH;
        _typeTextFieldWidth = viewWidth - _doneTypeButtonWidth - (DEF_FIELD_PADDING * 2) - DEF_TABLE_X_OFFSET;
        
    } else {
        _doneTypeButtonWidth   = 1.0;
        _typeTextFieldWidth = fullTextFieldWidth;
        
    }
    [_subjColorName setFrame:CGRectMake(_imageViewWidth, _textFieldYOffset, _colorTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_swatchTypeName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, _typeTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    
    
    _doneColorButtonXOffset  = _imageViewWidth + _colorTextFieldWidth + DEF_FIELD_PADDING;
    [_doneColorButton setFrame:CGRectMake(_doneColorButtonXOffset, _textFieldYOffset, _doneColorButtonWidth, DEF_TEXTFIELD_HEIGHT)];

    _doneTypeButtonXOffset  = DEF_TABLE_X_OFFSET + _typeTextFieldWidth + DEF_FIELD_PADDING;
    [_doneTypeButton setFrame:CGRectMake(_doneTypeButtonXOffset, _textFieldYOffset, _doneTypeButtonWidth, DEF_TEXTFIELD_HEIGHT)];

    // Keywords and Description text views
    //
    [_swatchKeywords  setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
    [_swatchDesc      setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (num_tableview_rows > 0) {
        return NUM_SECTIONS;
    } else {
        return NUM_SECTIONS - 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= DETAIL_DESC_SECTION) {
        return 1;
    } else {
        return num_tableview_rows;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == DETAIL_MIX_SECTION) {
        return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
    }
    
    return DEF_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section <= DETAIL_DESC_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
        
        // Global defaults
        //
        [cell setBackgroundColor: DARK_BG_COLOR];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell.textLabel setText:@""];

        // Set the widget frame sizes
        //
        [self setFrameSizes];
        
        // Name, and reference type
        //
        if (indexPath.section == DETAIL_NAME_SECTION) {
            [cell.contentView addSubview:_swatchName];
        
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

        // Keywords field
        //
        } else if (indexPath.section == DETAIL_KEYW_SECTION) {
            [cell.contentView addSubview:_swatchKeywords];

        // Description field
        //
        } else {
            [cell.contentView addSubview:_swatchDesc];
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
    return DEF_TABLE_HDR_HEIGHT;
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
        headerStr = @"Name";
        
    } else if (section == DETAIL_COLOR_SECTION) {
        headerStr = @"Subjective Color Selection";
        
    } else if (section == DETAIL_TYPES_SECTION) {
        headerStr = @"Swatch Type Selection";
        
    } else if (section == DETAIL_KEYW_SECTION) {
        headerStr = @"Comma-separated Keywords";
        
    } else if (section == DETAIL_DESC_SECTION) {
        headerStr = @"Description";
        
    } else {
        headerStr = @"Mix Associations";
    }

    return headerStr;
}

// Only the field contents can be edited
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Textfield Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark UITextField methods

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
        
    } else {
        [_pickerAlertLabel setText:@""];
    }
    [self setFrameSizes];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Just set the swatch name, type/color text fields are handled by the picker
    //
    if (textField.tag == NAME_FIELD_TAG) {
        [_paintSwatch setName:textField.text];
    
    // Keywords
    //
    } else if (textField.tag == KEYW_FIELD_TAG) {
//        _paintSwatch.keywords = [self keywordsTrim:[[NSMutableArray alloc] initWithArray:[textField.text componentsSeparatedByString:@","]]];

    // Description
    //
    } else if (textField.tag == DESC_FIELD_TAG) {
        [_paintSwatch setDesc:textField.text];
    }
    [textField resignFirstResponder];
    _typesPickerFlag = FALSE;
    _colorPickerFlag = FALSE;
    [self setFrameSizes];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Picker Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark UIPickerView methods


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
    } else {
        return (long)[_subjColorNames count];
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
    } else {
        return [_subjColorNames objectAtIndex:row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel *label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
    }

    if (pickerView.tag == SWATCH_PICKER_TAG) {
        [label setText:_swatchTypeNames[row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
        [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [label.layer setBorderWidth: DEF_BORDER_WIDTH];
        
        [_pickerAlertLabel setText:@"Single tap the type selection"];
        
    } else {
        NSString *colorName = _subjColorNames[row];
        UIColor *backgroundColor = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
        
        [label setTextColor:[self setTextColor:colorName]];
        [label setBackgroundColor:backgroundColor];
        [label setText:_subjColorNames[row]];
    
        [_pickerAlertLabel setText:@"Single tap the color selection"];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == SWATCH_PICKER_TAG) {
        NSString *swatchType = [_swatchTypeNames objectAtIndex:row];
        [_swatchTypeName setText:swatchType];
        [_paintSwatch setType_id: [NSNumber numberWithInteger:row]];
        
    } else {
        [self setColorPickerValues:(int)row];

        [_paintSwatch setSubj_color_id: [NSNumber numberWithInt:[[[_subjColorData objectForKey:_colorSelected] valueForKey:@"id"] intValue]]];
    }
}

- (void)createSwatchTypePicker {
    _swatchTypesPicker = [FieldUtils createPickerView:self.view.frame.size.width tag: SWATCH_PICKER_TAG];
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
    _subjColorPicker = [FieldUtils createPickerView:self.view.frame.size.width tag: COLOR_PICKER_TAG];
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

- (void)colorSelection {
    [_pickerAlertLabel setText:@""];
    [_subjColorName resignFirstResponder];
    [_subjColorPicker removeFromSuperview];
    [_doneColorButton setHidden:TRUE];
}

- (void)swatchTypeSelection {
    [_pickerAlertLabel setText:@""];
    [_swatchTypeName resignFirstResponder];
    [_swatchTypesPicker removeFromSuperview];
    [_doneTypeButton setHidden:TRUE];
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
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:[ColorUtils renderPaint:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight]];
    
    [swatchImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    [swatchImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    [swatchImageView.layer setCornerRadius: DEF_CORNER_RADIUS];
    [swatchImageView setContentMode: UIViewContentModeScaleAspectFill];
    [swatchImageView setClipsToBounds: YES];
    [swatchImageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
    
    
    cell.backgroundView = swatchImageView;
    
    return cell;
}

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

#pragma mark UIGestureRecognizer methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return true;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Storyboard, Tap, and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark Navigation and Multi-purpose methods

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

- (IBAction)saveSwatch:(id)sender {
    [_swatchName resignFirstResponder];
    [_swatchKeywords resignFirstResponder];
    [_swatchDesc resignFirstResponder];

    // Delete all  associations first and then add them back in (the cascade delete rules should
    // automatically delete the SwatchKeyword)
    //
    [ManagedObjectUtils deleteSwatchKeywords:_paintSwatch context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_swatchKeywords.text componentsSeparatedByString:@","]];
    
    // Add subjective color if not 'Other'
    //
    NSString *subj_color = _subjColorName.text;
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
        
        SwatchKeyword *swKwObj = [ManagedObjectUtils querySwatchKeyword:kwObj.objectID swatchId:_paintSwatch.objectID context:self.context];
        if (swKwObj == nil) {
            swKwObj = [[SwatchKeyword alloc] initWithEntity:_swatchKeywordEntity insertIntoManagedObjectContext:self.context];
            [swKwObj setKeyword:kwObj];
            [swKwObj setPaint_swatch:(PaintSwatch *)_paintSwatch];

            [_paintSwatch addSwatch_keywordObject:swKwObj];
            [kwObj addSwatch_keywordObject:swKwObj];
        }
    }

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Mix assoc save successful");
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

- (IBAction)editAction:(id)sender {
    if ([self.editButtonItem.title isEqualToString:@"Edit"]){
        [self.editButtonItem setTitle:@"Done"];
        [self setTextFieldsAttributes:DARK_TEXT_COLOR bgColor:LIGHT_BG_COLOR isEnabled:TRUE];

    } else {
        [self.editButtonItem setTitle:@"Edit"];
        [self setTextFieldsAttributes:LIGHT_TEXT_COLOR bgColor:DARK_BG_COLOR isEnabled:FALSE];
    }
}

- (void)setTextFieldsAttributes:(UIColor *)textColor bgColor:(UIColor *)bgColor isEnabled:(BOOL)isEnabled {
    [_swatchName setTextColor:textColor];
    [_swatchName setBackgroundColor:bgColor];
    [_swatchName setEnabled:isEnabled];
    [_swatchName.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
    [_subjColorName setEnabled:isEnabled];
    [_subjColorName.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
    [_swatchTypeName setTextColor:textColor];
    [_swatchTypeName setBackgroundColor:bgColor];
    [_swatchTypeName setEnabled:isEnabled];
    [_swatchTypeName setTextAlignment:NSTextAlignmentLeft];
    [_swatchTypeName.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];

    [_swatchKeywords setTextColor:textColor];
    [_swatchKeywords setBackgroundColor:bgColor];
    [_swatchKeywords setEnabled:isEnabled];
    [_swatchKeywords.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
    [_swatchDesc setTextColor:textColor];
    [_swatchDesc setBackgroundColor:bgColor];
    [_swatchDesc setEnabled:isEnabled];
    [_swatchDesc.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
}

@end
