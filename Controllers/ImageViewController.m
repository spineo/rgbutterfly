//
//  ImageViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 3/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "ImageViewController.h"
#import "SwatchDetailTableViewController.h"
#import "GlobalSettings.h"
#import "AppDelegate.h"
#import "AppColorUtils.h"
#import "ColorUtils.h"
#import "FieldUtils.h"
#import "AssocTableViewController.h"
#import "MatchTableViewController.h"
#import "MainViewController.h"
#import "BarButtonUtils.h"
#import "CustomCollectionTableViewCell.h"
#import "MatchAlgorithms.h"
#import "PaintSwatchesDiff.h"
#import "AlertUtils.h"
#import "ManagedObjectUtils.h"
#import "GenericUtils.h"
#import "SettingsTableViewController.h"

// NSManagedObject
//
#import "PaintSwatches.h"
#import "TapArea.h"
#import "TapAreaSwatch.h"
#import "MixAssocSwatch.h"
#import "Keyword.h"
#import "TapAreaKeyword.h"

@interface ImageViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIBarButtonItem *scrollViewUp, *scrollViewDown;

@property (nonatomic) int shapeLength, currTapSection, currSelectedSection, maxMatchNum, dbSwatchesCount, paintSwatchCount;
@property (nonatomic, strong) UIImage *cgiImage, *upArrowImage, *downArrowImage, *referenceTappedImage;
@property (nonatomic, strong) NSMutableArray *dbPaintSwatches, *compPaintSwatches, *collectionMatchArray, *tapNumberArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSString *assocName, *matchKeyw, *matchDesc;

@property (nonatomic, strong) UIAlertController *typeAlertController, *matchEditAlertController, *assocEditAlertController, *deleteTapsAlertController, *updateAlertController;
@property (nonatomic, strong) UIAlertAction *matchSave, *assocSave, *matchView, *associateMixes, *alertCancel, *matchAssocFieldsView, *matchAssocFieldsCancel, *matchAssocFieldsSave, *deleteTapsYes, *deleteTapsCancel;

@property (nonatomic, strong) NSString *shapeGeom, *rectLabel, *circleLabel;

@property (nonatomic) int tapAreaSeen, matchAlgIndex, maxRowLimit, imageViewSize;

@property (nonatomic) CGFloat headerViewYOffset, headerViewHeight, hue, sat, bri, alpha, borderThreshold;

@property (nonatomic) CGSize defTableViewSize;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint touchPoint, dragStartPoint, dragChangePoint, dragEndPoint;

@property (nonatomic, strong) NSDate *now;
@property (nonatomic) CGFloat pressStartTime;

// Datamodel related
//
@property (nonatomic, strong) PaintSwatches *swatchObj;
@property (nonatomic, strong) TapArea *tapArea;
@property (nonatomic, strong) TapAreaSwatch *tapAreaSwatch;
@property (nonatomic) int matchAssocId;

@property (nonatomic) BOOL saveFlag, imageInteractAlert, tapCollectAlert, isRGB, tapAreasChanged, matchNumChanged, dragAreaEnabled, firstTap;
@property (nonatomic, strong) NSString *reuseCellIdentifier;
@property (nonatomic, strong) NSMutableArray *matchAlgorithms;

@property (nonatomic, strong) UIBarButtonItem *matchButton, *assocButton, *upArrowItem, *downArrowItem;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity, *matchAssocEntity, *tapAreaEntity, *tapAreaSwatchEntity, *keywordEntity, *matchAssocKwEntity, *mixAssocEntity, *mixAssocSwatchEntity;

@end

@implementation ImageViewController

// Action Type Button Index (this button gets replaced in the Toolbar list)
//
int ACTION_TYPE_INDEX = 3;

// Set up the tags
//
// Defined programmatically
//
int TAPS_ALERT_TAG   = 11;
int MATCH_NAME_TAG   = 15;
int MATCH_KEYW_TAG   = 16;
int MATCH_DESC_TAG   = 17;

// Image/Table View Expansion
//
// 0 - Full table view
// 1 - Split view (default)
// 2 - Full image view
//
int TABLE_VIEW = 0;
int SPLIT_VIEW = 1;
int IMAGE_VIEW = 2;

// Tableview
//
int HEADER_TABLEVIEW_SECTION  = 0;
int COLLECT_TABLEVIEW_SECTION = 1;
int MAX_TABLEVIEW_SECTIONS    = 2;
int MAX_COLLECTVIEW_SECTIONS  = 1;
NSString *HDR_TABLEVIEW_TITLE = @"Match Method and Count";


// Pinch Image
//
CGFloat MAX_PINCH_IMAGE_SCALE  = 2.0;
CGFloat MIN_PINCH_IMAGE_SCALE  = 0.75;
CGFloat PINCH_RECOGNIZER_SCALE = 1.0;

// Tap Area
//
CGFloat TAP_AREA_LABEL_INSET    = 2.0;
CGFloat TAP_AREA_BORDER_WIDTH   = 2.0;
NSString *TAP_AREA_LIGHT_STROKE = @"white";

// Tableview Constants
//
CGFloat TABLEVIEW_BOTTOM_OFFSET = 100.0;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context     = [self.appDelegate managedObjectContext];
    
    // Initialize the PaintSwatch entity
    //
    _paintSwatchEntity    = [NSEntityDescription entityForName:@"PaintSwatch"       inManagedObjectContext:self.context];
    _matchAssocEntity     = [NSEntityDescription entityForName:@"MatchAssociation"  inManagedObjectContext:self.context];
    _tapAreaEntity        = [NSEntityDescription entityForName:@"TapArea"           inManagedObjectContext:self.context];
    _tapAreaSwatchEntity  = [NSEntityDescription entityForName:@"TapAreaSwatch"     inManagedObjectContext:self.context];
    _keywordEntity        = [NSEntityDescription entityForName:@"Keyword"           inManagedObjectContext:self.context];
    _matchAssocKwEntity   = [NSEntityDescription entityForName:@"MatchAssocKeyword" inManagedObjectContext:self.context];
    _mixAssocEntity       = [NSEntityDescription entityForName:@"MixAssociation"    inManagedObjectContext:self.context];
    _mixAssocSwatchEntity = [NSEntityDescription entityForName:@"MixAssocSwatch"    inManagedObjectContext:self.context];

    PaintSwatchType *matchSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:self.context];
    _matchAssocId = [[matchSwatchType order] intValue];
    
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:VIEW_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:VIEW_BTN_TAG width:HIDE_BUTTON_WIDTH];
    
    // For this release at least ensure that these buttons don't show
    //
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:DECR_TAP_BTN_TAG];
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:INCR_TAP_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:DECR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:INCR_TAP_BTN_TAG width:HIDE_BUTTON_WIDTH];
    
    // Keep track of the PaintSwatches count
    //
    _paintSwatchCount = 0;
    
    // Keep track of any changes to the TapAreas and MatchNum
    //
    _tapAreasChanged  = FALSE;
    _matchNumChanged  = FALSE;

    // First tap?
    //
    [self setFirstTap:TRUE];


    // Existing MatchAssociation
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _maxMatchNum = (int)[_userDefaults integerForKey:MATCH_NUM_KEY];
    if (! _maxMatchNum) {
        _maxMatchNum = DEF_MATCH_NUM;
    }
    [_userDefaults setInteger:_maxMatchNum forKey:MATCH_NUM_KEY];
    [_userDefaults synchronize];
    
    // Alerts
    //
    // Image Interaction
    //
    _imageInteractAlert = [_userDefaults boolForKey:IMAGE_INTERACT_KEY];
    if (_imageInteractAlert == TRUE && _newImage == TRUE) {
        UIAlertController *alert = [AlertUtils createNoShowAlert:@"Image Interaction" message:INTERACT_INSTRUCTIONS key:IMAGE_INTERACT_KEY];
    
        [self presentViewController:alert animated:YES completion:nil];
    }

    _defTableViewSize    = _imageTableView.bounds.size;

    // Used in sortByClosestMatch
    //
    _tapNumberArray = [[NSMutableArray alloc] init];
    

    _imageViewSize = SPLIT_VIEW;


    if (_viewType == nil) {
        _viewType           = MATCH_TYPE;
    }
    
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:VIEW_BTN_TAG];
    
    // Match algorithms
    //
    _matchAlgorithms = [ManagedObjectUtils fetchDictNames:@"MatchAlgorithm" context:self.context];
    _matchAlgIndex = 0;
    
    // Tableview defaults
    //
    _headerViewYOffset = DEF_TBL_HDR_Y_OFFSET;
    _headerViewHeight  = DEF_TABLE_HDR_HEIGHT;

    // Initial CoreData state
    //
    [self setSaveFlag:FALSE];


    // Labels
    //
    [self setRectLabel:SHAPE_RECT_VALUE];
    [self setCircleLabel:SHAPE_CIRCLE_VALUE];

    
    // Add the selected image
    //
    [_imageView setImage:_selectedImage];
    [_imageView setUserInteractionEnabled:YES];
    [_imageView setContentMode:UIViewContentModeScaleToFill];
    [_imageScrollView setScrollEnabled:YES];
    [_imageScrollView setClipsToBounds:YES];
    [_imageScrollView setContentSize:_selectedImage.size];
    [_imageScrollView setDelegate:self];

    
    // Initialize a tap gesture recognizer for selected image regions
    // and specify that the gesture must be a single tap
    //
    _tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(respondToTap:)];
    [_tapRecognizer setNumberOfTapsRequired:DEF_NUM_TAPS];
    [_imageView addGestureRecognizer:_tapRecognizer];

    
    // Initialize a pinch gesture recognizer for zooming in/out of the image
    //
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                        initWithTarget:self action:@selector(respondToPinch:)];
    [_imageView addGestureRecognizer:_pinchRecognizer];

    
    // Threshold brightness value under which a white border is drawn around the RGB image view
    // (default border is black)
    //
    [self setBorderThreshold:DEF_BORDER_THRESHOLD];
    
    
    // Long press recognizer (commented out, use button instead)
    //
//    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [_longPressRecognizer setMinimumPressDuration:MIN_PRESS_DUR];
//    [_longPressRecognizer setAllowableMovement:ALLOWABLE_MOVE];
//    [_imageView addGestureRecognizer:_longPressRecognizer];
    
    // Pan gesture recognizer
    //
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTapArea:)];
    //[_imageView addGestureRecognizer:_panGestureRecognizer];
    _dragAreaEnabled = FALSE;

    
    // Hide the "arrow" buttons by default
    //
    if (_matchAssociation != nil) {
        [self matchButtonsHide];
        _assocName = [_matchAssociation name];
    }

    // Clear taps Alert Controller
    //
    _deleteTapsAlertController = [UIAlertController alertControllerWithTitle:@"Delete Tapped Areas"
                                                                     message:@"Are you sure you want to delete this association?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *deleteTapsAlertController_ = _deleteTapsAlertController;
    
    _deleteTapsYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        [self.context rollback];
        
        if ([_viewType isEqualToString:MATCH_TYPE]) {
            [self deleteMatchAssoc];
            [self matchButtonsHide];
        } else {
            [self deleteMixAssoc];
            [self viewButtonHide];
        }
        [self editButtonDisable];
    }];
    
    _deleteTapsCancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [deleteTapsAlertController_ dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [deleteTapsAlertController_ addAction:_deleteTapsCancel];
    [deleteTapsAlertController_ addAction:_deleteTapsYes];

    
    // Match Edit Button Alert Controller
    //
    _matchEditAlertController = [UIAlertController alertControllerWithTitle:@"Match Association Edit"
                                                             message:@"Please select operation"
                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *matchUpdate = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault                     handler:^(UIAlertAction * action) {
        [self presentViewController:_updateAlertController animated:YES completion:nil];
    }];
    
    _matchSave = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (_matchAssociation != nil) {
            _assocName = [_matchAssociation name];
            if ([_assocName isEqualToString:@""] || _assocName == nil) {
                [self presentViewController:_updateAlertController animated:YES completion:nil];
                
            } else {
                [self saveMatchAssoc];
            }
            
        } else {
            [self presentViewController:_updateAlertController animated:YES completion:nil];
            
        }
    }];
    
    UIAlertAction *matchDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentViewController:_deleteTapsAlertController animated:YES completion:nil];
    }];

    
    UIAlertAction *matchCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_matchEditAlertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [_matchEditAlertController addAction:matchUpdate];
    [_matchEditAlertController addAction:_matchSave];
    [_matchEditAlertController addAction:matchDelete];
    [_matchEditAlertController addAction:matchCancel];
    
    [_matchSave setEnabled:FALSE];
    

    
    // Match Update Edit button Alert Controller
    //
    _updateAlertController = [UIAlertController alertControllerWithTitle:@"Match Association"
                                                      message:@"Enter/Update Match Name, Keyword(s), and/or Comments:"
                                               preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *updateAlertController_ = _updateAlertController;
    
    [updateAlertController_ addTextFieldWithConfigurationHandler:^(UITextField *matchNameTextField) {
        if (_matchAssociation != nil) {
            [matchNameTextField setText:[_matchAssociation name]];
        } else {
            [matchNameTextField setPlaceholder: NSLocalizedString(@"Match name.", nil)];
        }
        [matchNameTextField setTag:MATCH_NAME_TAG];
        [matchNameTextField setClearButtonMode: UITextFieldViewModeWhileEditing];
        [matchNameTextField setDelegate:self];
    }];
    
    [updateAlertController_ addTextFieldWithConfigurationHandler:^(UITextField *matchKeywTextField) {
        if (_matchAssociation != nil) {
            NSSet *matchAssocKeywords = [_matchAssociation match_assoc_keyword];
            NSMutableArray *keywords = [[NSMutableArray alloc] init];
            for (MatchAssocKeyword *match_assoc_keyword in matchAssocKeywords) {
                Keyword *keyword = [match_assoc_keyword keyword];
                [keywords addObject:keyword.name];
            }
            if ([keywords count] > 0) {
                [matchKeywTextField setText:[keywords componentsJoinedByString:KEYW_DISP_SEPARATOR]];
            } else {
                [matchKeywTextField setPlaceholder:NSLocalizedString(@"Semicolon-separated keywords.", nil)];
            }
        } else {
            [matchKeywTextField setPlaceholder:NSLocalizedString(@"Semicolon-separated keywords.", nil)];
        }
        [matchKeywTextField setTag:MATCH_KEYW_TAG];
        [matchKeywTextField setClearButtonMode: UITextFieldViewModeWhileEditing];
        [matchKeywTextField setDelegate: self];
    }];

    [updateAlertController_ addTextFieldWithConfigurationHandler:^(UITextField *matchDescTextField) {
        if ((_matchAssociation != nil) && !([[_matchAssociation desc] isEqualToString:@""] || ([_matchAssociation desc] == nil))) {
            [matchDescTextField setText:[_matchAssociation desc]];
        } else {
            [matchDescTextField setPlaceholder: NSLocalizedString(@"Match Comments.", nil)];
        }
        [matchDescTextField setTag:MATCH_DESC_TAG];
        [matchDescTextField setClearButtonMode: UITextFieldViewModeWhileEditing];
        [matchDescTextField setDelegate: self];
    }];

    _matchAssocFieldsSave = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateMatchAssoc];
    }];
    
    _matchAssocFieldsCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [updateAlertController_ dismissViewControllerAnimated:YES completion:nil];
    }];

    [updateAlertController_ addAction:_matchAssocFieldsSave];
    [updateAlertController_ addAction:_matchAssocFieldsCancel];


    // Assoc Edit Button Alert Controller
    //
    _assocEditAlertController = [UIAlertController alertControllerWithTitle:@"Association Edit"
                                                                    message:@"Please select operation"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    _assocSave = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self saveMixAssoc];
    }];
    
    UIAlertAction *assocDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentViewController:_deleteTapsAlertController animated:YES completion:nil];
    }];
    
    UIAlertAction *assocCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_assocEditAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_assocEditAlertController addAction:_assocSave];
    [_assocEditAlertController addAction:assocDelete];
    [_assocEditAlertController addAction:assocCancel];
    
    [_assocSave setEnabled:FALSE];

    
    // Navigation Item Title
    //
    [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:DEF_IMAGE_NAME];
    [[self.navigationItem.titleView.subviews objectAtIndex:0] setColor:LIGHT_YELLOW_COLOR];
    
    
    // Type Alert Controller
    //
    _typeAlertController = [UIAlertController alertControllerWithTitle:@"Action Types"
                                                                  message:@"Please select from the match actions below:"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    _matchView   = [UIAlertAction actionWithTitle:@"Match View (default)" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                _viewType = MATCH_TYPE;
                                                
                                                _matchButton = [[UIBarButtonItem alloc] initWithTitle:MATCH_TYPE
                                                                style: UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(selectMatchAction)];
                                                
                                                [_matchButton setTintColor:LIGHT_TEXT_COLOR];
                                                [_matchButton setTag:MATCH_BTN_TAG];
                                                [_matchButton setWidth:_matchButton.title.length];

                                                NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
                                                [items replaceObjectAtIndex:ACTION_TYPE_INDEX withObject:_matchButton];
                                                [self setToolbarItems:items];

                                                
                                                // Hide buttons (until at least one area tapped)
                                                //
                                                [self viewButtonHide];
                                                [self matchButtonsHide];
                                                [self editButtonDisable];
                                                
                                                [self resetViews];
                                            }];
    
    _associateMixes = [UIAlertAction actionWithTitle:@"Associations" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                _viewType = ASSOC_TYPE;

                                                _assocButton = [[UIBarButtonItem alloc] initWithTitle:ASSOC_TYPE
                                                                style: UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(selectAssocAction)];

                                                [_assocButton setTintColor:LIGHT_TEXT_COLOR];
                                                [_assocButton setTag:ASSOC_BTN_TAG];
                                                [_assocButton setWidth:_assocButton.title.length];

                                                
                                                [self removeUpArrow];
                                                
                                                NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
                                                [items replaceObjectAtIndex:ACTION_TYPE_INDEX withObject:_assocButton];
                                                [self setToolbarItems:items];

                                                
                                                // Hide buttons (until at least one area tapped)
                                                //
                                                [self viewButtonHide];
                                                [self matchButtonsHide];
                                                [self editButtonDisable];
                                                
                                                [self resetViews];
                                            }];
    
    _alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_typeAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_typeAlertController addAction:_matchView];
    [_typeAlertController addAction:_associateMixes];
    [_typeAlertController addAction:_alertCancel];
    

    // List of coordinates associated with tapped regions (i.e., GCPoint)
    // Hide this controller if the source is the MainViewController (as 'match' is the only valid context)
    //
    if ([_sourceViewContext isEqualToString:@"CollectionViewController"]) {
        _currTapSection = (int)[_paintSwatches count];
        [self matchButtonHide];
        if ([_viewType isEqualToString:MATCH_TYPE]) {
            [self matchButtonsShow];
        }

    } else {
        _paintSwatches = [[NSMutableArray alloc] init];
    }
    
    // TableView
    //
    _reuseCellIdentifier = @"ImageTableViewCell";


    [_imageTableView setDelegate:self];
    [_imageTableView setDataSource:self];

    // Shrink and expand image shown in the tableView header (for UIImageScrollView hide/show)
    //
    _upArrowImage = [[UIImage imageNamed:ARROW_UP_IMAGE_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _downArrowImage = [[UIImage imageNamed:ARROW_DOWN_IMAGE_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    // Initial state until tapped areas are added
    //
    //[_imageTableView setHidden:YES];
    
    _upArrowItem  = [[UIBarButtonItem alloc] initWithImage:_upArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(scrollViewDecrease)];
    _downArrowItem  = [[UIBarButtonItem alloc] initWithImage:_downArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(scrollViewIncrease)];
    
    _scrollViewUp = [[UIBarButtonItem alloc] initWithImage:_upArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(scrollViewDecrease)];
    [_scrollViewUp setTintColor:LIGHT_TEXT_COLOR];
    
    _scrollViewDown = [[UIBarButtonItem alloc] initWithImage:_downArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(scrollViewIncrease)];
    [_scrollViewDown setTintColor:LIGHT_TEXT_COLOR];
    
    [self resizeViews];
    
    // RGB settings?
    //
    _isRGB = [[NSUserDefaults standardUserDefaults] boolForKey:RGB_DISPLAY_KEY];

    // Notification center
    //
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeViews) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    // All Features?
    //
    if (ALL_FEATURES == 0)
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:MATCH_BTN_TAG isEnabled:FALSE];
};

- (void)viewWillAppear:(BOOL)willAppear {

    // Load the paint swatches
    //
    _dbPaintSwatches = [ManagedObjectUtils filterMatchPaintSwatches:self.context userDefaults:_userDefaults];
    _dbSwatchesCount = (int)[_dbPaintSwatches count];
    _maxRowLimit = (_dbSwatchesCount > _maxMatchNum) ? _maxMatchNum : _dbSwatchesCount;
}

- (void)viewDidAppear:(BOOL)didAppear {
    
    // Initialize from NSUserDefaults (or GlobalSettings)
    //
    _maxMatchNum = (int)[_userDefaults integerForKey:MATCH_NUM_KEY];
    if (! _maxMatchNum) {
        _maxMatchNum = DEF_MATCH_NUM;
    }
    [_userDefaults setInteger:_maxMatchNum forKey:MATCH_NUM_KEY];
    
    [self setShapeLength:[_userDefaults floatForKey:TAP_AREA_SIZE_KEY]];
    if (! _shapeLength) {
        [self setShapeLength:TAP_AREA_LENGTH];
    }
    [_userDefaults setFloat:_shapeLength forKey:TAP_AREA_SIZE_KEY];
    
    [self setShapeGeom:[_userDefaults valueForKey:SHAPE_GEOMETRY_KEY]];
    if (! _shapeGeom) {
        [self setShapeGeom:SHAPE_CIRCLE_VALUE];
    }
    [_userDefaults setValue:_shapeGeom forKey:SHAPE_GEOMETRY_KEY];
    [_userDefaults synchronize];


    // Resize the scroll and table views
    //
    [self resizeViews];

    _titleLabel = [FieldUtils createLabel:DEF_IMAGE_NAME];
    [_titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_titleLabel setFont:TITLE_VIEW_FONT];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel sizeToFit];
    
    // Title View containing the Label (i.e., association name)
    //
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, _titleLabel.bounds.size.width, _titleLabel.bounds.size.height)];
    [_titleView addSubview:_titleLabel];
    self.navigationItem.titleView = _titleView;

    if ([_sourceViewContext isEqualToString:@"CollectionViewController"]) {
        [self setTapAreas];
    }
    
    NSString *assocName;
    if ([_viewType isEqualToString:MATCH_TYPE] && _matchAssociation != nil) {
        assocName = [_matchAssociation name];
        
    } else if ([_viewType isEqualToString:ASSOC_TYPE] && _mixAssociation != nil) {
        assocName = [_mixAssociation name];
    }

    // Update the title
    //
    if (assocName != nil && ! [assocName isEqualToString:@""]) {
        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:assocName];
    }
    
    // Make any changes to tap areas in Settings VC effective immediately
    //
    [self setTapAreas];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Scrolling and Action Selection Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Scrolling and Action Selection Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = _imageView.frame;
    frame.origin.x = DEF_X_OFFSET;
    frame.origin.y = DEF_Y_OFFSET;
    self.imageView.frame = frame;
    
    [self viewWillLayoutSubviews];
}

- (void)selectMatchAction {
    _imageViewSize = SPLIT_VIEW;
    [self.context rollback];
    _currTapSection = 0;
    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

- (void)selectAssocAction {
    [self.context rollback];
    _currTapSection = 0;
    [_imageTableView reloadData];
    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

- (void)matchButtonsShow {
    [self editButtonEnable];
    if (_matchAssociation == nil) {
        [BarButtonUtils setButtonShow:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
        [BarButtonUtils setButtonShow:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
    }
}

- (void)matchButtonsHide {
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:DECR_ALG_BTN_TAG];
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:INCR_ALG_BTN_TAG];
}

- (void)editButtonDisable {
    [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
}

- (void)editButtonEnable {
    [self.navigationItem.rightBarButtonItem setEnabled:TRUE];
}

- (void)viewButtonShow {
    [self editButtonEnable];
    [BarButtonUtils setButtonShow:self.toolbarItems refTag:VIEW_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:VIEW_BTN_TAG width:DEF_BUTTON_WIDTH];
}

- (void)viewButtonHide {
    [self editButtonDisable];
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:VIEW_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:VIEW_BTN_TAG width:HIDE_BUTTON_WIDTH];
}

// When source view controller is 'ViewController' context
//
- (void)matchButtonHide {
    [BarButtonUtils setButtonHide:self.toolbarItems refTag:MATCH_BTN_TAG];
    [BarButtonUtils setButtonWidth:self.toolbarItems refTag:MATCH_BTN_TAG width:HIDE_BUTTON_WIDTH];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// General Purpose Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - General Purpose Methods

- (void)resizeViews {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGFloat width  = [[UIScreen mainScreen] bounds].size.width;
    
    _imageScrollView.translatesAutoresizingMaskIntoConstraints = YES;

    if ([_viewType isEqualToString:MATCH_TYPE]) {
        [_matchView setEnabled:FALSE];
        [_associateMixes setEnabled:TRUE];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        if (_imageViewSize == TABLE_VIEW) {
            [_imageScrollView setHidden:YES];
            [_imageTableView setHidden:NO];
            
            [_imageScrollView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_NIL_WIDTH, DEF_NIL_HEIGHT)];
            [_imageTableView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, height - TABLEVIEW_BOTTOM_OFFSET)];
            
            [self matchButtonsShow];
            
            [_scrollViewUp setEnabled:NO];
            [_scrollViewDown setEnabled:YES];
            
            [self removeUpArrow];
            
        } else if (_imageViewSize == SPLIT_VIEW) {
            [_imageScrollView setHidden:NO];
            [_imageTableView setHidden:NO];
            
            [_imageScrollView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, height / DEF_Y_OFFSET_DIVIDER)];
            [_imageTableView setFrame:CGRectMake(DEF_X_OFFSET, height / DEF_Y_OFFSET_DIVIDER, width, (height / DEF_Y_OFFSET_DIVIDER)  - TABLEVIEW_BOTTOM_OFFSET)];
            
            [_imageScrollView setNeedsDisplay];
            [_imageView setNeedsDisplay];
            [self.view setAutoresizingMask:TRUE];
            
            [_scrollViewUp setEnabled:YES];
            [_scrollViewDown setEnabled:YES];
            
            [self removeUpArrow];
        
        // Full-screen image
        //
        } else {
            [_imageScrollView setHidden:NO];
            [_imageTableView setHidden:YES];
            
            [_imageScrollView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, height)];
            [_imageTableView setFrame:CGRectMake(DEF_X_OFFSET, height, DEF_NIL_WIDTH, DEF_NIL_HEIGHT)];
            
            [self matchButtonsHide];
            
            [self removeUpArrow];
            [self addUpArrow];
        }

    // Assoc type
    //
    } else {
        [_matchView setEnabled:TRUE];
        [_associateMixes setEnabled:FALSE];
        [self viewButtonHide];
        
        [_imageTableView setHidden:YES];
        [_imageScrollView setHidden:NO];
        
        [_imageScrollView setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, height)];
        [_imageTableView setFrame:CGRectMake(DEF_X_OFFSET, height, DEF_NIL_WIDTH, DEF_NIL_HEIGHT)];

        [self matchButtonsHide];
        
        if (_currTapSection > 0) {
            [self viewButtonShow];
        }
        
        [self removeUpArrow];
    }
}

- (void)resetViews {
    [self.context rollback];
    
    [self setPaintSwatches:nil];
    [_imageView setImage:_selectedImage];
    
    _currTapSection = 0;
    
    // Disable the view and algorithm buttons
    //
    [self viewButtonHide];
    [self matchButtonsHide];
    
    [self refreshViews];
}

- (void)refreshViews {
    NSArray *swatches = [[NSArray alloc] initWithArray:_paintSwatches];
    
    for (int i=0; i<_currTapSection; i++) {
        [self sortTapSection:[swatches objectAtIndex:i] tapSection:i+1];
    }
    
    [self resizeViews];
}

- (void)scrollViewDecrease {

    _imageScrollView.translatesAutoresizingMaskIntoConstraints = YES;
        
    if (_imageViewSize == IMAGE_VIEW) {
        _imageViewSize = SPLIT_VIEW;

    // Split View
    //
    } else if (_currTapSection > 0) {
        _imageViewSize = TABLE_VIEW;
    }

    
    [self resizeViews];
}

- (void)scrollViewIncrease {
    
    _imageScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    [_imageScrollView setHidden:NO];
        
    if (_imageViewSize == TABLE_VIEW) {
        _imageViewSize = SPLIT_VIEW;
        
    } else if (_imageViewSize == SPLIT_VIEW) {
        _imageViewSize = IMAGE_VIEW;
    }
    
    [self resizeViews];
}

- (void)setAlertButtonStates {
    if ([_viewType isEqualToString:MATCH_TYPE]) {
        
    } else if ([_viewType isEqualToString:MATCH_TYPE]) {
        
    } else {
        [_associateMixes setEnabled:FALSE];
        [self viewButtonHide];
    }
}

- (void)addUpArrow {
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    
    // To the left of the Settings button
    //
    int targetIndex = (int)[toolbarButtons count] - 2;
    [toolbarButtons insertObject:_upArrowItem atIndex:targetIndex];
    [self setToolbarItems:toolbarButtons animated:YES];
}

- (void)removeUpArrow {
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    [toolbarButtons removeObject:_upArrowItem];
    [self setToolbarItems:toolbarButtons animated:YES];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GestureRecognizer Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Gesture Recognizer Methods

- (void)respondToTap:(id)sender {

    _touchPoint = [sender locationInView:_imageView];
    
    _tapAreasChanged = TRUE;

    [self drawTouchShape];
    
    if ([_viewType isEqualToString:MATCH_TYPE]) {
        if (_newImage == TRUE && _firstTap == TRUE) {
            // Tap Collection View
            //
            _tapCollectAlert = [_userDefaults boolForKey:TAP_COLLECT_KEY];
            if (_tapCollectAlert == TRUE) {
                UIAlertController *alert = [AlertUtils createNoShowAlert:@"Tap First Row Element" message:TAP_COLLECT_INSTRUCTIONS key:TAP_COLLECT_KEY];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        _firstTap = FALSE;
        [_matchSave setEnabled:TRUE];
    } else {
        [_assocSave setEnabled:TRUE];
    }
}


- (void)respondToPinch:(UIPinchGestureRecognizer *)recognizer {
    float imageScale = sqrtf(recognizer.view.transform.a * recognizer.view.transform.a +
                             recognizer.view.transform.c * recognizer.view.transform.c);
    if ((recognizer.scale > PINCH_RECOGNIZER_SCALE) && (imageScale >= MAX_PINCH_IMAGE_SCALE)) {
        return;
    }
    if ((recognizer.scale < PINCH_RECOGNIZER_SCALE) && (imageScale <= MIN_PINCH_IMAGE_SCALE)) {
        return;
    }
    [recognizer.view setTransform: CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale)];
    [recognizer setScale:PINCH_RECOGNIZER_SCALE];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    if ([_paintSwatches count] > 0  && gesture.state == UIGestureRecognizerStateEnded) {
        if (_dragAreaEnabled == FALSE) {
            [_imageView addGestureRecognizer:_panGestureRecognizer];
            _dragAreaEnabled = TRUE;
            [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:@"Drag Enabled"];
        } else {
            [_imageView removeGestureRecognizer:_panGestureRecognizer];
            _dragAreaEnabled = FALSE;
            [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:[self getTitle]];
        }
    }
}

- (void)respondToImageViewTap:(id)sender {
    UIAlertController *myAlert = [AlertUtils createOkAlert:@"Image Interaction" message:@""];
    [self presentViewController:myAlert animated:YES completion:nil];
}

- (void)moveTapArea:(UIPanGestureRecognizer *)gesture {

    CGPoint touchPoint = [gesture locationInView:_imageView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _dragStartPoint  = touchPoint;
        _dragChangePoint = _dragStartPoint;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        _dragEndPoint = touchPoint;

        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:@""];
        [self setViewBackgroundColor:_dragEndPoint view:self.navigationItem.titleView];
 
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _dragAreaEnabled = FALSE;
        _dragEndPoint = touchPoint;
        [self dragShape];
        
        [_imageView removeGestureRecognizer:_panGestureRecognizer];
        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:[self getTitle]];
        [self.navigationItem.titleView setBackgroundColor:CLEAR_COLOR];
    }
    
    if ([_viewType isEqualToString:MATCH_TYPE]) {
        [_matchSave setEnabled:TRUE];
    } else {
        [_assocSave setEnabled:TRUE];
    }
}

- (void)drawTouchShape {
    int listCount = (int)[_paintSwatches count];
    
    [self setTapAreaSeen:0];
    
    NSMutableArray *tempPaintSwatches = [[NSMutableArray alloc] initWithArray:_paintSwatches];
    _paintSwatches = [[NSMutableArray alloc] init];
    
    int seen_index = 0;
    
    for (int i=0; i<listCount; i++) {
        PaintSwatches *swatchObj = [tempPaintSwatches objectAtIndex:i];

        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        
        CGFloat xpt = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ypt = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        CGFloat xtpt= _touchPoint.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ytpt= _touchPoint.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);

        if ((abs((int)(xtpt - xpt)) <= _shapeLength) && (abs((int)(ytpt - ypt)) <= _shapeLength)) {
            [self setTapAreaSeen:1];
            seen_index   = i;

            // Remove the PaintSwatch and any existing relations
            //
            [_paintSwatches removeObject:swatchObj];
            [self deleteTapArea:swatchObj];
            _paintSwatchCount--;
            
        } else {
            [_paintSwatches addObject:swatchObj];
        }
    }
    tempPaintSwatches = nil;

    int newCount = (int)[_paintSwatches count];
    
    if (_tapAreaSeen == 0) {
        
        // Keep track of the tap section
        //
        _currTapSection++;
        
        [_imageTableView setHidden:NO];
        [_imageScrollView setHidden:NO];
        
        
        // Instantiate the new PaintSwatch Object
        //
        _swatchObj = [[PaintSwatches alloc] initWithEntity:_paintSwatchEntity insertIntoManagedObjectContext:self.context];


        [_swatchObj setCoord_pt:NSStringFromCGPoint(_touchPoint)];
        _paintSwatchCount++;
        
        // Set the RGB and HSB value
        //
        [self setColorValues:_touchPoint paintSwatch:_swatchObj];

        // Save the thumbnail image
        //
        CGFloat xpt= _touchPoint.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ypt= _touchPoint.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        UIImage *imageThumb = [ColorUtils cropImage:_selectedImage frame:CGRectMake(xpt, ypt, _shapeLength, _shapeLength)];
        [_swatchObj setImage_thumb:[NSData dataWithData:UIImagePNGRepresentation(imageThumb)]];
        
        [_paintSwatches addObject:_swatchObj];
        
        if ([_viewType isEqualToString:MATCH_TYPE]) {
            [self matchButtonsShow];
            
        } else {
            [self viewButtonShow];
        }
        
    } else if (newCount == 0) {
        _currTapSection = 0;
        
        // Disable view and algorithm buttons
        //
        [self viewButtonHide];
        [self matchButtonsHide];
        
        //[_imageTableView setHidden:YES];
    
    } else {

        [_imageTableView setHidden:NO];
        [_imageScrollView setHidden:NO];
        
        _currTapSection--;
        int index = _currTapSection - 1;
        int swatchCount = (int)[_paintSwatches count];

        // Ensure that empty element not retrieved
        //
        while (index >= swatchCount) {
            _paintSwatchCount--;
            _currTapSection--;
            index = _currTapSection - 1;
        }
        
        _swatchObj = [_paintSwatches objectAtIndex:index];
    }
    
    [self setTapAreas];
}

- (BOOL)dragShape {
    int listCount = (int)[_paintSwatches count];
    
    int i=0;
    while (i < listCount) {

        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];
        
        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        
        CGFloat xpt = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ypt = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        CGFloat xtpt= _dragStartPoint.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ytpt= _dragStartPoint.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        if ((abs((int)(xtpt - xpt)) <= _shapeLength) && (abs((int)(ytpt - ypt)) <= _shapeLength)) {
            
            if (_dragAreaEnabled == FALSE && [self existsEndPoint:listCount paintSwatches:_paintSwatches] == TRUE) {
                UIAlertController *myAlert = [AlertUtils createOkAlert:@"Tap Area Overlap" message:@"Please delete first the destination tap area."];
                [self presentViewController:myAlert animated:YES completion:nil];
                
                return FALSE;
            }
            
            [self setTapAreasChanged:TRUE];

            // Instantiate the new PaintSwatch Object
            //
            PaintSwatches *newSwatchObj = [[PaintSwatches alloc] initWithEntity:_paintSwatchEntity insertIntoManagedObjectContext:self.context];
            
            [newSwatchObj setCoord_pt:NSStringFromCGPoint(_dragEndPoint)];

            
            // Set the RGB and HSB valuetf
            //
            [self setColorValues:_dragEndPoint paintSwatch:newSwatchObj];
            
            // Save the thumbnail image
            //
            CGFloat xpt= _dragEndPoint.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
            CGFloat ypt= _dragEndPoint.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
            UIImage *imageThumb = [ColorUtils cropImage:_selectedImage frame:CGRectMake(xpt, ypt, _shapeLength, _shapeLength)];
            [newSwatchObj setImage_thumb:[NSData dataWithData:UIImagePNGRepresentation(imageThumb)]];
            
            [_paintSwatches insertObject:newSwatchObj atIndex:i];
            
            [_paintSwatches removeObjectAtIndex:i+1];
            [self deleteTapArea:swatchObj];
            
            if ([_viewType isEqualToString:MATCH_TYPE]) {
                [self matchButtonsShow];
                
            } else {
                [self viewButtonShow];
            }
        }
        i++;
    }

    [self setTapAreas];
    [_imageTableView reloadData];

    
    return TRUE;
}


- (BOOL)existsEndPoint:(int)count paintSwatches:(NSMutableArray *)paintSwatches {
    
    for (int i=0; i<count; i++) {
        
        PaintSwatches *swatchObj = [paintSwatches objectAtIndex:i];
        
        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        
        CGFloat xpt = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ypt = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        CGFloat xtpt= _dragEndPoint.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ytpt= _dragEndPoint.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        
        if ((abs((int)(xtpt - xpt)) <= _shapeLength) && (abs((int)(ytpt - ypt)) <= _shapeLength)) {
            return TRUE;
        }
    }
    return FALSE;
}


- (void)setTapAreas {
    if ([_viewType isEqualToString:MATCH_TYPE]) {
        NSArray *swatches = [[NSArray alloc] initWithArray:_paintSwatches];
        
        for (int i=0; i<_currTapSection; i++) {
            [self sortTapSection:[swatches objectAtIndex:i] tapSection:i+1];
        }
    }

    [self.imageTableView reloadData];
    [self drawTapAreas];
}

- (void)drawTapArea:(int)index {
    
    UIImage *tempImage = [self imageWithBorderFromImage:_selectedImage rectSize:_selectedImage.size shapeType:_shapeGeom lineColor:TAP_AREA_LIGHT_STROKE];
    
    tempImage = [self drawText:tempImage index:(int)index];
    
    [_imageView setImage:tempImage];
    [_imageView.layer setMasksToBounds:YES];
    [_imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    
    // Set the reference image (used by the detail views)
    //
    _referenceTappedImage = tempImage;
}

- (void)drawTapAreas {

    UIImage *tempImage = [self imageWithBorderFromImage:_selectedImage rectSize:_selectedImage.size shapeType:_shapeGeom lineColor:TAP_AREA_LIGHT_STROKE];
    
    tempImage = [self drawText:tempImage];
    
    [_imageView setImage:tempImage];
    [_imageView.layer setMasksToBounds:YES];
    [_imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    
    // Set the reference image (used by the detail views)
    //
    _referenceTappedImage = tempImage;
}

-(UIImage*)drawText:(UIImage*)image index:(int)i {
    
    UIImage *retImage = image;
        int count = i + 1;
        NSString *countStr = [[NSString alloc] initWithFormat:@"%i", count];
        
        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];
        
        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        CGFloat x, y;
        if ([_shapeGeom isEqualToString:_circleLabel]) {
            x = pt.x - (_shapeLength / DEF_CIRCLE_OFFSET_DIV);
            y = pt.y - (_shapeLength / DEF_CIRCLE_OFFSET_DIV);
        } else {
            x = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER) + TAP_AREA_LABEL_INSET;
            y = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER) + TAP_AREA_LABEL_INSET;
        }
        
        UIGraphicsBeginImageContext(image.size);
        
        [retImage drawInRect:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, image.size.width, image.size.height)];
        CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);
        
        NSDictionary *attr = @{NSForegroundColorAttributeName:LIGHT_TEXT_COLOR, NSFontAttributeName:TAP_AREA_FONT, NSBackgroundColorAttributeName:DARK_BG_COLOR};
        
        [countStr drawInRect:CGRectInset(rect, TAP_AREA_LABEL_INSET, TAP_AREA_LABEL_INSET) withAttributes:attr];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        retImage = newImage;
    
    return retImage;
}

-(UIImage*)drawText:(UIImage*)image {

    UIImage *retImage = image;
    
    int listCount = (int)[_paintSwatches count];
    
    for (int i=0; i<listCount; i++) {
        
        int count = i + 1;
        NSString *countStr = [[NSString alloc] initWithFormat:@"%i", count];
        
        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];

        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        CGFloat x, y;
        if ([_shapeGeom isEqualToString:_circleLabel]) {
            x = pt.x - (_shapeLength / DEF_CIRCLE_OFFSET_DIV);
            y = pt.y - (_shapeLength / DEF_CIRCLE_OFFSET_DIV);
        } else {
            x = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER) + TAP_AREA_LABEL_INSET;
            y = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER) + TAP_AREA_LABEL_INSET;
        }

        UIGraphicsBeginImageContext(image.size);
        
        [retImage drawInRect:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, image.size.width, image.size.height)];
        CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);

        NSDictionary *attr = @{NSForegroundColorAttributeName:LIGHT_TEXT_COLOR, NSFontAttributeName:TAP_AREA_FONT, NSBackgroundColorAttributeName:DARK_BG_COLOR};

        [countStr drawInRect:CGRectInset(rect, TAP_AREA_LABEL_INSET, TAP_AREA_LABEL_INSET) withAttributes:attr];
    
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        retImage = newImage;
    }
    
    return retImage;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// AlertView and Containing Widgets Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - AlertView and Containing Widgets Methods

// Display alert view with textfields when clicking on the 'Edit' button (Match only)
//
- (IBAction)editAlertShow:(id)sender {
    if ([_viewType isEqualToString:MATCH_TYPE]) {
        [self presentViewController:_matchEditAlertController animated:YES completion:nil];
    } else {
        [self presentViewController:_assocEditAlertController animated:YES completion:nil];
    }
}

- (IBAction)showTypeOptions:(id)sender {
    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Image and Color Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Image and Color Methods

- (UIImage*)imageWithBorderFromImage:(UIImage*)image rectSize:(CGSize)size shapeType:(NSString *)type lineColor:(NSString *)color {
    // Begin a graphics context of sufficient size
    //
    UIGraphicsBeginImageContext(size);
    
    
    // draw original image into the context]
    //
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, TAP_AREA_BORDER_WIDTH);
    
    // set stroking color and draw shape
    //
    if ([color isEqualToString:TAP_AREA_LIGHT_STROKE]) {
        [LIGHT_TEXT_COLOR setStroke];
        
    } else {
        [CLEAR_COLOR setStroke];
    }
    
    int width  = _shapeLength;
    int height = _shapeLength;
    
    for (int i=0; i<_paintSwatches.count; i++) {
        
        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];
        
        // Adjust the border color for visibility
        //
        if ([swatchObj.brightness floatValue] < _borderThreshold) {
            [LIGHT_TEXT_COLOR setStroke];
        } else {
            [DARK_TEXT_COLOR setStroke];
        }

        CGPoint pt = CGPointFromString([swatchObj coord_pt]);
        
        CGFloat xpoint = pt.x - (_shapeLength / DEF_X_OFFSET_DIVIDER);
        CGFloat ypoint = pt.y - (_shapeLength / DEF_Y_OFFSET_DIVIDER);
        
        // make shape 5 px from border
        //
        CGRect rect = CGRectMake(xpoint, ypoint, width, height);
        
        // draw rectangle or ellipse
        //
        if ([type isEqualToString:_rectLabel]) {
            CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
            CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
            CGContextMoveToPoint(ctx, minx, midy);
            CGContextAddArcToPoint(ctx, minx, miny, midx, miny, DEF_CORNER_RADIUS);
            CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, DEF_CORNER_RADIUS);
            CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, DEF_CORNER_RADIUS);
            CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, DEF_CORNER_RADIUS);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);

        } else {
            CGContextStrokeEllipseInRect(ctx, rect);
        }
    }
    
    // make image out of bitmap context
    //
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Free the context
    //
    UIGraphicsEndImageContext();
    
    
    return retImage;
}

-(void)setColorValues:(CGPoint)touchPoint paintSwatch:(PaintSwatches *)swatchObj {
    
    _cgiImage = [UIImage imageWithCGImage:[_selectedImage CGImage]];
    
    UIColor *rgbColor = [ColorUtils getPixelColorAtLocation:touchPoint image:_cgiImage];
    
    CGColorRef rgbPixelRef = [rgbColor CGColor];
    
    
    if(CGColorGetNumberOfComponents(rgbPixelRef) == 4) {
        const CGFloat *components = CGColorGetComponents(rgbPixelRef);
        swatchObj.red   = [NSString stringWithFormat:@"%f", components[0] * 255];
        swatchObj.green = [NSString stringWithFormat:@"%f", components[1] * 255];
        swatchObj.blue  = [NSString stringWithFormat:@"%f", components[2] * 255];
    }
    
    [rgbColor getHue:&_hue saturation:&_sat brightness:&_bri alpha:&_alpha];

    swatchObj.hue        = [NSString stringWithFormat:@"%f", _hue];
    swatchObj.saturation = [NSString stringWithFormat:@"%f", _sat];
    swatchObj.brightness = [NSString stringWithFormat:@"%f", _bri];
    swatchObj.alpha      = [NSString stringWithFormat:@"%f", _alpha];
    swatchObj.deg_hue    = [NSNumber numberWithFloat:_hue * 360];
}

-(void)setViewBackgroundColor:(CGPoint)touchPoint view:(UIView *)view {
        
    _cgiImage = [UIImage imageWithCGImage:[_selectedImage CGImage]];
    
    UIColor *rgbColor = [ColorUtils getPixelColorAtLocation:touchPoint image:_cgiImage];
    
    CGColorRef rgbPixelRef = [rgbColor CGColor];
    
    UIColor *backgroundColor;
    if(CGColorGetNumberOfComponents(rgbPixelRef) == 4) {
        const CGFloat *components = CGColorGetComponents(rgbPixelRef);
        backgroundColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0];
    } else {
        backgroundColor = CLEAR_COLOR;
    }
    
    [view setBackgroundColor:backgroundColor];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MAX_TABLEVIEW_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_TABLEVIEW_SECTION) {
        return 1;
    } else {
        return _currTapSection;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (_currTapSection == 0) {
        [tableView setSeparatorColor:DARK_BORDER_COLOR];
    } else {
        [tableView setSeparatorColor:LIGHT_BORDER_COLOR];
    }

    if (indexPath.section == HEADER_TABLEVIEW_SECTION) {
        if (_currTapSection == 0) {
            return DEF_NIL_CELL;
        } else {
            return DEF_TABLE_CELL_HEIGHT;
        }
    } else {
        return DEF_MD_TABLE_CELL_HGT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == COLLECT_TABLEVIEW_SECTION) {
        CustomCollectionTableViewCell *custCell = (CustomCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        if (! custCell) {
            custCell = [[CustomCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
        }
        [custCell setXOffset:custCell.bounds.origin.x + DEF_TABLE_CELL_HEIGHT + DEF_MD_FIELD_PADDING];
        [custCell setBackgroundColor:DARK_BG_COLOR];
        [custCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
        int tapNum = _currTapSection - (int)indexPath.row;
        int tapIndex = tapNum - 1;

        int match_algorithm_id = _matchAlgIndex;
        int swatch_ct          = _maxMatchNum;
        
        TapArea *tapArea;
        
        if (_tapAreasChanged == FALSE) {
            tapArea = [[ManagedObjectUtils queryTapAreas:_matchAssociation.objectID context:self.context] objectAtIndex:tapIndex];
 
        } else {
            int tap_obj_ct = (int)[[[_matchAssociation tap_area] allObjects] count];
            if (tapIndex < tap_obj_ct) {
                tapArea = [[[_matchAssociation tap_area] allObjects] objectAtIndex:tapIndex];
            }
        }
        if (tapArea != nil) {
            match_algorithm_id = [[tapArea match_algorithm_id] intValue];
            swatch_ct = (int)[[[tapArea tap_area_swatch] allObjects] count];
            if (swatch_ct != _maxMatchNum)
                _matchNumChanged = TRUE;
        }

        NSString *match_algorithm_text = [[NSString alloc] initWithFormat:@"Method: %@, Count: %i", [_matchAlgorithms objectAtIndex:match_algorithm_id], _maxMatchNum];
    
        [custCell addLabel:[FieldUtils createLabel:match_algorithm_text xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:custCell.contentView.bounds.size.width height:DEF_LABEL_HEIGHT]];
        
        NSInteger index = custCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        
        PaintSwatches *paintSwatch = [[self.collectionMatchArray objectAtIndex:indexPath.row] objectAtIndex:0];
        
        UIImage *image;
        if (_isRGB == TRUE) {
            image = [AppColorUtils renderRGB:paintSwatch cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TABLE_CELL_HEIGHT];
        } else {
            image = [AppColorUtils renderPaint:paintSwatch.image_thumb cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TABLE_CELL_HEIGHT];
        }
        
        custCell.imageView.image = [ColorUtils drawTapAreaLabel:image count:tapNum attrs:nil inset:DEF_RECT_INSET];

        
        // Tag the first reference image
        //
        [custCell.imageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        [custCell.imageView.layer setCornerRadius:DEF_CORNER_RADIUS];
        [custCell.imageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
        [custCell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        [custCell.imageView setClipsToBounds: YES];
        [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
        return custCell;

    } else {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier];
        
        [cell setBackgroundColor:DARK_BG_COLOR];
        
        NSString *headerTitle = @"";
        if (_currTapSection > 0) {
            headerTitle = HDR_TABLEVIEW_TITLE;
        }
        
        UIToolbar* scrollViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_SM_TBL_HDR_HEIGHT)];
        [scrollViewToolbar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *headerButtonLabel = [[UIBarButtonItem alloc] initWithTitle:headerTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        
        scrollViewToolbar.items = @[
                                    headerButtonLabel,
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    _scrollViewUp,
                                    _scrollViewDown,
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    ];
        
        
        [cell.contentView  addSubview:scrollViewToolbar];
        [scrollViewToolbar sizeToFit];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.imageView setFrame:CGRectMake(2.0, 15.0, cell.imageView.frame.size.width, cell.imageView.frame.size.height)];
}

// Use to switch between RGB and Paint
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isRGB == FALSE) {
        _isRGB = TRUE;
    } else {
        _isRGB = FALSE;
    }
    [_imageTableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Header sections
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return DEF_NIL_HEADER;
    } else {
        return DEF_NIL_HEADER;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width,DEF_SM_TBL_HDR_HEIGHT)];
    
    if (section == HEADER_TABLEVIEW_SECTION) {
        NSString *headerTitle = @"";
        if (_currTapSection > 0) {
            headerTitle = HDR_TABLEVIEW_TITLE;
        }
        
        UIToolbar* scrollViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_SM_TBL_HDR_HEIGHT)];
        [scrollViewToolbar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *headerButtonLabel = [[UIBarButtonItem alloc] initWithTitle:headerTitle style:UIBarButtonItemStylePlain target:nil action:nil];

        scrollViewToolbar.items = @[
                                    headerButtonLabel,
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    _scrollViewUp,
                                    _scrollViewDown,
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    ];

        [headerView addSubview:scrollViewToolbar];
        [scrollViewToolbar sizeToFit];
    }

    return headerView;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// CollectionView and ScrollView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - CollectionView and ScrollView Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return MAX_COLLECTVIEW_SECTIONS;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int index = (int)collectionView.tag;
    
    NSArray *collectionViewArray = [self.collectionMatchArray objectAtIndex:index];
    
    return (int)[collectionViewArray count] - 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    int index = (int)collectionView.tag;
    
    PaintSwatches *paintSwatch = [[self.collectionMatchArray objectAtIndex:index] objectAtIndex:indexPath.row + 1];

    UIImage *swatchImage;
    if (_isRGB == TRUE) {
        swatchImage = [AppColorUtils renderRGB:paintSwatch cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TABLE_CELL_HEIGHT];
    } else {
        swatchImage = [AppColorUtils renderPaint:paintSwatch.image_thumb cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TABLE_CELL_HEIGHT];
    }
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:swatchImage];

    [swatchImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
    [swatchImageView.layer setCornerRadius:DEF_CORNER_RADIUS];
    [swatchImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
    [swatchImageView setContentMode: UIViewContentModeScaleAspectFit];
    [swatchImageView setClipsToBounds: YES];
    [swatchImageView setFrame:CGRectMake(DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING, DEF_Y_OFFSET, DEF_TABLE_CELL_HEIGHT, DEF_TABLE_CELL_HEIGHT)];
    
    cell.backgroundView = swatchImageView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    _currSelectedSection = (int)collectionView.tag;

    
    [self performSegueWithIdentifier:@"MatchTableViewSegue" sender:self];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TextField Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - TextField Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [GenericUtils trimString:textField.text];
    
    if (textField.tag == MATCH_NAME_TAG) {
        _assocName = ((UITextField *)[_updateAlertController.textFields objectAtIndex:0]).text;
        
    } else if (textField.tag == MATCH_KEYW_TAG) {
        _matchKeyw = ((UITextField *)[_updateAlertController.textFields objectAtIndex:1]).text;

    } else if (textField.tag == MATCH_DESC_TAG) {
        _matchDesc = ((UITextField *)[_updateAlertController.textFields objectAtIndex:2]).text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Other Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Other Methods

- (void)sortTapSection:(PaintSwatches *)refObj tapSection:(int)tapSection {
    
    // If MatchAssociation exists (or has already been saved) then get the actual Match Algorithm or manual override
    //
    int matchAlgValue = _matchAlgIndex;
    BOOL maManualOverride = FALSE;
    int tapIndex = tapSection - 1;
    
    // Default
    //
    int maxMatchNum = _maxMatchNum;
    NSArray *tapAreaObjects;
    TapArea *tapArea;
    NSArray *tapAreaSwatches;
    
    if (_matchAssociation != nil) {

        if (_tapAreasChanged == FALSE) {
            tapAreaObjects = [ManagedObjectUtils queryTapAreas:_matchAssociation.objectID context:self.context];
        } else {
            tapAreaObjects = [[_matchAssociation tap_area] allObjects];
        }

        if ([tapAreaObjects count] >= tapSection) {
            tapArea = [tapAreaObjects objectAtIndex:tapIndex];
            
            matchAlgValue = [tapArea.match_algorithm_id intValue];
            maManualOverride = [tapArea.ma_manual_override boolValue];
            
            // Get the existing match count
            //
            tapAreaSwatches = [tapArea.tap_area_swatch allObjects];
            maxMatchNum = _maxMatchNum;
        }
    }
    
    if (maManualOverride == FALSE) {
        _compPaintSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:refObj swatches:_dbPaintSwatches matchAlgorithm:matchAlgValue maxMatchNum:maxMatchNum context:self.context entity:_paintSwatchEntity]];
    } else {
        _compPaintSwatches = [ManagedObjectUtils getManualOverrideSwatches:refObj tapIndex:tapIndex matchAssociation:_matchAssociation context:self.context];
    }
    
//    while ([_compPaintSwatches count] > _maxMatchNum) {
//        [_compPaintSwatches removeLastObject];
//    }

//    while ([_compPaintSwatches count] < _maxMatchNum) {
//        [self addTableRows];
//    }

    while (tapSection < [_tapNumberArray count]) {
        [_tapNumberArray removeLastObject];
    }
    
    if (tapIndex >= 0) {
        [_tapNumberArray setObject:_compPaintSwatches atIndexedSubscript:tapIndex];

        NSArray *tapNumberArrayReverse = [[_tapNumberArray reverseObjectEnumerator] allObjects];
        self.collectionMatchArray = [NSMutableArray arrayWithArray:tapNumberArrayReverse];
    }
    
}

//- (NSMutableArray *)getManualOverrideSwatches:(PaintSwatches *)refObj tapIndex:(int)tapIndex {
//    NSArray *tapAreaObjects = [ManagedObjectUtils queryTapAreas:_matchAssociation.objectID context:self.context];
//    TapArea *tapArea = [tapAreaObjects objectAtIndex:tapIndex];
//    NSArray *tapAreaSwatches = [tapArea.tap_area_swatch allObjects];
//    int maxMatchNum = (int)[tapAreaSwatches count];
//    
//    NSMutableArray *tmpSwatches = [[NSMutableArray alloc] init];
//    [tmpSwatches addObject:refObj];
//    for (int i=0; i<maxMatchNum; i++) {
//        TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
//        PaintSwatches *paintSwatch   = (PaintSwatches *)[tapAreaSwatch paint_swatch];
//        [tmpSwatches addObject:paintSwatch];
//    }
//    
//    return [tmpSwatches mutableCopy];
//}

-(NSString *)getTitle {

    NSString *titleText = DEF_IMAGE_NAME;
    if (_matchAssociation != nil) {
        titleText = [_matchAssociation name];
    } else if (_mixAssociation != nil) {
        titleText = [_mixAssociation name];
    }
    
    return titleText;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BarButton Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - BarButton Methods

- (IBAction)incrMatchAlgorithm:(id)sender {
    
    _matchAlgIndex++;

    if (_matchAlgIndex >= [_matchAlgorithms count]) {
        _matchAlgIndex = 0;
    }
    
    // Re-run the comparison algorithm
    //
    NSArray *swatches = [[NSArray alloc] initWithArray:_paintSwatches];
    
    for (int i=0; i<_currTapSection; i++) {
        [self sortTapSection:[swatches objectAtIndex:i] tapSection:i+1];
    }
    [_imageTableView reloadData];
    [_matchSave setEnabled:TRUE];
}

- (IBAction)decrMatchAlgorithm:(id)sender {
    
    _matchAlgIndex--;
    
    if (_matchAlgIndex < 0) {
        _matchAlgIndex = (int)[_matchAlgorithms count] - 1;
    }
    
    // Re-run the comparison algorithm
    //
    NSArray *swatches = [[NSArray alloc] initWithArray:_paintSwatches];
    
    for (int i=0; i<_currTapSection; i++) {
        [self sortTapSection:[swatches objectAtIndex:i] tapSection:i+1];
    }
    [_imageTableView reloadData];
    [_matchSave setEnabled:TRUE];
}

- (void)removeTableRows {
    if (_maxMatchNum > 1) {
        [_compPaintSwatches removeLastObject];
        _maxMatchNum--;
        
        // Re-run the comparison algorithm
        //
        [self refreshViews];
        
        [_imageTableView reloadData];
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:INCR_TAP_BTN_TAG isEnabled:TRUE];
        [_matchSave setEnabled:TRUE];
    }
    
    if (_maxMatchNum <= 1) {
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:DECR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (void)addTableRows {
    if (_maxMatchNum < _maxRowLimit) {
        _maxMatchNum++;
        
        // Re-run the comparison algorithm
        //
        [self refreshViews];
        
        [_imageTableView reloadData];
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:TRUE];
        [_matchSave setEnabled:TRUE];
        
    } else {
        UIAlertController *myAlert = [AlertUtils rowLimitAlert:_maxRowLimit];
        [self presentViewController:myAlert animated:YES completion:nil];
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Data Model Query/Update Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Data Model Query/Update Methods

- (void)saveMixAssoc {
    NSDate *currDate = [NSDate date];
    
    // Add a new Mix
    //
    if (_mixAssociation == nil) {
        _mixAssociation = [[MixAssociation alloc] initWithEntity:_mixAssocEntity insertIntoManagedObjectContext:self.context];
        
        [_mixAssociation setCreate_date:currDate];
        [_mixAssociation setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
    }
    
    // Applies to both updates and new
    //
    if ([_assocName isEqualToString:@""] || _assocName == nil) {
        _assocName = [[NSString alloc] initWithFormat:@"+Association %@", [GenericUtils getCurrDateString:@"YYYY-MM-dd HH:mm:ss"]];
    }
    
    [_mixAssociation setName:_assocName];
    [_mixAssociation setLast_update:currDate];
    
    
    // First delete any outstanding MixAssocSwatch relations (we will re-create them)
    //
    NSSet *maSwatchSet = [_mixAssociation mix_assoc_swatch];
    if (maSwatchSet != nil) {
        NSArray *maSwatchList = [maSwatchSet allObjects];
        for (MixAssocSwatch *mixAssocSwatch in maSwatchList) {
            PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
            
            [_mixAssociation removeMix_assoc_swatchObject:mixAssocSwatch];
            [paintSwatch removeMix_assoc_swatchObject:mixAssocSwatch];
            [self.context deleteObject:mixAssocSwatch];
        }
    }
    
    
    // Add the MixAssocSwatch relations
    //
    for (int i=0; i<[_paintSwatches count];i++) {
        PaintSwatches *paintSwatch = [_paintSwatches objectAtIndex:i];
        int mix_ct = i + 1;
        
        NSString *name = [paintSwatch name];
        if (name == nil) {
            [paintSwatch setName:[[NSString alloc] initWithFormat:@"Color %i", mix_ct]];
        }
        [paintSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
        
        MixAssocSwatch *mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:_mixAssocSwatchEntity insertIntoManagedObjectContext:self.context];
        [mixAssocSwatch setPaint_swatch:(PaintSwatch *)paintSwatch];
        [mixAssocSwatch setMix_association:_mixAssociation];

        int mix_order = i + 1;
        [mixAssocSwatch setMix_order:[NSNumber numberWithInt:mix_order]];
        [mixAssocSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
        
        [_mixAssociation addMix_assoc_swatchObject:mixAssocSwatch];
        [paintSwatch addMix_assoc_swatchObject:mixAssocSwatch];
    }

    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"Association and relations save" message:@"Error saving"];
        [self presentViewController:myAlert animated:YES completion:nil];
        
    } else {
        NSLog(@"Association and relations save successful");
        
        _tapAreasChanged = FALSE;
        
        // Update the title
        //
        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:_assocName];
        
        // Disable the Match/Assoc toggle (no reason to switch back)
        //
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:ASSOC_BTN_TAG isEnabled:FALSE];
        
        [_assocSave setEnabled:FALSE];
    }
}

- (void)deleteMixAssoc {
    
    if (_mixAssociation != nil) {

        [ManagedObjectUtils deleteMixAssociation:_mixAssociation context:self.context];
        
        // Commit the delete
        //
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            UIAlertController *myAlert = [AlertUtils createOkAlert:@"Association and relations delete" message:@"Error saving"];
            [self presentViewController:myAlert animated:YES completion:nil];
            
        } else {
            NSLog(@"Association and relations delete successful");

            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    _paintSwatches  = [[NSMutableArray alloc] init];
    _currTapSection = 0;
    
    [self drawTapAreas];
    [_imageTableView reloadData];
}

- (BOOL)updateMatchAssoc {
    
    // Run a series of checks first
    //
    if ([_assocName isEqualToString:@""]) {
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"Match Name Missing" message:@"Setting a default value"];
        [self presentViewController:myAlert animated:YES completion:nil];

    } else if ([_assocName length] > MAX_NAME_LEN) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_NAME_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return FALSE;
    }
    
    if ([_matchKeyw length] > MAX_KEYW_LEN) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_KEYW_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return FALSE;
        
    } else if ([_matchDesc length] > MAX_DESC_LEN) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_DESC_LEN];
        [self presentViewController:myAlert animated:YES completion:nil];
        return FALSE;
    }

    NSDate *currDate = [NSDate date];
    
    // Add a new Match
    //
    if (_matchAssociation == nil) {
        _matchAssociation = [[MatchAssociations alloc] initWithEntity:_matchAssocEntity insertIntoManagedObjectContext:self.context];
        
        [_matchAssociation setCreate_date:currDate];
        
        // Save the image as Transformable
        //
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(_selectedImage)];
        [_matchAssociation setImage_url:imageData];
    }

    // Applies to both updates and new
    //
    if ([_assocName isEqualToString:@""] || _assocName == nil) {
        _assocName = [[NSString alloc] initWithFormat:@"+MatchAssoc %@", [GenericUtils getCurrDateString:@"YYYY-MM-dd HH:mm:ss"]];
        ((UITextField *)[_updateAlertController.textFields objectAtIndex:0]).text = _assocName;
    }

    [_matchAssociation setName:_assocName];
    [_matchAssociation setDesc:_matchDesc];
    [_matchAssociation setLast_update:currDate];
    
    // Save keywords
    //
    // Delete all  associations first and then add them back in (the cascade delete rules should
    // automatically delete the MatchAssocKeyword)
    //
    [ManagedObjectUtils deleteMatchAssocKeywords:_matchAssociation context:self.context];
    
    // Add keywords
    //
    NSMutableArray *keywords = [GenericUtils trimStrings:[_matchKeyw componentsSeparatedByString:KEYW_PROC_SEPARATOR]];

    for (NSString *keyword in keywords) {
        if ([keyword isEqualToString:@""]) {
            continue;
        }
        
        Keyword *kwObj = [ManagedObjectUtils queryKeyword:keyword context:self.context];
        if (kwObj == nil) {
            kwObj = [[Keyword alloc] initWithEntity:_keywordEntity insertIntoManagedObjectContext:self.context];
            [kwObj setName:keyword];
        }

        MatchAssocKeyword *matchAssocKwObj = [ManagedObjectUtils queryObjectKeyword:kwObj.objectID objId:_matchAssociation.objectID relationName:@"match_association" entityName:@"MatchAssocKeyword" context:self.context];
        
        if (matchAssocKwObj == nil) {
            matchAssocKwObj = [[MatchAssocKeyword alloc] initWithEntity:_matchAssocKwEntity insertIntoManagedObjectContext:self.context];
            [matchAssocKwObj setKeyword:kwObj];
            [matchAssocKwObj setMatch_association:_matchAssociation];
            
            [_matchAssociation addMatch_assoc_keywordObject:matchAssocKwObj];
            [kwObj addMatch_assoc_keywordObject:matchAssocKwObj];
        }
    }
    [self saveMatchAssoc];
    
    return TRUE;
}

    
- (void)saveMatchAssoc {

    // Add the TapAreas, TapAreaSwatches, and PaintSwatches
    //
    for (int i=0; i<[self.collectionMatchArray count];i++) {
        NSMutableArray *swatches = [self.collectionMatchArray objectAtIndex:i];
        
        PaintSwatches *tapAreaRef = [swatches objectAtIndex:0];
        int tap_order = (int)[self.collectionMatchArray count] - i;
        
        // Based on order
        //
        [tapAreaRef setType_id:[NSNumber numberWithInt:_matchAssocId]];
        [tapAreaRef setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
        
        
        // Check if TapArea already exists
        //
        TapArea *tapArea;
        if (tapAreaRef.tap_area == nil) {
            NSString *tapAreaName = [[NSString alloc] initWithFormat:@"%@ Tap Area Swatch", _assocName];
            [tapAreaRef setName:tapAreaName];
            
            tapArea = [[TapArea alloc] initWithEntity:_tapAreaEntity insertIntoManagedObjectContext:self.context];
            [tapArea setMatch_algorithm_id:[NSNumber numberWithInt:_matchAlgIndex]];
            [tapArea setImage_section:tapAreaRef.image_thumb];
            [tapArea setTap_order:[NSNumber numberWithInt:tap_order]];
            [tapArea setCoord_pt:tapAreaRef.coord_pt];
            [tapArea setMatch_association:_matchAssociation];
            [tapArea setName:[[NSString alloc] initWithFormat:@"%@ Tap Area", _assocName]];
            [tapArea setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
            [tapArea setTap_area_match:tapAreaRef];
            [tapAreaRef setTap_area:tapArea];

            [_matchAssociation addTap_areaObject:tapArea];

        } else {
            tapArea = tapAreaRef.tap_area;
            [tapArea setTap_order:[NSNumber numberWithInt:tap_order]];
        }
        
//        // Remove existing TapAreaSwatch elements (will add them back in)
//        //
//        NSArray *tapAreaSwatches = [tapArea.tap_area_swatch allObjects];
//        for (int i=0; i<[tapAreaSwatches count]; i++) {
//            TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
//            PaintSwatches *paintSwatch   = (PaintSwatches *)tapAreaSwatch.paint_swatch;
//            
//            [tapArea removeTap_area_swatchObject:tapAreaSwatch];
//            [paintSwatch removeTap_area_swatchObject:tapAreaSwatch];
//            [self.context deleteObject:tapAreaSwatch];
//        }
//
//        // Add back the TapAreaSwatch elements
//        //
//        for (int j=1; j<(int)[swatches count]; j++) {
//            PaintSwatches *paintSwatch = [swatches objectAtIndex:j];
//            
//            // Check if the TapAreaSwatch already exists
//            //
//            TapAreaSwatch *tapAreaSwatch = [[TapAreaSwatch alloc] initWithEntity:_tapAreaSwatchEntity insertIntoManagedObjectContext:self.context];
//            [tapAreaSwatch setPaint_swatch:(PaintSwatch *)paintSwatch];
//            [tapAreaSwatch setTap_area:tapArea];
//            [tapAreaSwatch setMatch_order:[NSNumber numberWithInt:j]];
//            [tapAreaSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
//            
//            [tapArea addTap_area_swatchObject:tapAreaSwatch];
//            [paintSwatch addTap_area_swatchObject:tapAreaSwatch];
//        }
    }
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"MatchAssociation and relations save" message:@"Error saving"];
        [self presentViewController:myAlert animated:YES completion:nil];

    } else {
        NSLog(@"MatchAssociation and relations save successful");
        
        _tapAreasChanged = FALSE;
        
        // Update the title
        //
        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:_assocName];
        
        // Disable the Match/Assoc toggle (no reason to switch back)
        //
        [BarButtonUtils setButtonEnabled:self.toolbarItems refTag:MATCH_BTN_TAG isEnabled:FALSE];

        [self matchButtonsHide];
        
        [_matchSave setEnabled:FALSE];
    }
}

// Need to delete keywords
//
- (void)deleteTapArea:(PaintSwatches *)paintSwatch {
    if ([paintSwatch tap_area] != nil) {
        TapArea *tapArea = [paintSwatch tap_area];
        [_matchAssociation removeTap_areaObject:tapArea];
        
        // Delete tap area swatches
        //
        if ([tapArea tap_area_swatch] != nil) {
            [self deleteTapAreaSwatches:tapArea];
        }
        
        // Delete tap area keywords
        //
        if ([tapArea tap_area_keyword] != nil) {
            [self deleteTapAreaKeywords:tapArea];
        }
        
        [self.context deleteObject:tapArea];
    }
    [self.context deleteObject:paintSwatch];
    
    [self drawTapAreas];
    [_imageTableView reloadData];
}

- (void)deleteTapAreaSwatches:(TapArea *)tapArea {
    NSArray *tapAreaSwatches = [[tapArea tap_area_swatch] allObjects];
    for (int i=0; i<[tapAreaSwatches count]; i++) {
        TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
        PaintSwatches *paintSwatch   = (PaintSwatches *)tapAreaSwatch.paint_swatch;
        
        [tapArea removeTap_area_swatchObject:tapAreaSwatch];
        [paintSwatch removeTap_area_swatchObject:tapAreaSwatch];
    
        [self.context deleteObject:tapAreaSwatch];
    }
}

- (void)deleteTapAreaKeywords:(TapArea *)tapArea {
    NSArray *tapAreaKeywords = [[tapArea tap_area_keyword] allObjects];
    for (int i=0; i<[tapAreaKeywords count]; i++) {
        TapAreaKeyword *tapAreaKeyword = [tapAreaKeywords objectAtIndex:i];
        Keyword *keyword   = tapAreaKeyword.keyword;
        
        [tapArea removeTap_area_keywordObject:tapAreaKeyword];
        [keyword removeTap_area_keywordObject:tapAreaKeyword];
    
        [self.context deleteObject:tapAreaKeyword];
    }
}

// Need to delete keywords
//
- (void)deleteMatchAssoc {

    if (_matchAssociation != nil) {
        
        // Delete TapAreas, TapAreaSwatches, and any references to them
        //
        for (int i=0; i<[self.collectionMatchArray count];i++) {
            NSMutableArray *swatches = [self.collectionMatchArray objectAtIndex:i];
            
            PaintSwatches *tapAreaRef = [swatches objectAtIndex:0];
            
            // Check if TapArea already exists and, if so delete along with any association
            //
            TapArea *tapArea;
            if ([tapAreaRef tap_area] != nil) {
                tapArea = [tapAreaRef tap_area];
            
                // Remove existing TapAreaSwatch elements
                //
                if ([tapArea tap_area_swatch] != nil) {
                    [self deleteTapAreaSwatches:tapArea];
                }
                
                // Delete tap area keywords
                //
                if ([tapArea tap_area_keyword] != nil) {
                    [self deleteTapAreaKeywords:tapArea];
                }

                [self.context deleteObject:tapArea];
            }
            
            // Delete the associated PaintSwatch
            //
            [self.context deleteObject:tapAreaRef];
        }
        
        // Delete any MatchAssociation keywords
        //
        if (_matchAssociation.match_assoc_keyword != nil) {
            NSArray *matchAssocKeywords = [_matchAssociation.match_assoc_keyword allObjects];
            for (MatchAssocKeyword *matchAssocKwObj in matchAssocKeywords) {
                Keyword *kwObj = matchAssocKwObj.keyword;
                [kwObj removeMatch_assoc_keywordObject:matchAssocKwObj];
                [_matchAssociation removeMatch_assoc_keywordObject:matchAssocKwObj];
                [self.context deleteObject:matchAssocKwObj];
            }
        }
        
        // Delete the MatchAssociation
        //
        [self.context deleteObject:_matchAssociation];
        _matchAssociation = nil;
        [self editButtonDisable];

    
        // Commit the delete
        //
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            UIAlertController *myAlert = [AlertUtils createOkAlert:@"MatchAssociation and relations delete" message:@"Error saving"];
            [self presentViewController:myAlert animated:YES completion:nil];
            
        } else {
            NSLog(@"MatchAssociation and relations delete successful");

            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    // Re-initialize the view
    //
    _paintSwatches  = [[NSMutableArray alloc] init];
    _currTapSection = 0;

    [self drawTapAreas];
    [_imageTableView reloadData];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Navigation Methods

- (IBAction)segueToMatchOrAssoc:(id)sender {
    if ([_viewType isEqualToString:ASSOC_TYPE]) {
        [self performSegueWithIdentifier:@"AssocTableViewSegue" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AssocTableViewSegue"]) {
        
        // Save the Association first
        //
        if (_mixAssociation == nil || _tapAreasChanged == TRUE) {
            [self saveMixAssoc];
        }
        
        UINavigationController *navigationViewController = [segue destinationViewController];
        AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
        
        [assocTableViewController setPaintSwatches:_paintSwatches];
        [assocTableViewController setMixAssociation:_mixAssociation];
        [assocTableViewController setSaveFlag:_saveFlag];

    } else if ([[segue identifier] isEqualToString:@"MatchTableViewSegue"]) {
        
        // Save the MatchAssociation first
        //
        if (_matchAssociation == nil || _tapAreasChanged == TRUE || _matchNumChanged == TRUE) {
            [self updateMatchAssoc];
        }

        PaintSwatches *paintSwatch = [[self.collectionMatchArray objectAtIndex:_currSelectedSection] objectAtIndex:0];
        
        UINavigationController *navigationViewController = [segue destinationViewController];
        MatchTableViewController *matchTableViewController = (MatchTableViewController *)([navigationViewController viewControllers][0]);
        
        [matchTableViewController setSelPaintSwatch:paintSwatch];
        
        int currTapSection = _currTapSection - _currSelectedSection;
        [matchTableViewController setCurrTapSection:currTapSection];
        [matchTableViewController setTapSections:self.collectionMatchArray];
    
        [matchTableViewController setReferenceImage:_referenceTappedImage];

        [matchTableViewController setMaxMatchNum:_maxMatchNum];
        
        int tapIndex = currTapSection - 1;
        TapArea *tapArea = [[ManagedObjectUtils queryTapAreas:_matchAssociation.objectID context:self.context] objectAtIndex:tapIndex];
        [matchTableViewController setTapArea:tapArea];
        [matchTableViewController setMatchAlgIndex:[[tapArea match_algorithm_id] intValue]];

        [matchTableViewController setDbPaintSwatches:_dbPaintSwatches];
        [matchTableViewController setMatchAssociation:_matchAssociation];


    } else if ([[segue identifier] isEqualToString:@"AssocToDetailSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        SwatchDetailTableViewController *swatchDetailTableViewController = (SwatchDetailTableViewController *)([navigationViewController viewControllers][0]);
    
        [swatchDetailTableViewController setPaintSwatch:[_paintSwatches objectAtIndex:0]];

    // Settings or Other Segue (for now, no action)
    //
    } else {
        if ([_viewType isEqualToString:ASSOC_TYPE] && (_mixAssociation == nil || _tapAreasChanged == TRUE)) {
            [self saveMixAssoc];
            
        } else if ([_viewType isEqualToString:MATCH_TYPE] && (_matchAssociation == nil || _tapAreasChanged == TRUE)) {
            [self updateMatchAssoc];
        }
    }
}

- (IBAction)unwindToImageViewFromAssoc:(UIStoryboardSegue *)segue {
    AssocTableViewController *sourceViewController = [segue sourceViewController];
    
    _paintSwatches  = sourceViewController.paintSwatches;
    _mixAssociation = sourceViewController.mixAssociation;
    _saveFlag       = sourceViewController.saveFlag;
    
    [_assocButton setWidth:_assocButton.title.length];
    
    // Disable the view and algorithm buttons
    //
    if ([_paintSwatches count] == 0) {
        [self viewButtonHide];
        [self matchButtonsHide];
        [self editButtonDisable];
    }
    
    [self drawTapAreas];
}

- (IBAction)unwindToImageViewFromMatch:(UIStoryboardSegue *)segue {
    MatchTableViewController *sourceViewController = [segue sourceViewController];

    _maxMatchNum = [sourceViewController maxMatchNum];
    
    [self setTapAreasChanged:FALSE];
    
    [self drawTapAreas];
    [self refreshViews];
}

- (IBAction)goBack:(id)sender {
    [self.context rollback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
