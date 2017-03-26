//
//  PickerViewController.m
//  RGButterfly
//
//  Created by Stuart Pineo on 3/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "PickerViewController.h"
#import "ImageViewController.h"
#import "GlobalSettings.h"


@interface PickerViewController ()

@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic) BOOL autoRotate, photoSetUp;

@end

@implementation PickerViewController

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization and Refresh Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Initialization and Refresh Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _picker = [[UIImagePickerController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [_picker setDelegate:self];
    [_picker setAllowsEditing:YES];
    
    
    // For the Camera mode, the settings will change for _autoRotate
    //
    [self setAutoRotate:FALSE];
    [self setPhotoSetUp:FALSE];
    
    [self.view setFrame: CGRectMake(_picker.view.bounds.origin.x, _picker.view.bounds.origin.y, _picker.view.bounds.size.width, _picker.view.bounds.size.height)];
    [self.view addSubview:_picker.view];
    
    // For the PhotoLibrary rotation is allowed and each call recomputes the layout
    //
    if (_imageAction == SELECT_PHOTO_ACTION) {
        
        [self setAutoRotate:TRUE];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPicker)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    
    [self refreshPicker];
}

- (void)refreshPicker {
    if ((_imageAction == TAKE_PHOTO_ACTION) && ! _photoSetUp) {
        [self setPhotoSetUp:TRUE];
        [self takePhoto];
        
    } else if (_imageAction == SELECT_PHOTO_ACTION) {
        [self selectPhoto];
    }
}

- (BOOL)shouldAutorotate {
    return _autoRotate;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Photo Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Photo Methods

- (void)takePhoto {
    [_picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    
    [self.navigationItem setTitle:@"Take Photo"];
    [self.navigationItem setLeftBarButtonItem:nil];
}

- (void)selectPhoto {
    [self.view setFrame:CGRectMake(_picker.view.bounds.origin.x, _picker.view.bounds.origin.y, _picker.view.bounds.size.width, _picker.view.bounds.size.height)];
    
    [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self.navigationItem setTitle:@"Select Photo"];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Segue and Navigation Methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Segue and Navigation Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ImageViewSegue"]) {
        UINavigationController *navigationViewController = [segue destinationViewController];
        ImageViewController *imageViewController = (ImageViewController *)([navigationViewController viewControllers][0]);
        
        [imageViewController setSelectedImage:_selectedImage];
        [imageViewController setNewImage:TRUE];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _selectedImage = info[UIImagePickerControllerEditedImage];
    
    [self performSegueWithIdentifier:@"ImageViewSegue" sender:self];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)unwindToPickerViewController:(UIStoryboardSegue *)segue {
    if (_imageAction == TAKE_PHOTO_ACTION) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)dismissPicker:(id)sender {
    if ([_picker isKindOfClass:[UIImagePickerController class]]) {
        if ([_picker.viewControllers count] > 1) {
            [_picker popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

@end
