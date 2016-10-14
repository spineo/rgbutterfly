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

@property (nonatomic) int addSwatchCount;
@property (nonatomic, strong) NSString *searchString, *domColorLabel, *mixColorLabel, *addColorLabel;
@property (nonatomic) CGFloat defCellHeight;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage;


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

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL addMixShowAll;

@end

@implementation AddMixTableViewController

int ADD_MIX_LIST_SECTION = 0;
int MAX_ADD_MIX_SECTIONS = 1;

NSString *REUSE_CELL_IDENTIFIER = @"AddMixTableCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ColorUtils setNavBarGlaze:self.navigationController.navigationBar];
    
    // Check the PaintSwatch filter (all or ref only?)
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _addMixShowAll = [_userDefaults boolForKey:ADD_MIX_FILTER_KEY];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];

    
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

        NSRange rangeValue = [matchName rangeOfString:_searchString options:NSCaseInsensitiveSearch];

        BOOL isSelected = [sel_obj is_selected];
        if (rangeValue.length > 0 || isSelected == TRUE) {
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

    for (PaintSwatches *paintSwatch in _allPaintSwatches) {
        NSString *name = [paintSwatch name];
        
        // Filter by Reference only
        //
        if (_addMixShowAll == FALSE) {
            int type_id     = [[paintSwatch type_id] intValue];
            
            // Filter out match association swatches
            //
            PaintSwatchType *paintSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Reference" context:self.context];
            int ref_type_id = [[paintSwatchType order] intValue];
            
            if (type_id != ref_type_id) {
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
