//
//  LSTiledLayerDataSource.h
//  NetPhotoScroller
//
//  Created by Frank Schmitt on 3/1/12.
//  Copyright (c) 2012 Laika Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSTiledLayer;

@protocol LSTiledLayerDataSource <NSObject>

- (BOOL) tiledLayer:(LSTiledLayer *)layer canDrawRect:(CGRect)rect levelOfDetail:(int)level;
- (CGImageRef) tileForImageName:(NSString *) imageName scale:(CGFloat)scale row:(int)row col:(int)col rect:(CGRect)rect;

@end
