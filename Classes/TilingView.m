/*
     File: TilingView.m
 Abstract: Handles tile drawing and tile image loading.
  Version: 1.1
 Modified: Frank Schmitt. Copyright (C) 2012 Laika Systems. CC BY 3.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "TilingView.h"
#import <QuartzCore/CATiledLayer.h>
#import "LSTiledLayer.h"
#import "LSNetTiledLayerDataSource.h"


@implementation TilingView
@synthesize annotates;

+ (Class)layerClass {
	return [LSTiledLayer class];
}

- (id)initWithImageName:(NSString *)name size:(CGSize)size
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)])) {
        imageName = [name retain];

        LSTiledLayer *tiledLayer = (LSTiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = 4;
        tiledLayer.imageName = name;
        tiledLayer.dataSource = [LSNetTiledLayerDataSource sharedDataSource];
        tiledLayer.delegate = tiledLayer;
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {    
    CGRect rect = CGContextGetClipBoundingBox(context);
    
    // get the scale from the context by getting the current transform matrix, then asking for
    // its "a" component, which is one of the two scale components. We could also ask for "d".
    // This assumes (safely) that the view is being scaled equally in both dimensions.
    CGFloat scale = CGContextGetCTM(context).a;
    
    LSTiledLayer *tiledLayer = (LSTiledLayer *)layer;
    CGSize tileSize = tiledLayer.tileSize;
    
    // Even at scales lower than 100%, we are drawing into a rect in the coordinate system of the full
    // image. One tile at 50% covers the width (in original image coordinates) of two tiles at 100%. 
    // So at 50% we need to stretch our tiles to double the width and height; at 25% we need to stretch 
    // them to quadruple the width and height; and so on.
    // (Note that this means that we are drawing very blurry images as the scale gets low. At 12.5%, 
    // our lowest scale, we are stretching about 6 small tiles to fill the entire original image area. 
    // But this is okay, because the big blurry image we're drawing here will be scaled way down before 
    // it is displayed.)
    tileSize.width /= scale;
    tileSize.height /= scale;
    
    int col = floorf((CGRectGetMaxX(rect) - 1) / tileSize.width);
    int row = floorf((CGRectGetMaxY(rect) - 1) / tileSize.height);

    CGImageRef imageRef = [tiledLayer.dataSource tileForImageName:tiledLayer.imageName scale:scale row:row col:col rect:rect];

    if (imageRef) {
        CGContextTranslateCTM(context, 0.0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        rect = CGContextGetClipBoundingBox(context);

        CGContextDrawImage(context, rect, imageRef);
        CGImageRelease(imageRef);
    }
}

@end
