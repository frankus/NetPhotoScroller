//
//  LSNetTiledLayerDataSource.h
//  NetPhotoScroller
//
//  Created by Frank Schmitt on 3/1/12.
//  Copyright (c) 2012 Laika Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSTiledLayerDataSource.h"

@interface LSNetTiledLayerDataSource : NSObject <LSTiledLayerDataSource>

+ (LSNetTiledLayerDataSource *)sharedDataSource;

@property (nonatomic, retain) NSURL *baseURL;
@property (nonatomic, readonly) NSArray *imageData;

- (id)initWithBaseURL:(NSURL *)baseURL;

- (NSUInteger)imageCount;
- (NSString *)imageNameAtIndex:(NSUInteger)index;
- (CGSize)imageSizeAtIndex:(NSUInteger)index;

@end
