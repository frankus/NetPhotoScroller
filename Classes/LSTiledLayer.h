//
//  LSTiledLayer.h
//  NetPhotoScroller
//
//  Created by Frank Schmitt on 10/26/11.
//

#import <QuartzCore/QuartzCore.h>
#import "LSTiledLayerDataSource.h"

@interface LSTiledLayer : CATiledLayer

@property (nonatomic, assign) id<LSTiledLayerDataSource> dataSource;
@property (nonatomic, retain) NSString *imageName;

- (void) setNeedsDisplayInRect:(CGRect)r levelOfDetail:(int)level;

@end
