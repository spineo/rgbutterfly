//
//  AddMixTableTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 6/9/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AddMixTableViewController.h"
#import "AssocTableViewController.h"
#import "GlobalSettings.h"
#import "ColorUtils.h"
#import "PaintSwatches.h"
#import "BarButtonUtils.h"
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"
#import "PaintSwatchSelection.h"

// Entity related
//
#import "PaintSwatches.h"
#import "MixAssocSwatch.h"


@interface AddMixTableViewController ()

@property (nonatomic) BOOL searchMatch;

@property (nonatomic, strong) NSMutableArray *allPaintSwatches, *paintSwatchList;

@property (nonatomic) int addSwatchCount, numSwatches, matchAssocId, refTypeId, genTypeId;
@property (nonatomic, strong) NSString *searchString, *domColorLabel, *mixColorLabel, *addColorLabel;
@property (nonatomic) CGFloat defCellHeight;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage, *emptySquareImage, *checkboxSquareImage;


// Resize UISearchBar when rotated
//
@property (nonatomic) CGRect navBarBounds;
@property (nonatomic) CGFloat navBarWidth, navBarHeight;
@property (nonatomic, strong) UIButton *cancelButton;

// SearchBar related
//
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UISearchBar *mixSearchBar;
@property (nonatomic, strong) UIBarButtonItem *backButton, *searchButton;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIColor *defaultColor, *defaultBgColor,  *currColor;
@property (nonatomic, strong) UIFont *defaultFont, *placeholderFont, *currFont;
@property (nonatomic, strong) UILabel *mixTitleLabel;
@property (nonatomic) CGColorRef defColorBorder;


// Filtering related
//
@property (nonatomic) BOOL showAll, showRefOnly, showGenOnly;
@property (nonatomic, strong) UIBarButtonItem *allLabel, *refLabel, *genLabel, *allButton, *refButton, *genButton;

@end

@implementation AddMixTableViewController

int ADD_MIX_LIST_SECTION = 0;
int MAX_ADD_MIX_SECTIONS = 1;

NSString *REUSE_CELL_IDENTIFIER = @"AddMixTableCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[ColorUtils setNavBarGlaze:self.navigationController.navigationBar];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // Images
    //
    _emptySquareImage   = [[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]     imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _checkboxSquareImage = [[UIImage imageNamed:CHECKBOX_SQ_IMAGE_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    // Filters
    //
    PaintSwatchType *matchSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:self.context];
    _matchAssocId = [[matchSwatchType order] intValue];
    
    PaintSwatchType *refSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Reference" context:self.context];
    _refTypeId = [[refSwatchType order] intValue];
    
    PaintSwatchType *genSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Generic" context:self.context];
    _genTypeId = [[genSwatchType order] intValue];
    
    
    // Buttons
    //

    _refButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:CHECKBOX_SQ_IMAGE_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(filterByReference)];
    
    _genButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(filterByGenerics)];
    
    _allButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(showAllColors)];
    
    
    _refLabel = [[UIBarButtonItem alloc] initWithTitle:@"Reference" style:UIBarButtonItemStylePlain target:nil action:nil];
    [_refLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       LIGHT_TEXT_COLOR, NSForegroundColorAttributeName,
                                       TABLE_HEADER_FONT, NSFontAttributeName, nil]
                             forState:UIControlStateNormal];
    
    _genLabel = [[UIBarButtonItem alloc] initWithTitle:@"Generics" style:UIBarButtonItemStylePlain target:nil action:nil];
    [_genLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       LIGHT_TEXT_COLOR, NSForegroundColorAttributeName,
                                       TABLE_HEADER_FONT, NSFontAttributeName, nil]
                             forState:UIControlStateNormal];
    
    _allLabel = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStylePlain target:nil action:nil];
    [_allLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       LIGHT_TEXT_COLOR, NSForegroundColorAttributeName,
                                       TABLE_HEADER_FONT, NSFontAttributeName, nil]
                             forState:UIControlStateNormal];
    
    _showRefOnly = TRUE;
    _showGenOnly = FALSE;
    _showAll     = FALSE;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self loadTable];

    _addPaintSwatches = [[NSMutableArray alloc] init];
    _addSwatchCount = 0;
    
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_BUTTON_IMAGE_NAME]
                                                   style:UIBarButtonItemStylePlain
                                                   target:self
                                                    action:@selector(goBack)];

    _searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:SEARCH_IMAGE_NAME]
                                                   style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(search)];

    // Adjust the layout when the orientation changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarSetFrames)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _titleView = [[UIView alloc] init];
    
    _cancelButton = [BarButtonUtils createButton:@"Cancel" tag:CANCEL_BUTTON_TAG];
    [_cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
    
    _mixSearchBar = [[UISearchBar alloc] init];
    [_mixSearchBar setBackgroundColor:CLEAR_COLOR];
    [_mixSearchBar setBarTintColor:CLEAR_COLOR];
    [_mixSearchBar setReturnKeyType:UIReturnKeyDone];
    [_mixSearchBar setDelegate:self];
    
    [_titleView addSubview:_mixSearchBar];
    [_titleView addSubview:_cancelButton];
    
    [self searchBarSetFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Methods

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
    
    [headerView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_LG_TABLE_CELL_HGT)];
    
    UIToolbar* filterToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_SM_TABLE_CELL_HGT)];
    [filterToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    NSString *allListing = @"All";
    NSString *refListing = @"Ref.";
    NSString *genListing = @"Gen.";
    if (_showRefOnly == TRUE) {
        refListing = [[NSString alloc] initWithFormat:@"%@ (%i)", refListing, _numSwatches];
        
    } else if (_showGenOnly == TRUE) {
        genListing = [[NSString alloc] initWithFormat:@"%@ (%i)", genListing, _numSwatches];
        
    } else {
        allListing = [[NSString alloc] initWithFormat:@"%@ (%i)", allListing, _numSwatches];
    }
    [_allLabel setTitle:allListing];
    [_refLabel setTitle:refListing];
    [_genLabel setTitle:genListing];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [filterToolbar setItems: @[flexibleSpace, _refButton,_refLabel, flexibleSpace, _genButton, _genLabel, flexibleSpace, _allButton,_allLabel, flexibleSpace]];
    
    CGFloat filterToolbarHgt  = filterToolbar.bounds.size.height;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, filterToolbarHgt, tableView.bounds.size.width, DEF_TABLE_CELL_HEIGHT - filterToolbarHgt)];
    
    [headerView addSubview:filterToolbar];
    [headerView addSubview:paddingView];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DEF_LG_TABLE_CELL_HGT;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return MAX_ADD_MIX_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    //
    int objCount = (int)[_paintSwatchList count];
    return objCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.imageView.frame = CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, cell.bounds.size.height, cell.bounds.size.height);
    [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
    [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [cell.imageView setClipsToBounds:YES];

    cell.imageView.image = [ColorUtils renderSwatch:[[_paintSwatchList objectAtIndex:indexPath.row] paintSwatch] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
    
    cell.accessoryType   = UITableViewCellSeparatorStyleNone;

    
    BOOL test_val = [[_paintSwatchList objectAtIndex:indexPath.row] is_selected];
    if (test_val == TRUE) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    [cell.textLabel setText:[[[_paintSwatchList objectAtIndex:indexPath.row] paintSwatch] name]];
    [cell.textLabel setFont:TABLE_CELL_FONT];
    
    [cell setBackgroundColor:DARK_BG_COLOR];
    [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self checkStatus:tableView path:indexPath];
}


- (void)checkStatus:(UITableView *)tableView path:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        [cell setSelected: FALSE];
        [[_paintSwatchList objectAtIndex:indexPath.row] setIs_selected:FALSE];
        _addSwatchCount--;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        [cell setSelected:TRUE];
        [[_paintSwatchList objectAtIndex:indexPath.row] setIs_selected:TRUE];
        _addSwatchCount++;
    }

    if (_addSwatchCount > 0) {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:DONE_BTN_TAG isEnabled:TRUE];
    } else {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:DONE_BTN_TAG isEnabled:FALSE];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SearchBar Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - SearchBar Methods

- (IBAction)searchMix:(id)sender {
    [self search];
}

- (void)search {
    [self.navigationItem setTitleView:_titleView];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:nil];
    [_mixSearchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchString = searchText;

    if ([_searchString length] == 0) {
        [self loadTable];
    } else {
        [self updateTable];
    }
}

// Need index of items that have been checked
//
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateTable];
    
    [_mixSearchBar resignFirstResponder];
    [self.navigationItem setTitleView:nil];
    [self.navigationItem setLeftBarButtonItem:_backButton];
    [self.navigationItem setRightBarButtonItem:_searchButton];
}

- (void)pressCancel {
    [self.navigationItem setTitleView:nil];
    [self.navigationItem setLeftBarButtonItem:_backButton];
    [self.navigationItem setRightBarButtonItem:_searchButton];
    
    // Refresh the list
    //
    [self loadTable];
}

- (void)updateTable {
    int count = (int)[_paintSwatchList count];

    NSMutableArray *tmpPaintSwatches = [[NSMutableArray alloc] init];

    _searchMatch  = FALSE;

    for (int i=0; i<count; i++) {
        PaintSwatchSelection *sel_obj = [_paintSwatchList objectAtIndex:i];
        NSString *matchName = [[sel_obj paintSwatch] name];
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_searchString
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSRange searchedRange = NSMakeRange(0, [matchName length]);
        NSArray *rangeValue = [regex matchesInString:matchName options:0 range:searchedRange];

        BOOL isSelected = [sel_obj is_selected];
        if ([rangeValue count] > 0 || isSelected == TRUE) {
            _searchMatch = TRUE;

            [tmpPaintSwatches addObject:sel_obj];
        }
    }

    _paintSwatchList = tmpPaintSwatches;

    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (NSMutableDictionary *)returnSelected:(NSMutableArray *)swatchList {
    int count = (int)[swatchList count];
    
    NSMutableDictionary *selected = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<count; i++) {
        PaintSwatchSelection *sel_obj = [swatchList objectAtIndex:i];
        BOOL isSelected = [sel_obj is_selected];
        if (isSelected == TRUE) {
            [selected setValue:@"selected" forKey:[[sel_obj paintSwatch] name]];
        }
    }
    
    return selected;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Table Reload Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Table Reload Methods

- (void)showAllColors {
    _showAll     = TRUE;
    _showRefOnly = FALSE;
    _showGenOnly = FALSE;
    [_allButton setImage:_checkboxSquareImage];
    [_refButton setImage:_emptySquareImage];
    [_genButton setImage:_emptySquareImage];
    
    [self loadTable];
}

- (void)filterByReference {
    _showRefOnly = TRUE;
    _showAll     = FALSE;
    _showGenOnly = FALSE;
    [_refButton setImage:_checkboxSquareImage];
    [_allButton setImage:_emptySquareImage];
    [_genButton setImage:_emptySquareImage];
    
    [self loadTable];
}

- (void)filterByGenerics {
    _showGenOnly = TRUE;
    _showAll     = FALSE;
    _showRefOnly = FALSE;
    [_genButton setImage:_checkboxSquareImage];
    [_allButton setImage:_emptySquareImage];
    [_refButton setImage:_emptySquareImage];
    
    [self loadTable];
}

- (void)loadTable {
    
    // Get the full list of Paint Swatches and filter out the ones from the source MixAssociation
    //
    NSMutableDictionary *currPaintSwatchNames = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[_mixAssocSwatches count]; i++) {
        NSString *paintSwatchName = [(PaintSwatches *)[[_mixAssocSwatches objectAtIndex:i] paint_swatch] name];
        [currPaintSwatchNames setValue:@"seen" forKey:paintSwatchName];
    }
    
    _allPaintSwatches = [ManagedObjectUtils fetchPaintSwatches:self.context];
    NSMutableDictionary *selectedSwatchNames = [self returnSelected:_paintSwatchList];
    _paintSwatchList  = [[NSMutableArray alloc] init];

    _numSwatches = 0;
    for (PaintSwatches *paintSwatch in _allPaintSwatches) {
        NSString *name = [paintSwatch name];
        
        // Filters
        //
        int type_id     = [[paintSwatch type_id] intValue];
        
        // Skip match types
        //
        if (type_id == _matchAssocId) {
            continue;
        }
        
        if (![selectedSwatchNames valueForKey:name]) {
            if ((_showRefOnly == TRUE && type_id != _refTypeId) ||
                (_showGenOnly == TRUE && type_id != _genTypeId)) {
                continue;
            }
        }

        if (![currPaintSwatchNames valueForKey:name] || [selectedSwatchNames valueForKey:name]) {
            PaintSwatchSelection *paintSwatchSelection = [[PaintSwatchSelection alloc] init];
            [paintSwatchSelection setPaintSwatch:paintSwatch];
            
            if ([selectedSwatchNames valueForKey:name]) {
                [paintSwatchSelection setIs_selected:TRUE];
            } else {
                [paintSwatchSelection setIs_selected:FALSE];
            }
            [_paintSwatchList addObject:paintSwatchSelection];
            _numSwatches++;
        }
    }
    
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Rotation, Resizing, and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Rotation, Resizing, and Navigation Methods

- (void)searchBarSetFrames {

    CGSize navBarSize = self.view.bounds.size;
    [_titleView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, navBarSize.width, navBarSize.height)];

    CGSize buttonSize  = _cancelButton.bounds.size;
    CGFloat xPoint     = navBarSize.width - buttonSize.width - DEF_MD_FIELD_PADDING;
    CGFloat yPoint     = (navBarSize.height - buttonSize.height) / 2;
    [_cancelButton setFrame:CGRectMake(xPoint, yPoint, buttonSize.width, buttonSize.height)];
    
    CGFloat xOffset;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        xOffset = DEF_NAVBAR_X_OFFSET;
    } else {
        xOffset = DEF_X_OFFSET;
    }
    [_mixSearchBar setFrame:CGRectMake(xOffset, yPoint, xPoint - DEF_NAVBAR_X_OFFSET, buttonSize.height)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    for (int i=0; i<[_paintSwatchList count]; i++) {
        PaintSwatchSelection *selObj = [_paintSwatchList objectAtIndex:i];
        BOOL is_selected = [selObj is_selected];
        if (is_selected == TRUE) {
            PaintSwatches *paintSwatch = [selObj paintSwatch];
            [_addPaintSwatches addObject:paintSwatch];
        }
    }
}

- (void)goBack {
    [self performSegueWithIdentifier:@"unwindToAssoc" sender:self];
}

@end