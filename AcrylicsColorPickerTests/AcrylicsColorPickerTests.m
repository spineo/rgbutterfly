//
//  AcrylicsColorPickerTests.m
//  AcrylicsColorPickerTests
//
//  Created by Stuart Pineo on 2/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "UIImageViewController.h"
#import "PickerViewController.h"
#import "AssocTableViewController.h"
#import "SwatchDetailTableViewController.h"
#import "AppDelegate.h"
#import "BarButtonUtils.h"
#import "AssocCollectionTableViewCell.h"


// Data model and related API
//
#import "CoreDataUtils.h"
#import "PaintSwatches.h"
#import "ACPMixAssociationsDesc.h"

@interface AcrylicsColorPickerTests : XCTestCase

@property (nonatomic, strong) UIStoryboard *storyboard;

@property (nonatomic, strong) ViewController *vc;
@property (nonatomic, strong) UIImageViewController *ivc;
@property (nonatomic, strong) PickerViewController *pvc;
@property (nonatomic, strong) AssocTableViewController *atvc;
@property (nonatomic, strong) UINavigationController *nav1;

@property (nonatomic, strong) UIView *vcView, *ivcView, *pvcView;
@property (nonatomic, strong) UIImageView *ivcImageView;
@property (nonatomic, strong) UIScrollView *ivcImageScrollView;
@property (nonatomic, strong) UITableView *vcTableView, *ivcImageTableView;


// Data model and related API
//
@property (nonatomic, strong) NSArray *dataModelObjects;
@property (nonatomic, strong) NSString *entity;

@end

@implementation AcrylicsColorPickerTests

// Items to test
// Outlets non-nil for each view controller
// Data model
// Segues reach destination
//

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Setup the UIImageViewController tests
    //
    _storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // ViewController
    //
    _vc  = [_storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    _vcView             = _vc.view;
    _vcTableView        = _vc.colorTableView;

    
    // UIImageViewController
    //
    _ivc = [_storyboard instantiateViewControllerWithIdentifier:@"UIImageViewController"];
    _ivcView            = _ivc.view;
    _ivcImageView       = _ivc.imageView;
    _ivcImageScrollView = _ivc.imageScrollView;
    _ivcImageTableView  = _ivc.imageTableView;
    
    // AssocTableViewController
    //
    _atvc = [_storyboard instantiateViewControllerWithIdentifier:@"MixAssociationViewController"];

    // Navigation Controller
    //
    _nav1 = [_storyboard instantiateViewControllerWithIdentifier:@"Nav1"];
    
    // Data model
    //
    _dataModelObjects = @[ @"PaintSwatches", @"MixAssociations", @"SwatchKeywords", @"MixAssociationsDesc" ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}

// Ensure that data being returned
//
- (void)testDataModelAndAPI {
    NSLog(@"********************************************");
    for (_entity in _dataModelObjects) {
        int count = [CoreDataUtils fetchCount:_entity];
        XCTAssertGreaterThan(count, 0);
        NSLog(@"Entity %@ count is %i", _entity, count);
    }
    NSLog(@"********************************************");
}

// ViewController (starting view)
//
- (void)testViewController {
    
    // Test for non-nil
    //
    XCTAssertNotNil(_vc);
    XCTAssertNotNil(_vcView);
    XCTAssertNotNil(_vcView.subviews);
    
    // Test segue connections (including unwind)
    //
    [UIApplication sharedApplication].keyWindow.rootViewController = _vc;

    //[_vc performSegueWithIdentifier:@"ImagePickerSegue" sender:nil];
    //XCTAssertEqualObjects(_vc.presentedViewController.title, @"Image Picker View");
    
    // Need to set up
    //[_vc dismissViewControllerAnimated:YES completion:Nil];
    //[_vc performSegueWithIdentifier:@"VCToAssocSegue" sender:nil];
    //[_vc performSegueWithIdentifier:@"MainSwatchDetailSegue" sender:nil];
    
    
    // Test IBActions
    //
    UIToolbar *toolbar = [_vcView.subviews objectAtIndex:2];
    NSArray *toolbarItems = toolbar.items;
    
    // Select Photo
    //
    UIBarButtonItem *selectPhoto = [toolbarItems objectAtIndex:0];
    XCTAssertTrue([selectPhoto action] == @selector(selectPhoto:));
    
    // Take Photo (skip flexible space)
    //
    UIBarButtonItem *takePhoto = [toolbarItems objectAtIndex:2];
    XCTAssertTrue([takePhoto action] == @selector(takePhoto:));

    
    // Table view initialization
    //
    XCTAssertTrue(_vcTableView.numberOfSections == 1);
    XCTAssertTrue([_vcTableView numberOfRowsInSection:0] == [CoreDataUtils fetchCount:@"PaintSwatches"]);
}

// UIImageViewController
//
- (void)testUIImageViewController {
    
    // Test for non-nil
    //
    XCTAssertNotNil(_ivc);
    XCTAssertNotNil(_ivcView);
    XCTAssertNotNil(_ivcView.subviews);
    
    // Test the table view initialization
    //
    XCTAssertTrue(_ivcImageTableView.numberOfSections == 2);
    XCTAssertTrue(_ivcImageTableView.isHidden == TRUE);
}

// Performance Test Initialization Methods
//
- (void)testInitializationMethodsPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for (int i=0; i<10; i++) {
            //NSLog(@"Execute performance test...");
            // View Controller
            //
            [_vc viewDidLoad];
            [_vc viewDidAppear:YES];
            [_vc viewWillAppear:YES];
            
            // UIImageViewController
            //
            [_ivc viewDidLoad];
            [_ivc viewDidAppear:YES];
            [_ivc viewWillAppear:YES];
        }
    }];
}


@end
