//
//  Mapper.m
//  Mapper
//
//  Created by Huy Pham on 3/26/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

static void * const MapperContext = (void*)&MapperContext;

#import "Mapper.h"
#import "MapperUtils.h"

@interface MapperReaction : NSObject

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic) MapperEvent event;
@property (nonatomic, copy) void (^react)(id, id);

@end

@implementation MapperReaction

@end

@interface MapperAction : NSObject

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic) MapperEvent event;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;

@end

@implementation MapperAction

@end

@interface Mapper()

@property (nonatomic, getter=isFetching) BOOL fetching;

@end

@implementation Mapper {
    
    // Store callback reaction.
    NSMutableArray *_reactions;
    
    // Store action with target.
    NSMutableArray *_actions;
    
    // Store keyobserver.
    NSMutableArray *_keyPaths;
}

// Lazy initial array to store reaction.
- (NSMutableArray *)reactions {
    @synchronized(_reactions) {
        if (!_reactions) {
            _reactions = [NSMutableArray array];
        }
    }
    return _reactions;
}

// Lazy initial array to store action.
- (NSMutableArray *)actions {
    @synchronized(_actions) {
        if (!_actions) {
            _actions = [NSMutableArray array];
        }
    }
    return _actions;
}

- (NSMutableArray *)keyPaths {
    @synchronized(_keyPaths) {
        if (!_keyPaths) {
            _keyPaths = [NSMutableArray array];
        }
    }
    return _keyPaths;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _actions = nil;
    _reactions = nil;
    _fetching = NO;
}

// Check keys path existed
- (BOOL)keyPathExisted:(NSString *)keyPath {
    for (NSString *key in [_keyPaths copy]) {
        if ([key isEqualToString:keyPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)addKeyPath:(NSString *)keyPath {
    [[self keyPaths] addObject:[keyPath copy]];
}

- (void)removeKeyPath:(NSString *)keyPath {
    NSMutableArray *keysToDelete = [NSMutableArray array];
    for (NSString *key in [_keyPaths copy]) {
        if ([key isEqualToString:keyPath]) {
            [keysToDelete addObject:key];
        }
    }
    [_keyPaths removeObjectsInArray:keysToDelete];
}

// Get reaction of property on event.
- (NSArray *)getReactionsOfProperty:(NSString *)property
                            onEvent:(MapperEvent)event {
    NSMutableArray *reactions = [NSMutableArray array];
    for (MapperReaction *reaction in [_reactions copy]) {
        if ([reaction.keyPath isEqualToString:property]
            && reaction.event == event) {
            [reactions addObject:reaction];
        }
    }
    return reactions;
}

// Get reactions of property.
- (NSArray *)getReactionsOfProperty:(NSString *)property {
    NSMutableArray *reactions = [NSMutableArray array];
    for (MapperReaction *reaction in [_reactions copy]) {
        if ([reaction.keyPath isEqualToString:property]) {
            [reactions addObject:reaction];
        }
    }
    return reactions;
}

- (NSArray *)getActionsOfProperty:(NSString *)property
                           target:(id)target
                         selector:(SEL)selector
                          onEvent:(MapperEvent)event {
    NSMutableArray *actions = [NSMutableArray array];
    for (MapperAction *action in [_actions copy]) {
        if ([action.keyPath isEqualToString:property]
            && [action.target isEqual:target]
            && action.selector == selector
            && action.event == event) {
            [actions addObject:action];
        }
    }
    return actions;
}

- (NSArray *)getActionsOfProperty:(NSString *)property
                           target:(id)target
                         selector:(SEL)selector {
    NSMutableArray *actions = [NSMutableArray array];
    for (MapperAction *action in [_actions copy]) {
        if ([action.keyPath isEqualToString:property]
            && [action.target isEqual:target]
            && action.selector == selector) {
            [actions addObject:action];
        }
    }
    return actions;
}

- (NSArray *)getActionsOfProperty:(NSString *)property
                           target:(id)target {
    NSMutableArray *actions = [NSMutableArray array];
    for (MapperAction *action in [_actions copy]) {
        if ([action.keyPath isEqualToString:property]
            && [action.target isEqual:target]) {
            [actions addObject:action];
        }
        return actions;
    }
}

- (NSArray *)getActionsOfProperty:(NSString *)property
                          onEvent:(MapperEvent)event {
    NSMutableArray *actions = [NSMutableArray array];
    for (MapperAction *action in [_actions copy]) {
        if ([action.keyPath isEqualToString:property]
            && action.event == event) {
            [actions addObject:action];
        }
    }
    return actions;
}

// Get action of property.
- (NSArray *)getActionsOfProperty:(NSString *)property {
    NSMutableArray *actions = [NSMutableArray array];
    for (MapperAction *action in [_actions copy]) {
        if ([action.keyPath isEqualToString:property]) {
            [actions addObject:action];
        }
    }
    return actions;
}

- (void)registerObserverForKeyPath:(NSString *)keyPath {
    if (![self keyPathExisted:keyPath]) {
        @try {
            @synchronized(_keyPaths) {
                [self addKeyPath:keyPath];
                [self addObserver:self
                       forKeyPath:keyPath
                          options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                          context:MapperContext];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"[Register] Exception: %@", exception);
        }
    }
}

- (void)removeObserverForKeyPath:(NSString *)keyPath {
    if ([self keyPathExisted:keyPath]) {
        @try {
            @synchronized(_keyPaths) {
                [self removeKeyPath:keyPath];
                [self removeObserver:self
                          forKeyPath:keyPath
                             context:MapperContext];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"[Remove action] Exception: %@", exception);
        }
    }
}

- (void)removeAllObservers {
    @synchronized(_keyPaths) {
        for (NSString *keyPath in _keyPaths) {
            @try {
                [self removeObserver:self
                          forKeyPath:keyPath
                             context:MapperContext];
            }
            @catch (NSException *exception) {
                NSLog(@"[Remove action] Exception: %@", exception);
            }
        }
    }
}

- (void)removeActions:(NSArray *)actions
   observerForKeyPath:(NSString *)keyPath {
    NSInteger observerCount = [[self getActionsOfProperty:keyPath] count] +
    [[self getReactionsOfProperty:keyPath] count];
    if (observerCount == 0) return;
    [_actions removeObjectsInArray:actions];
    [self removeObserverForKeyPath:keyPath];
}

- (void)removeReactions:(NSArray *)reactions
     observerForKeyPath:(NSString *)keyPath {
    NSInteger observerCount = [[self getActionsOfProperty:keyPath] count] +
    [[self getReactionsOfProperty:keyPath] count];
    if (observerCount == 0) return;
    [_reactions removeObjectsInArray:reactions];
    [self removeObserverForKeyPath:keyPath];
}

// IMPLEMENT
- (void)property:(NSString *)property
         onEvent:(MapperEvent)event
        reaction:(void (^)(id, id))reaction {
    [self registerObserverForKeyPath:property];
    MapperReaction *modelReaction = [[MapperReaction alloc] init];
    modelReaction.keyPath = property;
    modelReaction.react = reaction;
    modelReaction.event = event;
    [[self reactions] addObject:modelReaction];
}

- (void)property:(NSString *)property
          target:(id)target
        selector:(SEL)selector
         onEvent:(MapperEvent)event {
    if ([[self getActionsOfProperty:property
                             target:target
                           selector:selector
                            onEvent:event] count] > 0) {
#ifdef DEBUG
        NSLog(@"Duplicated register keyPath: %@", property);
#endif
        return;
    }
    [self registerObserverForKeyPath:property];
    MapperAction *modelAction = [[MapperAction alloc] init];
    modelAction.keyPath = property;
    modelAction.target = target;
    modelAction.selector = selector;
    modelAction.event = event;
    [[self actions] addObject:modelAction];
}

- (void)properties:(NSArray *)properties
           onEvent:(MapperEvent)event
          reaction:(void (^)(id, id))reaction {
    for (NSString *property in properties) {
        [self property:property
               onEvent:event
              reaction:reaction];
    }
}

- (void)properties:(NSArray *)properties
            target:(id)target
          selector:(SEL)selector
           onEvent:(MapperEvent)event {
    for (NSString *property in properties) {
        [self property:property
                target:target
              selector:selector
               onEvent:event];
    }
}

- (void)removeReactionsForProperty:(NSString *)property
                           onEvent:(MapperEvent)event {
    NSArray *reactions = [self getReactionsOfProperty:property
                                              onEvent:event];
    if ([reactions count] == 0) return;
    [self removeReactions:reactions
       observerForKeyPath:property];
}

- (void)removeReactionsForProperty:(NSString *)property {
    NSArray *reactions = [self getReactionsOfProperty:property];
    if ([reactions count] == 0) return;
    [self removeReactions:reactions
       observerForKeyPath:property];
}

- (void)removeReactionsForProperties:(NSArray *)properties
                             onEvent:(MapperEvent)event {
    for (NSString *property in properties) {
        [self removeReactionsForProperty:property
                                 onEvent:event];
    }
}

- (void)removeReactionsForProperties:(NSArray *)properties {
    for (NSString *property in properties) {
        [self removeReactionsForProperty:property];
    }
}

- (void)removeAllReactions {
    while ([_reactions count] > 0) {
        MapperReaction *reaction = [_reactions firstObject];
        if (reaction) {
            [self removeReactionsForProperty:reaction.keyPath];
        }
    }
}

- (void)removeActionsForProperty:(NSString *)property
                          target:(id)target
                        selector:(SEL)selector
                         onEvent:(MapperEvent)event {
    NSArray *actions = [self getActionsOfProperty:property
                                           target:target
                                         selector:selector
                                          onEvent:event];
    if ([actions count] == 0) return;
    [self removeActions:actions
     observerForKeyPath:property];
}

- (void)removeActionsForProperty:(NSString *)property
                          target:(id)target {
    NSArray *actions = [self getActionsOfProperty:property
                                           target:target];
    if ([actions count] == 0) return;
    [self removeActions:actions
     observerForKeyPath:property];
}

- (void)removeActionsForProperty:(NSString *)property {
    NSArray *actions = [self getActionsOfProperty:property];
    if ([actions count] == 0) return;
    [self removeActions:actions
     observerForKeyPath:property];
}

- (void)removeActionsForProperties:(NSArray *)properties
                            target:(id)target
                          selector:(SEL)selector
                           onEvent:(MapperEvent)event {
    for (NSString *property in properties) {
        [self removeActionsForProperty:property
                                target:target
                              selector:selector
                               onEvent:event];
    }
}

- (void)removeActionsForProperties:(NSArray *)properties
                            target:(id)target {
    for (NSString *property in properties) {
        [self removeActionsForProperty:property
                                target:target];
    }
}

- (void)removeActionsForProperties:(NSArray *)properties {
    for (NSString *property in properties) {
        [self removeActionsForProperty:property];
    }
}

- (void)removeAllActions {
    while ([_actions count] > 0) {
        MapperAction *action = [_actions firstObject];
        if (action) {
            [self removeActionsForProperty:action.keyPath];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id oldValue = change[@"old"];
    id newValue = change[@"new"];
    MapperEvent event = MapperEventOnChange;
    NSArray *reactions = [self getReactionsOfProperty:keyPath
                                              onEvent:event];
    for (MapperReaction *reaction in reactions) {
        reaction.react(oldValue, newValue);
    }
    
    // Automatic delete action when target become nil.
    NSMutableArray *actionsToDelete = [NSMutableArray array];
    NSArray *actions = [self getActionsOfProperty:keyPath
                                          onEvent:event];
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        for (MapperAction *action in actions) {
            id target = action.target;
            if (target) {
                ((void (*)(id, SEL))[target methodForSelector:action.selector])(target,
                                                                                action.selector);
                continue;
            }
            [actionsToDelete addObject:action];
        }
        for (MapperAction *action in actionsToDelete) {
            [self removeActionsForProperty:action.keyPath
                                    target:action.target];
        }
    }];
}

- (void)fetchInBackground {
    [self fetchInBackground: nil];
}

- (void)fetchInBackground:(void (^)(id, NSError *))completion {
    if (self.isFetching) {
        return;
    }
    _fetching = YES;
    __weak Mapper *weakSelf = self;
    [MapperUtils request:[self getSourceUrl]
                  method:[self getSourceMethod]
              parameters:[self getSourceParameters]
                 headers:[self getSourceHeader]
       completionHandler:^(id response, NSError *error) {
        [weakSelf setFetching:NO];
        NSDictionary *data = [MapperUtils getDataFrom:response
                                          WithKeyPath:[weakSelf getSourceKeyPath]];


        if (data) {
            [weakSelf initData:data];
        }
        if (completion) {
            completion(data, error);
        }
    }];
}

- (NSString *)getSourceKeyPath {
    return @"";
}

- (NSString *)getSourceUrl {
    return @"";
}

- (NSString *)getSourceMethod {
    return @"GET";
}

- (NSDictionary *)getSourceParameters {
    return nil;
}

- (NSDictionary *)getSourceHeader {
    return nil;
}

- (BOOL)isFetching {
    return _fetching;
}

- (void)dealloc {
    [self removeAllObservers];
}

@end
