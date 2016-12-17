//
//  MapperUtils.h
//  Mapper
//
//  Created by Huy Pham on 4/9/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapperUtils : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+ (instancetype)sharedInstance;

+ (void)request:(NSString *)url
         method:(NSString *)method
     parameters:(NSDictionary *)parameters
        headers:(NSDictionary *)headers
completionHandler:(void(^)(id, NSError *))completion;

+ (NSDictionary *)getDataFrom:(NSDictionary *)data
                  WithKeyPath:(NSString *)keyPath;

@end
