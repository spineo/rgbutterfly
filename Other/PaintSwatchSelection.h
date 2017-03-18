//
//  PaintSwatchSelection.h
//  RGButterfly
//
//  Created by Stuart Pineo on 5/13/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "PaintSwatches.h"

@interface PaintSwatchSelection : NSObject

@property (nonatomic) BOOL is_selected;
@property (nonatomic, strong) PaintSwatches *paintSwatch;


@end
