//
//  ImageTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 8/30/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "ImageTableViewController.h"
#import "AppDelegate.h"
#import "ColorUtils.h"
#import "AssocTableViewController.h"
#import "CoreDataUtils.h"
#import "ViewController.h"
#import "BarButtonUtils.h"

@interface ImageTableViewController ()

@property (nonatomic, strong) NSString *reuseCellIdentifier;

@property (nonatomic, strong) UILabel *titleLabel, *stepperLabel, *tapMeLabel;
@property (nonatomic, strong) UIImageView *imageView, *rgbView, *alertImageView;
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) UIButton *shape;
@property (nonatomic) int goBackStatus, viewInit, shapeLength;
@property (nonatomic, strong) UIImage *cgiImage, *rgbImage, *infoImage;
@property (nonatomic, strong) NSMutableArray *paintSwatches, *mixAssociations;
@property (nonatomic, strong) GlobalSettings *globalSettings;
@property (nonatomic, strong) NSString *defaultRefName;
@property (nonatomic, strong) UIColor *defaultColor;

@property (nonatomic, strong) UIAlertController *typeAlertController;

@property (nonatomic, strong) UIAlertView *tapAreaAlertView, *clearTapsAlertView;
@property (nonatomic) int tapAreaSeen, tapAreaSize;
@property (nonatomic) BOOL saveFlag;
@property (nonatomic, strong) NSString *tapAreaShape, *shapeGeom, *rectLabel, *circleLabel, *shapeTitle, *viewType;
@property (nonatomic) int stepMinVal, stepMaxVal, stepIncVal;
@property (nonatomic) CGFloat screenWidth, titleOrigin, titleWidth, rgbOrigin, rgbWidth, rectSize, rgbViewWidth, rgbViewHeight, sizePadding, imgViewOffsetX, offsetY;

@property (nonatomic) CGFloat hue, sat, bri, alpha, borderThreshold;
@property (nonatomic, strong) UIView *titleAndRGBView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer, *rgbTapRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) CGPoint touchPoint;

@property (nonatomic, strong) PaintSwatches *swatchObj;
@property (nonatomic, strong) ACPMixAssociationsDesc *mixAssocDesc;

@end

@implementation ImageTableViewController

//#pragma mark - Initialization Methods
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    _reuseCellIdentifier = @"ImageTableViewCell";
//    
//    
//    // Initial CoreData state
//    //
//    [self setSaveFlag: FALSE];
//    
//    // Go back storyboard (i.e., home) status
//    //
//    [self setGoBackStatus: 1];
//    
//    // View globals
//    //
//    [self setViewInit: 1];
//    [self setRgbViewWidth: 40];
//    [self setSizePadding: 20.0];
//    [self setImgViewOffsetX: 30.0];
//    
//    // Stepper
//    //
//    [self setStepMinVal: 24];
//    [self setStepMaxVal: 52];
//    [self setStepIncVal: 4];
//    
//    // Labels
//    //
//    [self setRectLabel: @"Rect"];
//    [self setCircleLabel: @"Circle"];
//    
//    
//    // Defaults
//    //
//    [self setDefaultRefName: @"Reference Image"];
//    [self setTapAreaSize: 40];
//    [self setTapAreaShape: _circleLabel];
//    
//    
//    [self setGlobalSettings: [CoreDataUtils fetchGlobalSettings]];
//    [self setShapeLength: _globalSettings.tap_area_size];
//    [self setShapeGeom: _globalSettings.tap_area_shape];
//    
//    
//    // Default color used for the widgets
//    //
//    [self setDefaultColor: [GlobalSettings getDefaultColor]];
//    
//    
//    // Add the selected image
//    //
//    //[self initImage];
//    
//    
//    // Tap size Alert View
//    //
//    _tapAreaAlertView = [[UIAlertView alloc] initWithTitle:@"Tap Area RGB Display"
//                                                   message:@"The stepper and button can be used to change the size and shape of the tap area."
//                                                  delegate:self
//                                         cancelButtonTitle:@"Done"
//                                         otherButtonTitles:@"Save Settings", nil];
//    [_tapAreaAlertView setTintColor:[UIColor blackColor]];
//    [_tapAreaAlertView setTag: 1];
//    
//    
//    // Sizing parameters
//    //
//    CGFloat viewHeight     = _shapeLength + _sizePadding * 2;
//    CGFloat stepperOffsetX = 80.0;
//    CGFloat stepperOffsetY = _sizePadding + (_shapeLength / 2) - 13.0;
//    CGFloat shapeOffsetX   = 190.0;
//    CGFloat shapeOffsetY  = _sizePadding + (_shapeLength / 2) - 11.0;
//    
//    
//    // Creat the alertView main frame (to contain the imageView, stepper, and stepper label)
//    //
//    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, viewHeight)];
//    [mainView setBackgroundColor: [UIColor blackColor]];
//    
//    
//    // UIImageView (represents the current tap area)
//    //
//    [self setOffsetY: _sizePadding];
//    _alertImageView = [[UIImageView alloc] initWithFrame: CGRectMake(_imgViewOffsetX, _offsetY, _shapeLength, _shapeLength)];
//    [_alertImageView setBackgroundColor: _defaultColor];
//    
//    if ([_shapeGeom isEqualToString:_circleLabel]) {
//        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
//        [_alertImageView.layer setBorderWidth: 1.0];
//    } else {
//        [_alertImageView.layer setCornerRadius: 0.0];
//        [_alertImageView.layer setBorderWidth: 1.0];
//    }
//    
//    CGColorRef whiteBorder = [[UIColor whiteColor] CGColor];
//    [_alertImageView.layer setBorderColor: whiteBorder];
//    
//    
//    // Label displaying the value in the stepper
//    //
//    int size = (int)_shapeLength;
//    
//    _stepperLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _shapeLength, _shapeLength)];
//    [_stepperLabel setTextColor:[UIColor blackColor]];
//    [_stepperLabel setBackgroundColor:[UIColor clearColor]];
//    [_stepperLabel setText: [[NSString alloc] initWithFormat:@"%i", size]];
//    [_stepperLabel setTextAlignment: NSTextAlignmentCenter];
//    [_alertImageView addSubview:_stepperLabel];
//    
//    
//    // UIStepper (change the size of the tapping area)
//    //
//    _stepper = [[UIStepper alloc] initWithFrame:CGRectMake(stepperOffsetX, stepperOffsetY, _shapeLength, _shapeLength)];
//    [_stepper setTintColor: _defaultColor];
//    [_stepper addTarget:self action:@selector(stepperPressed) forControlEvents:UIControlEventValueChanged];
//    
//    
//    // Set min, max, step, and default values and wraps parameter
//    //
//    [_stepper setMinimumValue:_stepMinVal];
//    [_stepper setMaximumValue:_stepMaxVal];
//    [_stepper setStepValue:_stepIncVal];
//    [_stepper setValue:_shapeLength];
//    [_stepper setWraps:NO];
//    
//    
//    // Initialize the shape
//    //
//    if ([_shapeGeom isEqualToString:_circleLabel]) {
//        [self setShapeTitle: _rectLabel];
//    } else {
//        [self setShapeTitle: _circleLabel];
//    }
//    
//    _shape = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [_shape setFrame: CGRectMake(shapeOffsetX, shapeOffsetY, 60.0, 26.0)];
//    [_shape setTitle:_shapeTitle forState:UIControlStateNormal];
//    [_shape setTintColor: [UIColor blackColor]];
//    [_shape setBackgroundColor: _defaultColor];
//    [_shape addTarget:self action:@selector(changeShape) forControlEvents:UIControlEventTouchUpInside];
//    
//    [mainView addSubview:_alertImageView];
//    [mainView addSubview:_stepper];
//    [mainView addSubview:_shape];
//    
//    [_tapAreaAlertView setValue:mainView forKey:@"accessoryView"];
//    
//    
//    // Clear taps Alert View
//    //
//    _clearTapsAlertView = [[UIAlertView alloc] initWithTitle:@"Clear Taps"
//                                                     message:@"Do you want to clear all tapped areas?"
//                                                    delegate:self
//                                           cancelButtonTitle:@"No"
//                                           otherButtonTitles:@"Yes", nil];
//    [_clearTapsAlertView setTintColor:[UIColor blackColor]];
//    [_clearTapsAlertView setTag: 2];
//    
//    
//    // Adjust the NavBar layout when the orientation changes
//    //
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
//    
//    // Type Alert Controller
//    //
//    _typeAlertController = [UIAlertController alertControllerWithTitle:@"Action Types"
//                                                               message:@"Please select from the match actions below:"
//                                                        preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* defaultAction   = [UIAlertAction actionWithTitle:@"Match Colors (default)" style:UIAlertActionStyleDefault
//                                                            handler:^(UIAlertAction * action) {
//                                                                _viewType = @"match";
//                                                                
//                                                                UIBarButtonItem *matchButton = [[UIBarButtonItem alloc] initWithTitle:@"Match"
//                                                                                                                                style:      UIBarButtonItemStylePlain
//                                                                                                                               target: self
//                                                                                                                               action: @selector(selectAction)];
//                                                                
//                                                                [matchButton setTintColor:_defaultColor];
//                                                                
//                                                                
//                                                                NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
//                                                                [items replaceObjectAtIndex:2 withObject:matchButton];
//                                                                [self setToolbarItems:items];
//                                                            }];
//    
//    UIAlertAction *associateMixes = [UIAlertAction actionWithTitle:@"Associate Mixes" style:UIAlertActionStyleDefault                     handler:^(UIAlertAction * action) {
//        _viewType = @"assoc";
//        
//        UIBarButtonItem *assocButton = [[UIBarButtonItem alloc] initWithTitle:@"Assoc"
//                                                                        style:UIBarButtonItemStylePlain
//                                                                       target: self
//                                                                       action: @selector(selectAction)];
//        
//        
//        [assocButton setTintColor:_defaultColor];
//        
//        NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
//        [items replaceObjectAtIndex:2 withObject:assocButton];
//        [self setToolbarItems:items];
//        
//    }];
//    
//    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//        [_typeAlertController dismissViewControllerAnimated:YES completion:nil];
//    }];
//    
//    [_typeAlertController addAction:defaultAction];
//    [_typeAlertController addAction:associateMixes];
//    [_typeAlertController addAction:alertCancel];
//    
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}
//
//- (void)viewDidAppear:(BOOL)didAppear {
//    
//    // Get this value for calculating the relative dimensions
//    //
//    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
//    
//    // Left back button
//    //
//    CGFloat leftItemWidth  = self.navigationItem.leftBarButtonItem.width;
//    
//    
//    // Key origins and dimensions
//    //
//    CGRect navBarBounds        = self.navigationController.navigationBar.bounds;
//    CGFloat navBarOriginY      = navBarBounds.origin.y;
//    CGFloat navBarWidth        = navBarBounds.size.width;
//    CGFloat navBarHeight       = navBarBounds.size.height;
//    
//    CGFloat titleViewOrigin    = 0.0;
//    CGFloat titleViewWidth     = navBarWidth - leftItemWidth;
//    
//    _rgbViewWidth              = MIN(_rgbViewWidth, navBarHeight - 2.0);
//    
//    CGFloat rgbViewWidthOffset = _rgbViewWidth + (_screenWidth / 10);
//    CGFloat rgbViewOrigin      = titleViewWidth - rgbViewWidthOffset;
//    
//    _rgbViewHeight             = _rgbViewWidth;
//    
//    CGFloat titleLabelWidth    = titleViewWidth - rgbViewWidthOffset;
//    
//    
//    // Main view containing the label and RGB image view that is added to the NavBar titleView
//    //
//    _titleAndRGBView = [[UIView alloc] initWithFrame:CGRectMake(titleViewOrigin, navBarOriginY, titleViewWidth, _rgbViewHeight)];
//    
//    
//    // Default label
//    //
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleViewOrigin,navBarOriginY,titleLabelWidth,navBarHeight)];
//    [_titleLabel setTextColor:_defaultColor];
//    [_titleLabel setTextAlignment: NSTextAlignmentCenter];
//    [_titleLabel setBackgroundColor:[UIColor clearColor]];
//    [_titleLabel setText:_defaultRefName];
//    [_titleAndRGBView addSubview:_titleLabel];
//    
//    
//    // RGB view
//    //
//    _rgbView = [[UIImageView alloc] initWithFrame:CGRectMake(rgbViewOrigin, navBarOriginY, _rgbViewWidth, _rgbViewHeight)];
//    _rgbView.layer.masksToBounds = YES;
//    if ([_shapeGeom isEqualToString:_circleLabel]) {
//        _rgbView.layer.cornerRadius = _rgbViewWidth / 2.0;
//        _rgbView.layer.borderWidth  = 1.0;
//    } else {
//        _rgbView.layer.cornerRadius = 0.0;
//        _rgbView.layer.borderWidth  = 1.0;
//    }
//    
//    CGColorRef whiteBorder = [[UIColor whiteColor] CGColor];
//    _rgbView.layer.borderColor = whiteBorder;
//    _rgbView.backgroundColor = [UIColor clearColor];
//    
//    _tapMeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 0.0, _rgbViewWidth, _rgbViewHeight)];
//    [_tapMeLabel setTextColor:[UIColor blackColor]];
//    [_tapMeLabel setBackgroundColor:[UIColor clearColor]];
//    [_tapMeLabel setFont:[GlobalSettings getDefaultSmallFont]];
//    [_tapMeLabel setTag:1];
//    [_tapMeLabel setText:@"Tap Me"];
//    [_rgbView addSubview: _tapMeLabel];
//    
//    
//    // Set to render latest RGB value for touchpoint
//    //
//    //if (_rgbImage != nil) {
//    if (_viewInit == 0) {
//        _rgbView.image = _rgbImage;
//        [_tapMeLabel setText:@""];
//        
//        // _viewInit set once in viewDidLoad
//        //
//    } else if (_viewInit == 1) {
//        
//        //_rgbView.image = _infoImage;
//        
//        _rgbView.backgroundColor = _defaultColor;
//        _viewInit = 0;
//    }
//    
//    // Add a tap recognizer to the RGB View that will bring up a UIAlertView
//    // (to be used for setting the size of the tap area)
//    //
//    _rgbView.userInteractionEnabled = YES;
//    _rgbTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToRgbTap:)];
//    _rgbTapRecognizer.numberOfTouchesRequired = 1;
//    [_rgbView addGestureRecognizer:_rgbTapRecognizer];
//    
//    [_titleAndRGBView addSubview:_rgbView];
//    
//    self.navigationItem.titleView = _titleAndRGBView;
//}
//
//- (void)initImage {
//    [self setImageView: [[UIImageView alloc] initWithImage:_selectedImage]];
//    [_imageView setUserInteractionEnabled: YES];
//    [_imageScrollView addSubview:_imageView];
//    [_imageScrollView setContentSize:_selectedImage.size];
//    [_imageScrollView setDelegate: self];
//    
//    CGRect scrollViewFrame = _imageScrollView.frame;
//    CGFloat scaleWidth = scrollViewFrame.size.width / _imageScrollView.contentSize.width;
//    CGFloat scaleHeight = scrollViewFrame.size.height / _imageScrollView.contentSize.height;
//    CGFloat minScale = MIN(scaleWidth, scaleHeight);
//    
//    [_imageScrollView setMinimumZoomScale: minScale];
//    [_imageScrollView setMaximumZoomScale: 5.0f];
//    [_imageScrollView setZoomScale: minScale];
//    
//    [self centerScrollViewContents];
//    
//    // Initialize a tap gesture recognizer for selected image regions
//    // and specify that the gesture must be a single tap
//    //
//    _tapRecognizer = [[UITapGestureRecognizer alloc]
//                      initWithTarget:self action:@selector(respondToTap:)];
//    [_tapRecognizer setNumberOfTapsRequired: 1];
//    [_imageView addGestureRecognizer:_tapRecognizer];
//    
//    
//    // Initialize a pinch gesture recognizer for zooming in/out of the image
//    //
//    _pinchRecognizer = [[UIPinchGestureRecognizer alloc]
//                        initWithTarget:self action:@selector(respondToPinch:)];
//    [_imageView addGestureRecognizer:_pinchRecognizer];
//    
//    
//    // Threshold brightness value under which a white border is drawn around the RGB image view
//    // (default border is black)
//    //
//    [self setBorderThreshold: 0.34];
//    
//    
//    // List of coordinates associated with tapped regions (i.e., GCPoint)
//    //
//    _paintSwatches = [[NSMutableArray alloc] init];
//    
//    
//    // Set the info image
//    //
//    [self setInfoImage: [UIImage imageNamed:@"question.png"]];
//    
//    
//    // Long press recognizer
//    //
//    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [_longPressRecognizer setMinimumPressDuration: 1.0f];
//    [_longPressRecognizer setAllowableMovement: 100.0f];
//    [_imageView addGestureRecognizer:_longPressRecognizer];
//}
//
//#pragma mark - Scrolling and Action Selection Methods
//
//- (void)centerScrollViewContents {
//    CGSize boundsSize = _imageScrollView.bounds.size;
//    CGRect contentsFrame = _imageView.frame;
//    
//    if (contentsFrame.size.width < boundsSize.width) {
//        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
//    } else {
//        contentsFrame.origin.x = 0.0f;
//    }
//    
//    if (contentsFrame.size.height < boundsSize.height) {
//        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
//    } else {
//        contentsFrame.origin.y = 0.0f;
//    }
//    
//    [_imageView setFrame: contentsFrame];
//}
//
//- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return _imageView;
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    [self centerScrollViewContents];
//}
//
//- (void)selectAction {
//    [self presentViewController:_typeAlertController animated:YES completion:nil];
//}
//
//// ******************************************************************************
//// Handle tap, pinch, and long press events
//// ******************************************************************************
//
//#pragma mark - Gesture Recognizer Methods
//
//- (void)respondToTap:(id)sender {
//    
//    _touchPoint = [sender locationInView: _imageView];
//    
//    [self drawTouchShape];
//    
//    if (_tapAreaSeen == 0) {
//        [self setRgbView];
//        
//    } else {
//        [self setRgbImage: nil];
//        [_rgbView setImage: nil];
//        [_rgbView setBackgroundColor: [UIColor clearColor]];
//    }
//}
//
//
//// Render the UIAlertView pop-up
////
//- (void)respondToRgbTap:(id)sender {
//    [_tapAreaAlertView show];
//}
//
//
//- (void)respondToPinch:(UIPinchGestureRecognizer *)recognizer {
//    
//    float imageScale = sqrtf(recognizer.view.transform.a * recognizer.view.transform.a +
//                             recognizer.view.transform.c * recognizer.view.transform.c);
//    if ((recognizer.scale > 1.0) && (imageScale >= 2.00)) {
//        return;
//    }
//    if ((recognizer.scale < 1.0) && (imageScale <= 0.75)) {
//        return;
//    }
//    [recognizer.view setTransform: CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale)];
//    [recognizer setScale: 1.0];
//}
//
//- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
//    
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        [_clearTapsAlertView show];
//    }
//}
//
//- (void)drawTouchShape {
//    int listCount = (int)_paintSwatches.count;
//    [self setTapAreaSeen: 0];
//    
//    NSMutableArray *tempPaintSwatches = _paintSwatches;
//    _paintSwatches = [[NSMutableArray alloc] init];
//    
//    int seen_index = 0;
//    
//    for (int i=0; i<listCount; i++) {
//        PaintSwatches *swatchObj = tempPaintSwatches[i];
//        
//        CGPoint pt = swatchObj.coord_pt;
//        
//        //CGPoint pt = [(NSValue *)tempPaintSwatches[i] CGPointValue];
//        CGFloat xpt = pt.x - (_shapeLength / 2);
//        CGFloat ypt = pt.y - (_shapeLength / 2);
//        
//        CGFloat xtpt= _touchPoint.x - (_shapeLength / 2);
//        CGFloat ytpt= _touchPoint.y - (_shapeLength / 2);
//        
//        
//        if ((abs((int)(xtpt - xpt)) <= _shapeLength) && (abs((int)(ytpt - ypt)) <= _shapeLength)) {
//            [self setTapAreaSeen: 1];
//            seen_index   = i;
//            
//            //            if (swatchObj.uid != 0) {
//            //                int stat = (int)[CoreDataUtils deletePaintSwatch:swatchObj];
//            //                // In this context no need to check referential integrity
//            //                // as stat should never be more than 1
//            //            }
//            
//        } else {
//            [_paintSwatches addObject:swatchObj];
//        }
//    }
//    
//    int newCount = (int)_paintSwatches.count;
//    if (_tapAreaSeen == 0) {
//        
//        // Instantiate the new PaintSwatch Object
//        //
//        _swatchObj = [[PaintSwatches alloc] init];
//        [_swatchObj setCoord_pt: _touchPoint];
//        
//        // Set the RGB and HSB value
//        //
//        [self setColorValues];
//        
//        // Save the thumbnail image
//        //
//        CGFloat xpt= _touchPoint.x - (_shapeLength / 2);
//        CGFloat ypt= _touchPoint.y - (_shapeLength / 2);
//        [_swatchObj setImage_thumb: [self cropImage:_selectedImage frame:CGRectMake(xpt, ypt, _shapeLength, _shapeLength)]];
//        [_paintSwatches addObject:_swatchObj];
//        
//        // Enable list and save buttons
//        //
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:4 isEnabled:TRUE];
//        
//    } else if (newCount == 0) {
//        // Disable save button
//        //
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:4 isEnabled:FALSE];
//    }
//    
//    [self drawTapAreas];
//}
//
//- (void)drawTapAreas {
//    
//    UIImage *tempImage = [self imageWithBorderFromImage:_selectedImage rectSize:_selectedImage.size shapeType:_shapeGeom lineColor:@"white"];
//    
//    tempImage = [self drawText:tempImage];
//    
//    [_imageView setImage: tempImage];
//    [_imageView.layer setMasksToBounds: YES];
//    [_imageView.layer setCornerRadius: 5.0];
//}
//
//-(UIImage*)drawText:(UIImage*)image {
//    
//    UIImage *retImage = image;
//    
//    for (int i=0; i<_paintSwatches.count; i++) {
//        
//        int count = i + 1;
//        NSString *countStr = [[NSString alloc] initWithFormat:@"%i", count];
//        
//        PaintSwatches *swatchObj = _paintSwatches[i];
//        
//        CGPoint pt = swatchObj.coord_pt;
//        CGFloat x, y;
//        if ([_shapeGeom isEqualToString:_circleLabel]) {
//            x = pt.x - (_shapeLength / 3.3);
//            y = pt.y - (_shapeLength / 3.3);
//        } else {
//            x = pt.x - (_shapeLength / 2) + 2.0;
//            y = pt.y - (_shapeLength / 2) + 2.0;
//        }
//        
//        UIGraphicsBeginImageContext(image.size);
//        
//        [retImage drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
//        CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);
//        
//        UIColor *textColor = [UIColor whiteColor];
//        UIFont *font       = [UIFont boldSystemFontOfSize:10];
//        UIColor *bgndColor   = [UIColor blackColor];
//        
//        NSDictionary *attr = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font, NSBackgroundColorAttributeName: bgndColor};
//        
//        [countStr drawInRect:CGRectInset(rect, 2.0, 2.0) withAttributes:attr];
//        
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        retImage = newImage;
//    }
//    
//    return retImage;
//}
//
//#pragma mark - AlertView and Containing Widgets Methods
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 1) {
//        if(buttonIndex == 1) {
//            [CoreDataUtils updateGlobalSettings:_globalSettings];
//        }
//        
//    } else {
//        if (buttonIndex == 1) {
//            [self setPaintSwatches: nil];
//            [_imageView setImage: _selectedImage];
//            [_rgbView setImage: _infoImage];
//            [_rgbView setBackgroundColor: _defaultColor];
//            
//            // Disable the save button
//            //
//            [BarButtonUtils buttonEnabled:self.toolbarItems refTag:4 isEnabled:FALSE];
//        }
//    }
//}
//
//- (void)setRgbView {
//    UIColor *swatchColor = [UIColor colorWithRed:(_swatchObj.red/255.0) green:(_swatchObj.grn/255.0) blue:(_swatchObj.blu/255.0) alpha:_swatchObj.alpha];
//    
//    _rgbImage = [ColorUtils imageWithColor:swatchColor objWidth:_rgbViewWidth objHeight:_rgbViewHeight];
//    
//    [_rgbView setImage: _rgbImage];
//    [_tapMeLabel setText:@""];
//}
//
//- (void)stepperPressed {
//    int size = (int)_stepper.value;
//    
//    [_stepperLabel setText: [[NSString alloc] initWithFormat:@"%i", size]];
//    
//    CGFloat oldshapeLength = _shapeLength;
//    [self setShapeLength: (CGFloat)_stepper.value];
//    [_globalSettings setTap_area_size: _shapeLength];
//    
//    CGFloat diff = _shapeLength - oldshapeLength;
//    
//    _imgViewOffsetX = _imgViewOffsetX - (diff / 2.0);
//    _offsetY        = _offsetY - (diff / 2.0);
//    
//    [_alertImageView setFrame: CGRectMake(_imgViewOffsetX, _offsetY, _shapeLength, _shapeLength)];
//    if ([_shapeGeom isEqualToString:_circleLabel]) {
//        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
//    } else {
//        [_alertImageView.layer setCornerRadius: 0.0];
//    }
//    
//    [_stepperLabel setFrame: CGRectMake(0.0, 0.0, _shapeLength, _shapeLength)];
//}
//
//-(void)changeShape {
//    if ([_shape.titleLabel.text isEqualToString:_circleLabel]) {
//        _shapeTitle = _rectLabel;
//        _shapeGeom  = _circleLabel;
//        [_rgbView.layer setCornerRadius: _rgbViewWidth / 2.0];
//        [_alertImageView.layer setCornerRadius: _shapeLength / 2.0];
//        
//    } else {
//        _shapeTitle = _circleLabel;
//        _shapeGeom  = _rectLabel;
//        [_rgbView.layer setCornerRadius: 0.0];
//        [_alertImageView.layer setCornerRadius: 0.0];
//        
//    }
//    [_globalSettings setTap_area_shape: _shapeGeom];
//    [_shape setTitle:_shapeTitle forState:UIControlStateNormal];
//}
//
//
//
//- (IBAction)showTypeOptions:(id)sender {
//    [self presentViewController:_typeAlertController animated:YES completion:nil];
//}
//
//// ******************************************************************************
//// Image and Color Methods
//// ******************************************************************************
//
//#pragma mark - Image and Color Methods
//
//- (UIImage*)imageWithBorderFromImage:(UIImage*)image rectSize:(CGSize)size shapeType:(NSString *)type lineColor:(NSString *)color {
//    // Begin a graphics context of sufficient size
//    //
//    UIGraphicsBeginImageContext(size);
//    
//    
//    // draw original image into the context]
//    //
//    [image drawAtPoint:CGPointZero];
//    
//    // get the context for CoreGraphics
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextSetLineWidth(ctx, 2.0);
//    
//    // set stroking color and draw shape
//    //
//    if ([color isEqualToString:@"white"]) {
//        [[UIColor whiteColor] setStroke];
//        
//    } else {
//        [[UIColor clearColor] setStroke];
//    }
//    
//    int width  = _shapeLength;
//    int height = _shapeLength;
//    
//    for (int i=0; i<_paintSwatches.count; i++) {
//        
//        PaintSwatches *swatchObj = _paintSwatches[i];
//        
//        CGPoint pt = swatchObj.coord_pt;
//        
//        CGFloat xpoint = pt.x - (_shapeLength / 2);
//        CGFloat ypoint = pt.y - (_shapeLength / 2);
//        
//        // make shape 5 px from border
//        //
//        CGRect rect = CGRectMake(xpoint, ypoint, width, height);
//        
//        // draw rectangle or ellipse
//        //
//        if ([type isEqualToString:_rectLabel]) {
//            CGContextStrokeRect(ctx, rect);
//        } else {
//            CGContextStrokeEllipseInRect(ctx, rect);
//        }
//    }
//    
//    // make image out of bitmap context
//    //
//    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    // Free the context
//    //
//    UIGraphicsEndImageContext();
//    
//    
//    return retImage;
//}
//
//
//- (UIImage *)cropImage:(UIImage*)image frame:(CGRect)rect {
//    
//    rect = CGRectMake(rect.origin.x    * image.scale,
//                      rect.origin.y    * image.scale,
//                      rect.size.width  * image.scale,
//                      rect.size.height * image.scale);
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
//    
//    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
//                                                scale:image.scale
//                                          orientation:image.imageOrientation];
//    
//    CGImageRelease(imageRef);
//    
//    return croppedImage;
//}
//
//
//-(void)setRgbViewBorder {
//    
//    if (_swatchObj.bri < _borderThreshold) {
//        CGColorRef whiteBorder = [[UIColor whiteColor] CGColor];
//        _rgbView.layer.borderColor = whiteBorder;
//        
//    } else {
//        CGColorRef blackBorder = [[UIColor blackColor] CGColor];
//        _rgbView.layer.borderColor = blackBorder;
//    }
//}
//
//-(void)setColorValues {
//    
//    _cgiImage = [UIImage imageWithCGImage:[_selectedImage CGImage]];
//    
//    UIColor *rgbColor = [ColorUtils getPixelColorAtLocation:_touchPoint image:_cgiImage];
//    
//    CGColorRef rgbPixelRef = [rgbColor CGColor];
//    
//    
//    if(CGColorGetNumberOfComponents(rgbPixelRef) == 4) {
//        const CGFloat *components = CGColorGetComponents(rgbPixelRef);
//        _swatchObj.red = components[0] * 255;
//        _swatchObj.grn = components[1] * 255;
//        _swatchObj.blu = components[2] * 255;
//    }
//    
//    [rgbColor getHue:&_hue saturation:&_sat brightness:&_bri alpha:&_alpha];
//    
//    _swatchObj.hue     = _hue;
//    _swatchObj.sat     = _sat;
//    _swatchObj.bri     = _bri;
//    _swatchObj.alpha   = _alpha;
//    _swatchObj.deg_hue = [NSNumber numberWithFloat:_hue * 360];
//}
//
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    if (section == 0) {
//        return 1;
//    } else {
//        return 2;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
//    if (indexPath.section == 0) {
//        return DEF_XLG_TBL_CELL_HGT + DEF_FIELD_PADDING;
//    }
//    
//    return DEF_MD_TABLE_CELL_HGT;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
//    
//    // Global defaults
//    //
//    [cell setBackgroundColor: [UIColor blackColor]];
//    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
//    
//    if (indexPath.section == 0) {
//        [self initImage];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEF_XLG_TBL_CELL_HGT)];
//        [cell addSubview:view];
//        [view addSubview:_imageView];
//        
//    } else {
//        
//    }
//    
//    return cell;
//}
//
//
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//#pragma mark - Segue and Navigation Methods
//
//- (IBAction)segueToMatchOrAssoc:(id)sender {
//    if ([_viewType isEqualToString:@"assoc"]) {
//        [self performSegueWithIdentifier:@"AssocTableViewSegue2" sender:self];
//    } else {
//        [self performSegueWithIdentifier:@"MatchTableViewSegue2" sender:self];
//    }
//}
//
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([[segue identifier] isEqualToString:@"AssocTableViewSegue2"]) {
//        UINavigationController *navigationViewController = [segue destinationViewController];
//        AssocTableViewController *assocTableViewController = (AssocTableViewController *)([navigationViewController viewControllers][0]);
//        
//        [assocTableViewController setPaintSwatches:_paintSwatches];
//        [assocTableViewController setMixAssocDesc:_mixAssocDesc];
//        [assocTableViewController setSaveFlag:_saveFlag];
//    }
//}
//
//- (IBAction)unwindToImageView:(UIStoryboardSegue *)segue {
//    AssocTableViewController *sourceViewController = [segue sourceViewController];
//    
//    _paintSwatches = sourceViewController.paintSwatches;
//    _mixAssocDesc  = sourceViewController.mixAssocDesc;
//    _saveFlag      = sourceViewController.saveFlag;
//    
//    if (_saveFlag == TRUE) {
//        [sourceViewController saveData];
//    }
//    
//    // Disable the 'View' button
//    //
//    if ([_paintSwatches count] == 0) {
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:4 isEnabled:FALSE];
//    }
//    
//    [self drawTapAreas];
//}
//
//- (IBAction)goBack:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
