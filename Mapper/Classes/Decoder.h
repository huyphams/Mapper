//
//  Mapper.h
//  Mapper
//
//  Created by Huy Pham on 3/26/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPDecoder : NSObject
/**
 *  Auto Mapper properties object with dictionary/json.
 *
 *  @param dictionary Data to Mapper.
 *
 *  @return Object Mapper.
 */
- (instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

/**
 *  Auto Mapper properties object with dictionary/json.
 *
 *  @param dictionary Data to Mapper.
 */
- (void)initData:(nullable NSDictionary *)dictionary;

/**
 *  Convert object to dictionary.
 *
 *  @return Object dictionary.
 */
- (NSDictionary *)toDictionary;

/**
 *  Object initial status.
 *
 *  @return Initial state.
 */
- (BOOL)isInitiated;

@end

NS_ASSUME_NONNULL_END
