//
//  AssocTableViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 4/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "AssocTableViewController.h"
#import "AppDelegate.h"
#import "AddMixTableViewController.h"
#import "AppColorUtils.h"
#import "ColorUtils.h"
#import "SwatchDetailTableViewController.h"
#import "ManagedObjectUtils.h"
#import "FieldUtils.h"
#import "AlertUtils.h"
#import "GenericUtils.h"
#import "ButtonUtils.h"

#import "PaintSwatches.h"
#import "MixAssocSwatch.h"
#import "MixAssociation.h"
#import "AssociationType+CoreDataProperties.h"


@interface AssocTableViewController ()

@property (nonatomic, strong) PaintSwatches *addPaintSwatch, *selPaintSwatch;
@property (nonatomic, strong) NSMutableArray *mixAssocSwatches, *addPaintSwatches, *mixRatiosList, *mixRatiosComps, *mixRatiosSeen;
@property (nonatomic, strong) NSArray *assocTypeNames, *coverageNames;

@property (nonatomic, strong) UIAlertController *saveAlertController, *deleteAlertController;
@property (nonatomic, strong) UIAlertAction *save, *delete;

@property (nonatomic, strong) NSString *reuseCellIdentifier;

@property (nonatomic, strong) NSString *nameHeader, *colorsHeader, *keywHeader, *descHeader, *assocTypeText, *setRenameText, *applyRenameText, *mixRatiosText;
@property (nonatomic, strong) NSString *namePlaceholder, *assocName, *descPlaceholder, *assocDesc, *keywPlaceholder, *assocKeyw;
@property (nonatomic) BOOL editFlag, mainColorFlag, textReturn, isReadOnly;

@property (nonatomic, strong) UILabel *mixTitleLabel;
@property (nonatomic, strong) NSString *refColorLabel, *mixColorLabel, *addColorLabel, *mixAssocName, *mixAssocKeyw, *mixAssocDesc;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage;
@property (nonatomic) CGFloat imageViewXOffset, imageViewYOffset, imageViewWidth, imageViewHeight, assocImageViewWidth, assocImageViewHeight, textFieldYOffset;

@property (nonatomic, strong) UIButton *assocTypeButton, *setButton, *applyButton;
@property (nonatomic, strong) UITextField *pickerTextField, *assocTypeName, *coverageName;
@property (nonatomic) int mixCount, mixRatiosSelRow, assocTypePickerSelRow, coveragePickerSelRow;

@property (nonatomic, strong) AddMixTableViewController *sourceViewController;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *mixAssocEntity, *mixAssocSwatchEntity, *keywordEntity, *mixAssocKeywordEntity;
@property (nonatomic, strong) NSSortDescriptor *orderSort;
@property (nonatomic, strong) NSMutableDictionary *assocTypes, *paintSwatchTypes;
@property (nonatomic, strong) NSNumber *otherTypeId, *mixTypeId, *refTypeId, *mixAssocTypeId, *genericTypeId, *genPaintTypeId;
@property (nonatomic, strong) UIPickerView *assocTypePicker, *coveragePicker;

@end

@implementation AssocTableViewController

const int ASSOC_COLORS_SECTION = 0;
const int ASSOC_ADD_SECTION    = 1;
const int ASSOC_TYPE_SECTION   = 2;
const int ASSOC_COVER_SECTION  = 3;
const int ASSOC_APPLY_SECTION  = 4;
const int ASSOC_NAME_SECTION   = 5;
const int ASSOC_KEYW_SECTION   = 6;
const int ASSOC_DESC_SECTION   = 7;

const int ASSOC_MAX_SECTION    = 8;

const int ASSOC_TYPE_TAG       = 1;
const int ASSOC_COVER_TAG      = 2;
const int ASSOC_APPLY_TAG      = 3;
const int ASSOC_NAME_TAG       = 4;
const int ASSOC_KEYW_TAG       = 5;
const int ASSOC_DESC_TAG       = 6;
const int ASSOC_COLORS_TAG     = 7;
const int ASSOC_SET_TAG        = 8;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization/Cleanup Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods


- (void)viewDidLoad {
    [super viewDidLoad];

    //[ColorUtils setGlaze:self.navigationController.navigationBar];

    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _mixAssocEntity        = [NSEntityDescription entityForName:@"MixAssociation"    inManagedObjectContext:self.context];
    _mixAssocSwatchEntity  = [NSEntityDescription entityForName:@"MixAssocSwatch"    inManagedObjectContext:self.context];
    _keywordEntity         = [NSEntityDescription entityForName:@"Keyword"           inManagedObjectContext:self.context];
    _mixAssocKeywordEntity = [NSEntityDescription entityForName:@"MixAssocKeyword"   inManagedObjectContext:self.context];
    
    // Retrieve the AssociationType dictionary
    //
    _assocTypes   = [ManagedObjectUtils fetchDictByNames:@"AssociationType" context:self.context];
    _otherTypeId  = [_assocTypes valueForKey:@"Other"];
    _mixTypeId    = [_assocTypes valueForKey:@"Mix"];
    
    // Retrieve the PaintSwatchType dictionary
    //
    _paintSwatchTypes = [ManagedObjectUtils fetchDictByNames:@"PaintSwatchType" context:self.context];
    _refTypeId      = [_paintSwatchTypes valueForKey:@"Reference"];
    _mixAssocTypeId = [_paintSwatchTypes valueForKey:@"MixAssoc"];
    _genericTypeId  = [_paintSwatchTypes valueForKey:@"Generic"];
    _genPaintTypeId = [_paintSwatchTypes valueForKey:@"GenericPaint"];
    

    // Set the name and desc values
    //
    _mixAssocName  = [_mixAssociation name] ? [_mixAssociation name] : @"";
    _mixAssocDesc  = [_mixAssociation desc] ? [_mixAssociation desc] : @"";
    _coveragePickerSelRow  = [[_mixAssociation def_coverage_id] intValue];
    _assocTypePickerSelRow = [[_mixAssociation assoc_type_id] intValue];
    
    // Keywords
    //
    NSSet *mixAssocKeywords = [_mixAssociation mix_assoc_keyword];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (MixAssocKeyword *mix_assoc_keyword in mixAssocKeywords) {
        Keyword *keyword = [mix_assoc_keyword keyword];
        [keywords addObject:[keyword name]];
    }
    _mixAssocKeyw = [keywords componentsJoinedByString:KEYW_DISP_SEPARATOR];
    
    _orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
    _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
    
    _textReturn = FALSE;
    
    _namePlaceholder  = [[NSString alloc] initWithFormat:@" - Association Name (max. of %i chars) - ", MAX_NAME_LEN];
    _keywPlaceholder  = [[NSString alloc] initWithFormat:@" - Semicolon-sep. keywords (max. %i chars) - ", MAX_KEYW_LEN];
    _descPlaceholder  = [[NSString alloc] initWithFormat:@" - Association Comments (max. %i chars) - ", MAX_DESC_LEN];
    
    _reuseCellIdentifier = @"AssocTableCell";

    
    // Header labels
    //
    _colorsHeader      = @"Association Colors";
    _nameHeader        = @"Association Name";
    _keywHeader        = @"Association Keywords";
    _descHeader        = @"Association Comments";
    
    _refColorLabel     = @"Dominant";
    _mixColorLabel     = @"Mixing";
    _addColorLabel     = @"Add Refs/Mixes to Association";
    
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
    
    // If coming from the Swatch Detail we don't want to edit (just need the information in this context)
    //
    if ([_sourceViewName isEqualToString:@"SwatchDetail"]) {
        [self.editButtonItem setEnabled:FALSE];
    }


    // Offsets and Widths
    //
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tableview defaults
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _imageViewXOffset     = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewYOffset     = DEF_Y_OFFSET;
    _imageViewWidth       = DEF_VLG_TBL_CELL_HGT;
    _imageViewHeight      = DEF_VLG_TBL_CELL_HGT;
    
    //_assocImageViewWidth  = DEF_TABLE_CELL_HEIGHT;
    //_assocImageViewHeight = DEF_TABLE_CELL_HEIGHT;
    _assocImageViewWidth  = DEF_VLG_TBL_CELL_HGT;
    _assocImageViewHeight = DEF_VLG_TBL_CELL_HGT;
    
    _textFieldYOffset     = (DEF_TABLE_CELL_HEIGHT - DEF_TEXTFIELD_HEIGHT) / DEF_Y_OFFSET_DIVIDER;
    
    
    // Initialize the PaintSwatches array with default names if 'Other' (coming from Image VC) or pre-defined as 'Mix'
    //
    if (_assocTypePickerSelRow == [_otherTypeId intValue] || _assocTypePickerSelRow ==  [_mixTypeId intValue]) {
        [self initPaintSwatches];
    }
    
    // Assoc Types Picker
    //
    id assocTypeObj = [ManagedObjectUtils queryDictionaryName:@"AssociationType" entityId:_assocTypePickerSelRow context:self.context];
    NSString *assocTypeName = [assocTypeObj name];
    _assocTypeName = [FieldUtils createTextField:assocTypeName tag:ASSOC_TYPE_TAG];
    [_assocTypeName setTextAlignment:NSTextAlignmentCenter];
    [_assocTypeName setDelegate:self];
    _assocTypeNames  = [ManagedObjectUtils fetchDictNames:@"AssociationType" context:self.context];
    
    // Canvas Coverage Picker
    //
    id coverageObj = [ManagedObjectUtils queryDictionaryName:@"CanvasCoverage" entityId:_coveragePickerSelRow context:self.context];
    NSString *coverageName = [coverageObj name];
    _coverageName = [FieldUtils createTextField:coverageName tag:ASSOC_COVER_TAG];
    [_coverageName setTextAlignment:NSTextAlignmentCenter];
    [_coverageName setDelegate:self];
    _coverageNames  = [ManagedObjectUtils fetchDictNames:@"CanvasCoverage" context:self.context];


    // Adjust the layout when the orientation changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Match Edit Button Alert Controller
    //
    _saveAlertController = [UIAlertController alertControllerWithTitle:@"Association Edit"
                                                                    message:@"Please select operation"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    // Modified globally (i.e., enable/disable)
    //
    _save = [UIAlertAction actionWithTitle:@"Save Changes" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self saveData];
    }];
    
    _delete = [UIAlertAction actionWithTitle:@"Delete Association" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self deleteData];

    }];
    
    UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_saveAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_saveAlertController addAction:_save];
    [_saveAlertController addAction:_delete];
    [_saveAlertController addAction:discard];
   
    
    // Set the Association type, Canvas coverage and Apply renaming button
    //
    _assocTypeText = @"Association Type";
    [self recreateAssocTypeButton];
    [_assocTypeButton setEnabled:TRUE];
    
    _setRenameText = @"Canvas Coverage";
    [self recreateSetCanvasButton];
    [_setButton setEnabled:TRUE];
    
    _applyRenameText = @"";
    [self recreateApplyButton];
    [_applyButton setEnabled:TRUE];
    
    [_save setEnabled:FALSE];

    [self homeButtonShow];
    [self settingsButtonShow];
    
    
    _deleteAlertController =   [UIAlertController
                                  alertControllerWithTitle:@"Delete Association"
                                  message:@"Are you sure you want to delete this Association?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [_deleteAlertController dismissViewControllerAnimated:YES completion:nil];
                             [self deleteMixAssociation];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"No"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [_deleteAlertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [_deleteAlertController addAction:cancel];
    [_deleteAlertController addAction:ok];
    
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTintColor:LIGHT_TEXT_COLOR];
    
    // All Features?
    //
    if (ALL_FEATURES == 0)
      [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL is_shipped  = [[_mixAssociation is_shipped] boolValue];
    BOOL is_readonly = [[_mixAssociation is_readonly] boolValue];
    
    _isReadOnly = is_shipped ? is_shipped : is_readonly;
    
    if (_isReadOnly == TRUE) {
        [_delete setEnabled:FALSE];
    }
    
    // Used by the mixRatios Picker
    //
    _mixCount = (int)[_mixAssocSwatches count] - 2;
}

- (void)viewDidRotate {
    [self recreateAssocTypeButton];
    [self recreateSetCanvasButton];
    [self recreateApplyButton];
    [self.tableView reloadData];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - General Methods

- (void)setFrameSizes {
    
    // Text view widths
    //
    CGFloat viewWidth = self.tableView.bounds.size.width;
    CGFloat fullTextFieldWidth = viewWidth - DEF_TABLE_X_OFFSET - DEF_FIELD_PADDING;

    [_coverageName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, fullTextFieldWidth, DEF_TEXTFIELD_HEIGHT)];
}

- (void)recreateAssocTypeButton {
    NSString *buttonText = [[NSString alloc] initWithFormat:@"%@: %@", _assocTypeText, [_assocTypeName text]];
    CGRect colorButtonFrame = CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT);
    _assocTypeButton = [ButtonUtils create3DButton:buttonText tag:ASSOC_TYPE_TAG frame:colorButtonFrame];
    
    [_assocTypeButton setFrame:colorButtonFrame];

    _assocTypeButton = [ButtonUtils set3DGradient:_assocTypeButton];
    [_assocTypeButton.titleLabel setFont:TABLE_CELL_FONT];
    
    [_assocTypeButton addTarget:self action:@selector(showAssocTypePicker) forControlEvents:UIControlEventTouchUpInside];
}

- (void)recreateSetCanvasButton {
    NSString *buttonText = [[NSString alloc] initWithFormat:@"%@: %@", _setRenameText, [_coverageName text]];
    CGRect colorButtonFrame = CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT);
    _setButton = [ButtonUtils create3DButton:buttonText tag:ASSOC_SET_TAG frame:colorButtonFrame];
    
    _setButton = [ButtonUtils set3DGradient:_setButton];
    [_setButton.titleLabel setFont:TABLE_CELL_FONT];
    
    [_setButton addTarget:self action:@selector(showCoveragePicker) forControlEvents:UIControlEventTouchUpInside];
}

- (void)recreateApplyButton {
    SEL selector;
    if ([[_assocTypeName text] isEqualToString:MIX_TYPE]) {
        _applyRenameText = @"Apply Renaming with Ratios";
        selector = @selector(showMixRatiosPicker);
        
    } else if ([[_assocTypeName text] containsString:@"Generic"]) {
        _applyRenameText = @"Apply Generic Properties";
        selector = @selector(applyRenaming);
        
    } else if ([[_assocTypeName text] isEqualToString:@"Coverage"]) {
        _applyRenameText = @"Apply Coverage Renaming";
        selector = @selector(applyRenaming);
    }
    
    CGRect colorButtonFrame = CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT);
    _applyButton = [ButtonUtils create3DButton:_applyRenameText tag:ASSOC_APPLY_TAG frame:colorButtonFrame];
    
    _applyButton = [ButtonUtils set3DGradient:_applyButton];
    [_applyButton.titleLabel setFont:TABLE_CELL_FONT];
    
    [_applyButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MixAssocSwatch"];
    
    NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
    [request setSortDescriptors:@[orderSort]];

    
    [request setPredicate: [NSPredicate predicateWithFormat:@"mix_association == %@", [_mixAssociation objectID]]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"mix_order" cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    if (error != nil) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView Methods

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

    } else if ((section == ASSOC_ADD_SECTION) || (section == ASSOC_TYPE_SECTION) || (section == ASSOC_COVER_SECTION) || (section == ASSOC_APPLY_SECTION)) {
        return DEF_NIL_HEADER;
        
//    } else if ((section == ASSOC_COVER_SECTION) && (_editFlag == TRUE)) {
//        return DEF_NIL_HEADER;
        
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
        
    } else if (((section == ASSOC_APPLY_SECTION) || (section == ASSOC_ADD_SECTION)) &&
        ((_editFlag == FALSE) || (_isReadOnly == TRUE))
    ) {
        return 0;
        
    } else if (((section == ASSOC_APPLY_SECTION) || (section == ASSOC_COVER_SECTION)) && [[_assocTypeName text] isEqualToString:@"Other"]) {
        return 0;
    
    } else if (((section == ASSOC_COVER_SECTION)) && [[_assocTypeName text] containsString:@"Generic"]) {
        return 0;

    } else if (section == ASSOC_COLORS_SECTION) {
        return [_mixAssocSwatches count];
        
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (((indexPath.section == ASSOC_ADD_SECTION) || (indexPath.section == ASSOC_APPLY_SECTION)) && (_editFlag == FALSE)) {
        return DEF_NIL_HEIGHT;
    } else if (indexPath.section == ASSOC_COLORS_SECTION) {
        return DEF_VLG_TBL_CELL_HGT;
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
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];

    cell.imageView.image = nil;
    
    //[self initializeFetchedResultsController];
    
    //    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    
    // Remove the tags
    //
    int max_tag = (int)[_mixAssocSwatches count] + ASSOC_MAX_SECTION;
    for (int tag=1; tag<=max_tag; tag++) {
        [[cell.contentView viewWithTag:tag] removeFromSuperview];
    }
    
    // Set the widget frame sizes
    //
    //[self setFrameSizes];

    
    if (indexPath.section == ASSOC_COLORS_SECTION) {

        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:indexPath.row];
        
        PaintSwatches *paintSwatch     = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        NSString *name = [paintSwatch name];

        cell.imageView.image = [AppColorUtils renderSwatch:paintSwatch cellWidth:_assocImageViewWidth cellHeight:_assocImageViewHeight context:self.context];
        
        // Tag the first reference image
        //
        [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
        [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [cell.imageView setClipsToBounds: YES];
        //[cell.imageView setFrame:CGRectMake(_imageViewXOffset, _imageViewYOffset, _imageViewWidth, _imageViewHeight)];
        [cell.imageView setFrame:CGRectMake(_imageViewXOffset, _imageViewYOffset, _assocImageViewWidth, _assocImageViewHeight)];

        
        int tag_num = (int)indexPath.row + ASSOC_MAX_SECTION;
        //UITextField *refName  = [FieldUtils createTextField:name tag:tag_num];
        UITextView *refName  = [FieldUtils createTextView:name tag:tag_num];
        
        // Disable editing if the paint swatch is an "add" or any of the other flags set
        //
        if (
            ([[mixAssocSwatch paint_swatch_is_add] boolValue] == TRUE) || (_isReadOnly == TRUE)
        ) {
            //[refName setEnabled:FALSE];
            [refName setEditable:NO];
            
            [refName setBackgroundColor:GRAY_BG_COLOR];
        }
        
        CGFloat xpos  = _assocImageViewWidth + DEF_CELL_EDIT_DISPL;
        CGFloat width = cell.contentView.bounds.size.width - xpos;
        
        //[refName setFrame:CGRectMake(xpos, _textFieldYOffset, width, DEF_TEXTFIELD_HEIGHT)];
        [refName setFrame:CGRectMake(xpos, 0.0, width, cell.contentView.bounds.size.height)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];
        
        if (_editFlag == TRUE) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];

        } else {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [FieldUtils makeTextViewNonEditable:refName content:name border:FALSE];
        }
 
    } else if (indexPath.section == ASSOC_ADD_SECTION) {
        [cell.textLabel setText: _addColorLabel];
        cell.accessoryType       = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;
        
        [cell setBackgroundColor:DARK_BG_COLOR];
        [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
        [cell.textLabel setFont:TABLE_CELL_FONT];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
    } else if (indexPath.section == ASSOC_TYPE_SECTION) {
        
        NSString *assocTypeText = [[NSString alloc] initWithFormat:@"Association Type: %@", [_assocTypeNames objectAtIndex:_assocTypePickerSelRow]];
    
        if (_editFlag == TRUE) {
            [_assocTypeButton setTitle:assocTypeText forState:UIControlStateNormal];
            [cell.contentView addSubview:_assocTypeButton];
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        } else {
            [cell setBackgroundColor:DARK_BG_COLOR];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell.textLabel setFont:TABLE_HEADER_FONT];
            [cell.textLabel setText:assocTypeText];
        }
        
    } else if (indexPath.section == ASSOC_COVER_SECTION) {
        
        NSString *coverageText = [[NSString alloc] initWithFormat:@"Canvas Coverage: %@", [_coverageNames objectAtIndex:_coveragePickerSelRow]];
        
        if (_editFlag == TRUE) {
            [_setButton setTitle:coverageText forState:UIControlStateNormal];
            [cell.contentView addSubview:_setButton];
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        } else {
            [cell setBackgroundColor:DARK_BG_COLOR];
            [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
            [cell.textLabel setFont:TABLE_HEADER_FONT];
            [cell.textLabel setText:coverageText];
        }
        
    } else if (indexPath.section == ASSOC_APPLY_SECTION) {
        cell.accessoryType       = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;
        [cell.contentView addSubview:_applyButton];
        
        [cell setBackgroundColor:DARK_BG_COLOR];
        [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
        [cell.textLabel setFont:TABLE_CELL_FONT];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];

    } else if (indexPath.section == ASSOC_NAME_SECTION) {
        
        // Create the name text field
        //
        UITextField *refName  = [FieldUtils createTextField:_mixAssocName tag:ASSOC_NAME_TAG];
        [refName setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _textFieldYOffset, (self.tableView.bounds.size.width - DEF_TABLE_X_OFFSET) - DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
        [refName setDelegate:self];
        [cell.contentView addSubview:refName];

        if (
            (_editFlag == FALSE) || (_isReadOnly == TRUE)
        ) {
            [FieldUtils makeTextFieldNonEditable:refName content:_mixAssocName border:TRUE];
            
        } else {
            if ([_mixAssocName isEqualToString:@""]) {
                [refName setPlaceholder:_namePlaceholder];
            }
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

    // Comments section
    //
    } else {
        
        // Create the comments/description text field
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
        [cell setAccessoryType:UITableViewCellAccessoryNone];
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
        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:indexPath.row];
        _selPaintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        [self performSegueWithIdentifier:@"AssocSwatchDetailSegue" sender:self];
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Delete and Insert Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Delete and Insert Methods

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
        
        for (int i=0; i<[_mixAssocSwatches count]; i++) {
            int mix_order = i + 1;
            [[_mixAssocSwatches objectAtIndex:i] setMix_order:[NSNumber numberWithInt:mix_order]];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [_save setEnabled:TRUE];
        [_applyButton setEnabled:TRUE];
        
      
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self performSegueWithIdentifier:@"AddMixSegue" sender:self];
    }   
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Move and Edit
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Move and Edit

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
    
    [_applyButton setEnabled:TRUE];
    [_save setEnabled:TRUE];
    
    _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
    [super setEditing:flag animated:animated];
    
    _editFlag = flag;
    
    [_applyButton setEnabled:TRUE];

    if (_editFlag == FALSE) {
        [self presentViewController:_saveAlertController animated:YES completion:nil];
        
    } else {;
        //[self settingsButtonShow];
    }
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ASSOC_COLORS_SECTION) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (((indexPath.section == ASSOC_COLORS_SECTION) || (indexPath.section == ASSOC_ADD_SECTION)) && ! (
        (_isReadOnly == TRUE)
    )) {
        return YES;
    } else {
        return NO;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Buttons Show/Hide Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Buttons Show/Hide Methods

- (void)homeButtonShow {
    [BarButtonUtils setButtonShow:self.toolbarItems refTag:HOME_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:HOME_BTN_TAG     width:SHOW_BUTTON_WIDTH];
}

- (void)settingsButtonShow {
    [BarButtonUtils setButtonShow:self.toolbarItems refTag:SETTINGS_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:SETTINGS_BTN_TAG width:SHOW_BUTTON_WIDTH];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UITextField Delegates Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [GenericUtils trimString:textField.text];
    
    if ([textField.text isEqualToString:@""] &&
        ! (textField.tag == ASSOC_KEYW_TAG || textField.tag == ASSOC_DESC_TAG)
    ) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        _textReturn  = TRUE;

        if ((textField.tag == ASSOC_NAME_TAG) && (! [textField.text isEqualToString:@""])) {
            _mixAssocName = textField.text;
            
        } else if (textField.tag == ASSOC_KEYW_TAG) {
            _mixAssocKeyw = textField.text;
            
        } else if (textField.tag == ASSOC_DESC_TAG) {
            _mixAssocDesc = textField.text;
            
        } else {
            for (int i=0; i<[_mixAssocSwatches count]; i++) {
                int color_tag = i + ASSOC_MAX_SECTION;
                if (textField.tag == color_tag) {
                    MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];
                    PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
                    [paintSwatch setName:textField.text];
                }
            }
            [_applyButton setEnabled:TRUE];
        }
        [_save setEnabled:TRUE];
    }
    
    [textField resignFirstResponder];
    
    [self.tableView reloadData];
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
// TextView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextView Methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    textView.text = [GenericUtils trimString:textView.text];
    
    _textReturn  = TRUE;
    
    for (int i=0; i<[_mixAssocSwatches count]; i++) {
        int color_tag = i + ASSOC_MAX_SECTION;
        if (textView.tag == color_tag) {
            MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];
            PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
            [paintSwatch setName:textView.text];
        }
    }
    [_applyButton setEnabled:TRUE];
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
// Save and Delete Data Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Save and Delete Data Methods

// Invoked directly and by unwind to segue
//
- (void)saveData {
    
    // Add a placeholder value if missing
    //
    if ([_mixAssocName isEqualToString:@""]) {
        _mixAssocName = [[NSString alloc] initWithFormat:@"Association %i", (int)[_mixAssociation objectID]];
    }

    [_mixAssociation setName:_mixAssocName];
    [_mixAssociation setDesc:_mixAssocDesc];
    [_mixAssociation setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
    [_mixAssociation setDef_coverage_id:[NSNumber numberWithInt:_coveragePickerSelRow]];
    [_mixAssociation setAssoc_type_id:[NSNumber numberWithInt:_assocTypePickerSelRow]];

    
    // Delete all Association Keywords and first
    //
    [ManagedObjectUtils deleteMixAssocKeywords:_mixAssociation context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_mixAssocKeyw componentsSeparatedByString:KEYW_PROC_SEPARATOR]];
    
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
        
        MixAssocKeyword *maKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_mixAssociation.objectID relationName:@"mix_association" entityName:@"MixAssocKeyword" context:self.context];
        
        if (maKwObj == nil) {
            maKwObj = [[MixAssocKeyword alloc] initWithEntity:_mixAssocKeywordEntity insertIntoManagedObjectContext:self.context];
            [maKwObj setKeyword:kwObj];
            [maKwObj setMix_association:_mixAssociation];
            [maKwObj setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
            
            [_mixAssociation addMix_assoc_keywordObject:maKwObj];
            [kwObj addMix_assoc_keywordObject:maKwObj];
        }
    }

    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Association save successful");
        
        [_applyButton setEnabled:FALSE];
        [_save setEnabled:FALSE];
    }
    
    _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];
    
    _saveFlag = TRUE;
}

- (void)deleteData {
    [self presentViewController:_deleteAlertController animated:YES completion:nil];
}
    
- (void)deleteMixAssociation {
    [ManagedObjectUtils deleteMixAssociation:_mixAssociation context:self.context];

    NSError *error = nil;
    if (![self.context save:&error]) {
        [self.context rollback];
        NSLog(@"Error delete context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Association delete successful");
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Object methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Object Methods

- (void)initPaintSwatches {
    int objCount = (int)[_paintSwatches count];
    
    for (int i=0; i < objCount; i++) {
        NSString *colorFormatLabel;
        int ref_parts_ratio = 0;
        int mix_parts_ratio = 0;
        
        if (i == 0) {
            
            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithString:_refColorLabel];
            } else {
                _refColorLabel   = colorFormatLabel;
            }
            
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
            [[_paintSwatches objectAtIndex:i] setType_id:_refTypeId];
            
        } else if (i == 1) {
            
            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithString:_mixColorLabel];
            } else {
                _mixColorLabel = colorFormatLabel;
            }
            
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:NO]];
            [[_paintSwatches objectAtIndex:i] setType_id:_refTypeId];
            
        } else {
            ref_parts_ratio = [[[_paintSwatches objectAtIndex:i] ref_parts_ratio] intValue];
            mix_parts_ratio = [[[_paintSwatches objectAtIndex:i] mix_parts_ratio] intValue];
            
            colorFormatLabel = [[_paintSwatches objectAtIndex:i] name];
            if ([colorFormatLabel length] == 0) {
                colorFormatLabel = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i", _refColorLabel, _mixColorLabel, ref_parts_ratio, mix_parts_ratio];
            }
            
            [[_paintSwatches objectAtIndex:i] setIs_mix:[NSNumber numberWithBool:YES]];
            [[_paintSwatches objectAtIndex:i] setType_id:_mixAssocTypeId];
        }
        [[_paintSwatches objectAtIndex:i] setRef_parts_ratio:[NSNumber numberWithInt:ref_parts_ratio]];
        [[_paintSwatches objectAtIndex:i] setMix_parts_ratio:[NSNumber numberWithInt:mix_parts_ratio]];
        [[_paintSwatches objectAtIndex:i] setName:colorFormatLabel];
    }
}

- (void)applyRenaming {
    NSString *assocTypeName = [_assocTypeName text];
    if ([assocTypeName isEqualToString:MIX_TYPE]) {
        [self applyMixRenaming];
        
    } else if ([assocTypeName isEqualToString:@"Generic"]) {
        [self applyGenericRenaming:_genericTypeId];
        
    } else if ([assocTypeName isEqualToString:@"GenericPaint"]) {
        [self applyGenericRenaming:_genPaintTypeId];

    } else {
        [self applyCoverageRenaming];
    }
    
    [_save setEnabled:TRUE];
    [self.tableView reloadData];
}

- (void)applyMixRenaming {

    //[_applyButton setTitle:_applyRenameText forState:UIControlStateNormal];
    
    NSString *refName_1, *refName_2;
    
    // Determine th Canvas Coverage component (skip 'Unknown' and 'Thick')
    //
    NSString *coverageName = @"";
    if (_coveragePickerSelRow > 1) {
        coverageName = [[NSString alloc] initWithFormat:@" (%@)", [_coverageName text]];
    }

    int swatch_ct = (int)[_mixAssocSwatches count];
    for (int i=0; i<swatch_ct; i++) {
        int color_tag = i + ASSOC_MAX_SECTION;
        UITextField *textField = (UITextField *)[self.view viewWithTag:color_tag];
        
        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];

        PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        BOOL isMix;
        NSString *swatchName;
        NSNumber *swatchId;
        
        NSMutableArray *ratios;
        int index;

        int ratio_1 = 0;
        int ratio_2 = 0;

        if (i == 0) {
            refName_1 = [paintSwatch name];
            isMix = NO;
            swatchName = refName_1;
            swatchId = _refTypeId;
            
        } else if (i == 1) {
            refName_2 = [paintSwatch name];
            isMix = NO;
            swatchName = refName_2;
            swatchId = _refTypeId;
            
        } else {
            index = i - 2;
            ratios = [GenericUtils trimStrings:[[_mixRatiosComps objectAtIndex:index] componentsSeparatedByString:@":"]];
            
            ratio_1 = [[ratios objectAtIndex:0] intValue];
            ratio_2 = [[ratios objectAtIndex:1] intValue];
            
            isMix = YES;

            swatchName = [[NSString alloc] initWithFormat:@"%@ + %@ %i:%i%@", refName_1, refName_2, ratio_1, ratio_2, coverageName];

            swatchId = _mixAssocTypeId;
            
            [paintSwatch setCoverage_id:[NSNumber numberWithInt:_coveragePickerSelRow]];
        }

        // Skip any Paint Swatch that is an add
        //
        BOOL paintSwatchIsAdd = [[mixAssocSwatch paint_swatch_is_add] boolValue];
        if (paintSwatchIsAdd == TRUE) {
            continue;
        }
        
        [textField setText:swatchName];
        [paintSwatch setIs_mix:[NSNumber numberWithBool:isMix]];
        [paintSwatch setType_id:swatchId];
        [paintSwatch setName:swatchName];
        [paintSwatch setRef_parts_ratio:[NSNumber numberWithInt:ratio_1]];
        [paintSwatch setMix_parts_ratio:[NSNumber numberWithInt:ratio_2]];
    }
    
    // Rename the Association
    //
    _mixAssocName = [[NSString alloc] initWithFormat:@"%@ + %@%@", refName_1, refName_2, coverageName];
}

- (void)applyGenericRenaming:(NSNumber *)typeId {
    
    int swatch_ct = (int)[_mixAssocSwatches count];
    for (int i=0; i<swatch_ct; i++) {

        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];
        PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        // Skip any Paint Swatch that is an add
        //
        BOOL paintSwatchIsAdd = [[mixAssocSwatch paint_swatch_is_add] boolValue];
        if (paintSwatchIsAdd == TRUE) {
            continue;
        }
    
        [paintSwatch setIs_mix:[NSNumber numberWithBool:FALSE]];
        [paintSwatch setType_id:typeId];
    }
    
    // Rename the Generic Association
    //
    _mixAssocName = [[NSString alloc] initWithFormat:@"%@ Association %@", [_assocTypeName text], [GenericUtils getCurrDateString:@"YYYY-MM-dd HH:mm:ss"]];
}

- (void)applyCoverageRenaming {

    // Rename the Coverage Association
    //
    MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:0];
    PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
    
    _mixAssocName = [[NSString alloc] initWithFormat:@"%@ (%@)", [paintSwatch name], [_assocTypeName text]];
    
    // Make sure that all the PaintSwatches type ids are associated with 'Reference' by default
    //
    int swatch_ct = (int)[_mixAssocSwatches count];
    for (int i=0; i<swatch_ct; i++) {
        
        MixAssocSwatch *mixAssocSwatch = [_mixAssocSwatches objectAtIndex:i];
        PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        // Skip any Paint Swatch that is an add
        //
        BOOL paintSwatchIsAdd = [[mixAssocSwatch paint_swatch_is_add] boolValue];
        if (paintSwatchIsAdd == TRUE) {
            continue;
        }
        
        [paintSwatch setIs_mix:[NSNumber numberWithBool:FALSE]];
        [paintSwatch setType_id:_refTypeId];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIPickerView actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIPickerView Actions


- (void)showMixRatiosPicker {
    
    // NSUserDefaults (Mix Ratios)
    //
    _mixRatiosText = [[NSUserDefaults standardUserDefaults] stringForKey:MIX_RATIOS_KEY];

    if ([_mixRatiosText isEqualToString:@""] || (_mixRatiosText == nil)) {
        [self presentViewController:[AlertUtils createOkAlert:@"No Mix Ratios to Apply" message:@"Add Mix Ratios in Settings"] animated:YES completion:nil];
        
    } else {
        _mixRatiosList = [GenericUtils trimStrings:[_mixRatiosText componentsSeparatedByString:@"\n"]];
        [_mixRatiosList insertObject:@"Do Not Apply Mix Ratios" atIndex:0];
        
        int mixRatiosCount;
        BOOL mixRatioSeen;
        _mixRatiosSeen = [[NSMutableArray alloc] init];
        [_mixRatiosSeen addObject:[NSNumber numberWithBool:TRUE]];
        for (int i=1; i<[_mixRatiosList count]; i++) {
            mixRatiosCount = (int)[[GenericUtils trimStrings:[[_mixRatiosList objectAtIndex:i] componentsSeparatedByString:@","]] count];
            
            if (mixRatiosCount == _mixCount) {
                mixRatioSeen = TRUE;
            } else {
                mixRatioSeen = FALSE;
            }
            [_mixRatiosSeen addObject:[NSNumber numberWithBool:mixRatioSeen]];
        }
        
        // Tie the apply button to a UI Picker
        //
        UIPickerView *mixRatiosPicker = [FieldUtils createPickerView:self.view.frame.size.width tag:RATIOS_PICKER_TAG xOffset:DEF_X_OFFSET yOffset:DEF_TOOLBAR_HEIGHT];
        [mixRatiosPicker setDataSource:self];
        [mixRatiosPicker setDelegate:self];
        
        UIToolbar* pickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, mixRatiosPicker.bounds.size.width, DEF_TOOLBAR_HEIGHT)];
        [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(ratiosSelection)];
        [doneButton setTintColor:LIGHT_TEXT_COLOR];
        
        [pickerToolbar setItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton]];
        
        UIView *pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, mixRatiosPicker.bounds.size.width, mixRatiosPicker.bounds.size.height + DEF_TOOLBAR_HEIGHT)];
        [pickerParentView setBackgroundColor:DARK_BG_COLOR];
        [pickerParentView addSubview:pickerToolbar];
        [pickerParentView addSubview:mixRatiosPicker];
        
        _pickerTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [_pickerTextField setInputView:pickerParentView];
        [self.view addSubview:_pickerTextField];
        
        [_pickerTextField becomeFirstResponder];
    }
}

- (void)ratiosSelection {
    [_pickerTextField resignFirstResponder];
    
    if (_mixRatiosSelRow != 0) {
        NSString *mixRatios = [_mixRatiosList objectAtIndex:_mixRatiosSelRow];
        _mixRatiosComps = [GenericUtils trimStrings:[mixRatios componentsSeparatedByString:@","]];
        
        if ([_mixRatiosComps count] != _mixCount) {
            [self presentViewController:[AlertUtils createOkAlert:@"Mix Count and Ratios Number Mismatch" message:@"The mix number and ratios applied to it must match"] animated:YES completion:nil];
            
        } else {
            [self applyRenaming];
        }
    }
}

- (void)showAssocTypePicker {
    
    // Tie the set Coverage button to a UI Picker
    //
    _assocTypePicker = [FieldUtils createPickerView:self.view.frame.size.width tag:ASSOC_TYPE_TAG xOffset:DEF_X_OFFSET yOffset:DEF_TOOLBAR_HEIGHT];
    [_assocTypePicker setDataSource:self];
    [_assocTypePicker setDelegate:self];
    
    UIToolbar* pickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, _assocTypePicker.bounds.size.width, DEF_TOOLBAR_HEIGHT)];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(assocTypeSelection)];
    [doneButton setTintColor:LIGHT_TEXT_COLOR];
    
    [pickerToolbar setItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton]];
    
    UIView *pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, _assocTypePicker.bounds.size.width, _assocTypePicker.bounds.size.height + DEF_TOOLBAR_HEIGHT)];
    [pickerParentView setBackgroundColor:DARK_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:_assocTypePicker];
    
    _assocTypeName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_assocTypeName setInputView:pickerParentView];
    [self.view addSubview:_assocTypeName];
    
    [_assocTypePicker selectRow:_assocTypePickerSelRow inComponent:0 animated:YES];
    
    [_assocTypeName becomeFirstResponder];
}

- (void)assocTypeSelection {
    [_assocTypeName setText:[_assocTypeNames objectAtIndex:_assocTypePickerSelRow]];
    [_assocTypePicker selectRow:_assocTypePickerSelRow inComponent:0 animated:YES];
    [_assocTypeName resignFirstResponder];
}

- (void)showCoveragePicker {

    // Tie the set Coverage button to a UI Picker
    //
    _coveragePicker = [FieldUtils createPickerView:self.view.frame.size.width tag:ASSOC_COVER_TAG xOffset:DEF_X_OFFSET yOffset:DEF_TOOLBAR_HEIGHT];
    [_coveragePicker setDataSource:self];
    [_coveragePicker setDelegate:self];
    
    UIToolbar* pickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, _coveragePicker.bounds.size.width, DEF_TOOLBAR_HEIGHT)];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(coverageSelection)];
    [doneButton setTintColor:LIGHT_TEXT_COLOR];
    
    [pickerToolbar setItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton]];
    
    UIView *pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, _coveragePicker.bounds.size.width, _coveragePicker.bounds.size.height + DEF_TOOLBAR_HEIGHT)];
    [pickerParentView setBackgroundColor:DARK_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:_coveragePicker];
    
    _coverageName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_coverageName setInputView:pickerParentView];
    [self.view addSubview:_coverageName];
    
    [_coveragePicker selectRow:_coveragePickerSelRow inComponent:0 animated:YES];
    
    [_coverageName becomeFirstResponder];
}

- (void)coverageSelection {
    [_coverageName setText:[_coverageNames objectAtIndex:_coveragePickerSelRow]];
    [_coveragePicker selectRow:_coveragePickerSelRow inComponent:0 animated:YES];
    [_coverageName resignFirstResponder];
}

// The number of columns of data
//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
//
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (pickerView.tag == ASSOC_TYPE_TAG) {
        return (long)[_assocTypeNames count];
    
    } else if (pickerView.tag == ASSOC_COVER_TAG) {
        return (long)[_coverageNames count];

    } else {
        return (long)[_mixRatiosList count];
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
    
    if (pickerView.tag == ASSOC_TYPE_TAG) {
        return [_assocTypeNames objectAtIndex:row];
        
    } else if (pickerView.tag == ASSOC_COVER_TAG) {
        return [_coverageNames objectAtIndex:row];

    } else {
        return [_mixRatiosList objectAtIndex:row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, DEF_PICKER_ROW_HEIGHT)];
    }
    
    [label.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    [label.layer setBorderWidth: DEF_BORDER_WIDTH];

    if (pickerView.tag == ASSOC_TYPE_TAG) {
        [label setText:[_assocTypeNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
    
    } else if (pickerView.tag == ASSOC_COVER_TAG) {
        [label setText:[_coverageNames objectAtIndex:row]];
        [label setTextColor: LIGHT_TEXT_COLOR];
    
    } else {
        [label setText:[_mixRatiosList objectAtIndex:row]];
        
        BOOL mixRatioSeen = [[_mixRatiosSeen objectAtIndex:row] boolValue];
        CGColorRef backgroundCellColor;
        UIColor *textColor;
        if (mixRatioSeen == TRUE) {
            backgroundCellColor = [WIDGET_GREEN_COLOR CGColor];
            textColor = DARK_TEXT_COLOR;
        } else {
            backgroundCellColor = [WIDGET_RED_COLOR CGColor];
            textColor = LIGHT_TEXT_COLOR;
        }
        [label.layer setBackgroundColor:backgroundCellColor];
        [label setTextColor:textColor];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == ASSOC_TYPE_TAG) {
        NSString *assocType = [_assocTypeNames objectAtIndex:row];
        [_assocTypeName setText:assocType];
        _assocTypePickerSelRow = (int)row;

        [self recreateApplyButton];

    } else if (pickerView.tag == ASSOC_COVER_TAG) {
        NSString *coverageType = [_coverageNames objectAtIndex:row];
        [_coverageName setText:coverageType];
        _coveragePickerSelRow = (int)row;

    } else {
        _mixRatiosSelRow      = (int)row;
    }

    [self.tableView reloadData];
    [_save setEnabled:TRUE];
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
    
    return picker;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TapRecognizer Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIGestureRecognizer methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return true;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Unwind
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Unwind Methods

- (IBAction)goBack:(id)sender {
    if ([_sourceViewName isEqualToString:@"SwatchDetail"] || [_sourceViewName isEqualToString:@"MainViewController"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"unwindToImageViewFromAssoc" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"AddMixSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        AddMixTableViewController *addMixTableViewController = (AddMixTableViewController *)([navigationViewController viewControllers][0]);

        [addMixTableViewController setMixAssocSwatches:_mixAssocSwatches];
        
    } else if ([[segue identifier] isEqualToString:@"AssocSwatchDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        // Query the association ids
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
        
        int add_swatch_ct = (int)[_addPaintSwatches count];
        int mix_assoc_ct  = (int)[_mixAssocSwatches count] + add_swatch_ct;
        
        // Add the paint swatches
        //
        MixAssocSwatch *mixAssocSwatch;
        for (int i=0; i < mix_assoc_ct; i++) {
            if (i < add_swatch_ct) {
                PaintSwatch *paintSwatch = [_addPaintSwatches objectAtIndex:i];
                mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:_mixAssocSwatchEntity insertIntoManagedObjectContext:self.context];
                
                // Add MixAssoc relations
                //
                [mixAssocSwatch setPaint_swatch:paintSwatch];
                [mixAssocSwatch setMix_association:_mixAssociation];
                
                // Add PaintSwatch and MixAssociation relations
                //
                PaintSwatches *pswatches = (PaintSwatches *)paintSwatch;
                [pswatches addMix_assoc_swatchObject:mixAssocSwatch];
                [_mixAssociation addMix_assoc_swatchObject:mixAssocSwatch];

                
                // Flag it as an added paint swatch (so it will not be editable)
                //
                [mixAssocSwatch setPaint_swatch_is_add:[NSNumber numberWithBool:TRUE]];
                
                //[_paintSwatches addObject:paintSwatch];
                [_paintSwatches insertObject:paintSwatch atIndex:0];
                
            } else {
                int mix_assoc_index = i - add_swatch_ct;
                mixAssocSwatch = [_mixAssocSwatches objectAtIndex:mix_assoc_index];
            }
            int mix_order = i + 1;
            [mixAssocSwatch setMix_order:[NSNumber numberWithInt:mix_order]];
        }
        
        _mixAssocSwatches = (NSMutableArray *)[[[_mixAssociation mix_assoc_swatch] allObjects] sortedArrayUsingDescriptors:@[_orderSort]];

        [_applyButton setEnabled:TRUE];
        [_save setEnabled:TRUE];
    }
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Navigation Methods


- (IBAction)unwindToAssocFromDetail:(UIStoryboardSegue *)segue {
    
}


@end
