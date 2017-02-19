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
#import "ButtonUtils.h"
#import "SwatchDetailTableViewController.h"
#import "CustomCollectionTableViewCell.h"
#import "AssocTableViewController.h"
#import "SettingsTableViewController.h"
#import "AlertUtils.h"
#import "GenericUtils.h"
#import "HTTPUtils.h"
#import "FieldUtils.h"

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
@property (nonatomic, strong) UIImage *colorRenderingImage, *associationImage, *searchImage, *downArrowImage, *upArrowImage, *emptySquareImage, *checkboxSquareImage;
@property (nonatomic, strong) NSMutableArray *mixAssocObjs, *mixColorArray, *sortedLettersDefaults, *sortedLetters, *matchColorArray, *matchAssocObjs, *subjColorsArray, *subjColorsArrayState;
@property (nonatomic, strong) NSArray *defaultsIndexTitles, *keywordsIndexTitles, *swatchKeywords, *subjColorNames;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary, *defaultsNames, *keywordNames, *letters, *letterDefaults, *letterKeywords, *defaultsSwatches, *keywordSwatches, *subjColorData;
@property (nonatomic) int num_tableview_rows, collectViewSelRow, matchAssocId, refTypeId, genTypeId, numSwatches, numMixAssocs, numKeywords, numMatchAssocs, numSubjColors, selSubjColorSection;
@property (nonatomic) CGFloat imageViewWidth, imageViewHeight, imageViewXOffset;
@property (nonatomic) BOOL initColors, isCollapsedAll, showAll, showRefOnly, showGenOnly;


// Resize UISearchBar when rotated
//
@property (nonatomic) CGRect navBarBounds;
@property (nonatomic) CGFloat navBarWidth, navBarHeight;
@property (nonatomic, strong) UIButton *cancelButton;

// SearchBar related
//
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UISearchBar *mainSearchBar;
@property (nonatomic, strong) UIBarButtonItem *imageLibButton, *searchButton, *allLabel, *refLabel, *genLabel, *allButton, *refButton, *genButton;
@property (nonatomic, strong) NSString *searchString;


// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MixAssociation *mixAssociation;
@property (nonatomic, strong) MatchAssociations *matchAssociation;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL appIntroAlert, mixAssocUnfilter;
@property (nonatomic) int minAssocSize, updateStat;

// Activity Indicator
//
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *updateLabel;

@end


@implementation ViewController

// Minimum number of elements to display a mix association
//
//int MIX_ASSOC_RESTRICT_SIZE = 3;
int MIX_ASSOC_MIN_SIZE = 1;


#pragma mark - Initialization and Load Methods

- (void)startSpinner {
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    [_spinner setCenter:self.view.center];
    [_spinner setHidesWhenStopped:YES];
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    CGFloat labelYOffset = (self.view.bounds.size.height / 2.0) - (DEF_LABEL_HEIGHT / 2.0);
    _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, labelYOffset, self.view.bounds.size.width, DEF_LABEL_HEIGHT)];
    
    [_updateLabel setText:SPINNER_LABEL_LOAD];
    [_updateLabel setFont:VLG_TEXT_FIELD_FONT];
    [_updateLabel setTextColor:LIGHT_TEXT_COLOR];
    [_updateLabel setBackgroundColor:CLEAR_COLOR];
    [_updateLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:_updateLabel];
}

- (void)stopSpinner {
    [_spinner stopAnimating];
    [_updateLabel setText:@""];
    [self.view willRemoveSubview:_updateLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image
    //
    [ColorUtils setBackgroundImage:BACKGROUND_IMAGE_TITLE view:self.view];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    //[ColorUtils setNavBarGlaze:self.navigationController.navigationBar];
    //[ColorUtils setToolbarGlaze:self.navigationController.toolbar];
    
    // Initialization
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    // Welcome alert
    //
    _appIntroAlert = [_userDefaults boolForKey:APP_INTRO_KEY];
    if (_appIntroAlert == TRUE) {
        UIAlertController *alert = [AlertUtils createNoShowAlert:@"Welcome to the RGButterfly App" message:APP_INTRO_INSTRUCTIONS key:APP_INTRO_KEY];
        [self presentViewController:alert animated:YES completion:nil];
    }

    [GlobalSettings init];

    
    // Subjective color data
    //
    _subjColorNames = [ManagedObjectUtils fetchDictNames:@"SubjectiveColor" context:self.context];
    _numSubjColors  = (int)[_subjColorNames count];
    _subjColorData  = [ManagedObjectUtils fetchSubjectiveColors:self.context];
    _isCollapsedAll = TRUE;
    _initColors     = TRUE;
    
    [_colorTableView setDelegate:self];
    [_colorTableView setDataSource:self];
    
    _reuseCellIdentifier = @"InitTableCell";
    
    _listingType        = MIX_TYPE;

    // TableView defaults
    //
    _imageViewXOffset   = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewWidth     = DEF_TABLE_CELL_HEIGHT;
    _imageViewHeight    = DEF_TABLE_CELL_HEIGHT;
    

    // Images
    //
    _searchImage         = [[UIImage imageNamed:SEARCH_IMAGE_NAME]      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _downArrowImage      = [[UIImage imageNamed:ARROW_DOWN_IMAGE_NAME]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _upArrowImage        = [[UIImage imageNamed:ARROW_UP_IMAGE_NAME]    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _emptySquareImage    = [[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _checkboxSquareImage = [[UIImage imageNamed:CHECKBOX_SQ_IMAGE_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    
    // Listing Controller
    //
    _listingController = [UIAlertController alertControllerWithTitle:@"Colors Listings"
                                                                   message:@"Please select a listing type"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *mixAssociations = [UIAlertAction actionWithTitle:@"Color Associations" style:UIAlertActionStyleDefault                     handler:^(UIAlertAction * action) {
        [self updateTable:MIX_TYPE];
    }];
    
    UIAlertAction *matchAssociations = [UIAlertAction actionWithTitle:@"Match Associations" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateTable:MATCH_TYPE];
    }];
    
    UIAlertAction* fullColorsAction   = [UIAlertAction actionWithTitle:FULL_LISTING_TYPE style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self updateTable:FULL_LISTING_TYPE];
                                                               }];
    
    UIAlertAction *sortByKeywords = [UIAlertAction actionWithTitle:@"Keywords Listing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateTable:@"Keywords"];
    }];
    
    UIAlertAction *listByColors = [UIAlertAction actionWithTitle:@"Subjective Colors" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateTable:@"Colors"];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_listingController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_listingController addAction:mixAssociations];
    [_listingController addAction:matchAssociations];
    [_listingController addAction:fullColorsAction];
    [_listingController addAction:sortByKeywords];
    [_listingController addAction:listByColors];
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
    
    
    // Filters
    //
    PaintSwatchType *matchSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:self.context];
    _matchAssocId = [[matchSwatchType order] intValue];
    
    PaintSwatchType *refSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Reference" context:self.context];
    _refTypeId = [[refSwatchType order] intValue];
    
    PaintSwatchType *genSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Generic" context:self.context];
    _genTypeId = [[genSwatchType order] intValue];

    
    // SearchBar related
    //
    _imageLibButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:IMAGE_LIB_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(showPhotoOptions:)];
    [_imageLibButton setTag:IMAGELIB_BTN_TAG];
    
    _searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:SEARCH_IMAGE_NAME]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(search)];
    [_searchButton setTag:SEARCH_BTN_TAG];

    
    _allButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:CHECKBOX_SQ_IMAGE_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(showAllColors)];
    
    _refButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(filterByReference)];
    
    _genButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:EMPTY_SQ_IMAGE_NAME]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(filterByGenerics)];
    
    _allLabel = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStylePlain target:nil action:nil];
    [_allLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       LIGHT_TEXT_COLOR, NSForegroundColorAttributeName,
                                       TABLE_HEADER_FONT, NSFontAttributeName, nil]
                             forState:UIControlStateNormal];
    
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

    _showAll     = TRUE;
    _showRefOnly = FALSE;
    _showGenOnly = FALSE;
    
    self.navigationItem.rightBarButtonItem = _searchButton;

    
    // Adjust the layout when the orientation changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarSetFrames)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _titleView = [[UIView alloc] init];
    
    _cancelButton = [ButtonUtils createButton:@"Cancel" tag:CANCEL_BUTTON_TAG];
    [_cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
    
    _mainSearchBar = [[UISearchBar alloc] init];
    [_mainSearchBar setBackgroundColor:CLEAR_COLOR];
    [_mainSearchBar setBarTintColor:CLEAR_COLOR];
    [_mainSearchBar setReturnKeyType:UIReturnKeyDone];
    [_mainSearchBar setDelegate:self];
    
    [_titleView addSubview:_mainSearchBar];
    [_titleView addSubview:_cancelButton];
    
    [self searchBarSetFrames];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startSpinner];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSpinner];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadData];
    [self.view setBackgroundColor:DARK_BG_COLOR];
}

- (void)loadData {
    // Perform cleanup
    //
    [ManagedObjectUtils deleteOrphanPaintSwatches:self.context];
    [ManagedObjectUtils deleteChildlessMatchAssoc:self.context];
    
    [_searchButton setAction:@selector(search)];
    if ([_listingType isEqualToString:MIX_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadMixCollectionViewData];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadKeywordData];
        
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        [_searchButton setImage:_downArrowImage];
        [_searchButton setAction:@selector(expandAllSections)];
        [self loadColorsData];
        
    } else {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadFullColorsListing];
    }
    [self stopSpinner];
}

- (void)loadFullColorsListing {
    [self initPaintSwatchFetchedResultsController];
    _paintSwatches = [ManagedObjectUtils fetchPaintSwatches:self.context];
    
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][0];
    
    NSInteger objcount = [sectionInfo numberOfObjects];
    
    NSMutableDictionary *letters = [[NSMutableDictionary alloc] init];
    
    NSString *curr_letter = @"";
    
    NSMutableArray *letterPaintSwatches = [[NSMutableArray alloc] init];
    
    NSIndexPath *nspath;
    for (int i=0; i<objcount; i++) {
        nspath = [NSIndexPath indexPathForRow:i inSection:0];
        PaintSwatches *paint_swatch = [self.fetchedResultsController objectAtIndexPath:nspath];
        NSString *swatch_name = [paint_swatch name];
        
        NSString *firstLetter = [swatch_name substringToIndex:1];
        firstLetter = [firstLetter uppercaseString];
        
        if (![firstLetter isEqualToString:curr_letter]) {
            letterPaintSwatches = [[NSMutableArray alloc] init];
        }
        [letterPaintSwatches addObject:paint_swatch];
        
        // Add to alphabet array
        //
        [letters setObject:letterPaintSwatches forKey:firstLetter];
        
        curr_letter = firstLetter;
    }

    
    _sortedLettersDefaults = [NSMutableArray arrayWithArray:[letters allKeys]];
    [_sortedLettersDefaults sortUsingSelector:@selector(localizedStandardCompare:)];
    
    _letterDefaults = [[NSMutableDictionary alloc] init];

    _numSwatches = 0;
    for (NSString *letter in _sortedLettersDefaults) {
        NSMutableArray *sectionSwatches = [[NSMutableArray alloc] init];
        sectionSwatches = [letters objectForKey:letter];
        _numSwatches = _numSwatches + (int)[sectionSwatches count];
        
        [_letterDefaults setObject:sectionSwatches forKey:letter];
    }

    [_colorTableView reloadData];
}


- (void)loadMixCollectionViewData {
    [self initPaintSwatchFetchedResultsController];
//    _minAssocSize = MIX_ASSOC_RESTRICT_SIZE;
    
    // Check the PaintSwatch filter (all or ref only?)
    //
//    _mixAssocUnfilter = [_userDefaults boolForKey:MIX_ASSOC_COUNT_KEY];
//    if (_mixAssocUnfilter == TRUE) {
        _minAssocSize = MIX_ASSOC_MIN_SIZE;
//    }
    
    _mixAssocObjs = [ManagedObjectUtils fetchMixAssociations:self.context name:_searchString];
    int num_mix_assocs = (int)[_mixAssocObjs count];
    _numMixAssocs = 0;
    
    NSMutableArray *mixAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<num_mix_assocs; i++) {
        
        MixAssociation *mixAssocObj = [_mixAssocObjs objectAtIndex:i];
        
        NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"mix_order" ascending:YES];
        NSMutableArray *swatch_ids = (NSMutableArray *)[[ManagedObjectUtils queryMixAssocSwatches:mixAssocObj.objectID context:self.context] sortedArrayUsingDescriptors:@[orderSort]];
        
        int num_collectionview_cells = (int)[swatch_ids count];

        if (num_collectionview_cells >= _minAssocSize) {
            _numMixAssocs = _numMixAssocs + 1;
        }
        
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
    _matchAssocObjs = [ManagedObjectUtils fetchMatchAssociations:self.context name:_searchString];
    _numMatchAssocs = (int)[_matchAssocObjs count];
    
    NSMutableArray *matchAssociationIds = [[NSMutableArray alloc] init];
    for (int i=0; i<_numMatchAssocs; i++) {
        MatchAssociations *matchAssocObj = [_matchAssocObjs objectAtIndex:i];
        
        NSMutableArray *tap_area_ids = [ManagedObjectUtils queryTapAreas:matchAssocObj.objectID context:self.context];
        int num_collectionview_cells = (int)[tap_area_ids count];
        
        NSMutableArray *tapAreas = [NSMutableArray arrayWithCapacity:num_collectionview_cells];
        
       for (int j=0; j<num_collectionview_cells; j++) {
           TapArea *tapAreaObj = [tap_area_ids objectAtIndex:j];
           PaintSwatches *swatchObj = tapAreaObj.tap_area_match;

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
    _keywordSwatches = [[NSMutableDictionary alloc] init];
    
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][0];
    
    NSInteger objcount = [sectionInfo numberOfObjects];
    
    NSIndexPath *nspath;
    for (int i=0; i<objcount; i++) {
        
        nspath = [NSIndexPath indexPathForRow:i inSection:0];
        SwatchKeyword *skw = [self.fetchedResultsController objectAtIndexPath:nspath];
        
        PaintSwatches *ps = (PaintSwatches *)[skw paint_swatch];
        
        Keyword *kw = [skw keyword];
        NSString *keyword = [[kw name] stringByReplacingOccurrencesOfString:@"/"
                                                                 withString:@", "];
        
        int sct = 0;
        if (![keyword isEqualToString:@""] && keyword != nil) {
            
            NSArray *rangeValue = nil;
            if (!([_searchString isEqualToString:@""] || _searchString == nil)) {
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_searchString
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                NSRange searchedRange = NSMakeRange(0, [keyword length]);
                rangeValue = [regex matchesInString:keyword options:0 range:searchedRange];
            }
                
            if (rangeValue == nil || [rangeValue count] > 0) {
                id swatchKeywordNames = [_keywordNames objectForKey:keyword];
                if (swatchKeywordNames == nil) {
                    swatchKeywordNames = [NSMutableArray array];
                    [_keywordNames setObject:swatchKeywordNames forKey:keyword];
                }
                [swatchKeywordNames addObject:ps];
                sct = (int)[swatchKeywordNames count];
            }
            
        }
    }
    
    NSMutableArray *sortedKeywords = [NSMutableArray arrayWithArray:[_keywordNames allKeys]];
    [sortedKeywords sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _letters = [[NSMutableDictionary alloc] init];
    
    NSString *curr_letter = @"";
    NSMutableArray *keywordPaintSwatches = [[NSMutableArray alloc] init];
    
    
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
            [keywordList addObject:kw];
            [swatchList  addObject:kw];
            
            NSArray *paintSwatches = [_keywordNames objectForKey:kw];
            for (PaintSwatches *ps in paintSwatches) {
                [swatchList addObject:ps];
            }
            [_keywordSwatches setObject:swatchList  forKey:kw];
        }
        [_letterKeywords setObject:swatchList forKey:letter];
    }
    
    _numKeywords = (int)[sortedKeywords count];
    
    [_colorTableView reloadData];
}

- (void)loadColorsData {
    _subjColorsArray      = [[NSMutableArray alloc] init];
    
    for (int i=0; i<=_numSubjColors; i++) {
        NSArray *psArray = [ManagedObjectUtils queryPaintSwatchesBySubjColorId:i context:self.context];
        
        NSMutableArray *paintSwatches = [NSMutableArray arrayWithCapacity:[psArray count]];
        for (PaintSwatches *ps in psArray) {
            [paintSwatches addObject:ps];
        }
        [_subjColorsArray addObject:paintSwatches];
    }
    
    if (_initColors == TRUE) {
        _subjColorsArrayState = [[NSMutableArray alloc] init];
        [self updateColorsState:_isCollapsedAll];
        _initColors = FALSE;
        
    } else {
        [_colorTableView reloadData];
    }
}

- (void)updateColorsState:(BOOL)isCollapsed {
    for (int i=0; i<=_numSubjColors; i++) {

        // Initialized to closed (i.e., show no rows)
        //
        if (_initColors == TRUE) {
            [_subjColorsArrayState addObject:[NSNumber numberWithBool:isCollapsed]];
        } else {
            [_subjColorsArrayState replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:isCollapsed]];
        }
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

    
    if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
        
        if (section == 0) {
            NSString *keywordsListing = [[NSString alloc] initWithFormat:@"Keywords Listing (%i)", _numKeywords];
            [headerView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_LG_TABLE_CELL_HGT)];
            [headerView addSubview:headerLabel];
            [headerLabel setText:keywordsListing];
            [headerLabel setTextAlignment:NSTextAlignmentCenter];
            [letterLabel setFrame:CGRectMake(DEF_X_OFFSET, DEF_TABLE_HDR_HEIGHT, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
        }
        
        [letterLabel setBackgroundColor:DARK_BG_COLOR];
        [letterLabel setTextColor:LIGHT_TEXT_COLOR];
        [letterLabel setFont:TABLE_HEADER_FONT];
        
        [letterLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        [headerView addSubview:letterLabel];
        [letterLabel setText:[_sortedLetters objectAtIndex:section]];
        
    } else if ([_listingType isEqualToString:MIX_TYPE]) {
        NSString *mixAssocsListing = [[NSString alloc] initWithFormat:@"Associations Listing (%i)", _numMixAssocs];
        [headerView addSubview:headerLabel];
        [headerLabel setText:mixAssocsListing];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        NSString *matchAssocsListing = [[NSString alloc] initWithFormat:@"Match Associations Listing (%i)", _numMatchAssocs];
        [headerView addSubview:headerLabel];
        [headerLabel setText:matchAssocsListing];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {

        if (section == 0) {
            [headerLabel setText:@"Subjective Colors Groupings"];
            [headerLabel setTextAlignment: NSTextAlignmentCenter];

            [headerView addSubview:headerLabel];

        } else {
            int index = (int)section - 1;
            NSString *colorName = [_subjColorNames objectAtIndex:index];
            UIColor *backgroundColor = [ColorUtils colorFromHexString:[[_subjColorData objectForKey:colorName] valueForKey:@"hex"]];
            [headerLabel setTextColor:[ColorUtils setBestColorContrast:colorName darkColor:DARK_TEXT_COLOR lightColor:LIGHT_TEXT_COLOR]];
            [headerLabel setBackgroundColor:backgroundColor];
            [headerLabel setText:[_subjColorNames objectAtIndex:index]];
            
            UIBarButtonItem *arrowDownButtonItem = [[UIBarButtonItem alloc] initWithImage:_downArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(expandOrCollapseSection:)];
            
            UIBarButtonItem *arrowUpButtonItem = [[UIBarButtonItem alloc] initWithImage:_upArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(expandOrCollapseSection:)];
            
            UIToolbar* scrollViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_LG_TABLE_HDR_HGT)];
            [scrollViewToolbar setBarStyle:UIBarStyleBlackTranslucent];
            
            UIBarButtonItem *headerButtonLabel = [[UIBarButtonItem alloc] initWithTitle:[_subjColorNames objectAtIndex:index] style:UIBarButtonItemStylePlain target:nil action:nil];
            
            scrollViewToolbar.items = @[
                                        headerButtonLabel,
                                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                        ];
            
            NSMutableArray *newItems = [scrollViewToolbar.items mutableCopy];
            
            UIBarButtonItem *arrowButtonItem;
            
            BOOL isCollapsed = [[_subjColorsArrayState objectAtIndex:index] boolValue];
            if (isCollapsed == TRUE) {
                arrowButtonItem = arrowDownButtonItem;
            } else {
                arrowButtonItem = arrowUpButtonItem;
            }
            [newItems addObject:arrowButtonItem];
            int buttonTag = (int)section;
            [arrowButtonItem setTag:buttonTag];
            
            scrollViewToolbar.items = newItems;
            
            [headerView addSubview:scrollViewToolbar];
            
            if ([colorName isEqualToString:@"Black"]) {
                [headerButtonLabel setTintColor:LIGHT_TEXT_COLOR];
                [arrowButtonItem setTintColor:LIGHT_TEXT_COLOR];
                
            } else {
                [headerButtonLabel setTintColor:backgroundColor];
                [arrowButtonItem setTintColor:backgroundColor];
            };
            
            [scrollViewToolbar sizeToFit];

            [ColorUtils setGlaze:headerView];
        }
        
    } else {
        UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_SM_TABLE_CELL_HGT)];
        
        if (section == 0) {
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
    
            [filterToolbar setItems: @[_allButton,_allLabel, flexibleSpace, _refButton, _refLabel, flexibleSpace, _genButton,_genLabel, flexibleSpace]];
    
            CGFloat filterToolbarHgt  = filterToolbar.bounds.size.height;
    
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, filterToolbarHgt, tableView.bounds.size.width, DEF_TABLE_CELL_HEIGHT - filterToolbarHgt)];
    
            [headerView addSubview:filterToolbar];
            [headerView addSubview:paddingView];

            [letterLabel setFrame:CGRectMake(DEF_X_OFFSET, DEF_TABLE_HDR_HEIGHT, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
        }
    
        [letterLabel setBackgroundColor:DARK_BG_COLOR];
        [letterLabel setTextColor:LIGHT_TEXT_COLOR];
        [letterLabel setFont:TABLE_HEADER_FONT];
        
        [letterLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        [letterLabel setText:[_sortedLettersDefaults objectAtIndex:section]];
        
        [headerView addSubview:letterLabel];
    }

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_listingType isEqualToString:KEYWORDS_TYPE] && (section == 0)) {
        return DEF_LG_TABLE_CELL_HGT;
        
    } else if ([_listingType isEqualToString:FULL_LISTING_TYPE] && (section == 0)) {
            return DEF_LG_TABLE_CELL_HGT;

    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        return DEF_LG_TABLE_HDR_HGT;

    } else {
        return DEF_SM_TABLE_CELL_HGT;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //
    if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        return [_sortedLetters count];
        
    } else if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        return [_sortedLettersDefaults count];
    
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        return [_subjColorNames count] + 1;

    } else {
        return [[[self fetchedResultsController] sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    //
    NSInteger objCount;
    if ([_listingType isEqualToString:MIX_TYPE]) {
        objCount = [_mixAssocObjs count];

    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        objCount = [_matchAssocObjs count];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        NSString *sectionTitle = [_sortedLetters objectAtIndex:section];
        objCount = [[_letterKeywords objectForKey:sectionTitle] count];

    } else if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        NSString *letter = [_sortedLettersDefaults objectAtIndex:section];
        objCount = [[_letterDefaults objectForKey:letter] count];
        
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        if (section == 0) {
            objCount = 0;
        } else {
            int index = (int)section - 1;
            BOOL isCollapsed = [[_subjColorsArrayState objectAtIndex:index] boolValue];
            if (isCollapsed == TRUE) {
                objCount = 0;
            } else {
                objCount = [[_subjColorsArray objectAtIndex:index] count];
            }
        }
        
    } else {
        id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
        objCount = [sectionInfo numberOfObjects];
        _numSwatches = (int)objCount;
    }
    return objCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([_listingType isEqualToString:MIX_TYPE]) {
        int index = (int)indexPath.row;
        int ct = (int)[[self.mixColorArray objectAtIndex:index] count];
        if (ct < _minAssocSize) {
            return DEF_NIL_HEADER;
        } else {
            return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
        }
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_listingType isEqualToString:MIX_TYPE]) {
        CustomCollectionTableViewCell *custCell = (CustomCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        if (! custCell) {
            custCell = [[CustomCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
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

        [custCell addLabel:[FieldUtils createLabel:mix_assoc_name xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:custCell.contentView.bounds.size.width height:DEF_LABEL_HEIGHT]];
        [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
        
        NSInteger index = custCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
        return custCell;
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
            CustomCollectionTableViewCell *custCell = (CustomCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
            
            if (! custCell) {
                custCell = [[CustomCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
            }
            
            [custCell setBackgroundColor: DARK_BG_COLOR];
            
            MatchAssociations *matchAssocObj = [_matchAssocObjs objectAtIndex:indexPath.row];
            
            NSString *match_assoc_name = [matchAssocObj name];
            [custCell addLabel:[FieldUtils createLabel:match_assoc_name xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:custCell.contentView.bounds.size.width height:DEF_LABEL_HEIGHT]];
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
        
        if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
    
            NSString *sectionTitle = [_sortedLetters objectAtIndex:indexPath.section];
            id obj = [[_letterKeywords objectForKey:sectionTitle] objectAtIndex:indexPath.row];
            
            if ([obj isKindOfClass:[NSString class]]) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.imageView setImage:nil];
                [cell.textLabel setText:obj];
                [cell.textLabel setFont:TABLE_HEADER_FONT];
                cell.userInteractionEnabled = NO;
        
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell.imageView setImage:[AppColorUtils renderSwatch:obj cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height]];
                [cell.textLabel setText:[(PaintSwatches *)obj name]];
                cell.userInteractionEnabled = YES;
            }
            
        } else if ([_listingType isEqualToString:COLORS_TYPE]) {
            
            int index = (int)indexPath.section - 1;
            PaintSwatches *ps = [[_subjColorsArray objectAtIndex:index] objectAtIndex:indexPath.row];
            
            [cell.imageView setImage:[AppColorUtils renderSwatch:ps cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height]];
            [cell.textLabel setText:[ps valueForKeyPath:@"name"]];
            
        } else {
            NSString *sectionTitle = [_sortedLettersDefaults objectAtIndex:indexPath.section];
            PaintSwatches *swatch = [[_letterDefaults objectForKey:sectionTitle] objectAtIndex:indexPath.row];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.imageView setImage:[AppColorUtils renderSwatch:swatch cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height]];
            [cell.textLabel setText:[swatch name]];
            cell.userInteractionEnabled = YES;
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_listingType isEqualToString:MIX_TYPE]) {
        _selPaintSwatch = [_paintSwatches objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];
        
    } else    if ([_listingType isEqualToString:MATCH_TYPE]) {
        //_selPaintSwatch = [_paintSwatches objectAtIndex:indexPath.row];

    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        NSString *sectionTitle   = [_sortedLetters objectAtIndex:indexPath.section];
        _selPaintSwatch = [[_letterKeywords objectForKey:sectionTitle] objectAtIndex:indexPath.row];

        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];
        
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        int index = (int)indexPath.section - 1;
        _selPaintSwatch = [[_subjColorsArray objectAtIndex:index] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];

    } else {
        NSString *sectionTitle = [_sortedLettersDefaults objectAtIndex:indexPath.section];
        _selPaintSwatch = [[_letterDefaults objectForKey:sectionTitle] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:self];
    }
}

// Keywords index
//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        return _keywordsIndexTitles;
        
    } else if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        return _keywordsIndexTitles;
    
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        return [_sortedLetters indexOfObject:title];

    } else if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        return [_sortedLettersDefaults indexOfObject:title];
    
    } else {
        return 0;
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self stopSpinner];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIBarButton actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - UIBarButton, UIBarButtonItem and UIAlertController Methods


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UIAlertControllers
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (IBAction)showListingOptions:(id)sender {
    [self presentViewController:_listingController animated:YES completion:nil];
}

- (void)updateTable:(NSString *)listingType {
    _listingType = listingType;
    _searchString = nil;
    [_mainSearchBar setText:@""];
    [_searchButton setAction:@selector(search)];
    
    if ([_listingType isEqualToString:MIX_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadMixCollectionViewData];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        [self loadKeywordData];
        
    } else if ([_listingType isEqualToString:COLORS_TYPE]) {
        [_searchButton setImage:_downArrowImage];
        [_searchButton setAction:@selector(expandAllSections)];
        [_searchButton setEnabled:TRUE];
        [self loadColorsData];
        
    } else {
        [_searchButton setImage:_searchImage];
        [_searchButton setEnabled:TRUE];
        _searchString = nil;
        [self loadFullColorsListing];
    }
}

- (IBAction)showPhotoOptions:(id)sender {
    [self presentViewController:_photoSelectionController animated:YES completion:nil];
}

- (void)expandOrCollapseSection:(id)sender {
    _selSubjColorSection = (int)[sender tag] - 1;
    
    BOOL isCollapsed = [[_subjColorsArrayState objectAtIndex:_selSubjColorSection] boolValue];

    // Change state
    //
    if (isCollapsed == TRUE) {
        isCollapsed = FALSE;
    } else {
        isCollapsed = TRUE;
    }
    
    [_subjColorsArrayState replaceObjectAtIndex:_selSubjColorSection withObject:[NSNumber numberWithBool:isCollapsed]];
    
    [_colorTableView reloadData];
}

- (void)expandAllSections {
    _isCollapsedAll = FALSE;
    
    [_searchButton setImage:_upArrowImage];
    [_searchButton setAction:@selector(collapseAllSections)];
    
    [self updateColorsState:_isCollapsedAll];
}

- (void)collapseAllSections {
    
    _isCollapsedAll = TRUE;
    
    [_searchButton setImage:_downArrowImage];
    [_searchButton setAction:@selector(expandAllSections)];
    
    [self updateColorsState:_isCollapsedAll];
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
    
    if ([_listingType isEqualToString:MIX_TYPE]) {
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
    
    if ([_listingType isEqualToString:MIX_TYPE]) {
    
        PaintSwatches *paintSwatch = [[self.mixColorArray objectAtIndex:index] objectAtIndex:indexPath.row];

        swatchImage = [AppColorUtils renderSwatch:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];


    // Match
    //
    } else {
        PaintSwatches *paintSwatch = [[self.matchColorArray  objectAtIndex:index] objectAtIndex:indexPath.row];
        TapArea *tapArea = paintSwatch.tap_area;
        swatchImage = [AppColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
        swatchImage = [ColorUtils drawTapAreaLabel:swatchImage count:[tapArea.tap_order intValue] attrs:nil inset:DEF_RECT_INSET];
    }
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:swatchImage];
    
    [swatchImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    [swatchImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
    [swatchImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    [swatchImageView setContentMode:UIViewContentModeScaleAspectFill];
    [swatchImageView setClipsToBounds:YES];
    [swatchImageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
    
    cell.backgroundView = swatchImageView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int)collectionView.tag;

    [self setCollectViewSelRow:index];
    
    if ([_listingType isEqualToString:MIX_TYPE]) {
        PaintSwatches *paintSwatch = [[self.mixColorArray  objectAtIndex:index] objectAtIndex:indexPath.row];
        
        // Doesn't matter which one
        //
        MixAssocSwatch *mixAssocSwatch = [[paintSwatch.mix_assoc_swatch allObjects] objectAtIndex:0];

        _mixAssociation  = mixAssocSwatch.mix_association;
        _associationImage = [UIImage imageWithData:_mixAssociation.image_url];
        
        [self performSegueWithIdentifier:@"VCToAssocSegue" sender:self];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
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
// SearchBar Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - SearchBar and Filter Methods

- (void)search {
    [self.navigationItem setTitleView:_titleView];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:nil];
    
    [_mainSearchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchString = searchText;
    
    if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        [self loadFullColorsListing];

    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        [self loadKeywordData];

    } else {
        [self loadMixCollectionViewData];
    }
}

// Need index of items that have been checked
//
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        [self loadFullColorsListing];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        [self loadKeywordData];

    } else {
        [self loadMixCollectionViewData];
    }
    
    [_mainSearchBar resignFirstResponder];
    [self restoreNavItems];
}

- (void)pressCancel {
    [self restoreNavItems];
    
    _searchString = nil;
    if ([_listingType isEqualToString:FULL_LISTING_TYPE]) {
        [self loadFullColorsListing];
        
    } else if ([_listingType isEqualToString:MATCH_TYPE]) {
        [self loadMatchCollectionViewData];
        
    } else if ([_listingType isEqualToString:KEYWORDS_TYPE]) {
        [self loadKeywordData];

    } else {
        [self loadMixCollectionViewData];
    }
    [_mainSearchBar setText:@""];
}

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
    [_mainSearchBar setFrame:CGRectMake(xOffset, yPoint, xPoint - DEF_NAVBAR_X_OFFSET, buttonSize.height)];
}

- (void)showAllColors {
    _showAll     = TRUE;
    _showRefOnly = FALSE;
    _showGenOnly = FALSE;
    [_allButton setImage:_checkboxSquareImage];
    [_refButton setImage:_emptySquareImage];
    [_genButton setImage:_emptySquareImage];
    
    [self loadFullColorsListing];
}

- (void)filterByReference {
    _showRefOnly = TRUE;
    _showAll     = FALSE;
    _showGenOnly = FALSE;
    [_refButton setImage:_checkboxSquareImage];
    [_allButton setImage:_emptySquareImage];
    [_genButton setImage:_emptySquareImage];

    [self loadFullColorsListing];
}

- (void)filterByGenerics {
    _showGenOnly = TRUE;
    _showAll     = FALSE;
    _showRefOnly = FALSE;
    [_genButton setImage:_checkboxSquareImage];
    [_allButton setImage:_emptySquareImage];
    [_refButton setImage:_emptySquareImage];
    
    [self loadFullColorsListing];
}

- (void)restoreNavItems {
    [self.navigationItem setTitleView:nil];
    [self.navigationItem setLeftBarButtonItem:_imageLibButton];
    [self.navigationItem setRightBarButtonItem:_searchButton];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NSFetchedResultsController Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - NSFetchedResultsController Methods

- (void)initPaintSwatchFetchedResultsController {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PaintSwatch"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    // Skip match assoc types, and search if requested
    //
    if ((_searchString == nil) || [_searchString isEqualToString:@""]) {
        if (_showRefOnly == TRUE) {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id == %i", _refTypeId]];
        
        } else if (_showGenOnly == TRUE) {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id == %i", _genTypeId]];
            
        } else {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id != %i", _matchAssocId]];
        }
    } else {
        NSString *regexSearchString = [[NSString alloc] initWithFormat:@"%@*", _searchString];
        if (_showRefOnly == TRUE) {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id == %i and name like[c] %@", _refTypeId, regexSearchString]];
            
        } else if (_showGenOnly == TRUE) {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id == %i and name like[c] %@", _genTypeId, regexSearchString]];
            
        } else {
            [request setPredicate: [NSPredicate predicateWithFormat:@"type_id != %i and name like[c] %@", _matchAssocId, regexSearchString]];
        }
    }
    
    [request setSortDescriptors:@[nameSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    if (error != nil) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    [self.colorTableView reloadData];
}

- (void)initializeKeywordResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SwatchKeyword"];
    
    NSSortDescriptor *kwSort = [NSSortDescriptor sortDescriptorWithKey:@"keyword.name" ascending:YES];
    
    [request setSortDescriptors:@[kwSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil]];
    
    
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;

    [[self fetchedResultsController] performFetch:&error];
    if (error != nil) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Reload, Segue, and Unwind Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Reload, Segue, and Unwind Methods

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
        [imageViewController setViewType:MATCH_TYPE];
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

- (void) registerContextDidSaveNotificationForManagedObjectContext:(NSManagedObjectContext*) moc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(mergeChanges:)
               name:NSManagedObjectContextDidSaveNotification
             object:moc];
}

- (void)mergeChanges:(NSNotification *)notification {
    // Merge changes into the main context on the main thread
    [self.context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];
}

@end
