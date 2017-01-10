//
//  Mapper.h
//  Mapper
//
//  Created by Huy Pham on 3/26/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Decoder.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Mapper events description.
 */
typedef NS_ENUM(NSInteger, MapperEvent){
    /**
     *  Model will trigger event when value of data is increased.
     */
    MapperEventOnIncrease = 0x01,
    /**
     *  Model will trigger event when value of data is decreased.
     */
    MapperEventOnDecrease = 0x02,
    /**
     *  Model will trigger event when value of data is changed.
     */
    MapperEventOnChange = 0x03
};

@interface Mapper : Decoder
/**
 *  Register reaction for property on an event.
 *
 *  @param property Property key path.
 *  @param event    Event description.
 *  @param reaction Reaction handler.
 */
- (void)property:(NSString *)property
         onEvent:(MapperEvent)event
        reaction:(void(^)(id oldValue, id newValue))reaction;

/**
 *  Register reaction for multi properties on an event.
 *
 *  @param properties List of properties key path.
 *  @param event      Event description.
 *  @param reaction   Reaction handler.
 */
- (void)properties:(NSArray *)properties
           onEvent:(MapperEvent)event
          reaction:(void(^)(id oldValue, id newValue))reaction;

/**
 *  Register action for property on an event with selector.
 *
 *  @param property Property key path.
 *  @param target   Object trigger event.
 *  @param selector   A selector.
 *  @param event    Event description.
 */
- (void)property:(NSString *)property
          target:(id)target
        selector:(SEL)selector
         onEvent:(MapperEvent)event;

/**
 *  Register action for multi properties on an event.
 *
 *  @param properties List of properties key path.
 *  @param target     Object trigger event.
 *  @param selector     A selector.
 *  @param event      Event description.
 */
- (void)properties:(NSArray *)properties
            target:(id)target
          selector:(SEL)selector
           onEvent:(MapperEvent)event;

/**
 *  Remove reactions handler for property on event.
 *
 *  @param property Property key path.
 *  @param event    Event description.
 */
- (void)removeReactionsForProperty:(NSString *)property
                           onEvent:(MapperEvent)event;

/**
 *  Remove all reactions handler for property.
 *
 *  @param property Property key path.
 */
- (void)removeReactionsForProperty:(NSString *)property;

/**
 *  Remove reactions for multi properties.
 *
 *  @param properties List of properties.
 *  @param event      Event description.
 */
- (void)removeReactionsForProperties:(NSArray *)properties
                             onEvent:(MapperEvent)event;

/**
 *  Remove all reactions for multi properties.
 *
 *  @param properties List of properties.
 */
- (void)removeReactionsForProperties:(NSArray *)properties;

/**
 *  Remove all reaction.
 */
- (void)removeAllReactions;

/**
 *  Remove actions for property with target on event.
 *
 *  @param property Property key path.
 *  @param target   The target.
 *  @param selector The selector to remove.
 *  @param event    Event description.
 */
- (void)removeActionsForProperty:(NSString *)property
                          target:(id)target
                        selector:(SEL)selector
                         onEvent:(MapperEvent)event;

/**
 *  Remove actions of property with target for all event.
 *
 *  @param property Property key path.
 *  @param target   The target.
 */
- (void)removeActionsForProperty:(NSString *)property
                          target:(id)target;


/**
 *  Remove all actions for proprety.
 *
 *  @param property Property key path.
 */
- (void)removeActionsForProperty:(NSString *)property;

/**
 *  Remove actions for multi properties with target on event.
 *
 *  @param properties Property key path.
 *  @param target   The target.
 *  @param selector The selector to remove.
 *  @param event    Event description.
 */
- (void)removeActionsForProperties:(NSArray *)properties
                            target:(id)target
                          selector:(SEL)selector
                           onEvent:(MapperEvent)event;

/**
 *  Remove actions for multi property with target.
 *
 *  @param properties List of properties.
 *  @param target     The target, pass nil to remove action at all target.
 */
- (void)removeActionsForProperties:(NSArray *)properties
                            target:(id)target;

/**
 *  Remove all actions for list or properties.
 *
 *  @param properties List of properties.
 */
- (void)removeActionsForProperties:(NSArray *)properties;

/**
 *  Remove all actions.
 */
- (void)removeAllActions;

/**
 *  Get source url.
 *
 *  @return The source url.
 */
- (NSString *)getSourceUrl;

- (NSString *)getSourceMethod;

- (NSDictionary *)getSourceParameters;

- (NSDictionary *)getSourceHeader;


/**
 *  Get data key path.
 *
 *  @return The source key path.
 */
- (NSString *)getSourceKeyPath;

/**
 *  Fetch data in background.
 */
- (void)fetchInBackground;

/**
 *  Fetch data in background and handle data when fetch data completed.
 */
- (void)fetchInBackground:(nullable void(^)(id response,  NSError * _Nullable error))completion;
- (BOOL)isFetching;

@end

NS_ASSUME_NONNULL_END
