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

@property NSMutableArray *allPaintSwatches, *paintSwatchList;

@property (nonatomic) int addSwatchCount;
@property (nonatomic, strong) NSString *domColorLabel, *mixColorLabel, *addColorLabel;
@property (nonatomic) CGFloat defCellHeight;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage;

@property (nonatomic, strong) UIBarButtonItem *backButton, *searchButton;


// Resize UISearchBar when rotated
//
@property (nonatomic) CGRect navBarBounds;
@property (nonatomic) CGFloat navBarWidth, navBarHeight;
@property (nonatomic, strong) UIButton *cancelButton;

// SearchBar related
//
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UISearchBar *mixSearchBar;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property UIColor *defaultColor, *defaultBgColor,  *currColor;
@property UIFont *defaultFont, *placeholderFont, *currFont;
@property UILabel *mixTitleLabel;
@property CGColorRef defColorBorder;

@end

@implementation AddMixTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Get the full list of Paint Swatches and filter out the ones from the source MixAssociation
    //
    // (1) Create the lookup by Name
    //
    NSMutableDictionary *currPaintSwatchNames = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[_mixAssocSwatches count]; i++) {
        NSString *paintSwatchName = [(PaintSwatches *)[[_mixAssocSwatches objectAtIndex:i] paint_swatch] name];
        [currPaintSwatchNames setValue:@"seen" forKey:paintSwatchName];
    }

    _allPaintSwatches    = [ManagedObjectUtils fetchPaintSwatches:self.context];
    _paintSwatchList    = [[NSMutableArray alloc] init];
    for (PaintSwatches *paintSwatch in _allPaintSwatches) {
        NSString *name = [paintSwatch name];

        if (![currPaintSwatchNames valueForKey:name]) {
            PaintSwatchSelection *paintSwatchSelection = [[PaintSwatchSelection alloc] init];
            [paintSwatchSelection setPaintSwatch:paintSwatch];
            [paintSwatchSelection setIs_selected:FALSE];
            [_paintSwatchList addObject:paintSwatchSelection];
        }
    }
    
    _addPaintSwatches = [[NSMutableArray alloc] init];
    

    _addSwatchCount = 0;

    _reuseCellIdentifier = @"AddMixTableCell";

    
    [self setNavBarSizes];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    //
    int objCount = (int)[_paintSwatchList count];
    return objCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    cell.imageView.frame = CGRectMake(5.0, 0.0, cell.bounds.size.height, cell.bounds.size.height);
    [cell.imageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    [cell.imageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    [cell.imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
    
    [cell.imageView setContentMode: UIViewContentModeScaleAspectFill];
    [cell.imageView setClipsToBounds: YES];

    cell.imageView.image = [ColorUtils renderSwatch:[[_paintSwatchList objectAtIndex:indexPath.row] paintSwatch] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
    
    cell.accessoryType       = UITableViewCellSeparatorStyleNone;

    
    BOOL test_val = [[_paintSwatchList objectAtIndex:indexPath.row] is_selected];
    if (test_val == TRUE) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [cell.textLabel setText: [[[_paintSwatchList objectAtIndex:indexPath.row] paintSwatch] name]];
    [cell.textLabel setFont: TABLE_CELL_FONT];
    
    [cell setBackgroundColor: DARK_BG_COLOR];
    [cell.textLabel setTextColor: LIGHT_TEXT_COLOR];
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SEARCH BAR methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (IBAction)searchMix:(id)sender {
    [self search];
}

- (void)search {
    _titleView = [[UIView alloc] init];
    _mixSearchBar = [[UISearchBar alloc] init];
    [_mixSearchBar setBackgroundColor: CLEAR_COLOR];
    [_mixSearchBar setBarTintColor: CLEAR_COLOR];
    [_mixSearchBar setDelegate: self];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self searchBarSetFrames];
    
    [_titleView addSubview:_cancelButton];
    [_titleView addSubview:_mixSearchBar];
    
    [self.navigationItem setTitleView: _titleView];
    [self.navigationItem setLeftBarButtonItem: nil];
    [self.navigationItem setRightBarButtonItem: nil];
    
    [_mixSearchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchString = searchText;

    if ([searchText length] == 0) {
        [self reloadTable];
    } else {
        [self updateTable];
    }
}

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
//    
//    return YES;
//}

// Need index of items that have been checked
//
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateTable];
    
    [_mixSearchBar resignFirstResponder];
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
//    //    [self.tableView reloadData];
//    //    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//}

- (void)pressCancel {
    [self.navigationItem setTitleView: nil];
    [self.navigationItem setLeftBarButtonItem: _backButton];
    [self.navigationItem setRightBarButtonItem: _searchButton];
    
    [self reloadTable];

    for (int i=0; i< [_paintSwatchList count]; i++) {
        BOOL  test_val = [[_paintSwatchList objectAtIndex:i] is_selected];
        if (test_val == TRUE) {
            NSLog(@"Selected %i", i);
        }
    }
}

- (void)reloadTable {
    NSMutableArray *paintSwatches    = [ManagedObjectUtils fetchPaintSwatches:self.context];
    _paintSwatchList = [[NSMutableArray alloc] init];
    for (PaintSwatches *paintSwatch in paintSwatches) {
        PaintSwatchSelection *paintSwatchSelection = [[PaintSwatchSelection alloc] init];
        [paintSwatchSelection setPaintSwatch:paintSwatch];
    }
    
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)updateTable {
    int count = (int)[_paintSwatchList count];

    NSMutableArray *tmpPaintSwatches = [[NSMutableArray alloc] init];

    _searchMatch  = FALSE;

    for (int i=0; i<count; i++) {
        PaintSwatchSelection *sel_obj  = [_paintSwatchList objectAtIndex:i];
        NSString *matchName = [[sel_obj paintSwatch] name];

        NSRange rangeValue = [matchName rangeOfString:_searchString options:NSCaseInsensitiveSearch];

        if (rangeValue.length > 0) {
            _searchMatch = TRUE;

            [tmpPaintSwatches addObject:sel_obj];
        }
    }

    _paintSwatchList = tmpPaintSwatches;

    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ROTATION, RESIZING, and NAVIGATION
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)viewDidRotate {
    [self setNavBarSizes];
    [self searchBarSetFrames];
}
    
- (void)setNavBarSizes {
    _navBarBounds = self.navigationController.navigationBar.bounds;
    _navBarWidth  = _navBarBounds.size.width - 10;
    _navBarHeight = _navBarBounds.size.height;
}
    
- (void)searchBarSetFrames {
    [_titleView setFrame:CGRectMake(0, 0, _navBarWidth - 10, _navBarHeight)];
    [_mixSearchBar setFrame:CGRectMake(5, 5, _navBarWidth - 80, _navBarHeight - 10)];
    [_cancelButton setFrame: CGRectMake(_navBarWidth - 70, 5, 60, _navBarHeight - 10)];
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
