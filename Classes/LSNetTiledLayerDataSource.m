//
//  LSNetTiledLayerDataSource.m
//  NetPhotoScroller
//
//  Created by Frank Schmitt on 3/1/12.
//  Copyright (c) 2012 Laika Systems. All rights reserved.
//

#import "LSNetTiledLayerDataSource.h"
#import "LSTiledLayer.h"
#import "AFImageRequestOperation.h"

@interface LSNetTiledLayerDataSource ()

@property (nonatomic, retain) NSMutableDictionary *tileCache;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end

@implementation LSNetTiledLayerDataSource

#pragma mark Class methods

+ (LSNetTiledLayerDataSource *)sharedDataSource {
    static LSNetTiledLayerDataSource *sharedDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataSource = [[LSNetTiledLayerDataSource alloc] initWithBaseURL:[NSURL URLWithString:@"http://laikasys.com/test/tiles/"]];
    });
    
    return sharedDataSource;
}

#pragma mark - Properties

@synthesize baseURL = _baseURL;
@synthesize tileCache;
@synthesize operationQueue;

- (NSArray *)imageData {
    static NSArray *__imageData = nil; // only load the imageData array once
    if (__imageData == nil) {
        // read the filenames/sizes out of a plist off the internet (this should really be non-blocking)
        NSURL *path = [NSURL URLWithString:@"ImageData.plist" relativeToURL:self.baseURL];
        NSData *plistData = [NSData dataWithContentsOfURL:path];
        NSString *error; NSPropertyListFormat format;
        __imageData = [[NSPropertyListSerialization propertyListFromData:plistData
                                                        mutabilityOption:NSPropertyListImmutable
                                                                  format:&format
                                                        errorDescription:&error]
                       retain];
        if (!__imageData) {
            NSLog(@"Failed to read image names. Error: %@", error);
            [error release];
        }
    }
    return __imageData;
}

- (NSString *)imageNameAtIndex:(NSUInteger)index {
    NSString *name = nil;
    if (index < [self imageCount]) {
        NSDictionary *data = [[[LSNetTiledLayerDataSource sharedDataSource] imageData] objectAtIndex:index];
        name = [data valueForKey:@"name"];
    }
    return name;
}

- (CGSize)imageSizeAtIndex:(NSUInteger)index {
    CGSize size = CGSizeZero;
    if (index < [self imageCount]) {
        NSDictionary *data = [[[LSNetTiledLayerDataSource sharedDataSource] imageData] objectAtIndex:index];
        size.width = [[data valueForKey:@"width"] floatValue];
        size.height = [[data valueForKey:@"height"] floatValue];
    }
    return size;
}

- (NSUInteger)imageCount {
    static NSUInteger __count = NSNotFound;  // only count the images once
    if (__count == NSNotFound) {
        __count = [[[LSNetTiledLayerDataSource sharedDataSource] imageData] count];
    }
    return __count;
}

#pragma mark - Initialzation and deallocation

- (id)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    
    if (self) {
        self.baseURL = baseURL;
        
        self.tileCache = [NSMutableDictionary dictionaryWithCapacity:16];
        
        self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.operationQueue.maxConcurrentOperationCount = 8;
    }
    
    return self;
}

- (void)dealloc {
    [_baseURL release];
    
    [operationQueue cancelAllOperations];
    [operationQueue release];
    
    [tileCache release];
    
    [super dealloc];
}

# pragma mark - Tiled layer data source

- (BOOL) tiledLayer:(LSTiledLayer *)tiledLayer canDrawRect:(CGRect)rect levelOfDetail:(int)level
{    
    CGSize tileSize = tiledLayer.tileSize;
    
    int col = rect.origin.x / ((int)tileSize.width << level);
    int row = rect.origin.y / ((int)tileSize.height << level);
    CGFloat scale = 1 / (CGFloat)(1 << level);
    
    NSString *tileName = [NSString stringWithFormat:@"%@_%d_%d_%d.png", tiledLayer.imageName, (int)(scale * 1000), col, row];
    
    UIImage *cachedImage = [tileCache objectForKey:tileName];
    
    if ([cachedImage isKindOfClass:[NSNull class]])
        return NO;
    
    if (cachedImage)
        return YES;
    
    [tileCache setObject:[NSNull null] forKey:tileName];
    
    // Else download the tile
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tileName relativeToURL:self.baseURL]];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        [self.tileCache setObject:image forKey:tileName];
        
        [tiledLayer setNeedsDisplayInRect:rect levelOfDetail:level];
    }];
    
    [operationQueue addOperation:operation];
    
    return NO;
}

- (CGImageRef)tileForImageName:(NSString *)imageName scale:(CGFloat)scale row:(int)row col:(int)col rect:(CGRect)rect
{
    NSString *tileName = [NSString stringWithFormat:@"%@_%d_%d_%d.png", imageName, (int)round(scale * 1000), col, row];
    
    UIImage *cachedImage = [tileCache objectForKey:tileName];
    
    if (cachedImage && ![cachedImage isKindOfClass:[NSNull class]]) {
        CGImageRef result = cachedImage.CGImage;
        CGImageRetain(result);
        
        // Discard the tile now that we've drawn it
        [tileCache removeObjectForKey:tileName];
        return result;
    } else
        return nil;
}

@end
