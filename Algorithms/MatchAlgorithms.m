//
//  MatchAlgorithms.m
//  RGButterfly
//
//  Created by Stuart Pineo on 9/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "MatchAlgorithms.h"
#import "PaintSwatchesDiff.h"
#import "MatchColors.h"
#import "GenericUtils.h"


@implementation MatchAlgorithms

// callMatcher - Return a diff value based on the algorithm invoked
//
+ (float)callMatcher:(MatchColors *)matchObj algIndex:(int)algIndex {

    float diffValue;
    switch (algIndex)
    {
        case 0:
            // d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2) on RGB
            //
            return [matchObj colorDiffByRGB];
            
        case 1:
            // d = sqrt((h2-h1)^2 + (s2-s1)^2 + (b2-b1)^2) on HSB
            //
            return [matchObj colorDiffByHSB];

        case 2:
            // d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2) on RGB + Hue
            //
            return [matchObj colorDiffByRGBAndHue];

        case 3:
            // d = sqrt((r2-r1)^2 + (g2-g1)^2 + (b2-b1)^2 + (h2-h1)^2 + (s2-s1)^2 + (br2-br1)^2) on RGB + HSB
            //
            return [matchObj colorDiffByRGBAndHSB];

        case 4:
            // Weighted on RGB only
            // d = ((r2-r1)*0.30)^2
            //  + ((g2-g1)*0.59)^2
            //  + ((b2-b1)*0.11)^2
            //
            return [matchObj colorDiffByRGBW];

        case 5:
            // Weighted approach on RGB + HSB
            // d = ((r2-r1)*0.30)^2
            //  + ((g2-g1)*0.59)^2
            //  + ((b2-b1)*0.11)^2
            // Plus HSB diff
            //
            return [matchObj colorDiffByRGBWAndHSB];

        case 6:
            // d = sqrt((h2-h1)^2) on Hue only
            //
            return [matchObj colorDiffByHue];
    
        default:
            // Random value
            //
            return [GenericUtils getRandomVal];
    }
    
    return diffValue;
}

// Sort by closest match
//
+ (NSMutableArray *)sortByClosestMatch:(PaintSwatches *)refObj swatches:(NSMutableArray *)swatches matchAlgorithm:(int)matchAlgIndex maxMatchNum:(int)maxMatchNum context:(NSManagedObjectContext *)context entity:(NSEntityDescription *)entity {
    
    int maxIndex = (int)[swatches count] - 1;
    
    NSMutableArray *colorDiffs = [[NSMutableArray alloc] init];
    
    for (int i=0; i<= maxIndex; i++) {
        PaintSwatches *compObj = [swatches objectAtIndex:i];
        
        MatchColors *matchObj = [[MatchColors alloc] init];
        [matchObj setDict:[self createDict:refObj] compDict:[self createDict:compObj]];
        
        float diffValue = [self callMatcher:matchObj algIndex:matchAlgIndex];
        
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
        [modMatchedSwatches addObject:pswatch];
    }
    [modMatchedSwatches insertObject:refObj atIndex:0];
    
    return modMatchedSwatches;
}

+ (NSMutableDictionary *)createDict:(PaintSwatches *)obj {
    NSMutableDictionary *dictObj = [[NSMutableDictionary alloc] init];
    
    [dictObj setValue:[NSNumber numberWithDouble:[obj.red        floatValue]/255.0] forKey:@"red"];
    [dictObj setValue:[NSNumber numberWithDouble:[obj.green      floatValue]/255.0] forKey:@"green"];
    [dictObj setValue:[NSNumber numberWithDouble:[obj.blue       floatValue]/255.0] forKey:@"blue"];
    [dictObj setValue:[NSNumber numberWithDouble:[obj.hue        floatValue]/255.0] forKey:@"hue"];
    [dictObj setValue:[NSNumber numberWithDouble:[obj.saturation floatValue]/255.0] forKey:@"saturation"];
    [dictObj setValue:[NSNumber numberWithDouble:[obj.brightness floatValue]/255.0] forKey:@"brightness"];
    
    return dictObj;
}

@end
