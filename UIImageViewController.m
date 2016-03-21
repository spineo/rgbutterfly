//
//  UIImageViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 3/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "UIImageViewController.h"
#import "GlobalSettings.h"
#import "ACPMixAssociationsDesc.h"
#import "AppDelegate.h"
#import "ColorUtils.h"
#import "FieldUtils.h"
#import "AssocTableViewController.h"
#import "MatchTableViewController.h"
#import "CoreDataUtils.h"
#import "ViewController.h"
#import "BarButtonUtils.h"
#import "AssocCollectionTableViewCell.h"
#import "MatchAlgorithms.h"
#import "PaintSwatchesDiff.h"
#import "AlertUtils.h"
#import "MatchAssociations.h"
#import "ManagedObjectUtils.h"

#import "PaintSwatches.h"
#import "MatchAssociations.h"
#import "TapArea.h"
#import "TapAreaSwatch.h"
#import "MixAssocSwatch.h"


@interface UIImageViewController ()

@property (nonatomic, strong) UILabel *titleLabel, *stepperLabel, *tapMeLabel, *matchNumLabel;
@property (nonatomic, strong) UIImageView *rgbView, *alertImageView;
@property (nonatomic, strong) UIStepper *tapAreaStepper, *matchNumStepper;
@property (nonatomic, strong) UIButton *shape, *scrollViewUp, *scrollViewDown;
@property (nonatomic) int goBackStatus, viewInit, shapeLength, currTapSection, currSelectedSection, maxMatchNum, dbSwatchesCount, paintSwatchCount;
@property (nonatomic, strong) UIImage *cgiImage, *rgbImage, *tapMeImage, *upArrowImage, *downArrowImage, *referenceTappedImage;
@property (nonatomic, strong) NSMutableArray *dbPaintSwatches, *compPaintSwatches, *collectionMatchArray, *tapNumberArray, *swatchObjects, *matchTapAreas;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) GlobalSettings *globalSettings;
@property (nonatomic, strong) NSString *maxMatchNumKey, *matchName, *matchDesc;

@property (nonatomic, strong) UIAlertController *typeAlertController, *editButtonAlertController;
@property (nonatomic, strong) UIAlertAction *matchView, *associateMixes, *alertCancel, *matchAssocFieldsView, *matchAssocFieldsCancel, *matchAssocFieldsSave;

@property (nonatomic, strong) UIAlertView *tapAreaAlertView, *clearTapsAlertView;
@property (nonatomic) int tapAreaSeen, tapAreaSize;
@property (nonatomic, strong) NSString *tapAreaShape, *shapeGeom, *rectLabel, *circleLabel, *shapeTitle;

@property (nonatomic) int stepMinVal, stepMaxVal, stepIncVal, matchAlgIndex, matchStepMinVal, matchStepMaxVal, matchStepIncVal, maxRowLimit;

// Image view expansion
//
@property (nonatomic) int imageViewSize;

@property (nonatomic) CGFloat screenWidth, titleOrigin, titleWidth, rgbOrigin, rgbWidth, rectSize, rgbViewWidth, rgbViewHeight, sizePadding, imgViewOffsetX, offsetY, imageViewXOffset, imageViewWidth, imageViewHeight, headerViewYOffset, headerViewHeight, cellHeight;

@property (nonatomic) CGSize defScrollViewSize, defTableViewSize;
@property (nonatomic) CGPoint defScrollViewOrigin, defTableViewOrigin;

@property (nonatomic) CGFloat hue, sat, bri, alpha, borderThreshold;

@property (nonatomic, strong) UIView *titleAndRGBView, *rgbMainView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer, *rgbTapRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) CGPoint touchPoint;

@property (nonatomic, strong) PaintSwatches *swatchObj;
@property (nonatomic, strong) TapArea *tapArea;
@property (nonatomic, strong) TapAreaSwatch *tapAreaSwatch;


@property (nonatomic) BOOL saveFlag, isRGB;
@property (nonatomic, strong) NSString *reuseCellIdentifier;
@property (nonatomic, strong) NSMutableArray *matchAlgorithms;
@property (nonatomic, strong) UITextField *matchNumTextField;

@property (nonatomic) BOOL expandTableView;

@property (nonatomic, strong) UIBarButtonItem *flexibleItem, *upArrowItem;

// NSUserDefaults
//
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// NSManagedObject subclassing
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity, *matchAssocEntity, *mixAssocEntity, *mixAssocSwatchEntity, *tapAreaEntity, *tapAreaSwatchEntity;

@end

@implementation UIImageViewController

// Set up the tags
//
// Defined programmatically
//
const int TAPS_ALERT_TAG   = 11;
const int CLEAR_TAPS_TAG   = 12;
const int SHAPE_BUTTON_TAG = 13;
const int MATCH_NUM_TAG    = 14;
const int MATCH_NAME_TAG   = 15;
const int MATCH_DESC_TAG   = 16;

// Button widths
//
const CGFloat DECR_BUTTON_WIDTH = 20.0;
const CGFloat INCR_BUTTON_WIDTH = 20.0;

#pragma mark - Initialization Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSManagedObject subclassing
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // Initialize the PaintSwatch entity
    //
    _paintSwatchEntity    = [NSEntityDescription entityForName:@"PaintSwatch"      inManagedObjectContext:self.context];
    _matchAssocEntity     = [NSEntityDescription entityForName:@"MatchAssociation" inManagedObjectContext:self.context];
    _mixAssocSwatchEntity = [NSEntityDescription entityForName:@"MixAssocSwatch"   inManagedObjectContext:self.context];
    _tapAreaEntity        = [NSEntityDescription entityForName:@"TapArea"          inManagedObjectContext:self.context];
    _tapAreaSwatchEntity  = [NSEntityDescription entityForName:@"TapAreaSwatch"    inManagedObjectContext:self.context];
    

    [BarButtonUtils buttonHide:self.toolbarItems refTag: VIEW_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag:VIEW_BTN_TAG width: HIDE_BUTTON_WIDTH];
    
    // Keep track of the PaintSwatches count
    //
    _paintSwatchCount = 0;

    
    // Get/save NSUserDefaults handle
    //
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _maxMatchNumKey = @"MaxMatchNum";
    _maxMatchNum = (int)[_userDefaults integerForKey:_maxMatchNumKey];
    if (! _maxMatchNum) {
        _maxMatchNum = DEF_MATCH_NUM;
    }
    [_userDefaults setInteger:_maxMatchNum forKey:_maxMatchNumKey];
    [_userDefaults synchronize];
    
    // To contain the tap areas associated with the match functionality
    //
    _matchTapAreas = [[NSMutableArray alloc] init];
    
    // Load the paint swatches
    //
    _dbPaintSwatches = [ManagedObjectUtils fetchPaintSwatches:self.context];
    _dbSwatchesCount = (int)[_dbPaintSwatches count];
    
    _maxRowLimit = (_dbSwatchesCount > DEF_MAX_MATCH) ? DEF_MAX_MATCH : _dbSwatchesCount;

    _defScrollViewOrigin = _imageScrollView.bounds.origin;
    _defScrollViewSize   = _imageScrollView.bounds.size;
    _defTableViewOrigin  = _imageTableView.bounds.origin;
    _defTableViewSize    = _imageTableView.bounds.size;

    // Used in sortByClosestMatch
    //
    _tapNumberArray = [[NSMutableArray alloc] init];
    
    // Image view expansion
    // 0 - Full table view
    // 1 - Split view (default)
    // 2 - Full image view
    //
    _imageViewSize = 1;


    _cellHeight         = DEF_TABLE_CELL_HEIGHT + DEF_FIELD_PADDING + DEF_COLLECTVIEW_INSET;

    if (_viewType == nil) {
        _viewType           = @"match";
    }
    
    [BarButtonUtils buttonHide:self.toolbarItems refTag: VIEW_BTN_TAG];
    
    // Match algorithms
    //
    _matchAlgorithms = [ManagedObjectUtils fetchDictNames:@"MatchAlgorithm" context:self.context];
    _matchAlgIndex = 0;

    // RGB Rendering FALSE by default
    //
    _isRGB = FALSE;
    
    // Tableview defaults
    //
    _imageViewXOffset  = DEF_TABLE_X_OFFSET + DEF_FIELD_PADDING;
    _imageViewWidth    = DEF_TABLE_CELL_HEIGHT;
    _imageViewHeight   = DEF_TABLE_CELL_HEIGHT;
    _headerViewYOffset = DEF_Y_OFFSET + 1.0;
    _headerViewHeight  = DEF_TABLE_HDR_HEIGHT - 2.0;

    // Initial CoreData state
    //
    [self setSaveFlag: FALSE];

    // Go back storyboard (i.e., home) status
    //
    [self setGoBackStatus: 1];

    // View globals
    //
    [self setViewInit: 1];
    [self setRgbViewWidth: 40];
    [self setSizePadding: 20.0];
    [self setImgViewOffsetX: 30.0];
    
    // Tap Area Stepper
    //
    [self setStepMinVal: 24];
    [self setStepMaxVal: 48];
    [self setStepIncVal: 4];
    
    // Max Num Stepper
    //
    int max_swatch_num = _dbSwatchesCount - (_dbSwatchesCount % 5);
    int max_match = (max_swatch_num > DEF_MAX_MATCH) ? DEF_MAX_MATCH : max_swatch_num;
    [self setMatchStepMinVal: DEF_MIN_MATCH];
    [self setMatchStepMaxVal: max_match];
    [self setMatchStepIncVal: DEF_STEP_MATCH];
    
    
    // Labels
    //
    [self setRectLabel: @"Rect"];
    [self setCircleLabel: @"Circle"];

    
    // Defaults
    //
    [self setTapAreaSize: 36];
    [self setTapAreaShape: _circleLabel];
    
    
    [self setGlobalSettings: [CoreDataUtils fetchGlobalSettings]];
    [self setShapeLength: _globalSettings.tap_area_size];
    [self setShapeGeom: _globalSettings.tap_area_shape];


    // Add the selected image
    //
    [_imageView setImage: _selectedImage];
    [_imageView setUserInteractionEnabled: YES];
    [_imageView setContentMode:UIViewContentModeScaleToFill];
    [_imageScrollView setScrollEnabled:YES];
    [_imageScrollView setClipsToBounds:YES];
    [_imageScrollView setContentSize:_selectedImage.size];
    [_imageScrollView setDelegate: self];

    
    // Initialize a tap gesture recognizer for selected image regions
    // and specify that the gesture must be a single tap
    //
    _tapRecognizer = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(respondToTap:)];
    [_tapRecognizer setNumberOfTapsRequired: 1];
    [_imageView addGestureRecognizer:_tapRecognizer];

    
    // Initialize a pinch gesture recognizer for zooming in/out of the image
    //
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                        initWithTarget:self action:@selector(respondToPinch:)];
    [_imageView addGestureRecognizer:_pinchRecognizer];

    
    // Threshold brightness value under which a white border is drawn around the RGB image view
    // (default border is black)
    //
    [self setBorderThreshold: DEF_BORDER_THRESHOLD];
    
    
    // Set the info image
    //
    [self setTapMeImage: [UIImage imageNamed:[GlobalSettings tapMeImageName]]];
    
    
    // Long press recognizer
    //
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [_longPressRecognizer setMinimumPressDuration: 1.0f];
    [_longPressRecognizer setAllowableMovement: 100.0f];
    [_imageView addGestureRecognizer:_longPressRecognizer];
    
    
    // Tap size Alert View
    //
    _tapAreaAlertView = [[UIAlertView alloc] initWithTitle:@"Tap Area RGB Display"
                                                   message:@"Change the size and/or shape of the tap area."
                                                  delegate:self
                                         cancelButtonTitle:@"Done"
                                         otherButtonTitles:@"Save Settings", nil];
    [_tapAreaAlertView setTintColor: DARK_TEXT_COLOR];
    [_tapAreaAlertView setTag: TAPS_ALERT_TAG];
    
    
    // Sizing parameters
    //
    CGFloat viewHeight     = (_shapeLength * 2) + _sizePadding * 2;
    CGFloat stepperOffsetX = 80.0;
    CGFloat stepperOffsetY = _sizePadding + (_shapeLength / 2) - 13.0;
    CGFloat shapeOffsetX   = 190.0;
    CGFloat shapeOffsetY  = _sizePadding + (_shapeLength / 2) - 11.0;
    
    
    // Creat the alertView main frame (to contain the imageView, stepper, and stepper label)
    //
    _rgbMainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, viewHeight)];
    [_rgbMainView setBackgroundColor: DARK_BG_COLOR];
    
    
    // UIImageView (represents the current tap area)
    //
    [self setOffsetY: _sizePadding];
    _alertImageView = [[UIImageView alloc] initWithFrame: CGRectMake(_imgViewOffsetX, _offsetY, _shapeLength, _shapeLength)];
    [_alertImageView setBackgroundColor: LIGHT_BG_COLOR];

    if ([_shapeGeom isEqualToString:_circleLabel]) {
        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
        [_alertImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    } else {
        [_alertImageView.layer setCornerRadius: CORNER_RADIUS_NONE];
        [_alertImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    }
    [_alertImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    
    
    // Label displaying the value in the stepper
    //
    int size = (int)_shapeLength;
    
    _stepperLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _shapeLength, _shapeLength)];
    [_stepperLabel setTextColor: DARK_TEXT_COLOR];
    [_stepperLabel setBackgroundColor: CLEAR_COLOR];
    [_stepperLabel setText: [[NSString alloc] initWithFormat:@"%i", size]];
    [_stepperLabel setTextAlignment: NSTextAlignmentCenter];
    [_alertImageView addSubview:_stepperLabel];
    
    
    // UIStepper (change the size of the tapping area)
    //
    _tapAreaStepper = [[UIStepper alloc] initWithFrame:CGRectMake(stepperOffsetX, stepperOffsetY, _shapeLength, _shapeLength)];
    [_tapAreaStepper setTintColor: LIGHT_TEXT_COLOR];
    [_tapAreaStepper addTarget:self action:@selector(tapAreaStepperPressed) forControlEvents:UIControlEventValueChanged];
    
    
    // Set min, max, step, and default values and wraps parameter
    //
    [_tapAreaStepper setMinimumValue:_stepMinVal];
    [_tapAreaStepper setMaximumValue:_stepMaxVal];
    [_tapAreaStepper setStepValue:_stepIncVal];
    [_tapAreaStepper setValue:_shapeLength];
    [_tapAreaStepper setWraps:NO];
    
    
    // Create the Match Num Stepper
    //
    CGFloat matchNumYOffset = stepperOffsetY + _shapeLength + DEF_FIELD_PADDING;
    _matchNumLabel = [FieldUtils createLabel:@"Match #" xOffset:_imageViewXOffset yOffset:matchNumYOffset];
    [_matchNumLabel setFont: TEXT_LABEL_FONT];
    
    _matchNumStepper = [[UIStepper alloc] initWithFrame:CGRectMake(stepperOffsetX, matchNumYOffset, _shapeLength, _shapeLength)];
    [_matchNumStepper setTintColor: LIGHT_TEXT_COLOR];
    [_matchNumStepper addTarget:self action:@selector(matchNumStepperPressed) forControlEvents:UIControlEventValueChanged];
    
    // Set min, max, step, and default values and wraps parameter
    //
    [_matchNumStepper setMinimumValue:_matchStepMinVal];
    [_matchNumStepper setMaximumValue:_matchStepMaxVal];
    [_matchNumStepper setStepValue:_matchStepIncVal];
    [_matchNumStepper setValue:_maxMatchNum];
    [_matchNumStepper setWraps:NO];
    
    
    _matchNumTextField = [FieldUtils createTextField:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum] tag: INCR_ALG_BTN_TAG];
    [_matchNumTextField setFrame:CGRectMake(shapeOffsetX, matchNumYOffset, DEF_SM_TXTFIELD_WIDTH, DEF_TEXTFIELD_HEIGHT)];
    [_matchNumTextField setAutoresizingMask: NO];
    [_matchNumTextField setKeyboardType: UIKeyboardTypeNumberPad];
    [_matchNumTextField setTag: MATCH_NUM_TAG];
    [_matchNumTextField setDelegate:self];
    
    
    // Initialize the shape
    //
    if ([_shapeGeom isEqualToString:_circleLabel]) {
        [self setShapeTitle: _rectLabel];
    } else {
        [self setShapeTitle: _circleLabel];
    }

    CGRect buttonFrame = CGRectMake(shapeOffsetX, shapeOffsetY, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT);
    _shape = [BarButtonUtils create3DButton:_shapeTitle tag: SHAPE_BUTTON_TAG frame: buttonFrame];
    [_shape addTarget:self action:@selector(changeShape) forControlEvents:UIControlEventTouchUpInside];
    
    [_rgbMainView addSubview:_alertImageView];
    [_rgbMainView addSubview:_tapAreaStepper];
    [_rgbMainView addSubview:_shape];
    
    [_rgbMainView addSubview:_matchNumLabel];
    [_rgbMainView addSubview:_matchNumStepper];
    [_rgbMainView addSubview:_matchNumTextField];
    
    [_tapAreaAlertView setValue:_rgbMainView forKey:@"accessoryView"];
    
    // Hide the "arrow" buttons by default
    //
    [self matchButtonsHide];
    

    // Clear taps Alert View
    //
    _clearTapsAlertView = [[UIAlertView alloc] initWithTitle:@"Clear Taps"
                                                     message:@"Do you want to clear all tapped areas?"
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    [_clearTapsAlertView setTintColor: DARK_TEXT_COLOR];
    [_clearTapsAlertView setTag: CLEAR_TAPS_TAG];
    
    
    // Edit button Alert View
    //
    _editButtonAlertController = [UIAlertController alertControllerWithTitle:@"Match Association"
                                                      message:@"Please enter the information below:"
                                               preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *editButtonAlertController_ = _editButtonAlertController;
    
                                [editButtonAlertController_ addTextFieldWithConfigurationHandler:^(UITextField *matchNameTextField) {
                                    if (_matchAssociation != nil) {
                                        [matchNameTextField setText:_matchAssociation.name];
                                    } else {
                                        [matchNameTextField setPlaceholder: NSLocalizedString(@"Please enter a match name.", nil)];
                                    }
                                    [matchNameTextField setTag: MATCH_NAME_TAG];
                                    [matchNameTextField setClearButtonMode: UITextFieldViewModeWhileEditing];
                                    [matchNameTextField setDelegate: self];
                                }];
    
                                [editButtonAlertController_ addTextFieldWithConfigurationHandler:^(UITextField *matchDescTextField) {
                                    if (_matchAssociation != nil) {
                                        [matchDescTextField setText:_matchAssociation.desc];
                                    } else {
                                        [matchDescTextField setPlaceholder: NSLocalizedString(@"Please enter a match description.", nil)];
                                    }
                                    [matchDescTextField setTag: MATCH_DESC_TAG];
                                    [matchDescTextField setClearButtonMode: UITextFieldViewModeWhileEditing];
                                    [matchDescTextField setDelegate: self];
                                }];

    
    _matchAssocFieldsSave = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self updateMatchAssoc];
    }];
    
    _matchAssocFieldsCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [editButtonAlertController_ dismissViewControllerAnimated:YES completion:nil];
    }];

    [editButtonAlertController_ addAction:_matchAssocFieldsSave];
    [editButtonAlertController_ addAction:_matchAssocFieldsCancel];
    
    
    // Adjust the NavBar layout when the orientation changes
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Navigation Item Title
    //
    [[self.navigationItem.titleView.subviews objectAtIndex:0] setText: DEF_IMAGE_NAME];
    [[self.navigationItem.titleView.subviews objectAtIndex:0] setColor: LIGHT_YELLOW_COLOR];
    
    
    // Type Alert Controller
    //
    _typeAlertController = [UIAlertController alertControllerWithTitle:@"Action Types"
                                                                  message:@"Please select from the match actions below:"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    _matchView   = [UIAlertAction actionWithTitle:@"Match View (default)" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                _viewType = @"match";
                                                [self resetViews];
                                                
                                                
                                                UIBarButtonItem *matchButton = [[UIBarButtonItem alloc] initWithTitle:@"Match"
                                                                style: UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(selectMatchAction)];
                                                
                                                [matchButton setTintColor: LIGHT_TEXT_COLOR];

                                                NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
                                                [items replaceObjectAtIndex:3 withObject:matchButton];
                                                [self setToolbarItems:items];

                                                
                                                // Hide buttons (until at least one area tapped)
                                                //
                                                [self viewButtonHide];
                                                [self matchButtonsHide];
                                                
                                            }];
    
    _associateMixes = [UIAlertAction actionWithTitle:@"Associate Mixes" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                _viewType = @"assoc";
                                                [self resetViews];
                                                [self addMixAssociation];

                                                UIBarButtonItem *assocButton = [[UIBarButtonItem alloc] initWithTitle:@"Assoc"
                                                                style: UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(selectAssocAction)];

                                                [assocButton setTintColor: LIGHT_TEXT_COLOR];
                                                
                                                [self removeUpArrow];
                                                
                                                NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
                                                [items replaceObjectAtIndex:3 withObject:assocButton];
                                                [self setToolbarItems:items];

                                                
                                                // Hide buttons (until at least one area tapped)
                                                //
                                                [self viewButtonHide];
                                                [self matchButtonsHide];
                                            }];
    
    _alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [_typeAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_typeAlertController addAction:_matchView];
    [_typeAlertController addAction:_associateMixes];
    [_typeAlertController addAction:_alertCancel];
    

    // List of coordinates associated with tapped regions (i.e., GCPoint)
    // Hide this controller if the source is the main ViewController (as 'match' is the only valid context)
    //
    if ([_sourceViewContext isEqualToString:@"CollectionViewController"]) {
        _currTapSection = (int)[_paintSwatches count];
        [self matchButtonHide];
        if ([_viewType isEqualToString:@"match"]) {
            [self matchButtonsShow];
        }

    } else {
        _paintSwatches = [[NSMutableArray alloc] init];
    }
    
    // TableView
    //
    _reuseCellIdentifier = @"ImageTableViewCell";


    [_imageTableView setDelegate: self];
    [_imageTableView setDataSource: self];

    // Shrink and expand image shown in the tableView header (for UIImageScrollView hide/show)
    //
    _upArrowImage = [[UIImage imageNamed:[GlobalSettings arrowUpImageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    _downArrowImage = [[UIImage imageNamed:[GlobalSettings arrowDownImageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    // Initial state until tapped areas are added
    //
    [_imageTableView setHidden:TRUE];
    _expandTableView = TRUE;
    
    _flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _upArrowItem  = [[UIBarButtonItem alloc] initWithImage:_upArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(scrollViewDecrease)];
    
    // Notification center
    //
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeViews) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
};


- (void)viewDidAppear:(BOOL)didAppear {
    
    // Resize the scroll and table views
    //
    [self resizeViews];
    
    // Get this value for calculating the relative dimensions
    //
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;

    // Left back button
    //
    CGFloat leftItemWidth  = self.navigationItem.leftBarButtonItem.width;
    
    // Key origins and dimensions
    //
    CGRect navBarBounds        = self.navigationController.navigationBar.bounds;
    CGFloat navBarOriginY      = navBarBounds.origin.y;
    CGFloat navBarWidth        = navBarBounds.size.width;
    CGFloat navBarHeight       = navBarBounds.size.height;
    
    CGFloat titleViewOrigin    = 0.0;
    CGFloat titleViewWidth     = navBarWidth - leftItemWidth;

    _rgbViewWidth              = MIN(_rgbViewWidth, navBarHeight - 2.0);
    
    CGFloat rgbViewWidthOffset = _rgbViewWidth + (_screenWidth / 10);

    _rgbViewHeight             = _rgbViewWidth;

    CGFloat titleLabelWidth    = titleViewWidth - rgbViewWidthOffset;


    // Main view containing the label and RGB image view that is added to the NavBar titleView
    //
    _titleAndRGBView = [[UIView alloc] initWithFrame:CGRectMake(titleViewOrigin, navBarOriginY, titleViewWidth, _rgbViewHeight)];
    

    // Default label
    //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleViewOrigin,navBarOriginY,titleLabelWidth,navBarHeight)];
    [_titleLabel setTextColor: LIGHT_TEXT_COLOR];
    [_titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_titleLabel setBackgroundColor: CLEAR_COLOR];
    [_titleLabel setText: DEF_IMAGE_NAME];
    
    [_titleAndRGBView addSubview:_titleLabel];


    self.navigationItem.titleView = _titleAndRGBView;
    
    if ([_sourceViewContext isEqualToString:@"CollectionViewController"]) {
        [self setTapAreas];
    }
}


#pragma mark - Scrolling and Action Selection Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = _imageView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    self.imageView.frame = frame;
    
    [self viewWillLayoutSubviews];
}

- (void)selectMatchAction {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        _imageViewSize = 1;
    } else {
        _imageViewSize = 2;
    }

    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

- (void)selectAssocAction {
    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

- (void)matchButtonsShow {
    [self.navigationItem.rightBarButtonItem setEnabled: TRUE];
    [BarButtonUtils buttonShow:self.toolbarItems refTag: DECR_ALG_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag: INCR_ALG_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag: DECR_TAP_BTN_TAG];
    [BarButtonUtils buttonShow:self.toolbarItems refTag: INCR_TAP_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: DECR_TAP_BTN_TAG width: DECR_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: INCR_TAP_BTN_TAG width: INCR_BUTTON_WIDTH];
}

- (void)matchButtonsHide {
    [self.navigationItem.rightBarButtonItem setEnabled: FALSE];
    [BarButtonUtils buttonHide:self.toolbarItems refTag: DECR_ALG_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag: INCR_ALG_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag: DECR_TAP_BTN_TAG];
    [BarButtonUtils buttonHide:self.toolbarItems refTag: INCR_TAP_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: DECR_TAP_BTN_TAG width: HIDE_BUTTON_WIDTH];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: INCR_TAP_BTN_TAG width: HIDE_BUTTON_WIDTH];
}

- (void)viewButtonShow {
   [BarButtonUtils buttonShow:self.toolbarItems refTag: VIEW_BTN_TAG];
   [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: VIEW_BTN_TAG width: DEF_BUTTON_WIDTH];
}

- (void)viewButtonHide {
    [BarButtonUtils buttonHide:self.toolbarItems refTag: VIEW_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: VIEW_BTN_TAG width: HIDE_BUTTON_WIDTH];
}

// When source view controller is 'ViewController' context
//
- (void)matchButtonHide {
    [BarButtonUtils buttonHide:self.toolbarItems refTag: MATCH_BTN_TAG];
    [BarButtonUtils buttonSetWidth:self.toolbarItems refTag: MATCH_BTN_TAG width: HIDE_BUTTON_WIDTH];
}

// ******************************************************************************
// General Purpose Methods
// ******************************************************************************

#pragma mark - General Purpose Methods

- (void)resizeViews {
    
    CGFloat frameHeight = [[UIScreen mainScreen] bounds].size.height;

    if ([_viewType isEqualToString:@"match"]) {
        [_matchView setEnabled:FALSE];
        [_associateMixes setEnabled:TRUE];
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
                
            if (_imageViewSize == 0) {
                [_imageScrollView setHidden:TRUE];
                [_imageTableView setHidden:FALSE];
                self.tableHeightConstraint.constant = frameHeight;
                [self matchButtonsShow];
                
                [_scrollViewUp setHidden:TRUE];
                [_scrollViewDown setHidden:FALSE];
                
                [self removeUpArrow];
                
            } else if (_imageViewSize == 1) {
                [_imageScrollView setHidden:FALSE];
                [_imageTableView setHidden:FALSE];
                self.tableHeightConstraint.constant =  _defTableViewSize.height;
                
                [_scrollViewUp setHidden:FALSE];
                [_scrollViewDown setHidden:FALSE];
                
                [self removeUpArrow];
            
            // Full-screen image
            //
            } else {
                [_imageScrollView setHidden:FALSE];
                [_imageTableView setHidden:TRUE];
                self.tableHeightConstraint.constant =  0.0;
                [self matchButtonsHide];
                
                [self removeUpArrow];
                [self addUpArrow];
            }
    
        // In landscape, expand either the scroll view or the table view (as it looks kludgy otherwise on most devices)
        //
        } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {

            if (_imageViewSize == 0) {
                [_imageScrollView setHidden:TRUE];
                [_imageTableView setHidden:FALSE];
                self.tableHeightConstraint.constant = frameHeight;
                [self matchButtonsShow];
                
                [_scrollViewUp setHidden:TRUE];
                [_scrollViewDown setHidden:FALSE];

                [self removeUpArrow];
            
            // _imageViewSize > 0 (full-screen image)
            //
            } else {
                [_imageScrollView setHidden:FALSE];
                [_imageTableView setHidden:TRUE];
                self.tableHeightConstraint.constant =  0.0;
                [self matchButtonsHide];
                
                [self removeUpArrow];
                [self addUpArrow];
            }
        }
        
    // Assoc type
    //
    } else {
        self.tableHeightConstraint.constant = 0.0;
        
        [_matchView setEnabled:TRUE];
        [_associateMixes setEnabled:FALSE];
        [self viewButtonHide];
        
        [_imageTableView setHidden:TRUE];
        [_imageScrollView setHidden:FALSE];
        [self matchButtonsHide];
        
        if (_currTapSection > 0) {
            [self viewButtonShow];
        }
        
        [self removeUpArrow];
    }
    
    [self.imageTableView needsUpdateConstraints];
    [self.imageTableView reloadData];
}

- (void)resetViews {
    [self.context rollback];
    
    [self setPaintSwatches: nil];
    [_imageView setImage: _selectedImage];
    [_rgbView setImage: _tapMeImage];
    [_rgbView setBackgroundColor: LIGHT_BG_COLOR];
    
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
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        
        if (_imageViewSize == 2) {
            _imageViewSize = 1;
            [_scrollViewDown setHidden:FALSE];
            [_scrollViewUp setHidden:FALSE];
            
            self.tableHeightConstraint.constant =  _defTableViewSize.height;
            
            [_imageTableView setHidden:FALSE];
            [_imageScrollView setHidden:FALSE];
            
            if (_currTapSection > 0) {
                [self matchButtonsShow];
            } else {
                [self matchButtonsHide];
            }
            
            [self removeUpArrow];
            
        } else if ((_imageViewSize == 1) && (_currTapSection > 0)) {
            _imageViewSize = 0;
            [_scrollViewUp setHidden:TRUE];
            [_scrollViewDown setHidden:FALSE];

            CGFloat frameHeight = [[UIScreen mainScreen] bounds].size.height;
            self.tableHeightConstraint.constant = frameHeight;
            
            [_imageTableView setHidden:FALSE];
            [_imageScrollView setHidden:TRUE];
            
            [self matchButtonsShow];
        }
        
    // Landscape
    //
    } else if (_currTapSection > 0) {
        _imageViewSize = 0;
        [_scrollViewUp setHidden:TRUE];
        [_scrollViewDown setHidden:FALSE];
        
        //CGFloat frameHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        CGFloat frameHeight = [[UIScreen mainScreen] bounds].size.height;
        self.tableHeightConstraint.constant = frameHeight;
        
        [_imageTableView setHidden:FALSE];
        [_imageScrollView setHidden:TRUE];
        
        [self matchButtonsShow];
        
        [self removeUpArrow];
    }
    
    [self.imageTableView needsUpdateConstraints];
    [self.imageTableView reloadData];
}

- (void)scrollViewIncrease {
    
    [_imageScrollView setHidden:FALSE];
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        
        if (_imageViewSize == 0) {
            _imageViewSize = 1;
            self.tableHeightConstraint.constant =  _defTableViewSize.height;
            [_imageTableView setHidden:FALSE];
            
            if (_currTapSection > 0) {
                [self matchButtonsShow];
            } else {
                [self matchButtonsHide];
            }
            
        } else if (_imageViewSize == 1) {
            _imageViewSize = 2;
            self.tableHeightConstraint.constant =  0.0;
            [_imageTableView setHidden:TRUE];
            [self matchButtonsHide];
            
            [self addUpArrow];
        }
        
    // Landscape
    //
    } else {
        _imageViewSize = 2;
        self.tableHeightConstraint.constant =  0.0;
        [_imageTableView setHidden:TRUE];
        [self matchButtonsHide];
        
        [self removeUpArrow];
        [self addUpArrow];
    }
    [self.imageTableView reloadData];
    [self.imageTableView needsUpdateConstraints];
}

- (void)setAlertButtonStates {
    if ([_viewType isEqualToString:@"match"]) {
        
    } else if ([_viewType isEqualToString:@"match"]) {
        
    } else {
        [_associateMixes setEnabled:FALSE];
        [self viewButtonHide];
    }
}

- (void)addUpArrow {
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    [toolbarButtons addObject:_upArrowItem];
    [self setToolbarItems:toolbarButtons animated:YES];
}

- (void)removeUpArrow {
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    [toolbarButtons removeObject:_upArrowItem];
    [self setToolbarItems:toolbarButtons animated:YES];
}

// ******************************************************************************
// Handle tap, pinch, and long press events
// ******************************************************************************

#pragma mark - Gesture Recognizer Methods

- (void)respondToTap:(id)sender {

    _touchPoint = [sender locationInView:_imageView];

    [self drawTouchShape];
    
    if (_tapAreaSeen == 0) {
        [self setRgbView];

    } else {
        [self setRgbImage: nil];
        [_rgbView setImage: _tapMeImage];
        [_rgbView setBackgroundColor: LIGHT_BG_COLOR];
    }
}


// Render the UIAlertView pop-up
//
- (IBAction)respondToRgbTap:(id)sender {
    if ([_viewType isEqualToString:@"match"]) {
        [_matchNumLabel setHidden:NO];
        [_matchNumStepper setHidden:NO];
        [_matchNumTextField setHidden:NO];
        
    } else {
        [_matchNumLabel setHidden:YES];
        [_matchNumStepper setHidden:YES];
        [_matchNumTextField setHidden:YES];
    }

    [_tapAreaAlertView show];
}


- (void)respondToPinch:(UIPinchGestureRecognizer *)recognizer {
    float imageScale = sqrtf(recognizer.view.transform.a * recognizer.view.transform.a +
                             recognizer.view.transform.c * recognizer.view.transform.c);
    if ((recognizer.scale > 1.0) && (imageScale >= 2.00)) {
        return;
    }
    if ((recognizer.scale < 1.0) && (imageScale <= 0.75)) {
        return;
    }
    [recognizer.view setTransform: CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale)];
    [recognizer setScale: 1.0];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [_clearTapsAlertView show];
    }
}

- (void)drawTouchShape {
    int listCount = (int)[_paintSwatches count];
    
    [self setTapAreaSeen: 0];
    
    NSMutableArray *tempPaintSwatches = [[NSMutableArray alloc] initWithArray:_paintSwatches];
    _paintSwatches = [[NSMutableArray alloc] init];
    
    int seen_index = 0;
    
    for (int i=0; i<listCount; i++) {
        PaintSwatches *swatchObj = [tempPaintSwatches objectAtIndex:i];

        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        
        CGFloat xpt = pt.x - (_shapeLength / 2);
        CGFloat ypt = pt.y - (_shapeLength / 2);
        
        CGFloat xtpt= _touchPoint.x - (_shapeLength / 2);
        CGFloat ytpt= _touchPoint.y - (_shapeLength / 2);
        
    
        if ((abs((int)(xtpt - xpt)) <= _shapeLength) && (abs((int)(ytpt - ypt)) <= _shapeLength)) {
            [self setTapAreaSeen: 1];
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
        
        [_imageTableView setHidden:false];
        
        
        // Instantiate the new PaintSwatch Object
        //
        _swatchObj = [[PaintSwatches alloc] initWithEntity:_paintSwatchEntity insertIntoManagedObjectContext:self.context];


        [_swatchObj setCoord_pt:NSStringFromCGPoint(_touchPoint)];
        _paintSwatchCount++;
        
        // Set the RGB and HSB value
        //
        [self setColorValues];

        // Save the thumbnail image
        //
        CGFloat xpt= _touchPoint.x - (_shapeLength / 2);
        CGFloat ypt= _touchPoint.y - (_shapeLength / 2);
        UIImage *imageThumb = [ColorUtils cropImage:_selectedImage frame:CGRectMake(xpt, ypt, _shapeLength, _shapeLength)];
        [_swatchObj setImage_thumb:[NSData dataWithData:UIImagePNGRepresentation(imageThumb)]];
        
        [_paintSwatches addObject:_swatchObj];
        
        if ([_viewType isEqualToString:@"match"]) {
            if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) && _imageViewSize < 2) {
                [self matchButtonsShow];
            } else {
                [self matchButtonsHide];
            }
            
        } else {
            if (_mixAssociation == nil) {
                [self addMixAssociation];
            }
            
            MixAssocSwatch *mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:_mixAssocSwatchEntity insertIntoManagedObjectContext:self.context];
            [_swatchObj addMix_assoc_swatchObject:mixAssocSwatch];
            [_mixAssociation addMix_assoc_swatchObject:mixAssocSwatch];
            
            [self viewButtonShow];
        }
        
    } else if (newCount == 0) {
        _currTapSection = 0;
        
        // Disable view and algorithm buttons
        //
        [self viewButtonHide];
        [self matchButtonsHide];
        
        _imageTableView.hidden = true;
    
    } else {
        _currTapSection--;
        
        _imageTableView.hidden = false;
        
        int index = _currTapSection - 1;
        _swatchObj = [_paintSwatches objectAtIndex:index];
    }
    
    [self setTapAreas];
}

- (void)setTapAreas {
    if ([_viewType isEqualToString:@"match"]) {
        NSArray *swatches = [[NSArray alloc] initWithArray:_paintSwatches];
        
        for (int i=0; i<_currTapSection; i++) {
            [self sortTapSection:[swatches objectAtIndex:i] tapSection:i+1];
        }
    }

    [self.imageTableView reloadData];
    [self drawTapAreas];
}

- (void)drawTapAreas {

    UIImage *tempImage = [self imageWithBorderFromImage:_selectedImage rectSize:_selectedImage.size shapeType:_shapeGeom lineColor:@"white"];
    
    tempImage = [self drawText:tempImage];
    
    [_imageView setImage: tempImage];
    [_imageView.layer setMasksToBounds: YES];
    [_imageView.layer setCornerRadius: DEF_CORNER_RADIUS];
    
    // Set the reference image (used by the detail views)
    //
    _referenceTappedImage = tempImage;
}

-(UIImage*)drawText:(UIImage*)image {

    UIImage *retImage = image;
    
    for (int i=0; i<_paintSwatches.count; i++) {
        
        int count = i + 1;
        NSString *countStr = [[NSString alloc] initWithFormat:@"%i", count];
        
        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];

        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        CGFloat x, y;
        if ([_shapeGeom isEqualToString:_circleLabel]) {
            x = pt.x - (_shapeLength / 3.3);
            y = pt.y - (_shapeLength / 3.3);
        } else {
            x = pt.x - (_shapeLength / 2) + 2.0;
            y = pt.y - (_shapeLength / 2) + 2.0;
        }

        UIGraphicsBeginImageContext(image.size);
        
        [retImage drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
        CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);

        NSDictionary *attr = @{NSForegroundColorAttributeName: LIGHT_TEXT_COLOR, NSFontAttributeName: TAP_AREA_FONT, NSBackgroundColorAttributeName: DARK_BG_COLOR};

        [countStr drawInRect:CGRectInset(rect, 2.0, 2.0) withAttributes:attr];
    
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        retImage = newImage;
    }
    
    return retImage;
}

#pragma mark - AlertView and Containing Widgets Methods

// ******************************************************************************
// AlertView and Containing Methods
// ******************************************************************************

// Display alert view with textfields when clicking on the 'Edit' button (Match only)
//
- (IBAction)editMatchAlertShow:(id)sender {
    [self presentViewController:_editButtonAlertController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            // Currently two different 'settings' areas
            //
            [CoreDataUtils updateGlobalSettings:_globalSettings];

            [_userDefaults setInteger:_maxMatchNum forKey:_maxMatchNumKey];
            [_userDefaults synchronize];
        }
        
        [self refreshViews];
        
    } else {
        if (buttonIndex == 1) {
            [self resetViews];
        }
    }
}

- (void)setRgbView {
    UIColor *swatchColor = [UIColor colorWithRed:([_swatchObj.red floatValue]/255.0) green:([_swatchObj.green floatValue]/255.0) blue:([_swatchObj.blue floatValue]/255.0) alpha:[_swatchObj.alpha floatValue]];
    
    _rgbImage = [ColorUtils imageWithColor:swatchColor objWidth:_rgbViewWidth objHeight:_rgbViewHeight];
    
    [_rgbView setImage: _rgbImage];
    [_tapMeLabel setText:@""];
}

- (void)tapAreaStepperPressed {
    int size = (int)_tapAreaStepper.value;

    [_stepperLabel setText: [[NSString alloc] initWithFormat:@"%i", size]];
    
    CGFloat oldshapeLength = _shapeLength;
    [self setShapeLength: (CGFloat)_tapAreaStepper.value];
    [_globalSettings setTap_area_size: _shapeLength];
    
    CGFloat diff = _shapeLength - oldshapeLength;
    
    _imgViewOffsetX = _imgViewOffsetX - (diff / 2.0);
    _offsetY        = _offsetY - (diff / 2.0);

    [_alertImageView setFrame: CGRectMake(_imgViewOffsetX, _offsetY, _shapeLength, _shapeLength)];
    if ([_shapeGeom isEqualToString:_circleLabel]) {
        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
    } else {
        [_alertImageView.layer setCornerRadius: CORNER_RADIUS_NONE];
    }
    
    [_stepperLabel setFrame: CGRectMake(0.0, 0.0, _shapeLength, _shapeLength)];
}

- (void)matchNumStepperPressed {
    _maxMatchNum = (int)_matchNumStepper.value;
    
    [_matchNumTextField setText: [[NSString alloc] initWithFormat:@"%i", _maxMatchNum]];
    
    [_userDefaults setInteger:_maxMatchNum forKey:_maxMatchNumKey];
    [_userDefaults synchronize];
}

- (void)changeShape {
    if ([_shape.titleLabel.text isEqualToString:_circleLabel]) {
        _shapeTitle = _rectLabel;
        _shapeGeom  = _circleLabel;
        [_rgbView.layer setCornerRadius: _rgbViewWidth / 2.0];
        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
        
    } else {
        _shapeTitle = _circleLabel;
        _shapeGeom  = _rectLabel;
        [_rgbView.layer setCornerRadius: CORNER_RADIUS_NONE];
        [_alertImageView.layer setCornerRadius: CORNER_RADIUS_NONE];

    }
    [_globalSettings setTap_area_shape: _shapeGeom];
    [_shape setTitle:_shapeTitle forState:UIControlStateNormal];
}


- (IBAction)showTypeOptions:(id)sender {
    [self presentViewController:_typeAlertController animated:YES completion:nil];
}

// ******************************************************************************
// Image and Color Methods
// ******************************************************************************

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
    
    CGContextSetLineWidth(ctx, 2.0);
    
    // set stroking color and draw shape
    //
    if ([color isEqualToString:@"white"]) {
        [LIGHT_TEXT_COLOR setStroke];
        
    } else {
        [CLEAR_COLOR setStroke];
    }
    
    int width  = _shapeLength;
    int height = _shapeLength;
    
    for (int i=0; i<_paintSwatches.count; i++) {
        
        PaintSwatches *swatchObj = [_paintSwatches objectAtIndex:i];

        CGPoint pt = CGPointFromString(swatchObj.coord_pt);
        
        CGFloat xpoint = pt.x - (_shapeLength / 2);
        CGFloat ypoint = pt.y - (_shapeLength / 2);
        
        // make shape 5 px from border
        //
        CGRect rect = CGRectMake(xpoint, ypoint, width, height);
        
        // draw rectangle or ellipse
        //
        if ([type isEqualToString:_rectLabel]) {
            CGContextStrokeRect(ctx, rect);
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


-(void)setRgbViewBorder {
    
    if ([_swatchObj.brightness floatValue] < _borderThreshold) {
        _rgbView.layer.borderColor = [LIGHT_BORDER_COLOR CGColor];
    } else {
        _rgbView.layer.borderColor = [DARK_BORDER_COLOR CGColor];
    }
}

-(void)setColorValues {
    
    _cgiImage = [UIImage imageWithCGImage:[_selectedImage CGImage]];
    
    UIColor *rgbColor = [ColorUtils getPixelColorAtLocation:_touchPoint image:_cgiImage];
    
    CGColorRef rgbPixelRef = [rgbColor CGColor];
    
    
    if(CGColorGetNumberOfComponents(rgbPixelRef) == 4) {
        const CGFloat *components = CGColorGetComponents(rgbPixelRef);
        _swatchObj.red   = [NSString stringWithFormat:@"%f", components[0] * 255];
        _swatchObj.green = [NSString stringWithFormat:@"%f", components[1] * 255];
        _swatchObj.blue  = [NSString stringWithFormat:@"%f", components[2] * 255];
    }
    
    [rgbColor getHue:&_hue saturation:&_sat brightness:&_bri alpha:&_alpha];

    _swatchObj.hue        = [NSString stringWithFormat:@"%f", _hue];
    _swatchObj.saturation = [NSString stringWithFormat:@"%f", _sat];
    _swatchObj.brightness = [NSString stringWithFormat:@"%f", _bri];
    _swatchObj.alpha      = [NSString stringWithFormat:@"%f", _alpha];
    _swatchObj.deg_hue    = [NSNumber numberWithFloat:_hue * 360];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TableView Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return _currTapSection;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (_currTapSection == 0) {
        [tableView setSeparatorColor: DARK_BORDER_COLOR];
    } else {
        [tableView setSeparatorColor: LIGHT_BORDER_COLOR];
    }

    if (indexPath.section == 0) {
        return 0.0;
    } else {
        return _cellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        AssocCollectionTableViewCell *custCell = (AssocCollectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
        
        if (! custCell) {
            custCell = [[AssocCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionViewCellIdentifier];
        }
        
        [custCell setBackgroundColor: DARK_BG_COLOR];
        
        [custCell setNoLabelLayout];
        
        [custCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        
        NSInteger index = custCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [custCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
        
        return custCell;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier];
        
        [cell setBackgroundColor: DARK_BG_COLOR];
        
        return cell;
    }
}

// Unused (delegate set to the collection view)
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Header sections
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return DEF_TABLE_HDR_HEIGHT;
    } else {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_SM_TBL_HDR_HEIGHT)];
    
    if (section == 0) {
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        
        CGFloat headerViewWidth  = tableView.bounds.size.width;
        UILabel *headerLabel     = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, _headerViewYOffset, headerViewWidth, _headerViewHeight)];
        [headerLabel setBackgroundColor: DARK_BG_COLOR];
        [headerLabel setTextColor: LIGHT_TEXT_COLOR];
        [headerLabel setFont: TABLE_HEADER_FONT];
        
        [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        
        //[headerLabel setTextAlignment: NSTextAlignmentCenter];
        if (_currTapSection > 0) {
            [headerLabel setText:[[NSString alloc] initWithFormat:@"Match Type Method: %@", [_matchAlgorithms objectAtIndex:_matchAlgIndex]]];
        }
        
        [headerLabel setTextAlignment:NSTextAlignmentLeft];
        [headerView addSubview:headerLabel];
        
        if (_currTapSection > 0) {
            _scrollViewUp = [[UIButton alloc] initWithFrame:CGRectMake(DEF_X_OFFSET + headerViewWidth - 60, _headerViewYOffset, 30, _headerViewHeight)];
            [_scrollViewUp setImage:_upArrowImage forState:UIControlStateNormal];
        }
        
        _scrollViewDown = [[UIButton alloc] initWithFrame:CGRectMake(DEF_X_OFFSET + headerViewWidth - 30, _headerViewYOffset, 30, _headerViewHeight)];
        [_scrollViewDown setImage:_downArrowImage forState:UIControlStateNormal];
        
        [_scrollViewUp addTarget:self action:@selector(scrollViewDecrease) forControlEvents:UIControlEventTouchUpInside];
        [_scrollViewDown addTarget:self action:@selector(scrollViewIncrease) forControlEvents:UIControlEventTouchUpInside];

        [_scrollViewUp setTintColor: LIGHT_TEXT_COLOR];
        [_scrollViewDown setTintColor: LIGHT_TEXT_COLOR];
        
        if ((_imageViewSize == 0) || (_currTapSection == 0)) {
            [_scrollViewUp setHidden:TRUE];
        } else {
            [_scrollViewUp setHidden:FALSE];
        }
        
        [headerView addSubview:_scrollViewUp];
        [headerView addSubview:_scrollViewDown];
    }

    return headerView;
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
    
    NSArray *collectionViewArray = [self.collectionMatchArray objectAtIndex:index];
    
    return (int)[collectionViewArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    int index = (int)collectionView.tag;
    
    PaintSwatches *paintSwatch = [[self.collectionMatchArray objectAtIndex:index] objectAtIndex:indexPath.row];
    
    UIImage *swatchImage;
    
    if (_isRGB == FALSE) {
        swatchImage = [ColorUtils renderPaint:paintSwatch.image_thumb cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
    } else {
        swatchImage = [ColorUtils renderRGB:paintSwatch cellWidth:_imageViewWidth cellHeight:_imageViewHeight];
    }
    
    // Tag the first reference image
    //
    if (indexPath.row == 0) {
        int area = _currTapSection - index;
        swatchImage = [ColorUtils drawTapAreaLabel:swatchImage count:area];
    }
    
    UIImageView *swatchImageView = [[UIImageView alloc] initWithImage:swatchImage];

    [swatchImageView.layer setBorderWidth: DEF_BORDER_WIDTH];
    [swatchImageView.layer setCornerRadius: DEF_CORNER_RADIUS];
    [swatchImageView.layer setBorderColor: [LIGHT_BORDER_COLOR CGColor]];
    
    [swatchImageView setContentMode: UIViewContentModeScaleAspectFit];
    [swatchImageView setClipsToBounds: YES];
    [swatchImageView setFrame:CGRectMake(_imageViewXOffset, DEF_Y_OFFSET, _imageViewWidth, _imageViewHeight)];
    
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
    
    if (textField.tag == MATCH_NUM_TAG) {
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:textField.text];
        
        if ([numbersOnly isSupersetOfSet:characterSetFromTextField]) {
            int newValue = [textField.text intValue];
            if (newValue > DEF_MAX_MATCH) {
                _maxMatchNum = DEF_MAX_MATCH;
                
            } else if (newValue <= 0) {
                _maxMatchNum = 1;
                
            } else {
                _maxMatchNum = newValue;
            }
        }
        [textField setText:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum]];
        [_matchNumStepper setValue:(double)_maxMatchNum];

    } else if (textField.tag == MATCH_NAME_TAG) {
        _matchName = ((UITextField *)[_editButtonAlertController.textFields objectAtIndex:0]).text;

    } else if (textField.tag == MATCH_DESC_TAG) {
        _matchDesc = ((UITextField *)[_editButtonAlertController.textFields objectAtIndex:1]).text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Match Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Match Methods

- (void)sortTapSection:(PaintSwatches *)refObj tapSection:(int)tapSection {
    
    _compPaintSwatches = [[NSMutableArray alloc] initWithArray:[MatchAlgorithms sortByClosestMatch:refObj swatches:_dbPaintSwatches matchAlgorithm:_matchAlgIndex maxMatchNum:_maxMatchNum context:self.context entity:_paintSwatchEntity]];
    
    while (tapSection < [_tapNumberArray count]) {
        [_tapNumberArray removeLastObject];
    }
    
    int tapIndex = tapSection - 1;
    if (tapIndex >= 0) {
        [_tapNumberArray setObject:_compPaintSwatches atIndexedSubscript:tapIndex];

        NSArray *tapNumberArrayReverse = [[_tapNumberArray reverseObjectEnumerator] allObjects];
        self.collectionMatchArray = [NSMutableArray arrayWithArray:tapNumberArrayReverse];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Mix Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Match Methods

- (void)addMixAssociation {
    _mixAssocEntity       = [NSEntityDescription entityForName:@"MixAssociation"   inManagedObjectContext:self.context];
    _mixAssociation = [[MixAssociation alloc] initWithEntity:_mixAssocEntity insertIntoManagedObjectContext:self.context];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(_selectedImage)];
    [_mixAssociation setImage_url:imageData];
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
    [self.imageTableView reloadData];
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
    [self.imageTableView reloadData];
}

- (IBAction)removeTableRows:(id)sender {
    if (_maxMatchNum > 1) {
        [_compPaintSwatches removeLastObject];
        _maxMatchNum--;
        
        // Re-run the comparison algorithm
        //
        [self refreshViews];
        
        [self.imageTableView reloadData];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:TRUE];
    }
    
    if (_maxMatchNum <= 1) {
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

- (IBAction)addTableRows:(id)sender {
    if (_maxMatchNum < _maxRowLimit) {
        _maxMatchNum++;
        
        // Re-run the comparison algorithm
        //
        [self refreshViews];
        
        [self.imageTableView reloadData];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: DECR_TAP_BTN_TAG isEnabled:TRUE];
        
    } else {
        UIAlertController *myAlert = [AlertUtils rowLimitAlert: _maxRowLimit];
        [self presentViewController:myAlert animated:YES completion:nil];
        [BarButtonUtils buttonEnabled:self.toolbarItems refTag: INCR_TAP_BTN_TAG isEnabled:FALSE];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Data Model Query/Update Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Data Model Query/Update Methods

- (BOOL)existsMatchAssocName {
    
    NSFetchedResultsController *frc = [CoreDataUtils fetchedResultsController: self.context entity: MATCH_ASSOCIATIONS sortDescriptor:@"name" predicate: [[NSString alloc] initWithFormat:@"name == '%@'", _matchName]];

    NSArray *objects = [frc fetchedObjects];
    
    if ([objects count] > 0) {
        UIAlertController *myAlert = [AlertUtils valueExistsAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        return TRUE;
    }
    
    return FALSE;
}

- (BOOL)updateMatchAssoc {
    
    // Run a series of checks first
    //
    if ([_matchName isEqualToString:@""]) {
        UIAlertController *myAlert = [AlertUtils noValueAlert];
        [self presentViewController:myAlert animated:YES completion:nil];
        return FALSE;
        
    } else if ([_matchName length] > MAX_NAME_LEN) {
        UIAlertController *myAlert = [AlertUtils sizeLimitAlert: MAX_NAME_LEN];
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
    [_matchAssociation setName:_matchName];
    [_matchAssociation setDesc:_matchDesc];
    [_matchAssociation setLast_update:currDate];

    
    // Add the TapAreas, TapAreaSwatches, and PaintSwatches
    //
    for (int i=0; i<[self.collectionMatchArray count];i++) {
        NSMutableArray *swatches = [self.collectionMatchArray objectAtIndex:i];
        
        PaintSwatches *tapAreaRef = [swatches objectAtIndex:0];
        int tap_order = (int)[self.collectionMatchArray count] - i;
        
        // Based on order
        //
        [tapAreaRef setType_id:[NSNumber numberWithInt:3]];
        
        
        // Check if TapArea already exists
        //
        TapArea *tapArea;
        if (tapAreaRef.tap_area == nil) {
            NSString *tapAreaName = [[NSString alloc] initWithFormat:@"Tap Area %i", tap_order];
            [tapAreaRef setName:tapAreaName];
            
            tapArea = [[TapArea alloc] initWithEntity:_tapAreaEntity insertIntoManagedObjectContext:self.context];
            [tapArea setMatch_algorithm_id:[NSNumber numberWithInt:_matchAlgIndex]];
            [tapArea setImage_section:tapAreaRef.image_thumb];
            [tapArea setTap_order:[NSNumber numberWithInt:tap_order]];
            [tapArea setCoord_pt:tapAreaRef.coord_pt];
            [tapArea setMatch_association:_matchAssociation];
            [tapArea setName:[[NSString alloc] initWithFormat:@"%@ Tap Area %i", _matchName, tap_order]];
            [tapArea setTap_area_match:tapAreaRef];
            [tapAreaRef setTap_area:tapArea];

            [_matchAssociation addTap_areaObject:tapArea];

        } else {
            tapArea = tapAreaRef.tap_area;
        }
        
        // Remove existing TapAreaSwatch elements (will add them back in)
        //
        NSArray *tapAreaSwatches = [tapArea.tap_area_swatch allObjects];
        for (int i=0; i<[tapAreaSwatches count]; i++) {
            TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
            PaintSwatches *paintSwatch   = (PaintSwatches *)tapAreaSwatch.paint_swatch;
            
            [tapArea removeTap_area_swatchObject:tapAreaSwatch];
            [paintSwatch removeTap_area_swatchObject:tapAreaSwatch];
            [self.context deleteObject:tapAreaSwatch];
        }
        

        // Add back the TapAreaSwatch elements
        //
        for (int j=1; j<(int)[swatches count]; j++) {
            PaintSwatches *paintSwatch = [swatches objectAtIndex:j];
            
            // Check if the TapAreaSwatch already exists
            //
            TapAreaSwatch *tapAreaSwatch = [[TapAreaSwatch alloc] initWithEntity:_tapAreaSwatchEntity insertIntoManagedObjectContext:self.context];
            [tapAreaSwatch setPaint_swatch:(PaintSwatch *)paintSwatch];
            [tapAreaSwatch setTap_area:tapArea];
            [tapAreaSwatch setMatch_order:[NSNumber numberWithInt:j]];
            
            [tapArea addTap_area_swatchObject:tapAreaSwatch];
            [paintSwatch addTap_area_swatchObject:tapAreaSwatch];
        }
    }
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        UIAlertController *myAlert = [AlertUtils createOkAlert:@"MatchAssociation and relations save" message:@"Error saving"];
        [self presentViewController:myAlert animated:YES completion:nil];

    } else {
        NSLog(@"MatchAssociation and relations save successful");
        
        // Update the title
        //
        [[self.navigationItem.titleView.subviews objectAtIndex:0] setText:_matchName];
    }
    return TRUE;
}

- (void)deleteTapArea:(PaintSwatches *)paintSwatch {
    TapArea *tapArea = paintSwatch.tap_area;
    [self.context deleteObject:tapArea];
    [self.context deleteObject:paintSwatch];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Navigation Methods

- (IBAction)segueToMatchOrAssoc:(id)sender {
    if ([_viewType isEqualToString:@"assoc"]) {
        [self performSegueWithIdentifier:@"AssocTableViewSegue" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AssocTableViewSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
        
        [assocTableViewController setPaintSwatches:_paintSwatches];
        [assocTableViewController setMixAssociation:_mixAssociation];
        [assocTableViewController setSaveFlag:_saveFlag];

        
    } else if ([[segue identifier] isEqualToString:@"MatchTableViewSegue"]) {
        PaintSwatches *paintSwatch = [[self.collectionMatchArray objectAtIndex:_currSelectedSection] objectAtIndex:0];
        
        UINavigationController *navigationViewController = [segue destinationViewController];
        MatchTableViewController *matchTableViewController = (MatchTableViewController *)([navigationViewController viewControllers][0]);
        
        [matchTableViewController setSelPaintSwatch:paintSwatch];
        
        int currTapSection = _currTapSection - _currSelectedSection;
        [matchTableViewController setCurrTapSection:currTapSection];
        [matchTableViewController setReferenceImage:_referenceTappedImage];
        [matchTableViewController setMatchAlgIndex:_matchAlgIndex];
        [matchTableViewController setMaxMatchNum:_maxMatchNum];
        [matchTableViewController setDbPaintSwatches:_dbPaintSwatches];

    } else {
        NSLog(@"Segue Identifier %@, row %i", [segue identifier], _currTapSection);
    }
}

- (IBAction)unwindToImageViewFromAssoc:(UIStoryboardSegue *)segue {
    AssocTableViewController *sourceViewController = [segue sourceViewController];
    
    _paintSwatches  = sourceViewController.paintSwatches;
    _mixAssociation = sourceViewController.mixAssociation;
    _saveFlag       = sourceViewController.saveFlag;

    
    // Disable the view and algorithm buttons
    //
    if ([_paintSwatches count] == 0) {
        [self viewButtonHide];
        [self matchButtonsHide];
    }
    
    [self drawTapAreas];
}

- (IBAction)unwindToImageViewFromMatch:(UIStoryboardSegue *)segue {
    MatchTableViewController *sourceViewController = [segue sourceViewController];

    _maxMatchNum = sourceViewController.maxMatchNum;
    
    [self drawTapAreas];
    [self refreshViews];
}

- (IBAction)goBack:(id)sender {
    [self.context rollback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
