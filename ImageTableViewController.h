//
//  ImageTableViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 8/30/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalSettings.h"
#import "PaintSwatches.h"
#import "ACPMixAssociationsDesc.h"

@interface ImageTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>


//@property (nonatomic, weak) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImage *selectedImage;

@end
