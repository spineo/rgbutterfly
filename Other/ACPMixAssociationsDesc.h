//
//  MixAssociationsDesc.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/29/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPMixAssociationsDesc : NSObject

@property (nonatomic) int uid;
@property (nonatomic, strong) NSString *mix_assoc_name;
@property (nonatomic, strong) NSString *mix_assoc_desc;

@end
