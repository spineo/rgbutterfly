//
//  ViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "ViewController.h"
#import "GlobalSettings.h"
#import "PickerViewController.h"
#import "AppDelegate.h"
#import "BarButtonUtils.h"
#import "SwatchDetailTableViewController.h"
#import "AssocCollectionTableViewCell.h"
#import "AssocTableViewController.h"
#import "SettingsTableViewController.h"
#import "AlertUtils.h"

#import "ManagedObjectUtils.h"
#import "PaintSwatches.h"
#import "SwatchKeyword.h"
#import "Keyword.h"
#import "MixAssociation.h"
#import "MixAssocSwatch.h"
#import "MatchAssociations.h"
#import "TapArea.h"


@interface ViewController()

@property (nonatomic, strong) UIAlertController *listingController, *photoSelectionController;
@property (nonatomic, strong) NSString *reuseCellIdentifier;

@property (nonatomic, strong) UILabel *mixTitleLabel;
@property (nonatomic, strong) NSString *domColorLabel, *mixColorLabel, *addColorLabel, *listingType;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIImage *colorRenderingImage, *associationImage;
@property (nonatomic, strong) NSMutableArray *mixAssocObjs, *mixColorArray, *sortedLetters, *matchColorArray, *matchAssocObjs;
@property (nonatomic, strong) NSArray *keywordsIndexTitles, *swatchKeywords;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary, *keywordNames, *letters, *letterKeywords, *letterSwatches;
@property (nonatomic) int num_tableview_rows, collectViewSelRow, matchAssocId;
@property (nonatomic) CGFloat imageViewWidth, imageViewHeight, imageViewXOffset;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MixAssociation *mixAssociation;
@property (nonatomic, strong) MatchAssociations *matchAssociation;

@end


@implementation ViewController


#pragma mark - Initialization and Load Methods

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [GlobalSettings init];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    [_colorTableView setDelegate:self];
    [_colorTableView setDataSource:self];
    
    _reuseCellIdentifier = @"InitTableCell";
    

    _listingType        = DEFAULT_LISTING_TYPE;
    
    // TableView defaults
    //
    _imageViewXOffset   = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewWidth     = DEF_TABLE_CELL_HEIGHT;
    _imageViewHeight    = DEF_TABLE_CELL_HEIGHT;

    
    // Listing Controller
    //
    _listingController = [UIAlertController alertControllerWithTitle:@"Colors Listings"
                                                                   message:@"Please select a listing type"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction   = [UIAlertAction actionWithTitle:@"Default Colors Listing" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                [self updateTable:DEFAULT_LISTING_TYPE];
                                                            }];
    
    UIAlertAction *mixAssociations = [UIAlertAction actionWithTitle:@"Mix Associations" style:UIAlertActionStyleDefault                     handler:^(UIAlertAction * action) {
        [self updateTable:@"Mix"];
    }];
    
    UIAlertAction *sortByKeywords = [UIAlertAction actionWithTitle:@"Sort By Keywords" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateTable:@"Keywords"];
    }];
    
    UIAlertAction *matchAssociations = [UIAlertAction actionWithTitle:@"MatchAssociations" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateTable:@"Match"];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_listingController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_listingController addAction:defaultAction];
    [_listingController addAction:mixAssociations];
    [_listingController addAction:sortByKeywords];
    [_listingController addAction:matchAssociations];
    [_listingController addAction:alertCancel];
    
    
    // Listing Alert Controller
    //
    _photoSelectionController = [UIAlertController alertControllerWithTitle:@"Photo Selection"
                                                             message:@"Please select from options below"
                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* selLibraryAction   = [UIAlertAction actionWithTitle:@"My Photo Library" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                [self selectPhoto];
                                                            }];
    
    UIAlertAction *selTakePhotoAction = [UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault                     handler:^(UIAlertAction * action) {
        [self takePhoto];
    }];
    
    UIAlertAction *selCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_photoSelectionController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_photoSelectionController addAction:selLibraryAction];
    [_photoSelectionController addAction:selTakePhotoAction];
    [_photoSelectionController addAction:selCancel];
    
    _keywordsIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    PaintSwatchType *paintSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:self.context];
    _matchAssocId = [[paintSwatchType order] intValue];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self initPaintSwatchFetchedResultsController];
    _paintSwatches = [ManagedObjectUtils fetchPaintSwatches:self.context];
 
    if ([_listingType isEqualToString:@"Mix"]) {
        [self loadMixCollectionViewData];
        
    } else if ([_listingType isEqualToString:@"Match"]) {
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:@"Keywords"]) {
        [self loadKeywordData];
    }
    [_colorTableView reloadData];
}

- (void)loadMixCollectionViewData {
    _mixAssocObjs = [ManagedObjectUtils fetchMixAssociations:self.context];
    int num_tableview_rows = (int)[_mixAssocObjs count];
    
    NSMutableArray *mixAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<num_tableview_rows; i++) {
        
        MixAssociation *mixAssocObj = [_mixAssocObjs objectAtIndex:i];
        
        NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
        NSMutableArray *swatch_ids = (NSMutableArray *)[[ManagedObjectUtils queryMixAssocSwatches:mixAssocObj.objectID context:self.context]sortedArrayUsingDescriptors:@[orderSort]];
        
        int num_collectionview_cells = (int)[swatch_ids count];
        
        NSMutableArray *paintSwatches = [NSMutableArray arrayWithCapacity:num_collectionview_cells];
        
        for (int j=0; j<num_collectionview_cells; j++) {
            MixAssocSwatch *mixAssocSwatchObj = [swatch_ids objectAtIndex:j];
            PaintSwatches *swatchObj = (PaintSwatches *)mixAssocSwatchObj.paint_swatch;
            
            [paintSwatches addObject:swatchObj];
        }
        [mixAssociationIds addObject:paintSwatches];
    }
    
    self.mixColorArray = [NSMutableArray arrayWithArray:mixAssociationIds];
    
    _paintSwatches = [ManagedObjectUtils fetchPaintSwatches:self.context];
    
    [_colorTableView reloadData];
}

- (void)loadMatchCollectionViewData {
    
    _matchAssocObjs = [ManagedObjectUtils fetchMatchAssociations:self.context];
    int num_tableview_rows = (int)[_matchAssocObjs count];
    
    NSMutableArray *matchAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<num_tableview_rows; i++) {
        
        MatchAssociations *matchAssocObj = [_matchAssocObjs objectAtIndex:i];
        
        NSMutableArray *tap_area_ids = [ManagedObjectUtils queryTapAreas:matchAssocObj.objectID context:self.context];
        int num_collectionview_cells = (int)[tap_area_ids count];
        
        NSMutableArray *tapAreas = [NSMutableArray arrayWithCapacity:num_collectionview_cells];
        
       for (int j=0; j<num_collectionview_cells; j++) {
           TapArea *tapAreaObj = [tap_area_ids objectAtIndex:j];
           PaintSwatches *swatchObj = tapAreaObj.tap_area_match;

           //[tapAreas addObject:tapAreaObj];
           [tapAreas addObject:swatchObj];
        }
        [matchAssociationIds addObject:tapAreas];
    }
    
    self.matchColorArray = [NSMutableArray arrayWithArray:matchAssociationIds];
    
    [_colorTableView reloadData];    
}

- (void)loadKeywordData {
    
    [self initializeKeywordResultsController];
    
    _keywordNames   = [[NSMutableDictionary alloc] init];
    _letterKeywords = [[NSMutableDictionary alloc] init];
    _letterSwatches = [[NSMutableDictionary alloc] init];
    
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][0];
    
    NSInteger objcount = [sectionInfo numberOfObjects];
    
    NSIndexPath *nspath;
    for (int i=0; i<objcount; i++) {
    
        nspath = [NSIndexPath indexPathForRow:i inSection:0];
        SwatchKeyword *skw = [self.fetchedResultsController objectAtIndexPath:nspath];
        
        PaintSwatches *ps = (PaintSwatches *)[skw paint_swatch];
        
        Keyword *kw = [skw keyword];
        NSString *keyword = [kw name];
        
        int sct = 0;
        if (![keyword isEqualToString:@""] && keyword != nil) {
            id swatchKeywordNames = [_keywordNames objectForKey:keyword];
            if (swatchKeywordNames == nil) {
                swatchKeywordNames = [NSMutableArray array];
                [_keywordNames setObject:swatchKeywordNames forKey:keyword];
            }
            [swatchKeywordNames addObject:ps];
            sct = (int)[swatchKeywordNames count];
        }
    }
    
    NSMutableArray *keywordPaintSwatches = [[NSMutableArray alloc] init];
    
    NSMutableArray *sortedKeywords = [NSMutableArray arrayWithArray:[_keywordNames allKeys]];
    [sortedKeywords sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _letters = [[NSMutableDictionary alloc] init];
    
    NSString *curr_letter = @"";
    keywordPaintSwatches = [[NSMutableArray alloc] init];
    

    NSMutableArray *keywordList = [[NSMutableArray alloc] init];
    NSMutableArray *swatchList  = [[NSMutableArray alloc] init];
    
    for (id keyword_name in sortedKeywords) {

        NSString *firstLetter = [keyword_name substringToIndex:1];
        firstLetter = [firstLetter uppercaseString];
        
        if (![firstLetter isEqualToString:curr_letter]) {
            keywordPaintSwatches = [[NSMutableArray alloc] init];
        }
        [keywordPaintSwatches addObject:keyword_name];
        
        // Add to alphabet array
        //
        [_letters setObject:keywordPaintSwatches forKey:firstLetter];
        
        curr_letter = firstLetter;
    }
    
    _sortedLetters = [NSMutableArray arrayWithArray:[_letters allKeys]];
    [_sortedLetters sortUsingSelector:@selector(localizedStandardCompare:)];
    
    for (NSString *letter in _sortedLetters) {
        NSArray *sectionKeywords = [_letters objectForKey:letter];
        
        keywordList = [[NSMutableArray alloc] init];
        swatchList  = [[NSMutableArray alloc] init];
        for (NSString *kw in sectionKeywords) {
            NSArray *paintSwatches = [_keywordNames objectForKey:kw];
            for (PaintSwatches *ps in paintSwatches) {
                [keywordList addObject:kw];
                [swatchList addObject:ps];
            }
        }
        [_letterKeywords setObject:keywordList forKey:letter];
        [_letterSwatches setObject:swatchList  forKey:letter];
    }

    [_colorTableView reloadData];
}


- (void)takePhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:[AlertUtils createOkAlert:@"Error" message:@"Device has no camera"] animated:YES completion:nil];
        
    } else {
        [self setImageAction:TAKE_PHOTO_ACTION];
        
        NSLog(@"Image picker segue");
        [self performSegueWithIdentifier:@"ImagePickerSegue" sender:self];
    }
}

- (void)selectPhoto {
    [self setImageAction:SELECT_PHOTO_ACTION];
    [self performSegueWithIdentifier:@"ImagePickerSegue" sender:self];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tableview methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UITableView Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
    [headerView setBackgroundColor: DARK_BG_COLOR];
    
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
    [headerLabel setBackgroundColor: DARK_BG_COLOR];
    [headerLabel setTextColor: LIGHT_TEXT_COLOR];
    [headerLabel setFont: TABLE_HEADER_FONT];
    
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];

    
    if ([_listingType isEqualToString:@"Keywords"]) {
        UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
        
        if (section == 0) {
            [headerView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_LG_TABLE_CELL_HGT)];
            [headerView addSubview:headerLabel];
            [headerLabel setText: @"Keywords Listing"];
            [headerLabel setTextAlignment: NSTextAlignmentCenter];
            
            [letterLabel setFrame:CGRectMake(DEF_X_OFFSET, DEF_TABLE_HDR_HEIGHT, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
        }
        

        [letterLabel setBackgroundColor: DARK_BG_COLOR];
        [letterLabel setTextColor: LIGHT_TEXT_COLOR];
        [letterLabel setFont: TABLE_HEADER_FONT];
        
        [letterLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        [headerView addSubview:letterLabel];
        [letterLabel setText: [_sortedLetters objectAtIndex:section]];
        
    } else if ([_listingType isEqualToString:@"Mix"]) {
        [headerView addSubview:headerLabel];
        [headerLabel setText: @"Mix Associations Listing"];
        [headerLabel setTextAlignment: NSTextAlignmentCenter];
        
    } else if ([_listingType isEqualToString:@"Match"]) {
        [headerView addSubview:headerLabel];
        [headerLabel setText: @"Match Associations Listing"];
        [headerLabel setTextAlignment: NSTextAlignmentCenter];
        
    } else {
        [headerView addSubview:headerLabel];
        [headerLabel setText: @"Colors Listing"];
        [headerLabel setTextAlignment: NSTextAlignmentCenter];
    }

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_listingType isEqualToString:@"Keywords"] && (section == 0)) {
        return DEF_LG_TABLE_CELL_HGT;
    } else {
        return DEF_SM_TABLE_CELL_HGT;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    if ([_listingType isEqualToString:@"Keywords"]) {
        return [_sortedLetters count];
    } else {
        return [[[self fetchedResultsController] sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    //
    NSInteger objCount;
    if ([_listingType isEqualToString:@"Mix"]) {
        objCount = [_mixAssocObjs count];

    } else if ([_listingType isEqualToString:@"Match"]) {
        objCount = [_matchAssocObjs count];
        
    } else if ([_listingType isEqualToString:@"Keywords"]) {
        NSString *sectionTitle = [_sortedLetters objectAtIndex:section];
        objCount = [[_letterKeywords objectForKey:sectionTitle] count];
        
    } else {
        id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
        objCount = [sectionInfo numberOfObjects];
    }
    return objCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([_listingType isEqualToString:@"Mix"] || [_listingType isEqualToString:@"Match"]) {
        return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
    
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_listingType isEqualToString:@"Mix"]) {
        AssocCollectionTableViewCell *custCell = (AssocCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        if (! custCell) {
            custCell = [[AssocCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
        }
        
        [custCell setBackgroundColor: DARK_BG_COLOR];
        
        MixAssociation *mixAssocObj = [_mixAssocObjs objectAtIndex:indexPath.row];
        
        NSString *mix_assoc_name = [mixAssocObj name];
        
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"^- Include Mix .*"
                                      options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange searchedRange = NSMakeRange(0, [mix_assoc_name length]);
        
        if(error != nil) {
            NSLog(@"Error: %@", error);
            
        } else {
            NSArray *matches = [regex matchesInString:mix_assoc_name options:NSMatchingAnchored range:searchedRange];
            if ([matches count] > 0) {
                PaintSwatches *ref = [[self.mixColorArray objectAtIndex:indexPath.row] objectAtIndex:0];
                PaintSwatches *mix = [[self.mixColorArray objectAtIndex:indexPath.row] objectAtIndex:1];
                
                mix_assoc_name = [[NSString alloc] initWithFormat:@"%@ and %@ Mix", ref.name, mix.name];
            }
        }
        
        [custCell setAssocName:mix_assoc_name];
        [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
        
        NSInteger index = custCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
        return custCell;
        
    } else if ([_listingType isEqualToString:@"Match"]) {
            AssocCollectionTableViewCell *custCell = (AssocCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
            
            if (! custCell) {
                custCell = [[AssocCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
            }
            
            [custCell setBackgroundColor: DARK_BG_COLOR];
            
            MatchAssociations *matchAssocObj = [_matchAssocObjs objectAtIndex:indexPath.row];
            
            NSString *match_assoc_name = [matchAssocObj name];
            
            [custCell setAssocName:match_assoc_name];
            [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
            NSInteger index = custCell.collectionView.tag;
            
            CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
            [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
            
            return custCell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
        
        [cell.imageView setFrame:CGRectMake(DEF_FIELD_PADDING, DEF_Y_OFFSET, cell.bounds.size.height, cell.bounds.size.height)];
        [cell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        [cell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        [cell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
        
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView setClipsToBounds:YES];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:TABLE_CELL_FONT];
        [cell setBackgroundColor:DARK_BG_COLOR];
        [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([_listingType isEqualToString:@"Keywords"]) {
    
            NSString *sectionTitle = [_sortedLetters objectAtIndex:indexPath.section];
            NSString *kw_name = [[_letterKeywords objectForKey:sectionTitle] objectAtIndex:indexPath.row];
            PaintSwatches *ps = [[_letterSwatches objectForKey:sectionTitle] objectAtIndex:indexPath.row];

            [cell.imageView setImage:[ColorUtils renderSwatch:ps cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height]];
            
            [cell.textLabel setText:kw_name];
            
        } else {
            
            PaintSwatches *ps = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];

            [cell.imageView setImage:[ColorUtils renderSwatch:ps cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height]];
            [cell.textLabel setText:[ps valueForKeyPath:@"name"]];
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_listingType isEqualToString:@"Mix"]) {
        _selPaintSwatch = [_paintSwatches objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];
        
    } else    if ([_listingType isEqualToString:@"Match"]) {
        //_selPaintSwatch = [_paintSwatches objectAtIndex:indexPath.row];

    } else if ([_listingType isEqualToString:@"Keywords"]) {
        
        NSString *sectionTitle   = [_sortedLetters objectAtIndex:indexPath.section];
        _selPaintSwatch = [[_letterSwatches objectForKey:sectionTitle] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];

    } else {
        _selPaintSwatch = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];
    }
    
}

// Keywords index
//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([_listingType isEqualToString:@"Keywords"]) {
        return _keywordsIndexTitles;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if ([_listingType isEqualToString:@"Keywords"]) {
        return [_sortedLetters indexOfObject:title];
    } else {
        return 0;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIBarButton actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIBarButton and UIAlertController Methods


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIAlertControllers
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (IBAction)showListingOptions:(id)sender {
    [self presentViewController:_listingController animated:YES completion:nil];
}

- (void)updateTable:(NSString *)listingType {
    _listingType = listingType;
    
    if ([_listingType isEqualToString:@"Mix"]) {
        [self loadMixCollectionViewData];
        
    } else if ([_listingType isEqualToString:@"Match"]) {
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:@"Keywords"]) {
        [self loadKeywordData];
        
    } else {
        [self initPaintSwatchFetchedResultsController];
    }
    [_colorTableView reloadData];
}

- (IBAction)showPhotoOptions:(id)sender {
    [self presentViewController:_photoSelectionController animated:YES completion:nil];
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
    
    if ([_listingType isEqualToString:@"Mix"]) {
        return [[self.mixColorArray objectAtIndex:index] count];

    // Match
    //
    } else {
        return [[self.matchColorArray objectAtIndex:index] count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    int index = (int)collectionView.tag;
    
    UIImage *swatchImage;
    
    if ([_listingType isEqualToString:@"Mix"]) {
    
        PaintSwatches *paintSwatch = [[self.mixColorArray objectAtIndex:index] objectAtIndex:indexPath.row];

        swatchImage = [ColorUtils renderSwatch:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];


    // Match
    //
    } else {
        PaintSwatches *paintSwatch = [[self.matchColorArray  objectAtIndex:index] objectAtIndex:indexPath.row];
        TapArea *tapArea = paintSwatch.tap_area;
        swatchImage = [ColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
        swatchImage = [ColorUtils drawTapAreaLabel:swatchImage count:[tapArea.tap_order intValue]];
    }
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:swatchImage];
    
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

    [self setCollectViewSelRow:index];
    
    if ([_listingType isEqualToString:@"Mix"]) {
        PaintSwatches *paintSwatch = [[self.mixColorArray  objectAtIndex:index] objectAtIndex:indexPath.row];
        
        // Doesn't matter which one
        //
        MixAssocSwatch *mixAssocSwatch = [[paintSwatch.mix_assoc_swatch allObjects] objectAtIndex:0];

        _mixAssociation  = mixAssocSwatch.mix_association;
        _associationImage = [UIImage imageWithData:_mixAssociation.image_url];
        
        [self performSegueWithIdentifier:@"VCToAssocSegue" sender:self];
        
    } else if ([_listingType isEqualToString:@"Match"]) {
        PaintSwatches *paintSwatch = [[self.matchColorArray  objectAtIndex:index] objectAtIndex:indexPath.row];
        TapArea *tapArea = [paintSwatch tap_area];
        _matchAssociation = [tapArea match_association];
        _associationImage = [UIImage imageWithData:[_matchAssociation image_url]];
        
        [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSFetchedResultsController Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - NSFetchedResultsController Methods

- (void)initPaintSwatchFetchedResultsController {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PaintSwatch"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    // Skip match assoc types
    //
    [request setPredicate: [NSPredicate predicateWithFormat:@"type_id != %i", _matchAssocId]];
    
    [request setSortDescriptors:@[nameSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    
    @try {
        [[self fetchedResultsController] performFetch:&error];
    } @catch (NSException *exception) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)initializeKeywordResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SwatchKeyword"];
    
    NSSortDescriptor *kwSort = [NSSortDescriptor sortDescriptorWithKey:@"keyword.name" ascending:YES];
    
    [request setSortDescriptors:@[kwSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    
    @try {
        [[self fetchedResultsController] performFetch:&error];
    } @catch (NSException *exception) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Unwind Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Unwind Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ImagePickerSegue"]) {

        PickerViewController *pickerViewController = (PickerViewController *)[segue destinationViewController];
        [pickerViewController setImageAction:_imageAction];
    
    } else if ([[segue identifier] isEqualToString:@"VCToAssocSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
        
        [assocTableViewController setPaintSwatches:[self.mixColorArray objectAtIndex:_collectViewSelRow]];
        [assocTableViewController setMixAssociation:[_mixAssocObjs objectAtIndex:_collectViewSelRow]];
        [assocTableViewController setSaveFlag:TRUE];
        [assocTableViewController setSourceViewName:@"ViewController"];
        
    // ImageSelectionSegue (applies to Match Collections only)
    //
    } else if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"]) {

        UINavigationController *navigationViewController = [segue destinationViewController];
        UIImageViewController *imageViewController = (UIImageViewController *)([navigationViewController viewControllers][0]);
        
        [imageViewController setSelectedImage:_associationImage];
        [imageViewController setSourceViewContext:@"CollectionViewController"];
        [imageViewController setPaintSwatches:[self.matchColorArray objectAtIndex:_collectViewSelRow]];
        [imageViewController setViewType:@"match"];
        [imageViewController setMatchAssociation:_matchAssociation];
        
    // MainSwatchDetailSegue
    //
    } else  if ([[segue identifier] isEqualToString:@"MainSwatchDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
        
        // Query the mix association ids
        //
        NSMutableArray *mixAssocSwatches = [ManagedObjectUtils queryMixAssocBySwatch:_selPaintSwatch.objectID context:self.context];
        
        [swatchDetailTableViewController setPaintSwatch:_selPaintSwatch];
        [swatchDetailTableViewController setMixAssocSwatches:mixAssocSwatches];
    
    // SettingsSegue
    //
    } else {

    }
}

- (IBAction)unwindToViewController:(UIStoryboardSegue *)segue {
    [self.context rollback];
}

@end
