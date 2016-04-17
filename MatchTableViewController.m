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
#import "AlertUtils.h"
#import "StringObjectUtils.h"
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"

// NSManagedObject
//
#import "TapAreaSwatch.h"
#import "PaintSwatches.h"
#import "Keyword.h"
#import "TapAreaKeyword.h"


@interface MatchTableViewController ()

@property (nonatomic) BOOL isRGB, textReturn;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *nameEntered, *keywEntered, *descEntered, *colorSelected, *typeSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *colorName, *imagesHeader, *matchesHeader, *nameHeader, *keywHeader, *descHeader;
@property (nonatomic, strong) UIColor *subjColorValue;
@property (nonatomic) CGFloat textFieldYOffset, refNameWidth, imageViewWidth, imageViewHeight, imageViewXOffset, imageViewYOffset, matchImageViewWidth, matchImageViewHeight, tableViewWidth, doneButtonWidth, selTextFieldWidth, doneButtonXOffset;
@property (nonatomic) BOOL editFlag;
@property (nonatomic) int selectedRow, dbSwatchesCount, maxRowLimit, colorPickerSelRow, typesPickerSelRow;
@property (nonatomic, strong) NSMutableArray *matchedSwatches;
@property (nonatomic, strong) NSMutableArray *matchAlgorithms;

// Picker views
//
@property (nonatomic, strong) UITextField *swatchTypeName, *subjColorName;
@property (nonatomic, strong) NSDictionary *subjColorData, *swatchTypeData;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity, *tapAreaSwatchEntity, *keywordEntity, *tapAreaKeywordEntity;

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

const int MAX_SECTION   = 7;


// Table views tags
//
const int ALG_TAG    = 2;
const int TYPE_TAG   = 4;
const int IMAGE_TAG  = 6;


- (void)viewDidLoad {
    [super viewDidLoad];

    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // Initialize the PaintSwatch entity
    //
    _paintSwatchEntity    = [NSEntityDescription entityForName:@"PaintSwatch"    inManagedObjectContext:self.context];
    _tapAreaSwatchEntity  = [NSEntityDescription entityForName:@"TapAreaSwatch"  inManagedObjectContext:self.context];
    _tapAreaKeywordEntity = [NSEntityDescription entityForName:@"TapAreaKeyword" inManagedObjectContext:self.context];
    _keywordEntity        = [NSEntityDescription entityForName:@"Keyword"        inManagedObjectContext:self.context];
    
    
    _isRGB    = FALSE;
    _editFlag = FALSE;
    _reuseCellIdentifier = @"MatchTableCell";


    // Header names
    //
    _imagesHeader  = @"Tap Area Reference Images";
    _matchesHeader = @"Matches";
    _nameHeader    = @"Tap Area Name";
    _keywHeader    = @"Tap Area Keywords";
    _descHeader    = @"Tap Area Description";


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
    
    // Offsets and Widths
    //
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / 2;
    _doneButtonWidth  = 1.0;

    
    // Set the placeholders
    //
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Tap Area Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Comma-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Tap Area Description (max. %i chars) - ", MAX_DESC_LEN];
    
    _dbSwatchesCount  = (int)[_dbPaintSwatches count];

    _maxRowLimit = (_dbSwatchesCount > DEF_MAX_MATCH) ? DEF_MAX_MATCH : _dbSwatchesCount;


    // Match algorithms
    //
    _maxMatchNum     = (int)[[_tapArea.tap_area_swatch allObjects] count];
    _matchAlgorithms = [ManagedObjectUtils fetchDictNames:@"MatchAlgorithm" context:self.context];
    _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    
    
    // Initialize
    //
    // Override the default Algorithm index?
    //
    _matchAlgIndex = [_tapArea.match_algorithm_id intValue];
    _nameEntered   = _tapArea.name;
    _descEntered   = _tapArea.desc;
    
    // Keywords
    //
    NSSet *tapAreaKeywords = _tapArea.tap_area_keyword;
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (TapAreaKeyword *tap_area_keyword in tapAreaKeywords) {
        Keyword *keyword = tap_area_keyword.keyword;
        [keywords addObject:keyword.name];
    }
    _keywEntered = [keywords componentsJoinedByString:@", "];
    
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
        
    } else if (indexPath.section == DIV1_SECTION || indexPath.section == DIV2_SECTION) {
        return DEF_TBL_DIVIDER_HGT;
    }
    return DEF_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor:DARK_BG_COLOR];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];

    cell.imageView.image = nil;

    
    // Remove the tags
    //
    for (int tag=1; tag<=MAX_TAG; tag++) {
        [[cell.contentView viewWithTag:tag] removeFromSuperview];
    }

    // Set up the image name and match method fields
    //
    if (indexPath.section == NAME_SECTION) {
        
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
            
        } else {
            [FieldUtils makeTextFieldNonEditable:refName content:_nameEntered border:TRUE];
        }
        [cell setAccessoryType: UITableViewCellAccessoryNone];
    
    // Set up the keywords and match type fields
    //
    } else if (indexPath.section == KEYW_SECTION) {

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
        
    
    // Set up the description field
    //
    } else if (indexPath.section == DESC_SECTION) {
        
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
        
    } else if (indexPath.section == IMAGE_SECTION) {
        
        if (_isRGB == FALSE) {
            cell.imageView.image = [ColorUtils renderPaint:_selPaintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
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
            cell.imageView.image = [ColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_matchImageViewWidth cellHeight:_matchImageViewHeight];
        } else {
            cell.imageView.image = [ColorUtils renderRGB:paintSwatch cellWidth:_matchImageViewWidth cellHeight:_matchImageViewHeight];
        }
        
        // Tag the first reference image
        //
        [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds:YES];
        [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _matchImageViewWidth, _matchImageViewHeight)];
        
        [cell.textLabel setFont:TABLE_CELL_FONT];
        [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
        [cell.textLabel setText: paintSwatch.name];
        
        if (_editFlag == TRUE) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = (int)indexPath.row;
    if (indexPath.section == MATCH_SECTION) {
        [self performSegueWithIdentifier:@"ShowSwatchDetailSegue" sender:self];
    }
}

// For now (perhaps even this version), disallow the manual override
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == MATCH_SECTION) {
//        return YES;
//    } else {
//        return NO;
//    }
    return NO;
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
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == KEYW_SECTION) {
        if ((_editFlag == FALSE) && [_keywEntered isEqualToString:@""]) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == DESC_SECTION) {
        if ((_editFlag == FALSE) && [_descEntered isEqualToString:@""]) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == DIV1_SECTION || section == DIV2_SECTION) {
        return DEF_NIL_HEADER;

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
        headerStr = _nameHeader;
        
    } else if (section == KEYW_SECTION) {
        headerStr = _keywHeader;

    } else if (section == DESC_SECTION) {
        headerStr = _descHeader;
        
    } else if (section == IMAGE_SECTION) {
        headerStr = _imagesHeader;
        
    } else if (section == MATCH_SECTION) {
        int match_ct = (int)[_matchedSwatches count] - 1;
        headerStr = [[NSString alloc] initWithFormat:@"%@ (Method: %@, Count: %i)", _matchesHeader, [_matchAlgorithms objectAtIndex:_matchAlgIndex], match_ct];
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

// For now (perhaps even this version), disallow the manual override
//
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//    int fromIndex = (int)fromIndexPath.row + 1;
//    int toIndex   = (int)toIndexPath.row + 1;
//    
//    // 2 takes into account the first "swatch" item
//    //
//    if ((fromIndex != toIndex) && [_matchedSwatches count] > 2) {
//        PaintSwatches *fromSwatch = [_matchedSwatches objectAtIndex:fromIndex];
//        
//        [_matchedSwatches removeObjectAtIndex:fromIndex];
//        [_matchedSwatches insertObject:fromSwatch atIndex:toIndex];
//
//        [self.tableView reloadData];
//    }
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
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        _textReturn  = TRUE;
    }
    
    if ((textField.tag == NAME_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _nameEntered = textField.text;
    } else if ((textField.tag == KEYW_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _keywEntered = textField.text;
    } else if ((textField.tag == DESC_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
        _descEntered = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == NAME_FIELD_TAG && textField.text.length >= MAX_NAME_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert:MAX_NAME_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == KEYW_FIELD_TAG && textField.text.length >= MAX_KEYW_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert:MAX_KEYW_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else if (textField.tag == DESC_FIELD_TAG && textField.text.length >= MAX_DESC_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert:MAX_DESC_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
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
        UIAlertController *myAlert = [AlertUtils rowLimitAlert: _maxRowLimit];
        [self presentViewController:myAlert animated:YES completion:nil];
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
    
    // Ensure that this value is not empty or nil
    //
    if (![_nameEntered isEqualToString:@""] && _nameEntered != nil) {
        [_tapArea setName:_nameEntered];
    }
    
    [_tapArea setDesc:_descEntered];
    
    // Delete all tapAreaKeywords and associations first
    //
    [ManagedObjectUtils deleteTapAreaKeywords:_tapArea context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_keywEntered componentsSeparatedByString:@","]];
    
    for (NSString *keyword in keywords) {
        if ([keyword isEqualToString:@""]) {
            continue;
        }
        
        Keyword *kwObj = [ManagedObjectUtils queryKeyword:keyword context:self.context];
        if (kwObj == nil) {
            kwObj = [[Keyword alloc] initWithEntity:_keywordEntity insertIntoManagedObjectContext:self.context];
            [kwObj setName:keyword];
        }
        
        TapAreaKeyword *taKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_tapArea.objectID relationName:@"tap_area" entityName:@"TapAreaKeyword" context:self.context];
        
        if (taKwObj == nil) {
            taKwObj = [[TapAreaKeyword alloc] initWithEntity:_tapAreaKeywordEntity insertIntoManagedObjectContext:self.context];
            [taKwObj setKeyword:kwObj];
            [taKwObj setTap_area:_tapArea];
            
            [_tapArea addTap_area_keywordObject:taKwObj];
            [kwObj addTap_area_keywordObject:taKwObj];
        }
    }

    
    NSArray *tapAreaSwatches = [_tapArea.tap_area_swatch allObjects];
    
    // Get the currently saved values for swatch count and algorithm id
    //
    int saved_algorithm_id = [[_tapArea match_algorithm_id] intValue];
    int saved_swatch_count = (int)[tapAreaSwatches count];

    
    // If either of the currently saved values differ, recreate the tapAreaSwatches
    //
    int curr_swatch_ct = (int)[_matchedSwatches count] - 1;
    if ((saved_algorithm_id != _matchAlgIndex) || (saved_swatch_count != curr_swatch_ct)) {
    
        [_tapArea setMatch_algorithm_id:[NSNumber numberWithInt:_matchAlgIndex]];
        
        // Clear the existing tapAreaSwatches
        //
        for (int i=0; i<saved_swatch_count; i++) {
            TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
            PaintSwatches *paintSwatch   = (PaintSwatches *)tapAreaSwatch.paint_swatch;

            [_tapArea removeTap_area_swatchObject:tapAreaSwatch];
            [paintSwatch removeTap_area_swatchObject:tapAreaSwatch];
            [self.context deleteObject:tapAreaSwatch];
        }
        
        
        // The _matchedSwatch array gets automatically recreated when the algorithm changes
        //
        for (int i=curr_swatch_ct; i>=1; i--) {
            PaintSwatches *paintSwatch   = [_matchedSwatches objectAtIndex:i];
    
            TapAreaSwatch *tapAreaSwatch = [[TapAreaSwatch alloc] initWithEntity:_tapAreaSwatchEntity insertIntoManagedObjectContext:self.context];
            [tapAreaSwatch setPaint_swatch:(PaintSwatch *)paintSwatch];
            [tapAreaSwatch setTap_area:_tapArea];
            [tapAreaSwatch setMatch_order:[NSNumber numberWithInt:i]];
    
            [_tapArea addTap_area_swatchObject:tapAreaSwatch];
            [paintSwatch addTap_area_swatchObject:tapAreaSwatch];
        }
    }

    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"TapArea save" message:@"Error saving"];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        NSLog(@"TapArea save successful");
    }
}


@end
