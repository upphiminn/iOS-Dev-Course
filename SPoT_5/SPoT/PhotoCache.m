//
//  PhotoCache.m
//  SPoT_4
//
//  Created by Corneliu on 4/20/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "PhotoCache.h"
@interface PhotoCache()
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSURL *cacheDir;
@end

@implementation PhotoCache

#define CACHE_NAME @"STANFORD_PHOTOS"
#define CACHE_BYTES_SIZE 3.146e+6 
//Size is set to 3 megabytes

static PhotoCache *cacheInstance;

+ (void) initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        cacheInstance = [[PhotoCache alloc] init];
    }
}

- (NSFileManager*) fileManager
{
    return _fileManager ? _fileManager : (_fileManager = [NSFileManager defaultManager]);
}

- (NSURL*) cacheDir
{
    if (!_cacheDir){
        NSURL* caches = [[self.fileManager URLsForDirectory:NSCachesDirectory
                                                  inDomains:NSUserDomainMask]
                    lastObject];
        _cacheDir = [caches URLByAppendingPathComponent:CACHE_NAME isDirectory:TRUE];
        BOOL isDir;
        if(![self.fileManager fileExistsAtPath:[_cacheDir path]
                                  isDirectory:&isDir] && isDir){
            
            [self.fileManager createDirectoryAtPath:[_cacheDir path]
                        withIntermediateDirectories:NO
                                         attributes:nil
                                              error:nil];
        }
    }
    return _cacheDir;
}

+ (BOOL) isIdentifierInCache:(NSString*) identifier
{
    PhotoCache* cache = cacheInstance;
    return [cache hasCachedFile:identifier];
}

+ (NSData*) retrieveDataForIdentifier:(NSString*) identifier
{
    PhotoCache* cache = cacheInstance;
    [cache updateModificationDateForFile:identifier];
    return [cache getDataForFile: identifier];
}

+ (void) storeData:(NSData*) data withIdentifier:(NSString*) identifier
{
    if(data){
        PhotoCache* cache = cacheInstance;
        if([cache hasCachedFile:identifier]){
            [cache updateModificationDateForFile:identifier];
        }
        else{
            if(![cache isCacheEmptySpaceSizeGreaterThan:[data length]])
                [cache makeCacheEmptySpaceSizeGreaterThan:[data length]];
            [cache writeFile:identifier withData:data];
        }
    }
    
}

- (BOOL) hasCachedFile:(NSString*) filename
{
   return [self.fileManager fileExistsAtPath:
                [[self.cacheDir URLByAppendingPathComponent:filename] path]
           ];
}

- (void) updateModificationDateForFile:(NSString*) filename
{
    [self.fileManager setAttributes:@{NSFileModificationDate: [NSDate date]}
                       ofItemAtPath:[[self.cacheDir URLByAppendingPathComponent:filename] path]
                              error:nil
    ];
}

- (void) writeFile:(NSString*) filename withData:(NSData*) data
{
    NSLog(@"Adding File %@ \n", filename);
    [self.fileManager createFileAtPath:[[self.cacheDir URLByAppendingPathComponent:filename] path]
                              contents:data
                            attributes:nil];
}

- (NSData*) getDataForFile:(NSString*) filename
{
    if ([self hasCachedFile:filename]){
        NSURL* fileURL = [self.cacheDir URLByAppendingPathComponent:filename];
        return [self.fileManager contentsAtPath:[fileURL path]];
    }
    return nil;
}

- (unsigned long long) getCurrentCacheSize
{
    unsigned long long cacheSize = 0;
    NSArray* allFilesInCache = [self.fileManager contentsOfDirectoryAtURL:self.cacheDir
                                               includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLFileSizeKey,nil]
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                    error:nil];
    for(NSURL* file in allFilesInCache){
        NSNumber* fileSize;
        [file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        cacheSize += [fileSize longLongValue];
    }
    
    return cacheSize;
}

- (BOOL) isCacheEmptySpaceSizeGreaterThan:(unsigned long long) size
{
    unsigned long long cacheSize = [self getCurrentCacheSize];
    //over limit
    if (cacheSize > CACHE_BYTES_SIZE)
        return NO;
    
    unsigned long long emptyspaceSize = CACHE_BYTES_SIZE - cacheSize;
    NSLog(@"Empty CacheSize: %lld bytes",emptyspaceSize);
    
    if (emptyspaceSize >= size){
        return YES;
    }
    return NO;
}

- (void) makeCacheEmptySpaceSizeGreaterThan:(unsigned long long) size
{

    __block unsigned long long cacheSize        = [self getCurrentCacheSize];
    __block long long          emptyspaceSize   = CACHE_BYTES_SIZE - cacheSize;
    
    NSArray* allFilesInCache = [self.fileManager contentsOfDirectoryAtURL:self.cacheDir
                                               includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,NSURLAttributeModificationDateKey,NSURLFileSizeKey,NSURLPathKey,nil]
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                    error:nil];
    
    NSArray* timeSortedFilesInCache = [allFilesInCache sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *obj1_date, *obj2_date;
        [obj1 getResourceValue:&obj1_date forKey:NSURLAttributeModificationDateKey error:nil];
        [obj2 getResourceValue:&obj2_date forKey:NSURLAttributeModificationDateKey error:nil];
        return [obj1_date compare:obj2_date];
    }];
    
    [timeSortedFilesInCache enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSNumber* fileSize;
        [obj getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        emptyspaceSize += [fileSize longLongValue];
        cacheSize      -= [fileSize longLongValue];
        NSLog(@"Deleting File %@ \n", [(NSURL*)obj lastPathComponent]);
        [self.fileManager removeItemAtPath:[obj path] error:nil];
        *stop = (emptyspaceSize > size) && (cacheSize < CACHE_BYTES_SIZE);
    }];
    
}

@end
