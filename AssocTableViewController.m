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

#import "PaintSwatches.h"
#import "MixAssocSwatch.h"
#import "MixAssociation.h"


@interface AssocTableViewController ()

@property (nonatomic, strong) PaintSwatches *addPaintSwatch, *selPaintSwatch;
@property (nonatomic, strong) NSMutableArray *addPaintSwatches;

@property (nonatomic, strong) NSString *reuseCellIdentifier;

@property (nonatomic, strong) NSString *nameHeader, *colorHeader, *descHeader;
@property (nonatomic, strong) NSString *namePlaceholder, *assocName, *descPlaceholder, *assocDesc;
@property (nonatomic) BOOL editingFlag, mainColorFlag, isRGB, textReturn;

@property (nonatomic, strong) UILabel *mixTitleLabel;
@property (nonatomic, strong) NSString *refColorLabel, *mixColorLabel, *addColorLabel, *mixAssocName, *mixAssocDesc;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage;
@property (nonatomic) int goBackStatus;

@property (nonatomic, strong) AddMixViewController *sourceViewController;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *mixAssocEntity, *mixAssocSwatchEntity;

@end

@implementation AssocTableViewController

const int ASSOC_NAME_SECTION  = 2;
const int ASSOC_DESC_SECTION  = 3;

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
    
    _mixAssocEntity       = [NSEntityDescription entityForName:@"MixAssociation"   inManagedObjectContext:self.context];
    _mixAssocSwatchEntity = [NSEntityDescription entityForName:@"MixAssocSwatch"   inManagedObjectContext:self.context];

    // Set the name and desc values
    //
    if (_mixAssociation != nil) {
        _mixAssocName = _mixAssociation.name;
        _mixAssocDesc = _mixAssociation.desc;
        
    } else {
        _mixAssocName = @"";
        _mixAssocDesc = @"";
    }
    _textReturn = FALSE;
    
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Selection Name (max. of %i chars) - ", MAX_NAME_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Selection Description (max. %i chars) - ", MAX_DESC_LEN];
    
    // Set RGB Rendering to FALSE by default
    //
    _isRGB         = FALSE;
    
    _reuseCellIdentifier = @"AssocTableCell";
    
    [self.tableView registerClass:[AssocTableViewCell class] forCellReuseIdentifier:assocCellIdentifier];
    [self.tableView registerClass:[AssocDescTableViewCell class] forCellReuseIdentifier:assocDescCellIdentifier];
    
    
    // Header labels
    //
    _nameHeader        = @"Mix Name";
    _colorHeader       = @"Mix Color Names";
    _descHeader        = @"Mix Description";
    
    _refColorLabel     = @"Dominant";
    _mixColorLabel     = @"Mixing";
    _addColorLabel     = @"Add Mix Color";
    
    // Placeholder
    //
    _namePlaceholder   = @"- Include Mix Association Name Here -";
    _descPlaceholder   = @"- Include Mix Association Description Here -";
    
    _editingFlag       = FALSE;
    _mainColorFlag     = FALSE;
    _bgColorView = [[UIView alloc] init];
    [_bgColorView setBackgroundColor: DARK_BG_COLOR];

    
    _mixTitleLabel = [[UILabel alloc] init];
    _mixTitleLabel.text = @"Mix Association";
    [_mixTitleLabel setBackgroundColor: CLEAR_COLOR];
    [_mixTitleLabel setTextColor: LIGHT_TEXT_COLOR];
    [_mixTitleLabel sizeToFit];
    self.navigationItem.titleView = _mixTitleLabel;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor: LIGHT_TEXT_COLOR];
    
    
    // Initialize the MixAssociationDesc object (containing the name and description for that mix association)
    //
    
    
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
}


- (void)viewDidRotate {
    AssocDescTableViewCell* cell = (AssocDescTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
    UIView *subView = (UITextView *)[cell.contentView viewWithTag: DEF_TAG_NUM];
    [(UITextView *) subView setFrame:CGRectMake(18.0, 5.0, cell.bounds.size.width - (cell.bounds.size.width / 5.0), cell.bounds.size.height - 10.0)];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView Methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
    [headerView setBackgroundColor: DARK_BG_COLOR];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET+1.0, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT-2.0)];
    [headerLabel setBackgroundColor: DARK_BG_COLOR];
    [headerLabel setTextColor: LIGHT_TEXT_COLOR];
    [headerLabel setFont: TABLE_HEADER_FONT];
    
    if (section == 0) {
        [headerView addSubview:headerLabel];
        [headerLabel setText:_colorHeader];
        
    } else if (section == 2) {
        [headerView addSubview:headerLabel];
        [headerLabel setText:_nameHeader];
        
    } else if (section == 3) {
        [headerView addSubview:headerLabel];
        [headerLabel setText:_descHeader];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return DEF_NIL_HEADER;
    } else {
        return DEF_TABLE_HDR_HEIGHT;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //
    if (section == 0) {
        int objCount = (int)_paintSwatches.count;
        return objCount;
        
    } else if ((section == 1) && (_editingFlag == FALSE)) {
        return 0;
        
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return DEF_TABLE_CELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

////    //    CGFloat tableViewWidth = self.tableView.bounds.size.width;
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
////    
//    // Remove the tags
//    //
//    for (int tag=1; tag<=MAX_TAG; tag++) {
//        [[cell.contentView viewWithTag:tag] removeFromSuperview];
//    }

    if (indexPath.section <= 2) {
        if (indexPath.section == ASSOC_NAME_SECTION) {
            
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
//            
//            // Global defaults
//            //
//            [cell setBackgroundColor: DARK_BG_COLOR];
//            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
//            [tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
//            [tableView setSeparatorColor: GRAY_BG_COLOR];
//            [cell.textLabel.layer setBorderWidth: BORDER_WIDTH_NONE];
//            [cell.textLabel setBackgroundColor: DARK_BG_COLOR];
//            [cell.textLabel setText:@""];
//            cell.imageView.image = nil;
//            
//            if (self.editingFlag == FALSE) {
//                [cell.textLabel setText:[[NSString alloc] initWithFormat:@" %@", _mixAssocName]];
//                [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
//                [cell.textLabel setFont: TABLE_CELL_FONT];
//                cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
//                cell.textLabel.numberOfLines = 0;
//                
//                [cell.textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
//                [cell.textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
//                [cell.textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];
//                
//            } else {
//                
//                // Create the image name text field
//                //
//                UITextField *refName  = [FieldUtils createTextField:_mixAssocName tag:NAME_FIELD_TAG];
//                [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, 5.0, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
//                [refName setDelegate:self];
//                [cell.contentView addSubview:refName];
//                [cell.textLabel setText:@""];
//                
//                if ([_mixAssocName isEqualToString:@""]) {
//                    [refName setPlaceholder: _namePlaceholder];
//                }
//            }
//            
//            [cell setAccessoryType: UITableViewCellAccessoryNone];
//            
//            return cell;
            
            AssocTableViewCell *cell = [[AssocTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assocCellIdentifier];
            UIView *subView = (UITextField *)[cell.contentView viewWithTag:DEF_TAG_NUM];
            [(UITextField *) subView setFrame:CGRectMake(5.0, 5.0, cell.bounds.size.width - 20.0, cell.bounds.size.height - 10.0)];
            
            if ([_mixAssocName isEqualToString:@""]) {
                [(UITextField *) subView setPlaceholder:_namePlaceholder];
            } else {
                [(UITextField *) subView setText:_mixAssocName];
            }
            
            
            if (cell.textReturn == TRUE) {
                _mixAssocName = (NSString *)[(UITextField *)[cell.contentView viewWithTag:DEF_TAG_NUM] text];
                
            } else {
                [(UITextField *) subView setText:_mixAssocName];
            }
            
            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            cell.imageView.image = nil;
            
            [(UITextField *)subView setFont: TEXT_FIELD_FONT];
            [subView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
            
            if (self.editingFlag == FALSE) {
                [(UITextField *) subView setBackgroundColor: DARK_BG_COLOR];
                [(UITextField *) subView setTextColor: LIGHT_TEXT_COLOR];
                [(UITextField *) subView setUserInteractionEnabled:NO];
                
                //[(UITextField *) subView setTextColor: GRAY_TEXT_COLOR];
                
            } else {
                [(UITextField *) subView setBackgroundColor: LIGHT_BG_COLOR];
                [(UITextField *) subView setTextColor: DARK_TEXT_COLOR];
                [(UITextField *) subView setUserInteractionEnabled:YES];
            }
            
            return cell;
            
        } else if (indexPath.section == 0) {
            
            if (self.editingFlag == TRUE) {
                AssocTableViewCell *cell = [[AssocTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assocCellIdentifier];
                
                [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
                
                cell.imageView.frame = CGRectMake(5.0, 0.0, cell.bounds.size.height, cell.bounds.size.height);
                [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
                [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
                [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
                
                [cell.imageView setContentMode: UIViewContentModeScaleAspectFill];
                [cell.imageView setClipsToBounds: YES];
                
                if (_isRGB == FALSE) {
                    cell.imageView.image = [ColorUtils renderPaint:[[_paintSwatches objectAtIndex:indexPath.row] image_thumb] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
                } else {
                    cell.imageView.image = [ColorUtils renderRGB:[_paintSwatches objectAtIndex:indexPath.row] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
                }
                
                UIView *subView = (UITextField *)[cell.contentView viewWithTag: DEF_TAG_NUM];
                [(UITextField *) subView setText: [[_paintSwatches objectAtIndex:indexPath.row] name]];
                
                return cell;
                
            } else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
                
                cell.imageView.frame = CGRectMake(5.0, 0.0, cell.bounds.size.height, cell.bounds.size.height);
                cell.imageView.layer.borderColor = [LIGHT_BORDER_COLOR CGColor];
                [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
                [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
                
                [cell.imageView setContentMode: UIViewContentModeScaleAspectFill];
                [cell.imageView setClipsToBounds: YES];
                
                if (_isRGB == FALSE) {
                    cell.imageView.image = [ColorUtils renderPaint:[[_paintSwatches objectAtIndex:indexPath.row] image_thumb] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
                } else {
                    cell.imageView.image = [ColorUtils renderRGB:_paintSwatches[indexPath.row] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
                }
            
                cell.accessoryType       = UITableViewCellAccessoryDisclosureIndicator;
                
                [cell.textLabel setText: [[_paintSwatches objectAtIndex:indexPath.row] name]];
                [cell.textLabel setFont: TABLE_CELL_FONT];
                
                [cell setBackgroundColor: DARK_BG_COLOR];
                [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
                [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
                
                return cell;
            }

        } else  {
    
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
            
            [cell.textLabel setText: _addColorLabel];
            cell.accessoryType       = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
            
            [cell setBackgroundColor: DARK_BG_COLOR];
            [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
            [cell.textLabel setFont: TABLE_CELL_FONT];
    
            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            
            return cell;
        }

    } else {
        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
//        
//        // Global defaults
//        //
//        [cell setBackgroundColor: DARK_BG_COLOR];
//        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
//        [tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
//        [tableView setSeparatorColor: GRAY_BG_COLOR];
//        [cell.textLabel.layer setBorderWidth: BORDER_WIDTH_NONE];
//        [cell.textLabel setBackgroundColor: DARK_BG_COLOR];
//        [cell.textLabel setText:@""];
//        cell.imageView.image = nil;
//        
//        if (self.editingFlag == FALSE) {
//            [cell.textLabel setText:[[NSString alloc] initWithFormat:@" %@", _mixAssocDesc]];
//            [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
//            [cell.textLabel setFont: TABLE_CELL_FONT];
//            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
//            cell.textLabel.numberOfLines = 0;
//            
//            [cell.textLabel.layer setBorderWidth: DEF_BORDER_WIDTH];
//            [cell.textLabel.layer setCornerRadius: DEF_CORNER_RADIUS];
//            [cell.textLabel.layer setBorderColor: [GRAY_BORDER_COLOR CGColor]];
//            
//        } else {
//            
//            // Create the image name text field
//            //
//            UITextField *refName  = [FieldUtils createTextField:_mixAssocDesc tag:NAME_FIELD_TAG];
//            [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, 5.0, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
//            [refName setDelegate:self];
//            [cell.contentView addSubview:refName];
//            [cell.textLabel setText:@""];
//            
//            if ([_mixAssocDesc isEqualToString:@""]) {
//                [refName setPlaceholder: _descPlaceholder];
//            }
//        }
//        
//        [cell setAccessoryType: UITableViewCellAccessoryNone];
//        
//        return cell;

        AssocDescTableViewCell *cell = [[AssocDescTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assocDescCellIdentifier];
        UIView *subView = (UITextView *)[cell.contentView viewWithTag: DEF_TAG_NUM];
        [(UITextView *) subView setFrame:CGRectMake(5.0, 5.0, cell.bounds.size.width - 20.0, cell.bounds.size.height - 10.0)];
        
        if (cell.textReturn == TRUE) {
            _mixAssocDesc = (NSString *)[(UITextField *)[cell.contentView viewWithTag:DEF_TAG_NUM] text];
            
        } else {
            [(UITextView *) subView setText:_mixAssocDesc];
        }
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        cell.imageView.image = nil;

        [(UITextView *)subView setFont: TEXT_FIELD_FONT];
        [subView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        
        if (self.editingFlag == FALSE) {
            [(UITextView *) subView setBackgroundColor: DARK_BG_COLOR];
            [(UITextView *) subView setTextColor: LIGHT_TEXT_COLOR];
            [(UITextView *) subView setUserInteractionEnabled:NO];
            
            if ([_mixAssociation.desc isEqualToString:@""]) {
                [(UITextView *) subView setTextColor: GRAY_TEXT_COLOR];
                [(UITextView *) subView setText:_descPlaceholder];
             
            // Initialized with the placeholder
            //
            } else if ([_mixAssociation.desc isEqualToString:_descPlaceholder]) {
                [(UITextView *) subView setTextColor: GRAY_TEXT_COLOR];
            }
            
        } else {
            [(UITextView *) subView setBackgroundColor: LIGHT_BG_COLOR];
            [(UITextView *) subView setTextColor: DARK_TEXT_COLOR];
            [(UITextView *) subView setUserInteractionEnabled:YES];
            
            if ([_mixAssociation.desc isEqualToString:_descPlaceholder]) {
                [(UITextView *) subView setText:@""];
            }
        }
        [(UITextView *) subView setFont: TEXT_FIELD_FONT];

        return cell;
    }
}


// (5) editingStyleForRowAtIndexPath: Invoked for each table cell (add logic here to pick whether to delete or insert)
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
        
    } else if (indexPath.section == 1) {
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

        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:indexPath.row];
        BOOL is_selected = [[swatchObj is_selected] boolValue];
        
        // Remove the swatch and cascade delete the mixassocswatch
        //
        if (is_selected == FALSE) {
            [self.context deleteObject:swatchObj];
        
        // Remove the mixassocswatch only (as swatch is associated with another mix)
        //
        } else {
            NSSet *assocSwatchSet = swatchObj.mix_assoc_swatch;
            for (MixAssocSwatch *obj in assocSwatchSet) {
                PaintSwatches *ps = (PaintSwatches *)obj.paint_swatch;
                MixAssociation *ma = obj.mix_association;
                if (([ps.name isEqualToString:swatchObj.name]) && (_mixAssociation.objectID == ma.objectID)) {
                    
                    // Need to delete set element for ps.paint_swatch
                    // Need to delete reference for ma.mix_association
                    
                    [self.context deleteObject:obj];
                }
            }
        }
        [_paintSwatches removeObjectAtIndex:indexPath.row];
            
        if ([_paintSwatches count] > 0) {
            [self recalculateOrder];
            
        } else {
            [self.context deleteObject:_mixAssociation];
            _mixAssociation = nil;
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        

      
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
    if (indexPath.section == 0) {
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
    int fromRow                    = (int)fromIndexPath.row;
    PaintSwatches *fromPaintSwatch = _paintSwatches[fromRow];
    
    // Create the destination objects
    //
    int toRow                     = (int)toIndexPath.row;
    
    PaintSwatches *tmpSwatch;
    
    if (toRow <= 1) {
        _mainColorFlag = TRUE;
    }
    
    if (toRow > fromRow) {
        for (int i=toRow; i>=fromRow; i--) {
            tmpSwatch         = _paintSwatches[i];
            _paintSwatches[i] = fromPaintSwatch;
            fromPaintSwatch   = tmpSwatch;
        }
        
    } else {
        for (int i=toRow; i<=fromRow; i++) {
            tmpSwatch         = _paintSwatches[i];
            _paintSwatches[i] = fromPaintSwatch;
            fromPaintSwatch   = tmpSwatch;
        }
    }
    
    [self recalculateOrder];
}

#pragma mark - UITextField Delegate Methods

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UITextField Delegates
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    //    if (textField.tag == COLTXT_TAG) {
//    //        [_doneColorButton setHidden:FALSE];
//    //
//    //    } else if (textField.tag == TYPTXT_TAG) {
//    //        [_doneTypeButton setHidden:FALSE];
//    //    };
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if ([textField.text isEqualToString:@""]) {
//        UIAlertController *myAlert = [AlertUtils noValueAlert];
//        [self presentViewController:myAlert animated:YES completion:nil];
//        
//    } else {
//        _textReturn  = TRUE;
//    }
//    
//    if ((textField.tag == NAME_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
//        _mixAssocName = textField.text;
//    } else if ((textField.tag == DESC_FIELD_TAG) && (! [textField.text isEqualToString:@""])) {
//        _mixAssocDesc = textField.text;
//        //    } else if (textField.tag == COLTXT_TAG) {
//        //        _colorSelected = textField.text;
//        //    } else if (textField.tag == TYPTXT_TAG) {
//        //        _typeSelected = textField.text;
//    }
//}



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Edit Action
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Edit Action

- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];
    
    //NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    _editingFlag = flag;

    if (_editingFlag == FALSE) {

        // Enable the 'Save' button
        //
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: SAVE_BTN_TAG isEnabled:TRUE];
    
        int objCount = (int)_paintSwatches.count;

        for (int i=0; i < objCount; i++) {
            AssocTableViewCell* cell = (AssocTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UIView *subView = (UITextField *)[cell.contentView viewWithTag:DEF_TAG_NUM];
            
            if (i < 2) {
                if (cell.textReturn == TRUE) {
                    [[_paintSwatches objectAtIndex:i] setName:cell.textEntered];
                    _mainColorFlag = TRUE;
                    
                    [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
                    [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"Reference"]]];
                }

            } else {

                if ([cell.textEntered length] == 0) {
                    if (_mainColorFlag == TRUE) {
                        NSString *ref_name = [[_paintSwatches objectAtIndex:0] name];
                        NSString *mix_name = [[_paintSwatches objectAtIndex:1] name];
                        
                        NSString *mixName = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", ref_name, mix_name, [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue], [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue]];
                        [[_paintSwatches objectAtIndex:i] setName:mixName];
                        
                    } else {
                        [(UITextField *) subView setText:[[_paintSwatches objectAtIndex:i] name]];
                    }
                } else {
                    
                    NSString *textEntered = cell.textEntered;
                    NSString *textReplaced;
                    NSError *error = nil;

                    NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:@".*([0-9]+:[0-9]+).*"
                                options:NSRegularExpressionCaseInsensitive error:&error];
                    
                    if(error != nil) {
                        NSLog(@"Error: %@", error);
                        
                    } else {
                        textReplaced = [regex stringByReplacingMatchesInString:textEntered
                                    options:0
                                    range:NSMakeRange(0, [textEntered length])
                                    withTemplate:[NSString stringWithFormat:@"%@", @"$1"]];
                    }
                    
                    NSArray *comps = [textReplaced componentsSeparatedByString:@":"];
                    if ([comps count] == 2) {
                        [[_paintSwatches objectAtIndex:i] setRef_parts_ratio:[NSNumber numberWithInt:[comps[0] intValue]]];
                        [[_paintSwatches objectAtIndex:i] setMix_parts_ratio:[NSNumber numberWithInt:[comps[1] intValue]]];
                    }
                    
                    if (_mainColorFlag == TRUE) {
                        NSString *ref_name = [[_paintSwatches objectAtIndex:0] name];
                        NSString *mix_name = [[_paintSwatches objectAtIndex:1] name];
                        
                        NSString *mixName = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", ref_name, mix_name, [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue], [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue]];
                        [[_paintSwatches objectAtIndex:i] setName:mixName];
                        
                    } else {
                        [[_paintSwatches objectAtIndex:i] setName:cell.textEntered];
                    }
                }
                [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"MixAssoc"]]];
            }
            
        }
        
        AssocTableViewCell* nameCell = (AssocTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        if (nameCell.textReturn == TRUE) {
            _mixAssocName = nameCell.textEntered;
        }
    
        AssocDescTableViewCell* descCell = (AssocDescTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        if (descCell.textReturn == TRUE) {
            _mixAssocDesc = descCell.textEntered;
        }

        _mainColorFlag = FALSE;

    } else {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: SAVE_BTN_TAG isEnabled:FALSE];
    }

    [self.tableView reloadData];
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Save Action
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Save Action

- (IBAction)save:(id)sender {
    [self saveData];
}

// Invoked directly and by unwind to segue
//
- (void)saveData {
    
    // Create if needed
    //
    if (_mixAssociation == nil) {
        _mixAssociation = [[MixAssociation alloc] initWithEntity:_mixAssocEntity insertIntoManagedObjectContext:self.context];
    }
    [_mixAssociation setName:_mixAssocName];
    [_mixAssociation setDesc: _mixAssocDesc];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Mix assoc save successful");
    }
    
    _saveFlag = TRUE;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Object methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Object Methods

- (void)recalculateOrder {

    // Reset the order and is_mix flag
    //
    int ct = (int)[_paintSwatches count];
    
    for (int i=0; i<ct; i++) {
        if (i < 2) {
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"Reference"]]];
        } else {
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:YES]];
            [[_paintSwatches objectAtIndex:i] setType_id:[NSNumber numberWithInt:[GlobalSettings getSwatchId:@"MixAssoc"]]];
        }
        
        [[_paintSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:i+1]];
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
        if (_mixAssociation == nil) {
            _mixAssociation = [[MixAssociation alloc] initWithEntity:_mixAssocEntity insertIntoManagedObjectContext:self.context];
        }
        
        for (int i=0; i<_addPaintSwatches.count; i++) {
            PaintSwatches *swatchObj = [_addPaintSwatches objectAtIndex:i];
            MixAssocSwatch *mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:_mixAssocSwatchEntity insertIntoManagedObjectContext:self.context];
            [swatchObj addMix_assoc_swatchObject:mixAssocSwatch];
            [_mixAssociation addMix_assoc_swatchObject:mixAssocSwatch];
            
            [_paintSwatches addObject:swatchObj];
        }
    }
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView reloadData];
}

- (IBAction)unwindToAssocFromDetail:(UIStoryboardSegue *)segue {
    
}


@end
