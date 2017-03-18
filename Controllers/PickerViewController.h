//
//  PickerViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 3/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) int imageAction;

@end
