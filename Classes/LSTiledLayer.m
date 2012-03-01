//
//  LSTiledLayer.m
//  NetPhotoScroller
//
//  Created by Frank Schmitt on 10/26/11.
//

#import "LSTiledLayer.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation LSTiledLayer

@synthesize dataSource;
@synthesize imageName;

- (BOOL) canDrawRect:(CGRect)rect levelOfDetail:(int)level {
    return [dataSource tiledLayer:self canDrawRect:rect levelOfDetail:level];
}

@end
