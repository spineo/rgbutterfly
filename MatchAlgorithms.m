//
//  MatchAlgorithms.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 9/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "MatchAlgorithms.h"
#import "PaintSwatchesDiff.h"


@implementation MatchAlgorithms


// d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2) on RGB
//
+ (float)colorDiffAlgorithm0:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.red floatValue]/255.0 - [compObj.red floatValue]/255.0),2) +
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2) +
                             pow(fabs([mainObj.blue floatValue]/255.0 - [compObj.blue floatValue]/255.0),2)
                             );

    return (float)color_diff;
}

// d = sqrt((h2-h1)^2 + (s2-s1)^2 + (b2-b1)^2) on HSB
//
+ (float)colorDiffAlgorithm1:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.hue floatValue] - [compObj.hue floatValue]),2) +
                             pow(fabs([mainObj.saturation floatValue] - [compObj.saturation floatValue]),2) +
                             pow(fabs([mainObj.brightness floatValue] - [compObj.brightness floatValue]),2)
                             );
    
    return (float)color_diff;
}

// d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2) on RGB + Hue
//
+ (float)colorDiffAlgorithm2:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.red floatValue]/255.0 - [compObj.red floatValue]/255.0),2) +
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2) +
                             pow(fabs([mainObj.blue floatValue]/255.0 - [compObj.blue floatValue]/255.0),2) +
                             pow(fabs([mainObj.hue floatValue] - [compObj.hue floatValue]),2)
                             );
    
    return (float)color_diff;
}

// d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2 + (s2-s1)^2 + (br2-br1)^2) on RGB + HSB
//
+ (float)colorDiffAlgorithm3:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.red floatValue]/255.0 - [compObj.red floatValue]/255.0),2) +
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2) +
                             pow(fabs([mainObj.blue floatValue]/255.0 - [compObj.blue floatValue]/255.0),2) +
                             pow(fabs([mainObj.hue floatValue] - [compObj.hue floatValue]),2) +
                             pow(fabs([mainObj.saturation floatValue] - [compObj.saturation floatValue]),2) +
                             pow(fabs([mainObj.brightness floatValue] - [compObj.brightness floatValue]),2)
                             );
    
    return (float)color_diff;
}

// Weighted approach on RGB only
// d = ((r2-r1)*0.30)^2
//  + ((g2-g1)*0.59)^2
//  + ((b2-b1)*0.11)^2
//
+ (float)colorDiffAlgorithm4:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff =
    pow((fabs([mainObj.red floatValue]/255.0 - [compObj.red floatValue]/255.0) * 0.30),2) +
    pow((fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0) * 0.59),2) +
    pow((fabs([mainObj.blue floatValue]/255.0 - [compObj.blue floatValue]/255.0) * 0.11),2);
    
    return (float)color_diff;
}

// Weighted approach on RGB + HSB
// d = ((r2-r1)*0.30)^2
//  + ((g2-g1)*0.59)^2
//  + ((b2-b1)*0.11)^2
// Plus HSB diff
//
+ (float)colorDiffAlgorithm5:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff =
    pow((fabs([mainObj.red floatValue]/255.0 - [compObj.red floatValue]/255.0) * 0.30),2) +
    pow((fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0) * 0.59),2) +
    pow((fabs([mainObj.blue floatValue]/255.0 - [compObj.blue floatValue]/255.0) * 0.11),2) +
    pow(fabs([mainObj.hue floatValue] - [compObj.hue floatValue]),2) +
    pow(fabs([mainObj.saturation floatValue] - [compObj.saturation floatValue]),2) +
    pow(fabs([mainObj.brightness floatValue] - [compObj.brightness floatValue]),2);
    
    return (float)color_diff;
};


// d = sqrt((h2-h1)^2) on Hue only
//
+ (float)colorDiffAlgorithm6:(PaintSwatches *)mainObj  compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.hue floatValue] - [compObj.hue floatValue]),2)
                             );
    
    return (float)color_diff;
}

// Messy random one
//
+ (float)colorDiffAlgorithm7:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj {
    double color_diff = sqrt(
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2) +
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2) +
                             pow(fabs([mainObj.green floatValue]/255.0 - [compObj.green floatValue]/255.0),2)
                             );


    return (float)color_diff;
}

// Sort by closest match
//
+ (NSMutableArray *)sortByClosestMatch:(PaintSwatches *)refObj swatches:(NSMutableArray *)swatches matchAlgorithm:(int)matchAlgIndex maxMatchNum:(int)maxMatchNum context:(NSManagedObjectContext *)context entity:(NSEntityDescription *)entity {
    
    int maxIndex = (int)[swatches count] - 1;
    
    NSMutableArray *colorDiffs = [[NSMutableArray alloc] init];
    
    for (int i=0; i<= maxIndex; i++) {
        //PaintSwatches *compObj =  [[PaintSwatches alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        PaintSwatches *compObj = [swatches objectAtIndex:i];
        
        float diffValue;
        
        NSString *algorithmName = [[NSString alloc] initWithFormat:@"colorDiffAlgorithm%i:compObj:", matchAlgIndex];
        SEL selector = NSSelectorFromString(algorithmName);
        
        NSMethodSignature *signature = [MatchAlgorithms methodSignatureForSelector:selector];
        
        if ([MatchAlgorithms respondsToSelector:selector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setSelector:selector];
            [invocation setTarget:[MatchAlgorithms class]];
            [invocation setArgument:&refObj atIndex:2];
            [invocation setArgument:&compObj atIndex:3];
            [invocation invoke];
            [invocation getReturnValue:&diffValue];
        }
        
        PaintSwatchesDiff *diffObj  = [[PaintSwatchesDiff alloc] init];
        diffObj.name = compObj.name;
        diffObj.diff = diffValue;
        diffObj.index = i;
        
        [colorDiffs addObject:diffObj];
    }
    
    // Sort by diff value
    //
    NSArray *sortedArray = [colorDiffs sortedArrayUsingComparator:^NSComparisonResult(PaintSwatchesDiff *p1, PaintSwatchesDiff *p2){
        if (p1.diff > p2.diff)
            return NSOrderedDescending;
        else if (p1.diff < p2.diff)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    NSMutableArray *modMatchedSwatches = [[NSMutableArray alloc] init];
    for (int i=0; i<= maxIndex; i++) {
        if (i >= maxMatchNum) {
            break;
        }
        
        int index = [[sortedArray objectAtIndex:i] index];
        
        PaintSwatches *pswatch = [swatches objectAtIndex:index];
//        NSLog(@"INSERT PS ++ 2 ++++++++++++++++++");
//        PaintSwatches *psdiff = [[PaintSwatches alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
//        
//        psdiff.name        = pswatch.name;
//        psdiff.red         = pswatch.red;
//        psdiff.green       = pswatch.green;
//        psdiff.blue        = pswatch.blue;
//        psdiff.hue         = pswatch.hue;
//        psdiff.saturation  = pswatch.saturation;
//        psdiff.brightness  = pswatch.brightness;
//        psdiff.image_thumb = pswatch.image_thumb;
        
//        [modMatchedSwatches addObject:psdiff];
        [modMatchedSwatches addObject:pswatch];
    }
    [modMatchedSwatches insertObject:refObj atIndex:0];
    
    return modMatchedSwatches;
}

@end
