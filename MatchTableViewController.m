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

@property (nonatomic, strong) UIAlertController *saveAlertController;
@property (nonatomic, strong) UIAlertAction *save;


@property (nonatomic) BOOL textReturn;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *nameEntered, *keywEntered, *descEntered, *colorSelected, *typeSelected, *namePlaceholder, *keywPlaceholder, *descPlaceholder, *colorName, *imagesHeader, *matchesHeader, *nameHeader, *keywHeader, *descHeader;
@property (nonatomic, strong) UIColor *subjColorValue;
@property (nonatomic) CGFloat textFieldYOffset, refNameWidth, imageViewWidth, imageViewHeight, imageViewXOffset, imageViewYOffset, matchSectionHeight, tableViewWidth, doneButtonWidth, selTextFieldWidth, doneButtonXOffset;
@property (nonatomic) BOOL editFlag, scrollFlag;
@property (nonatomic) int selectedRow, dbSwatchesCount, maxRowLimit, colorPickerSelRow, typesPickerSelRow, pressSelectedRow, tappedCount;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ColorUtils setNavBarGlaze:self.navigationController.navigationBar];

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
    
    _editFlag    = FALSE;
    _scrollFlag  = FALSE;
    _tappedCount = 0;
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
    _maxMatchNum     = (int)[[[_tapArea tap_area_swatch] allObjects] count];
    _matchAlgorithms = [ManagedObjectUtils fetchDictNames:@"MatchAlgorithm" context:self.context];
    
    if (_maManualOverride == TRUE) {
        _matchedSwatches = [_dbPaintSwatches mutableCopy];
        
    } else {
        _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    }
    [self initTappedSwatches:(int)[_matchedSwatches count]];
    
    
    // Initialize
    //
    // Override the default Algorithm index?
    //
    _matchAlgIndex = [[_tapArea match_algorithm_id] intValue];
    _nameEntered   = [_tapArea name] ? [_tapArea name] : @"";
    _descEntered   = [_tapArea desc] ? [_tapArea desc] : @"";


    // Keywords
    //
    NSSet *tapAreaKeywords = _tapArea.tap_area_keyword;
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (TapAreaKeyword *tap_area_keyword in tapAreaKeywords) {
        Keyword *keyword = tap_area_keyword.keyword;
        [keywords addObject:[keyword name]];
    }
    _keywEntered = [keywords componentsJoinedByString:@", "];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
    
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

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    // Background color
//    //
//    [view setTintColor:DARK_TEXT_COLOR];
//
//    // Text Color
//    //
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header.textLabel setTextColor:LIGHT_TEXT_COLOR];
//    [header.contentView setBackgroundColor:DARK_BG_COLOR];
//    [header.textLabel setFont:TABLE_CELL_FONT];
//}

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
        
        if (_scrollFlag == FALSE || _editFlag == FALSE) {
            UIImage *refImage = [ColorUtils renderSwatch:_selPaintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            
            // Tag the first reference image
            //
            refImage =  [ColorUtils drawTapAreaLabel:refImage count:_currTapSection];
            UIImageView *refImageView = [[UIImageView alloc] initWithImage:refImage];
            
            [refImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
            [refImageView.layer setCornerRadius: DEF_CORNER_RADIUS];
            [refImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
            
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
            CGFloat ypt = CGPointFromString(_selPaintSwatch.coord_pt).y - _imageViewHeight / 2;
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
            
            UIImage *refImage = [ColorUtils renderRGB:_selPaintSwatch cellWidth:imageViewWidth cellHeight:_imageViewHeight];
            
            // Tag the first reference image
            //
            refImage =  [ColorUtils drawTapAreaLabel:refImage count:_currTapSection];
            UIImageView *refImageView = [[UIImageView alloc] initWithImage:refImage];
            
            [refImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
            [refImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
            [refImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
            
            [refImageView setContentMode: UIViewContentModeScaleAspectFit];
            [refImageView setClipsToBounds: YES];
            [refImageView setFrame:CGRectMake(_imageViewXOffset, DEF_TABLE_HDR_HEIGHT + 2.0, imageViewWidth, _imageViewHeight)];
            
            [headerView addSubview:refImageView];
        }
        
    }
    [headerLabel setText:headerStr];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *headerStr;
//    if (section == NAME_SECTION) {
//        headerStr = _nameHeader;
//
//    } else if (section == KEYW_SECTION) {
//        headerStr = _keywHeader;
//
//    } else if (section == DESC_SECTION) {
//        headerStr = _descHeader;
//
//    } else if (section == MATCH_SECTION) {
//        int match_ct = (int)[_matchedSwatches count] - 1;
//        headerStr = [[NSString alloc] initWithFormat:@"%@ (Method: %@, Count: %i)", _matchesHeader, [_matchAlgorithms objectAtIndex:_matchAlgIndex], match_ct];
//    }
//    
//    return headerStr;
//}

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
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];
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
        
        if (_editFlag == FALSE || _scrollFlag == FALSE || _pressSelectedRow != index) {
            cell.imageView.image = [ColorUtils renderSwatch:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
            [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
            
            [cell.textLabel setFont:TABLE_CELL_FONT];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell.textLabel setText:[paintSwatch name]];
            [cell.textLabel setTag:indexPath.row + 1];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            
            if (_editFlag == TRUE) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                
                BOOL tappedStat = [[_tappedSwatches objectAtIndex:indexPath.row] boolValue];
                if (tappedStat == TRUE) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }

            // Add the Gesture Recognizer
            //
            [cell.textLabel setUserInteractionEnabled:YES];
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pressCell:)];
            panGesture.delegate = self;
            [cell.textLabel addGestureRecognizer:panGesture];
            
        } else if (_editFlag == TRUE && _scrollFlag == TRUE && _pressSelectedRow == index) {
            CGFloat matchImageViewWidth = self.tableView.bounds.size.width - _imageViewXOffset - DEF_FIELD_PADDING;
            cell.imageView.image = [ColorUtils renderRGB:paintSwatch cellWidth:matchImageViewWidth cellHeight:_imageViewHeight];
            [cell.imageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, matchImageViewWidth, _imageViewHeight)];
            
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

    if (indexPath.section == MATCH_SECTION && _editFlag == FALSE)  {
        [self performSegueWithIdentifier:@"ShowSwatchDetailSegue" sender:self];
        
    } else {
        BOOL tappedStat = [[_tappedSwatches objectAtIndex:indexPath.row] boolValue];
        if (tappedStat == FALSE) {
            [_tappedSwatches replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:TRUE]];
            _tappedCount++;

        } else {
            [_tappedSwatches replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:FALSE]];
            _tappedCount--;
        }
        
        [tableView reloadData];
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
    
    if (_editFlag == FALSE) {
        if (_tappedCount > 0) {
            [_save setEnabled:TRUE];
        }
        [self matchButtonsHide];
        [self presentViewController:_saveAlertController animated:YES completion:nil];
    } else {
        if (_maManualOverride == FALSE) {
            [self matchButtonsShow];
        }
    }
    
    [self.tableView reloadData];
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

#pragma mark - UIPickerView methods

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Picker Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// The number of columns of data
//
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
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

- (IBAction)decrMatchAlgorithm:(id)sender {
    
    _matchAlgIndex--;
    
    if (_matchAlgIndex < 0) {
        _matchAlgIndex = (int)[_matchAlgorithms count] - 1;
    }
    
    // Re-run the comparison algorithm
    //
    _matchedSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:_selPaintSwatch swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    [self initTappedSwatches:(int)[_matchedSwatches count]];
    
    [_save setEnabled:TRUE];
    
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
    [self initTappedSwatches:(int)[_matchedSwatches count]];
    
    [_save setEnabled:TRUE];

    [self.tableView reloadData];
}

- (IBAction)removeTableRows:(id)sender {
    if (_maxMatchNum > 1) {
        [_matchedSwatches removeLastObject];
        [_tappedSwatches removeLastObject];
        _maxMatchNum--;

        [self.tableView reloadData];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:INCR_TAP_BTN_TAG isEnabled:TRUE];
        
        [_save setEnabled:TRUE];
    }
    
    if (_maxMatchNum <= 1) {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:DECR_TAP_BTN_TAG isEnabled:FALSE];
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
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:TRUE];
        
        [_save setEnabled:TRUE];
        
    } else {
        UIAlertController *myAlert = [AlertUtils rowLimitAlert: _maxRowLimit];
        [self presentViewController:myAlert animated:YES completion:nil];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (void)matchButtonsShow {
    [BarButtonUtils buttonShow:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag:DECR_TAP_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag:INCR_TAP_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag:SETTINGS_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag:HOME_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:DECR_TAP_BTN_TAG width:DECR_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:INCR_TAP_BTN_TAG width:SHOW_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:SETTINGS_BTN_TAG width:SHOW_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:HOME_BTN_TAG     width:HIDE_BUTTON_WIDTH];
}

- (void)matchButtonsHide {
    [BarButtonUtils buttonHide:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag:DECR_TAP_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag:INCR_TAP_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag:SETTINGS_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag:HOME_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:DECR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:INCR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:SETTINGS_BTN_TAG width:HIDE_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:HOME_BTN_TAG     width:SHOW_BUTTON_WIDTH];
}

#pragma mark - General purpose methods

- (void)resizeSelFieldAndDone:(CGFloat)doneWidth {
    _tableViewWidth     = self.tableView.bounds.size.width;
    _doneButtonWidth    = doneWidth;
    _selTextFieldWidth  = _tableViewWidth - _imageViewWidth - _doneButtonWidth - (DEF_FIELD_PADDING * 2);
    _doneButtonXOffset  = _imageViewWidth + _selTextFieldWidth + DEF_FIELD_PADDING;
}

- (void)initTappedSwatches:(int)count {
    _tappedSwatches = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        [_tappedSwatches addObject:[NSNumber numberWithBool:FALSE]];
    }
}

#pragma mark - Navigation/Save


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
