//
//  MatchTableViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 8/25/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "MatchTableViewController.h"
#import "SwatchDetailTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "BarButtonUtils.h"
#import "AppColorUtils.h"
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

@property (nonatomic, strong) UIAlertController *saveAlertController;
@property (nonatomic, strong) UIAlertAction *save;


@property (nonatomic) BOOL textReturn;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *nameEntered, *keywEntered, *descEntered, *colorSelected, *typeSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *colorName, *imagesHeader, *matchesHeader, *nameHeader, *keywHeader, *descHeader, *actionTitle;
@property (nonatomic, strong) UIColor *subjColorValue;
@property (nonatomic) CGFloat textFieldYOffset, refNameWidth, imageViewWidth, imageViewHeight, imageViewXOffset, imageViewYOffset, matchSectionHeight, tableViewWidth, doneButtonWidth, selTextFieldWidth, doneButtonXOffset;
@property (nonatomic) BOOL editFlag, scrollFlag, isRGB;
@property (nonatomic) int selectedRow, dbSwatchesCount, maxRowLimit, colorPickerSelRow, typesPickerSelRow, pressSelectedRow, tappedCount, numTapSections, changedMaxNum;
@property (nonatomic, strong) NSMutableArray *matchedSwatches, *tappedSwatches;
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
const int MATCH_SECTION = 0;
const int DIV_SECTION   = 1;
const int NAME_SECTION  = 2;
const int KEYW_SECTION  = 3;
const int DESC_SECTION  = 4;
const int EMPTY_SECTION = 5;

const int MAX_SECTION   = 6;


// Table views tags
//
const int ALG_TAG    = 2;
const int TYPE_TAG   = 4;
const int IMAGE_TAG  = 6;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    //[ColorUtils setNavBarGlaze:self.navigationController.navigationBar];

    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];

    
    // Initialize the PaintSwatch entity
    //
    _paintSwatchEntity    = [NSEntityDescription entityForName:@"PaintSwatch"    inManagedObjectContext:self.context];
    _tapAreaSwatchEntity  = [NSEntityDescription entityForName:@"TapAreaSwatch"  inManagedObjectContext:self.context];
    _tapAreaKeywordEntity = [NSEntityDescription entityForName:@"TapAreaKeyword" inManagedObjectContext:self.context];
    _keywordEntity        = [NSEntityDescription entityForName:@"Keyword"        inManagedObjectContext:self.context];
    
    _editFlag    = FALSE;
    _scrollFlag  = FALSE;
    _tappedCount = 0;
    _reuseCellIdentifier = @"MatchTableCell";
    
    // Number of tap sections
    //
    _numTapSections = (int)[_tapSections count];


    // Header names
    //
    _imagesHeader  = @"Tap Area Reference Images";
    _matchesHeader = @"Matches";
    _nameHeader    = @"Tap Area Name";
    _keywHeader    = @"Tap Area Keywords";
    _descHeader    = @"Tap Area Comments";


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tableview defaults
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _imageViewXOffset     = DEF_TABLE_X_OFFSET;
    _imageViewYOffset     = DEF_Y_OFFSET;
    _imageViewWidth       = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight      = DEF_VLG_TBL_CELL_HGT;
    _matchSectionHeight   = DEF_TABLE_HDR_HEIGHT + _imageViewHeight + DEF_FIELD_PADDING;
    

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // TextField Setup
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    _textReturn       = FALSE;
    
    // Offsets and Widths
    //
    _textFieldYOffset = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / DEF_Y_OFFSET_DIVIDER;
    _doneButtonWidth  = HIDE_BUTTON_WIDTH;

    
    // Set the placeholders
    //
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Tap Area Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Semicolon-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Tap Area Comments (max. %i chars) - ", MAX_DESC_LEN];
    
    _dbSwatchesCount  = (int)[_dbPaintSwatches count];

    _maxRowLimit = (_dbSwatchesCount > DEF_MAX_MATCH) ? DEF_MAX_MATCH : _dbSwatchesCount;

    
    // Match algorithms
    //
    _matchAlgorithms = [ManagedObjectUtils fetchDictNames:@"MatchAlgorithm" context:self.context];
    
    // Render the TapArea Data
    //
    [self renderTapAreaData];

    
    // For initial release, this button is visible but disabled
    //
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.editButtonItem setTintColor:LIGHT_TEXT_COLOR];
    [self.editButtonItem setEnabled:FALSE];
    
    
    // Match Edit Button Alert Controller
    //
    _saveAlertController = [UIAlertController alertControllerWithTitle:@"Match Association Edit"
                                                               message:@"Please select operation"
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    // Modified globally (i.e., enable/disable)
    //
    _save = [UIAlertAction actionWithTitle:@"Save Changes" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self saveData];
                                   }];
    
    
    UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_saveAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_saveAlertController addAction:_save];
    [_saveAlertController addAction:discard];
    
    [_save setEnabled:FALSE];
    
    [self matchButtonsHide];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // isRGB forced to true (with option to change if not thick coverage)
    //
    _isRGB = TRUE;
    [BarButtonUtils setButtonImage:self.toolbarItems refTag:RGB_BTN_TAG imageName:RGB_IMAGE_NAME];
    
    // Disable RGB toggle if anything less than 'Thick' rendered
    //
    BOOL covFilter = [[NSUserDefaults standardUserDefaults] boolForKey:COV_FILTER_KEY];
    if (covFilter == FALSE) {
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:RGB_BTN_TAG isEnabled:FALSE];
    }

    // Reset some widths and offset per rotation
    //
    [self resizeSelFieldAndDone:_doneButtonWidth];
    
    _maxMatchNum = (int)[[NSUserDefaults standardUserDefaults] integerForKey:MATCH_NUM_KEY];
    if (_maxMatchNum && (_maxMatchNum != _changedMaxNum)) {
        _changedMaxNum = _maxMatchNum;
        [self viewDidLoad];
        [self viewWillAppear:YES];
    
    } else {
        _changedMaxNum = _maxMatchNum;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Tableview Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    return MAX_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((
         ((section == NAME_SECTION)  && [_nameEntered  isEqualToString:@""]) ||
         ((section == KEYW_SECTION)  && [_keywEntered  isEqualToString:@""]) ||
         ((section == DESC_SECTION)  && [_descEntered  isEqualToString:@""])
         ) && (_editFlag == FALSE)) {
        return 0;
    
    } else if (section == EMPTY_SECTION) {
        return 0;

    } else if (section != MATCH_SECTION) {
        return 1;

    } else {
        return [_matchedSwatches count] - 1;
    }
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
    } else if (section == DIV_SECTION) {
        return DEF_NIL_HEADER;
        
    } else if (section == MATCH_SECTION) {
        return _matchSectionHeight;
        
    } else if (section == EMPTY_SECTION) {
        return self.tableView.bounds.size.height - _matchSectionHeight - ((DEF_TABLE_HDR_HEIGHT + DEF_TABLE_CELL_HEIGHT) * 3);
        
    } else {
        return DEF_TABLE_HDR_HEIGHT;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
    [headerView setBackgroundColor:DARK_BG_COLOR];
    
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
    [headerLabel setBackgroundColor:DARK_BG_COLOR];
    [headerLabel setTextColor:LIGHT_TEXT_COLOR];
    [headerLabel setFont:TABLE_HEADER_FONT];
    
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];
    
    NSString *headerStr;
    if (section == NAME_SECTION) {
        headerStr = _nameHeader;
        
    } else if (section == KEYW_SECTION) {
        headerStr = _keywHeader;
        
    } else if (section == DESC_SECTION) {
        headerStr = _descHeader;
        
    } else if (section == MATCH_SECTION) {
        int match_ct = (int)[_matchedSwatches count] - 1;
        headerStr = [[NSString alloc] initWithFormat:@"%@ (Method: %@, Count: %i)", _matchesHeader, [_matchAlgorithms objectAtIndex:_matchAlgIndex], match_ct];

        if (_scrollFlag == FALSE) {
            UIImage *refImage;
            
            if (_isRGB == TRUE) {
                refImage = [AppColorUtils renderRGB:_selPaintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            } else {
                refImage = [AppColorUtils renderPaint:_selPaintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            }
            
            // Tag the first reference image
            //
            refImage =  [ColorUtils drawTapAreaLabel:refImage count:_currTapSection attrs:nil inset:DEF_RECT_INSET];

            
            UIImageView *refImageView = [[UIImageView alloc] initWithImage:refImage];
        
            [refImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
            [refImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
            [refImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
            
            [refImageView setContentMode: UIViewContentModeScaleAspectFit];
            [refImageView setClipsToBounds: YES];
            [refImageView setFrame:CGRectMake(_imageViewXOffset, DEF_TABLE_HDR_HEIGHT + 2.0, _imageViewWidth, _imageViewHeight)];
            
            // Compute the xpt
            //
            CGFloat xpt = CGPointFromString(_selPaintSwatch.coord_pt).x - _imageViewWidth;
            xpt = (xpt < 0.0) ? 0.0 : xpt;
            
            CGFloat xAxisLimit = _referenceImage.size.width - (_imageViewWidth * 2);
            xpt = (xpt > xAxisLimit) ? xAxisLimit : xpt;
            
            // Compute the ypt
            //
            CGFloat ypt = CGPointFromString(_selPaintSwatch.coord_pt).y - _imageViewHeight / DEF_Y_OFFSET_DIVIDER;
            ypt = (ypt < 0.0) ? 0.0 : ypt;
            
            CGFloat yAxisLimit = _referenceImage.size.height - _imageViewHeight;
            ypt = (ypt > yAxisLimit) ? yAxisLimit : ypt;
            
            CGFloat croppedImageXOffset = _imageViewXOffset + _imageViewWidth + DEF_FIELD_PADDING;
            CGFloat croppedImageWidth = self.tableView.bounds.size.width - croppedImageXOffset - DEF_FIELD_PADDING;
            
            UIImage *croppedImage = [ColorUtils cropImage:_referenceImage frame:CGRectMake(xpt, ypt, croppedImageWidth, _imageViewHeight)];
            UIImageView *croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
            [croppedImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
            [croppedImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
            [croppedImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
            
            [croppedImageView setContentMode: UIViewContentModeScaleAspectFit];
            [croppedImageView setClipsToBounds: YES];
            
            [croppedImageView setFrame:CGRectMake(croppedImageXOffset, DEF_TABLE_HDR_HEIGHT + 2.0, croppedImageWidth, _imageViewHeight)];
            [croppedImageView setTag:IMAGE_TAG];
            
            [headerView addSubview:refImageView];
            [headerView addSubview:croppedImageView];

        } else {
            CGFloat imageViewWidth = self.tableView.bounds.size.width - _imageViewXOffset - DEF_FIELD_PADDING;
            
            UIImage *refImage = [AppColorUtils renderRGB:_selPaintSwatch cellWidth:imageViewWidth cellHeight:_imageViewHeight];
            
            // Add the RGB label
            //
            refImage = [AppColorUtils drawRGBLabel:refImage rgbValue:_selPaintSwatch location:@"top"];
            
            // Tag the first reference image
            //
            UIImageView *refImageView = [[UIImageView alloc] initWithImage:refImage];
            
            [refImageView.layer setBorderWidth:BORDER_WIDTH_NONE];
            //[refImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
            //[refImageView.layer setBorderColor:[[AppColorUtils colorFromSwatch:_selPaintSwatch] CGColor]];
            [refImageView.layer setCornerRadius:DEF_NIL_CORNER_RADIUS];
            
            [refImageView setContentMode: UIViewContentModeScaleAspectFit];
            [refImageView setClipsToBounds: YES];
            
            // Align this border with the cell match
            //
            [refImageView setFrame:CGRectMake(_imageViewXOffset + DEF_X_COORD, DEF_TABLE_HDR_HEIGHT + DEF_FIELD_PADDING, imageViewWidth, _imageViewHeight)];
            
            [headerView addSubview:refImageView];
        }
    }
    [headerLabel setText:headerStr];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == DIV_SECTION) {
        return DEF_TBL_DIVIDER_HGT;

    } else if (indexPath.section == EMPTY_SECTION) {
        return DEF_NIL_CELL;

    } else if (indexPath.section == MATCH_SECTION) {
        return _imageViewHeight;
        
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor:DARK_BG_COLOR];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (_scrollFlag == TRUE) {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [tableView setSeparatorColor:GRAY_BG_COLOR];
    }

    [tableView setAllowsSelectionDuringEditing:YES];

    [cell.imageView setImage:nil];
    [cell.textLabel setText:nil];

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
        
    
    // Set up the description/comments field
    //
    } else if (indexPath.section == DESC_SECTION) {
        // Create the description/comments text field
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
        
    } else if (indexPath.section == MATCH_SECTION) {

        PaintSwatches *paintSwatch = [_matchedSwatches objectAtIndex:indexPath.row + 1];
        
        // Tag the first reference image
        //
        [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds:YES];
        
        int index = (int)indexPath.row;
        
        if (_scrollFlag == FALSE || _pressSelectedRow != index) {
            if (_isRGB == TRUE) {
                cell.imageView.image = [AppColorUtils renderRGB:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            } else {
                cell.imageView.image = [AppColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            }
            
            [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
            
            [cell.textLabel setFont:TABLE_CELL_FONT];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell.textLabel setText:[paintSwatch name]];
            [cell.textLabel setTag:indexPath.row + 1];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

            // Add the Gesture Recognizer
            //
            [cell.textLabel setUserInteractionEnabled:YES];
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pressCell:)];
            panGesture.delegate = self;
            [cell.textLabel addGestureRecognizer:panGesture];

        } else if (_scrollFlag == TRUE && _pressSelectedRow == index) {
            CGFloat matchImageViewWidth = self.tableView.bounds.size.width - _imageViewXOffset - DEF_FIELD_PADDING;

            UIImage *refImage = [AppColorUtils renderRGB:paintSwatch cellWidth:matchImageViewWidth cellHeight:_imageViewHeight];
            
            // Add the RGB label
            //
            cell.imageView.image = [AppColorUtils drawRGBLabel:refImage rgbValue:paintSwatch location:@"bottom"];
            [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, matchImageViewWidth, _imageViewHeight)];
            [cell.imageView.layer setBorderWidth:BORDER_WIDTH_NONE];
            [cell.imageView.layer setCornerRadius:DEF_NIL_CORNER_RADIUS];
            
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [tableView setSeparatorColor:CLEAR_COLOR];
            
            [cell.textLabel setText:@""];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }

    return cell;
}

- (void)pressCell:(UIPanGestureRecognizer *)panGesture {
    UILabel *label = (UILabel *)panGesture.view;
    _pressSelectedRow = (int)[label tag] - 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = (int)indexPath.row;

    [self performSegueWithIdentifier:@"ShowSwatchDetailSegue" sender:self];
}

// For now (perhaps even this version), disallow the manual override
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Scrollview Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Scrollview Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _scrollFlag = TRUE;

    [self.tableView reloadData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollingFinish];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollingFinish];
}
- (void)scrollingFinish {
    _scrollFlag = FALSE;

    [self.tableView reloadData];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TextField Delegate Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextField Delegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [GenericUtils trimString:textField.text];
    
    if ([textField.text isEqualToString:@""] && (textField.tag == NAME_FIELD_TAG)) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        _textReturn  = TRUE;
    
        if (textField.tag == NAME_FIELD_TAG) {
            _nameEntered = textField.text;
        } else if ((textField.tag == KEYW_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
            _keywEntered = textField.text;
        } else if ((textField.tag == DESC_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
            _descEntered = textField.text;
        }
        
        [_save setEnabled:TRUE];
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Gesture Recognizer Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Gesture Recognizer Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return true;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BarButton Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - BarButton Methods

- (IBAction)decr:(id)sender {
    
    if (_editFlag == FALSE) {

        if (_currTapSection > 1) {
            _currTapSection = _currTapSection - 1;

        } else {
            _currTapSection = _numTapSections;
        }
        [self renderTapAreaData];
    
    } else {
    
        _matchAlgIndex--;
        
        if (_matchAlgIndex < 0) {
            _matchAlgIndex = (int)[_matchAlgorithms count] - 1;
        }
        
        // Re-run the comparison algorithm
        //
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum+1 context:self.context entity:_paintSwatchEntity]];
        [_matchedSwatches removeObjectAtIndex:0];
        [self initTappedSwatches:(int)[_matchedSwatches count]];
        
        [_save setEnabled:TRUE];
    }
    
    [self.tableView reloadData];
}


- (IBAction)incr:(id)sender {
        
    if (_editFlag == FALSE) {

        if (_currTapSection < _numTapSections) {
            _currTapSection = _currTapSection + 1;

        } else {
            _currTapSection = 1;
        }
        [self renderTapAreaData];
        
    } else {

        _matchAlgIndex++;
        
        if (_matchAlgIndex >= [_matchAlgorithms count]) {
            _matchAlgIndex = 0;
        }
        
        // Re-run the comparison algorithm
        //
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum+1 context:self.context entity:_paintSwatchEntity]];
        [_matchedSwatches removeObjectAtIndex:0];
        [self initTappedSwatches:(int)[_matchedSwatches count]];
        
        [_save setEnabled:TRUE];
    }

    [self.tableView reloadData];
}

- (void)renderTapAreaData {

    int tapSectionsIndex = _numTapSections - _currTapSection;
    _selPaintSwatch = [[_tapSections objectAtIndex:tapSectionsIndex] objectAtIndex:0];

    int tapIndex = _currTapSection - 1;
    _tapArea = [[ManagedObjectUtils queryTapAreas:_matchAssociation.objectID context:self.context] objectAtIndex:tapIndex];
    
    // Override the default Algorithm index?
    //
    _matchAlgIndex = [[_tapArea match_algorithm_id] intValue];
    _nameEntered   = [_tapArea name] ? [_tapArea name] : @"";
    _descEntered   = [_tapArea desc] ? [_tapArea desc] : @"";
    
    
    // Match algorithms
    //
    _maManualOverride = [[_tapArea ma_manual_override] boolValue];

    if (_maManualOverride == TRUE) {
        _matchedSwatches = [_dbPaintSwatches mutableCopy];
        
    } else if (_selPaintSwatch != nil) {
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum+1 context:self.context entity:_paintSwatchEntity]];
        [_matchedSwatches removeObjectAtIndex:0];
    }
    
    [self initTappedSwatches:(int)[_matchedSwatches count]];
    

    // Keywords
    //
    NSSet *tapAreaKeywords = _tapArea.tap_area_keyword;
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (TapAreaKeyword *tap_area_keyword in tapAreaKeywords) {
        Keyword *keyword = tap_area_keyword.keyword;
        [keywords addObject:[keyword name]];
    }
    _keywEntered = [keywords componentsJoinedByString:KEYW_DISP_SEPARATOR];

}

- (IBAction)removeTableRows:(id)sender {
    if (_maxMatchNum > 1) {
        [_matchedSwatches removeLastObject];
        [_tappedSwatches removeLastObject];
        _maxMatchNum--;

        [self.tableView reloadData];
        //[BarButtonUtils setButtonEnabled:self.toolbarItems refTag:INCR_TAP_BTN_TAG isEnabled:TRUE];
        
        [_save setEnabled:TRUE];
    }
    
    if (_maxMatchNum <= 1) {
        //[BarButtonUtils setButtonEnabled:self.toolbarItems refTag:DECR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (IBAction)addTableRows:(id)sender {
    if (_maxMatchNum < _maxRowLimit) {
        _maxMatchNum++;
 
        // Re-run the comparison algorithm
        //
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
        [self initTappedSwatches:(int)[_matchedSwatches count]];

        [self.tableView reloadData];
        //[BarButtonUtils setButtonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:TRUE];
        
        [_save setEnabled:TRUE];
        
    } else {
        UIAlertController *myAlert = [AlertUtils rowLimitAlert: _maxRowLimit];
        [self presentViewController:myAlert animated:YES completion:nil];
        //[BarButtonUtils setButtonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (IBAction)toggleRGB:(id)sender {
    if (_isRGB == TRUE) {
        [BarButtonUtils setButtonImage:self.toolbarItems refTag:RGB_BTN_TAG imageName:PALETTE_IMAGE_NAME];
        [self setIsRGB:FALSE];
    } else {
        [BarButtonUtils setButtonImage:self.toolbarItems refTag:RGB_BTN_TAG imageName:RGB_IMAGE_NAME];
        [self setIsRGB:TRUE];
    }
    [self.tableView reloadData];
}


- (void)matchButtonsShow {
    [self algButtonsShow];
    _actionTitle = @"Match";
    //[BarButtonUtils setButtonShow:self.toolbarItems refTag:DECR_TAP_BTN_TAG];
    //[BarButtonUtils setButtonShow:self.toolbarItems refTag:INCR_TAP_BTN_TAG];
    [BarButtonUtils setButtonTitle:self.toolbarItems refTag:MATCH_BTN_TAG title:_actionTitle];
    //[BarButtonUtils setButtonWidth:self.toolbarItems refTag:DECR_TAP_BTN_TAG width:DECR_BUTTON_WIDTH];
    //[BarButtonUtils setButtonWidth:self.toolbarItems refTag:INCR_TAP_BTN_TAG width:SHOW_BUTTON_WIDTH];
}

- (void)matchButtonsHide {
    [self algButtonsShow];
    _actionTitle = @"Areas";
    //[BarButtonUtils setButtonHide:self.toolbarItems refTag:DECR_TAP_BTN_TAG];
    //[BarButtonUtils setButtonHide:self.toolbarItems refTag:INCR_TAP_BTN_TAG];
    [BarButtonUtils setButtonTitle:self.toolbarItems refTag:MATCH_BTN_TAG title:_actionTitle];
    //[BarButtonUtils setButtonWidth:self.toolbarItems refTag:DECR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
    //[BarButtonUtils setButtonWidth:self.toolbarItems refTag:INCR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
}

- (void)algButtonsShow {
    [BarButtonUtils setButtonShow:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
    [BarButtonUtils setButtonShow:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:DECR_ALG_BTN_TAG width:SHOW_BUTTON_WIDTH];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:INCR_ALG_BTN_TAG width:SHOW_BUTTON_WIDTH];
}

- (void)algButtonsHide {
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
    [BarButtonUtils setButtonTitle:self.toolbarItems refTag:MATCH_BTN_TAG title:@""];
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:DECR_ALG_BTN_TAG width:HIDE_BUTTON_WIDTH];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:INCR_ALG_BTN_TAG width:HIDE_BUTTON_WIDTH];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General Purpose Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - General Purpose Methods

// flag is 1 after pressing the 'Edit' button
//
- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];
    
    _editFlag = flag;
    
    if (_editFlag == FALSE) {
        if (_tappedCount > 0) {
            [_save setEnabled:TRUE];
        }
        [self matchButtonsHide];
        if ([_save isEnabled] == TRUE) {
            [self presentViewController:_saveAlertController animated:YES completion:nil];
        }
    } else {
        if (_maManualOverride == FALSE) {
            [self matchButtonsShow];
            
        } else {
            [self algButtonsHide];
        }
    }
    
    [self.tableView reloadData];
}

// Toggle between "Areas" and "Match
// _editFlag used for the toggle even though no editing takes place
//
- (IBAction)toggleAction:(id)sender {
    if ([_actionTitle isEqualToString:@"Areas"]) {
        [self matchButtonsShow];
        _editFlag = TRUE;
        
    } else {
        [self matchButtonsHide];
        _editFlag = FALSE;
    }
}

- (void)resizeSelFieldAndDone:(CGFloat)doneWidth {
    _tableViewWidth     = self.tableView.bounds.size.width;
    _doneButtonWidth    = doneWidth;
    _selTextFieldWidth  = _tableViewWidth - _imageViewWidth - _doneButtonWidth - DEF_MD_FIELD_PADDING;
    _doneButtonXOffset  = _imageViewWidth + _selTextFieldWidth + DEF_FIELD_PADDING;
}

- (void)initTappedSwatches:(int)count {
    _tappedSwatches = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        [_tappedSwatches addObject:[NSNumber numberWithBool:FALSE]];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation/Save Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation/Save Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ShowSwatchDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        int index = _selectedRow + 1;
        
        // Query the mix association ids
        //
        PaintSwatches *paintSwatch = [_matchedSwatches objectAtIndex:index];
        int type_id = [[paintSwatch type_id] intValue];
        
        PaintSwatchType *paintSwatchType = [ManagedObjectUtils  queryDictionaryName:@"PaintSwatchType" entityId:type_id context:self.context];
        
        NSMutableArray *mixAssocSwatches = [ManagedObjectUtils queryMixAssocBySwatch:paintSwatch.objectID context:self.context];
        
        [swatchDetailTableViewController setPaintSwatch:paintSwatch];
        [swatchDetailTableViewController setMixAssocSwatches:mixAssocSwatches];
        
        if ([paintSwatchType.name isEqualToString:@"MixAssoc"]) {
            MixAssocSwatch *assocSwatchObj = [mixAssocSwatches objectAtIndex:0];
            MixAssociation *mixAssocObj = [assocSwatchObj mix_association];
            NSMutableArray *swatch_ids = [ManagedObjectUtils queryMixAssocSwatches:mixAssocObj.objectID context:self.context];
            
            MixAssocSwatch *refAssocSwatchObj = [swatch_ids objectAtIndex:0];
            PaintSwatches *refPaintSwatch = (PaintSwatches *)refAssocSwatchObj.paint_swatch;
            [swatchDetailTableViewController setRefPaintSwatch:refPaintSwatch];
            
            MixAssocSwatch *mixAssocSwatchObj = [swatch_ids objectAtIndex:1];
            PaintSwatches *mixPaintSwatch = (PaintSwatches *)mixAssocSwatchObj.paint_swatch;
            [swatchDetailTableViewController setMixPaintSwatch:mixPaintSwatch];
        }
    }
}

- (void)saveData {
    
    // Ensure that this value is not empty or nil
    //
    if (![_nameEntered isEqualToString:@""] && _nameEntered != nil) {
        [_tapArea setName:_nameEntered];
    }
    
    [_tapArea setDesc:_descEntered];
    [_tapArea setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
    
    // Delete all tapAreaKeywords and associations first
    //
    [ManagedObjectUtils deleteTapAreaKeywords:_tapArea context:self.context];
    
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
        
        TapAreaKeyword *taKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_tapArea.objectID relationName:@"tap_area" entityName:@"TapAreaKeyword" context:self.context];
        
        if (taKwObj == nil) {
            taKwObj = [[TapAreaKeyword alloc] initWithEntity:_tapAreaKeywordEntity insertIntoManagedObjectContext:self.context];
            [taKwObj setKeyword:kwObj];
            [taKwObj setTap_area:_tapArea];
            [taKwObj setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
            
            [_tapArea addTap_area_keywordObject:taKwObj];
            [kwObj addTap_area_keywordObject:taKwObj];
        }
    }

    
    NSArray *tapAreaSwatches = [_tapArea.tap_area_swatch allObjects];
    
    // Get the currently saved values for swatch count and algorithm id
    //
    int saved_algorithm_id = [[_tapArea match_algorithm_id] intValue];
    int saved_swatch_count = (int)[tapAreaSwatches count];
    
    // If needed
    //
    [self deleteSwatches];
    [_tapArea setMa_manual_override:[NSNumber numberWithBool:_maManualOverride]];

    
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
            [tapAreaSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];

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
        
        [_save setEnabled:FALSE];
    }
    
    [self.tableView reloadData];
}

- (void)deleteSwatches {
    // Initialize with the comparison swatch
    //
    NSMutableArray *tmpSwatches = [[NSMutableArray alloc] init];
    [tmpSwatches addObject:[_matchedSwatches objectAtIndex:0]];
    
    int max_ct = (int)[_matchedSwatches count] - 1;
    for (int i=0; i<max_ct; i++) {
        BOOL tappedSwatch = [[_tappedSwatches objectAtIndex:i] boolValue];

        PaintSwatches *paintSwatch = [_matchedSwatches objectAtIndex:i+1];
        if (tappedSwatch == TRUE) {
            [tmpSwatches addObject:paintSwatch];
        }
    }

    if ([tmpSwatches count] > 1) {
        _matchedSwatches  = [tmpSwatches mutableCopy];
        _maManualOverride = TRUE;
        [self initTappedSwatches:(int)[_matchedSwatches count]];
    }
    
}

@end
