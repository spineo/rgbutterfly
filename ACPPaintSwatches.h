//
//  ACPPaintSwatches.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/13/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ACPPaintSwatches : NSObject

// Paint Swatches properties
//
@property (nonatomic) int uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *abbr_name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSMutableArray *keywords;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic) float red;
@property (nonatomic) float grn;
@property (nonatomic) float blu;
@property (nonatomic) float hue;
@property (nonatomic) float bri;
@property (nonatomic) float sat;
@property (nonatomic) float alpha;
@property (nonatomic, strong) NSNumber *deg_hue;
@property (nonatomic, strong) UIImage *image_thumb;
@property (nonatomic, strong) NSURL *image_url;
@property (nonatomic, strong) NSNumber *ref_src_id;
@property (nonatomic, strong) NSDate *create_date;
@property (nonatomic, strong) NSDate *last_update;
@property (nonatomic) BOOL is_mix;


// Lookup dictionaries
//
@property (nonatomic) int type_id;
@property (nonatomic) int subj_color_id;


// Flag add mix row selections
//
@property (nonatomic) BOOL is_selected;


// Mix Assoc properties
//
@property (nonatomic) int mix_assoc_uid;
@property (nonatomic) int mix_order;
@property (nonatomic) int dom_parts_ratio;
@property (nonatomic) int mix_parts_ratio;
@property (nonatomic) int mix_assoc_desc_uid;


// Database independent
//
@property (nonatomic) CGPoint coord_pt;

@end
