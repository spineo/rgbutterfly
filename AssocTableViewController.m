//
//  AssocTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "AssocTableViewController.h"
#import "AppDelegate.h"
#import "AssocTableViewCell.h"
#import "AssocDescTableViewCell.h"
#import "AddMixViewController.h"
#import "ColorUtils.h"
#import "CoreDataUtils.h"
#import "SwatchDetailTableViewController.h"
#import "ManagedObjectUtils.h"
#import "FieldUtils.h"
#import "AlertUtils.h"
#import "GenericUtils.h"

#import "PaintSwatches.h"
#import "MixAssocSwatch.h"
#import "MixAssociation.h"


@interface AssocTableViewController ()

@property (nonatomic, strong) PaintSwatches *addPaintSwatch, *selPaintSwatch;
@property (nonatomic, strong) NSMutableArray *mixAssocSwatches, *addPaintSwatches;

@property (nonatomic, strong) UIAlertController *saveAlertController;

@property (nonatomic, strong) NSString *reuseCellIdentifier;

@property (nonatomic, strong) NSString *nameHeader, *colorsHeader, *keywHeader, *descHeader;
@property (nonatomic, strong) NSString *namePlaceholder, *assocName, *descPlaceholder, *assocDesc, *keywPlaceholder, *assocKeyw;
@property (nonatomic) BOOL editFlag, mainColorFlag, isRGB, textReturn;

@property (nonatomic, strong) UILabel *mixTitleLabel;
@property (nonatomic, strong) NSString *refColorLabel, *mixColorLabel, *addColorLabel, *mixAssocName, *mixAssocKeyw, *mixAssocDesc;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage;
@property (nonatomic) int goBackStatus;
@property (nonatomic) CGFloat imageViewXOffset, imageViewYOffset, imageViewWidth, imageViewHeight, assocImageViewWidth, assocImageViewHeight, textFieldYOffset;

@property (nonatomic, strong) AddMixViewController *sourceViewController;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *mixAssocEntity, *mixAssocSwatchEntity, *keywordEntity, *mixAssocKeywordEntity;
@property (nonatomic, strong) NSSortDescriptor *orderSort;

@end

@implementation AssocTableViewController

const int ASSOC_COLORS_SECTION = 0;
const int ASSOC_ADD_SECTION    = 1;
const int ASSOC_NAME_SECTION   = 2;
const int ASSOC_KEYW_SECTION   = 3;
const int ASSOC_DESC_SECTION   = 4;

const int ASSOC_MAX_SECTION    = 5;

const int ASSOC_NAME_TAG       = 1;
const int ASSOC_KEYW_TAG       = 2;
const int ASSOC_DESC_TAG       = 3;
const int ASSOC_COLORS_TAG     = 4;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Init methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Init Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _mixAssocEntity        = [NSEntityDescription entityForName:@"MixAssociation"    inManagedObjectContext:self.context];
    _mixAssocSwatchEntity  = [NSEntityDescription entityForName:@"MixAssocSwatch"    inManagedObjectContext:self.context];
    _keywordEntity         = [NSEntityDescription entityForName:@"Keyword"           inManagedObjectContext:self.context];
    _mixAssocKeywordEntity = [NSEntityDescription entityForName:@"MixAssocKeyword"   inManagedObjectContext:self.context];

    // Set the name and desc values
    //
    if (_mixAssociation != nil) {
        _mixAssocName = _mixAssociation.name;
        _mixAssocDesc = _mixAssociation.desc;
        
        // Keywords
        //
        NSSet *mixAssocKeywords = _mixAssociation.mix_assoc_keyword;
        NSMutableArray *keywords = [[NSMutableArray alloc] init];
        for (MixAssocKeyword *mix_assoc_keyword in mixAssocKeywords) {
            Keyword *keyword = mix_assoc_keyword.keyword;
            [keywords addObject:keyword.name];
        }
        _mixAssocKeyw = [keywords componentsJoinedByString:@", "];
        
        _orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
        _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
    }
    
    _textReturn = FALSE;
    
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Mix Association Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Comma-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Mix Association Description (max. %i chars) - ", MAX_DESC_LEN];

    
    // Set RGB Rendering to FALSE by default
    //
    _isRGB         = FALSE;
    
    _reuseCellIdentifier = @"AssocTableCell";
    
    [self.tableView registerClass:[AssocTableViewCell class] forCellReuseIdentifier:assocCellIdentifier];
    [self.tableView registerClass:[AssocDescTableViewCell class] forCellReuseIdentifier:assocDescCellIdentifier];
    
    
    // Header labels
    //
    _colorsHeader      = @"Mix Association Colors";
    _nameHeader        = @"Mix Association Name";
    _keywHeader        = @"Mix Association Keywords";
    _descHeader        = @"Mix Association Description";
    
    _refColorLabel     = @"Dominant";
    _mixColorLabel     = @"Mixing";
    _addColorLabel     = @"Add Mix Association Color";

    
    _editFlag       = FALSE;
    _mainColorFlag  = FALSE;
    _bgColorView    = [[UIView alloc] init];
    [_bgColorView setBackgroundColor: DARK_BG_COLOR];

    
    _mixTitleLabel = [[UILabel alloc] init];
    _mixTitleLabel.text = [_mixAssociation name];
    [_mixTitleLabel setBackgroundColor: CLEAR_COLOR];
    [_mixTitleLabel setTextColor: LIGHT_TEXT_COLOR];
    [_mixTitleLabel sizeToFit];
    self.navigationItem.titleView = _mixTitleLabel;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
    
    // Offsets and Widths
    //
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tableview defaults
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _imageViewXOffset     = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewYOffset     = DEF_Y_OFFSET;
    _imageViewWidth       = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight      = DEF_VLG_TBL_CELL_HGT;
    _assocImageViewWidth  = DEF_TABLE_CELL_HEIGHT;
    _assocImageViewHeight = DEF_TABLE_CELL_HEIGHT;
    _textFieldYOffset      = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / 2;
    
    
    // Initialize the PaintSwatches array with default names (if values don't already exist)
    //
    int objCount = (int)[_paintSwatches count];

    for (int i=0; i < objCount; i++) {
        
        NSString *colorFormatLabel;
        int ref_parts_ratio, mix_parts_ratio;

        if (i == 0) {
            ref_parts_ratio = 1;
            mix_parts_ratio = 0;
            
            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithString:_refColorLabel];
            } else {
                _refColorLabel   = colorFormatLabel;
            }
            
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInteger:[GlobalSettings getSwatchId:@"Reference"]]];
            
            
        } else if (i == 1) {
            ref_parts_ratio = 0;
            mix_parts_ratio = 1;

            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithString:_mixColorLabel];
            } else {
                _mixColorLabel = colorFormatLabel;
            }

            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInteger:[GlobalSettings getSwatchId:@"Reference"]]];
            
        } else {
            ref_parts_ratio = [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue];

            if (ref_parts_ratio == 0) {
                ref_parts_ratio = objCount - i;
            }
    
            mix_parts_ratio = [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue];
            if (mix_parts_ratio == 0) {
                mix_parts_ratio = i - 1;
            }
    
            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", _refColorLabel, _mixColorLabel, ref_parts_ratio, mix_parts_ratio];
            }

            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:YES]];
            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInteger:[GlobalSettings getSwatchId:@"MixAssoc"]]];
        }
        int mix_order = i + 1;

        [[_paintSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:mix_order]];
        [[_paintSwatches objectAtIndex:i] setRef_parts_ratio:[NSNumber numberWithInt:ref_parts_ratio]];
        [[_paintSwatches objectAtIndex:i] setMix_parts_ratio:[NSNumber numberWithInt:mix_parts_ratio]];
        [[_paintSwatches objectAtIndex:i] setName:colorFormatLabel];
        
    }
    
    
    
    // Adjust the layout when the orientation changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Match Edit Button Alert Controller
    //
    _saveAlertController = [UIAlertController alertControllerWithTitle:@"Mix Association Edit"
                                                                    message:@"Please select operation"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save Changes" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self saveData];
    }];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete Mix" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self deleteData];

    }];
    
    UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_saveAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_saveAlertController addAction:save];
    [_saveAlertController addAction:delete];
    [_saveAlertController addAction:discard];
}

- (void)viewDidRotate {
//    AssocDescTableViewCell* cell = (AssocDescTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
//    
//    int tag_num = DEF_TAG_NUM - ASSOC_DESC_SECTION;
//    UIView *subView = (UITextView *)[cell.contentView viewWithTag:tag_num];
//    [(UITextView *) subView setFrame:CGRectMake(18.0, 5.0, cell.bounds.size.width - (cell.bounds.size.width / 5.0), cell.bounds.size.height - 10.0)];
//    [cell.descField setTag:tag_num];
}

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MixAssocSwatch"];
    
    NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
    [request setSortDescriptors:@[orderSort]];

    
    [request setPredicate: [NSPredicate predicateWithFormat:@"mix_association == %@", [_mixAssociation objectID]]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"mix_order" cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    
    @try {
        [[self fetchedResultsController] performFetch:&error];
    } @catch (NSException *exception) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView Methods

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
//    [headerView setBackgroundColor: DARK_BG_COLOR];
//    
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET+1.0, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT-2.0)];
//    [headerLabel setBackgroundColor: DARK_BG_COLOR];
//    [headerLabel setTextColor: LIGHT_TEXT_COLOR];
//    [headerLabel setFont: TABLE_HEADER_FONT];
//    
//    if (section == 0) {
//        [headerView addSubview:headerLabel];
//        [headerLabel setText:_colorHeader];
//        
//    } else if (section == 2) {
//        [headerView addSubview:headerLabel];
//        [headerLabel setText:_nameHeader];
//        
//    } else if (section == 3) {
//        [headerView addSubview:headerLabel];
//        [headerLabel setText:_descHeader];
//    }
//    
//    return headerView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == ASSOC_NAME_SECTION) {
        if ((_editFlag == FALSE) && [_mixAssocName isEqualToString:@""]) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
    
    } else if (section == ASSOC_KEYW_SECTION) {
        if ((_editFlag == FALSE) && [_mixAssocKeyw isEqualToString:@""]) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }
        
    } else if (section == ASSOC_DESC_SECTION) {
        if ((_editFlag == FALSE) && [_mixAssocDesc isEqualToString:@""]) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_TABLE_HDR_HEIGHT;
        }

    } else if (section == ASSOC_ADD_SECTION) {
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
    [header.textLabel setTextColor:LIGHT_TEXT_COLOR];
    [header.contentView setBackgroundColor:DARK_BG_COLOR];
    [header.textLabel setFont:TABLE_HEADER_FONT];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    if (section == ASSOC_NAME_SECTION) {
        headerStr = _nameHeader;
        
    } else if (section == ASSOC_KEYW_SECTION) {
        headerStr = _keywHeader;
        
    } else if (section == ASSOC_DESC_SECTION) {
        headerStr = _descHeader;
        
    } else if (section == ASSOC_COLORS_SECTION) {
        headerStr = _colorsHeader;
    }
    
    return headerStr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    return ASSOC_MAX_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    //
    if ((
         ((section == ASSOC_NAME_SECTION)  && [_mixAssocName  isEqualToString:@""]) ||
         ((section == ASSOC_KEYW_SECTION)  && [_mixAssocKeyw  isEqualToString:@""]) ||
         ((section == ASSOC_DESC_SECTION)  && [_mixAssocDesc  isEqualToString:@""]))
         && (_editFlag == FALSE)) {
        return 0;

    } else if ((section == ASSOC_ADD_SECTION) && (_editFlag == FALSE)) {
        return 0;

    } else if (section == ASSOC_COLORS_SECTION) {
        return [_mixAssocSwatches count];
        
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if ((indexPath.section == ASSOC_ADD_SECTION) && (_editFlag == FALSE)) {
        return DEF_NIL_HEIGHT;
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor: DARK_BG_COLOR];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor: GRAY_BG_COLOR];

    cell.imageView.image = nil;
    
    //[self initializeFetchedResultsController];
    
    //    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    
    // Remove the tags
    //
    int max_tag = (int)[_mixAssocSwatches count] + ASSOC_COLORS_TAG;
    for (int tag=1; tag<=max_tag; tag++) {
        [[cell.contentView viewWithTag:tag] removeFromSuperview];
    }
    
    if (indexPath.section == ASSOC_COLORS_SECTION) {
        //MixAssocSwatch *mixAssocSwatch = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:ASSOC_COLORS_SECTION]];
        
        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:indexPath.row];
        
        PaintSwatches *paintSwatch     = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        NSString *name = [paintSwatch name];
        
        if (_isRGB == FALSE) {
            cell.imageView.image = [ColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_assocImageViewWidth cellHeight:_assocImageViewHeight];
        } else {
            cell.imageView.image = [ColorUtils renderRGB:paintSwatch cellWidth:_assocImageViewWidth cellHeight:_assocImageViewHeight];
        }
        
        // Tag the first reference image
        //
        [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds: YES];
        [cell.imageView setFrame:CGRectMake(_imageViewXOffset, _imageViewYOffset, _imageViewWidth, _imageViewHeight)];

        
        int tag_num = (int)indexPath.row + ASSOC_COLORS_TAG;
        UITextField *refName  = [FieldUtils createTextField:name tag:tag_num];
        
        CGFloat xpos  = _assocImageViewWidth + DEF_CELL_EDIT_DISPL;
        CGFloat width = cell.contentView.bounds.size.width - xpos;
        
        [refName setFrame:CGRectMake(xpos, _textFieldYOffset, width, DEF_TEXTFIELD_HEIGHT)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];
        
        if (_editFlag == TRUE) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];

        } else {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [FieldUtils makeTextFieldNonEditable:refName content:name border:FALSE];
        }
 
    } else if (indexPath.section == ASSOC_ADD_SECTION) {
        [cell.textLabel setText: _addColorLabel];
        cell.accessoryType       = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;
        
        [cell setBackgroundColor: DARK_BG_COLOR];
        [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
        [cell.textLabel setFont: TABLE_CELL_FONT];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];

    } else if (indexPath.section == ASSOC_NAME_SECTION) {
        
        // Create the name text field
        //
        UITextField *refName  = [FieldUtils createTextField:_mixAssocName tag:ASSOC_NAME_TAG];
        [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];

        if (_editFlag == TRUE) {
            if ([_mixAssocName isEqualToString:@""]) {
                [refName setPlaceholder:_namePlaceholder];
            }

        } else {
            [FieldUtils makeTextFieldNonEditable:refName content:_mixAssocName border:TRUE];
        }
        [cell setAccessoryType: UITableViewCellAccessoryNone];

    } else if (indexPath.section == ASSOC_KEYW_SECTION) {
        
        // Create the keywords text field
        //
        UITextField *refName  = [FieldUtils createTextField:_mixAssocKeyw tag:ASSOC_KEYW_TAG];
        [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];
        
        if (_editFlag == TRUE) {
            if ([_mixAssocKeyw isEqualToString:@""]) {
                [refName setPlaceholder:_keywPlaceholder];
            }
            
        } else {
            [FieldUtils makeTextFieldNonEditable:refName content:_mixAssocKeyw border:TRUE];
        }
        [cell setAccessoryType: UITableViewCellAccessoryNone];

    // Desc section
    //
    } else {
        
        // Create the description text field
        //
        UITextField *refName  = [FieldUtils createTextField:_mixAssocDesc tag:ASSOC_DESC_TAG];
        [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];
        
        if (_editFlag == TRUE) {
            if ([_mixAssocDesc isEqualToString:@""]) {
                [refName setPlaceholder: _descPlaceholder];
            }

        } else {
            [FieldUtils makeTextFieldNonEditable:refName content:_mixAssocDesc border:TRUE];
        }
        [cell setAccessoryType: UITableViewCellAccessoryNone];
    }
    return cell;
}


// (5) editingStyleForRowAtIndexPath: Invoked for each table cell (add logic here to pick whether to delete or insert)
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ASSOC_COLORS_SECTION) {
        return UITableViewCellEditingStyleDelete;
        
    } else if (indexPath.section == ASSOC_ADD_SECTION) {
        return UITableViewCellEditingStyleInsert;

    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _selPaintSwatch = [_paintSwatches objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"AssocSwatchDetailSegue" sender:self];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Delete and Insert
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Delete and Insert

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:indexPath.row];
        PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        // Delete only if it references just this mix association
        //
        if ([[[paintSwatch mix_assoc_swatch] allObjects] count] == 1) {
            [self.context deleteObject:paintSwatch];
            
        } else {
            [paintSwatch removeMix_assoc_swatchObject:mixAssocSwatch];
        }
        
        [_mixAssociation removeMix_assoc_swatchObject:mixAssocSwatch];
        [self.context deleteObject:mixAssocSwatch];
        
        if ([_mixAssocSwatches count] == 1) {;
            [self.context deleteObject:_mixAssociation];
        }
    
        _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
        
        //[_mixAssocSwatches removeObjectAtIndex:indexPath.row];
        
        for (int i=0; i<[_mixAssocSwatches count]; i++) {
            int mix_order = i + 1;
            [[_mixAssocSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:mix_order]];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
      
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self performSegueWithIdentifier:@"AddMixSegue" sender:self];
    }   
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Move
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Move

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ASSOC_COLORS_SECTION) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support rearranging the table view.
//
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // Create the source objects
    //
    int fromRow   = (int)fromIndexPath.row;
    int toRow     = (int)toIndexPath.row;
    int mix_order = toRow + 1;
    
    if (toRow > fromRow) {

        for (int i=fromRow; i<=toRow; i++) {
            [[_mixAssocSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:mix_order]];
            mix_order = i + 1;
        }
        
    } else {
        
        for (int i=fromRow; i>=toRow; i--) {
            [[_mixAssocSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:mix_order]];
            mix_order = i + 1;
        }
    }
    
    _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];

}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Edit Action
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Edit Action

- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];
    
    _editFlag = flag;

    if (_editFlag == FALSE) {
        [self presentViewController:_saveAlertController animated:YES completion:nil];
    }
//
//        // Enable the 'Save' button
//        //
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:SAVE_BTN_TAG isEnabled:TRUE];
//    
//        int objCount = (int)[_paintSwatches count];
//
//        for (int i=0; i < objCount; i++) {
//            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//            //int tag_num = DEF_TAG_NUM + i;
//            UIView *subView = (UITextField *)[cell.contentView viewWithTag:tag_num];
//            //[cell.mixName setTag:tag_num];
//            
//            if (i < 2) {
//                if (cell.textReturn == TRUE) {
//                    [[_paintSwatches objectAtIndex:i] setName:cell.textEntered];
//                    _mainColorFlag = TRUE;
//                    
//                    [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
//                    [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"Reference"]]];
//                }
//
//            } else {
//
//                if ([cell.textEntered length] == 0) {
//                    if (_mainColorFlag == TRUE) {
//                        NSString *ref_name = [[_paintSwatches objectAtIndex:0] name];
//                        NSString *mix_name = [[_paintSwatches objectAtIndex:1] name];
//                        
//                        NSString *mixName = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", ref_name, mix_name, [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue], [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue]];
//                        [[_paintSwatches objectAtIndex:i] setName:mixName];
//                        
//                    } else {
//                        [(UITextField *) subView setText:[[_paintSwatches objectAtIndex:i] name]];
//                    }
//                } else {
//                    
//                    NSString *textEntered = cell.textEntered;
//                    NSString *textReplaced;
//                    NSError *error = nil;
//
//                    NSRegularExpression *regex = [NSRegularExpression
//                                regularExpressionWithPattern:@".*([0-9]+:[0-9]+).*"
//                                options:NSRegularExpressionCaseInsensitive error:&error];
//                    
//                    if(error != nil) {
//                        NSLog(@"Error: %@", error);
//                        
//                    } else {
//                        textReplaced = [regex stringByReplacingMatchesInString:textEntered
//                                    options:0
//                                    range:NSMakeRange(0, [textEntered length])
//                                    withTemplate:[NSString stringWithFormat:@"%@", @"$1"]];
//                    }
//                    
//                    NSArray *comps = [textReplaced componentsSeparatedByString:@":"];
//                    if ([comps count] == 2) {
//                        [[_paintSwatches objectAtIndex:i] setRef_parts_ratio:[NSNumber numberWithInt:[comps[0] intValue]]];
//                        [[_paintSwatches objectAtIndex:i] setMix_parts_ratio:[NSNumber numberWithInt:[comps[1] intValue]]];
//                    }
//                    
//                    if (_mainColorFlag == TRUE) {
//                        NSString *ref_name = [[_paintSwatches objectAtIndex:0] name];
//                        NSString *mix_name = [[_paintSwatches objectAtIndex:1] name];
//                        
//                        NSString *mixName = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", ref_name, mix_name, [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue], [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue]];
//                        [[_paintSwatches objectAtIndex:i] setName:mixName];
//                        
//                    } else {
//                        [[_paintSwatches objectAtIndex:i] setName:cell.textEntered];
//                    }
//                }
//                [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"MixAssoc"]]];
//            }
//            
//        }
//        
//        UITableViewCell* nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
//        _mixAssocName = (NSString *)[(UITextField *)[nameCell.contentView viewWithTag:ASSOC_NAME_TAG] text];
//        
//        UITableViewCell* descCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
//        _mixAssocDesc = (NSString *)[(UITextField *)[descCell.contentView viewWithTag:ASSOC_DESC_TAG] text];
//        
//        if (nameCell.textReturn == TRUE) {
//            _mixAssocName = nameCell.textEntered;
//        }
//    
//        AssocDescTableViewCell* descCell = (AssocDescTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
//        if (descCell.textReturn == TRUE) {
//            _mixAssocDesc = descCell.textEntered;
//        }
        
//        for (int tag=1; tag<=ASSOC_MAX_TAG; tag++) {
//            [[cell.contentView viewWithTag:tag] removeFromSuperview];
//        }
//
//        _mainColorFlag = FALSE;
//
//
//    } else {
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:SAVE_BTN_TAG isEnabled:FALSE];
//    }
//
//    [self.tableView reloadData];
//    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
//    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
//    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
    
    _editFlag = flag;
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == ASSOC_COLORS_SECTION) || (indexPath.section == ASSOC_ADD_SECTION)) {
        return YES;
    } else {
        return NO;
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
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        _textReturn  = TRUE;
    }
    
    if ((textField.tag == ASSOC_NAME_TAG) && (! [textField.text isEqualToString:@""])) {
        _mixAssocName = textField.text;
        
    } else if ((textField.tag == ASSOC_KEYW_TAG) && (! [textField.text isEqualToString:@""])) {
        _mixAssocKeyw = textField.text;
        
    } else if ((textField.tag == ASSOC_DESC_TAG) && (! [textField.text isEqualToString:@""])) {
        _mixAssocDesc = textField.text;
        
    } else {
        for (int i=0; i<[_mixAssocSwatches count]; i++) {
            int COLOR_TAG = i + ASSOC_COLORS_TAG;
            if (textField.tag == COLOR_TAG) {
                MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];
                PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
                [paintSwatch setName:textField.text];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == ASSOC_NAME_TAG && textField.text.length >= MAX_NAME_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_NAME_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;

    } else if (textField.tag == ASSOC_KEYW_TAG && textField.text.length >= MAX_KEYW_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_KEYW_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
        
    } else if (textField.tag == ASSOC_DESC_TAG && textField.text.length >= MAX_DESC_LEN && range.length == 0) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_DESC_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Save and Delete Data
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Save and Delete Data

// Invoked directly and by unwind to segue
//
- (void)saveData {
    
    // Add a placeholder value if missing
    //
    if ([_mixAssocName isEqualToString:@""]) {
        _mixAssocName = [[NSString alloc] initWithFormat:@"MixAssoc %i", (int)[_mixAssociation objectID]];
    }

    [_mixAssociation setName:_mixAssocName];
    [_mixAssociation setDesc:_mixAssocDesc];

    
    // Delete all MixAssociation Keywords and first
    //
    [ManagedObjectUtils deleteMixAssocKeywords:_mixAssociation context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_mixAssocKeyw componentsSeparatedByString:@","]];
    
    for (NSString *keyword in keywords) {
        if ([keyword isEqualToString:@""]) {
            continue;
        }
        
        Keyword *kwObj = [ManagedObjectUtils queryKeyword:keyword context:self.context];
        if (kwObj == nil) {
            kwObj = [[Keyword alloc] initWithEntity:_keywordEntity insertIntoManagedObjectContext:self.context];
            [kwObj setName:keyword];
        }
        
        MixAssocKeyword *maKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_mixAssociation.objectID relationName:@"mix_association" entityName:@"MixAssocKeyword" context:self.context];
        
        if (maKwObj == nil) {
            maKwObj = [[MixAssocKeyword alloc] initWithEntity:_mixAssocKeywordEntity insertIntoManagedObjectContext:self.context];
            [maKwObj setKeyword:kwObj];
            [maKwObj setMix_association:_mixAssociation];
            
            [_mixAssociation addMix_assoc_keywordObject:maKwObj];
            [kwObj addMix_assoc_keywordObject:maKwObj];
        }
    }

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Mix assoc save successful");
    }
    
    _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
    
    _saveFlag = TRUE;
}

- (void)deleteData {
    
    [ManagedObjectUtils deleteMixAssociation:_mixAssociation context:self.context];

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error delete context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Mix delete successful");
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Object methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Object Methods

- (void)recalculateOrder {

    // Reset the order and is_mix flag
    //
//    int ct = (int)[_paintSwatches count];
//    
//    for (int i=0; i<ct; i++) {
//        if (i < 2) {
//            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
//            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"Reference"]]];
//        } else {
//            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:YES]];
//            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"MixAssoc"]]];
//        }
//        
//        [[_paintSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:i+1]];
//    }
    
    for (int i=0; i<[_mixAssocSwatches count]; i++) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:ASSOC_COLORS_SECTION]];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIBarButton actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIBarButton Actions

- (IBAction)changeButtonRendering:(id)sender {
    _isRGB = [BarButtonUtils changeButtonRendering:_isRGB refTag: RGB_BTN_TAG toolBarItems:self.toolbarItems];
    [self.tableView reloadData];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Unwind
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Unwind Methods

- (IBAction)goBack:(id)sender {
    if ([_sourceViewName isEqualToString:@"SwatchDetail"] || [_sourceViewName isEqualToString:@"ViewController"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"unwindToImageViewFromAssoc" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"AddMixSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        AddMixViewController *addMixViewController = (AddMixViewController *)([navigationViewController viewControllers][0]);
        
        [addMixViewController setIsRGB:_isRGB];
        
    } else if ([[segue identifier] isEqualToString:@"AssocSwatchDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        // Query the mix association ids
        //
        NSMutableArray *mixAssocSwatches = [ManagedObjectUtils queryMixAssocBySwatch:_addPaintSwatch.objectID context:self.context];
        
        [swatchDetailTableViewController setPaintSwatch:_selPaintSwatch];
        [swatchDetailTableViewController setMixAssocSwatches:mixAssocSwatches];
    }
}

- (IBAction)unwindToAssocFromAdd:(UIStoryboardSegue *)segue {
    _sourceViewController = [segue sourceViewController];
    
    _addPaintSwatches = _sourceViewController.addPaintSwatches;
    
    if ([_addPaintSwatches count] > 0) {
        
        int mix_assoc_ct = (int)[_mixAssocSwatches count];
        
        for (int i=0; i<_addPaintSwatches.count; i++) {
            PaintSwatch *paintSwatch = [_addPaintSwatches objectAtIndex:i];
            MixAssocSwatch *mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:_mixAssocSwatchEntity insertIntoManagedObjectContext:self.context];
            
            // Add MixAssoc relations
            //
            [mixAssocSwatch setPaint_swatch:paintSwatch];
            [mixAssocSwatch setMix_association:_mixAssociation];
            
            // Add PaintSwatch and MixAssociation relations
            //
            PaintSwatches *pswatches = (PaintSwatches *)paintSwatch;
            [pswatches addMix_assoc_swatchObject:mixAssocSwatch];
            [_mixAssociation addMix_assoc_swatchObject:mixAssocSwatch];
            
            // Set the mix_order
            //
            mix_assoc_ct += 1;
            [mixAssocSwatch setMix_order:[NSNumber numberWithInt:mix_assoc_ct]];
            
            _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
            
            [_paintSwatches addObject:paintSwatch];
        }
    }
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)unwindToAssocFromDetail:(UIStoryboardSegue *)segue {
    
}


@end
