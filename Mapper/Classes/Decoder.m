//
//  Mapper.m
//  Mapper
//
//  Created by Huy Pham on 3/26/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Decoder.h"
#import <objc/runtime.h>

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1
                                                      length:strlen(attribute) - 1
                                                    encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3
                                                      length:strlen(attribute) - 4
                                                    encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

@interface Attribute : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameWithoutUnderscore;
@property (nonatomic, strong) NSString *type;


@end

@implementation Attribute

@end

@interface Decoder() {
    NSMutableDictionary *_attributes;
}

@property (nonatomic, getter=isInitiated) BOOL initiated;

@end

static NSArray<Attribute *> *_attributes = nil;

@implementation Decoder

+ (NSArray<Attribute *> *)attributes {
    return _attributes;
}

+ (void)setAttributes:(NSArray<Attribute *> *)attributes {
    _attributes = attributes;
}

+ (NSArray<Attribute *> *)getAttributeForClass:(Class)class {
    NSMutableArray<Attribute *> *attributes = [NSMutableArray array];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for(int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyNameChar = property_getName(property);
        if (propertyNameChar) {
            @autoreleasepool {
                const char *propertyTypeChar = getPropertyType(property);
                NSString *propertyName = [NSString stringWithCString:propertyNameChar
                                                            encoding:NSUTF8StringEncoding];
                NSString *propertyType = [NSString stringWithCString:propertyTypeChar
                                                            encoding:NSUTF8StringEncoding];
                NSString *propertyNameStrippedUnderscore = [self getPropertyNameStrippedUnderscore:propertyName];
                
                Attribute *attribute = [[Attribute alloc] init];
                attribute.name = propertyName;
                attribute.nameWithoutUnderscore = propertyNameStrippedUnderscore;
                attribute.type = propertyType;
                
                [attributes addObject:attribute];
            }
        }
    }
    free(properties);
    return attributes;
}

+ (NSString *)getPropertyNameStrippedUnderscore:(NSString *)property {
    if (!property) {
        return nil;
    }
    if ([property length] == 0) {
        return @"";
    }
    if ([property characterAtIndex:0] == '_') {
        return [property substringFromIndex:1];
    }
    return property;
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self commonInit];
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@:",
                                             NSStringFromClass(self.class)]);
        if ([self respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))[self methodForSelector:selector])(self,
                                                                       selector, dictionary);
        } else {
            [self initData:nil];
        }
        return self;
    }
    [self initData:dictionary];
    return self;
}

- (void)commonInit {
    _initiated = NO;
    _attributes = [[NSMutableDictionary alloc] init];
}

- (NSArray<Attribute *> *)attributes {
    if ([Decoder attributes]) {
        return [Decoder attributes];
    }
    NSMutableArray<Attribute *> *attributes = [NSMutableArray array];
    Class class = [self class];
    while ([class isSubclassOfClass:[Decoder class]]) {
        NSArray *attrs = [Decoder getAttributeForClass:class];
        [attributes addObjectsFromArray:attrs];
        class = [class superclass];
    }
    
    [Decoder setAttributes:attributes];
    return attributes;
}

- (void)initData:(NSDictionary *)dictionary {
    // Automic
    @synchronized (self) {
        for(Attribute *attribute in [self attributes]) {
            id value = [dictionary objectForKey:attribute.nameWithoutUnderscore];
            [self setProperty:attribute.name
                 propertyType:attribute.type
                        value:value];
        }
    }
}

- (void)setProperty:(NSString *)propertyName
       propertyType:(NSString *)propertyType
              value:(id)value {
    id instanceType = [self valueForKey:propertyName];
    if (!instanceType) {
        if ([NSClassFromString(propertyType) isSubclassOfClass:[Decoder class]]) {
            instanceType = [[NSClassFromString(propertyType) alloc] initWithDictionary:value];
            [self setValue:instanceType forKey:propertyName];
            return;
        }
        instanceType = [NSClassFromString(propertyType) alloc];
    } else {
        if ([instanceType isKindOfClass:[NSArray class]]) {
            instanceType = [NSArray alloc];
        } else if ([instanceType isKindOfClass:[NSMutableArray class]]){
            instanceType = [NSMutableArray alloc];
        } else if ([instanceType isKindOfClass:[NSDictionary class]]) {
            instanceType = [NSDictionary alloc];
        } else if ([instanceType isKindOfClass:[NSMutableDictionary class]]) {
            instanceType = [NSMutableDictionary alloc];
        } else if ([instanceType isKindOfClass:[NSString class]]) {
            instanceType = [NSString alloc];
        }
    }
    if (value && value != [NSNull null]) {
        if ([propertyType respondsToSelector:@selector(initData:)]) {
            [instanceType initData:value];
        } else if ([instanceType respondsToSelector:@selector(initWithArray:)]) {
            [self setValue:[instanceType initWithArray:value] forKey:propertyName];
        } else if ([instanceType respondsToSelector:@selector(initWithDictionary:)]) {
            [self setValue:[instanceType initWithDictionary:value] forKey:propertyName];
        } else {
            [self setValue:value forKey:propertyName];
        }
    } else {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@", propertyName]);
        if ([self respondsToSelector:selector]) {
            ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
        } else {
            [self setValue:[instanceType init] forKey:propertyName];
        }
    }
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:propertyName];
        if (value) {
            NSString *propertyNameStrippedUnderscore = [Decoder getPropertyNameStrippedUnderscore:propertyName];
            if ([[value class] isSubclassOfClass:[Decoder class]]) {
                [mutableDictionary setObject:[value toDictionary]
                                      forKey:propertyNameStrippedUnderscore];
            } else if ([value isKindOfClass:[NSArray class]]) {
                [mutableDictionary setObject:[self arraySerializer:value]
                                      forKey:propertyNameStrippedUnderscore];
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                [mutableDictionary setObject:[self dictionarySerializer:value]
                                      forKey:propertyNameStrippedUnderscore];
            } else {
                [mutableDictionary setValue:[self valueSerializer:value
                                                              key:propertyNameStrippedUnderscore]
                                     forKey:propertyNameStrippedUnderscore];
            }
        }
    }
    free(properties);
    return mutableDictionary;
}

- (NSDictionary *)dictionarySerializer:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in [dictionary allKeys]) {
        id value = [dictionary valueForKey:key];
        if ([[value class] isSubclassOfClass:[Decoder class]]) {
            [mutableDictionary setObject:[value toDictionary]
                                  forKey:key];
        } else if ([value isKindOfClass:[NSArray class]]){
            [mutableDictionary setObject:[self arraySerializer:value]
                                  forKey:key];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [mutableDictionary setObject:[self dictionarySerializer:value]
                                  forKey:key];
        } else {
            [mutableDictionary setObject:[self valueSerializer:value
                                                           key:key]
                                  forKey:key];
        }
    }
    return mutableDictionary;
}

- (NSArray *)arraySerializer:(NSArray *)array {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id value in array) {
        if ([[value class] isSubclassOfClass:[Decoder class]]) {
            [mutableArray addObject:[value toDictionary]];
        } else if ([value isKindOfClass:[NSArray class]]){
            [mutableArray addObject:[self arraySerializer:value]];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [mutableArray addObject:[self dictionarySerializer:value]];
        } else {
            [mutableArray addObject:value];
        }
    }
    return mutableArray;
}

- (id)valueSerializer:(id)value key:(NSString *)key {
    NSString *type  = [_attributes valueForKey:key];
    if ([type isEqualToString:@"q"]) {
        long long longValue = (long long)[value longLongValue];
        return @(longValue);
    }
    if ([type isEqualToString:@"Q"]) {
        unsigned long long ulongValue = [value unsignedLongValue];
        return @(ulongValue);
    }
    
    if ([type isEqualToString:@"B"]) {
        BOOL boolValue = [value boolValue];
        return @(boolValue);
    }
    
    if ([type isEqualToString:@"C"]) {
        Boolean boolValue = [value boolValue];
        return @(boolValue);
    }
    
    if ([type isEqualToString:@"d"]) {
        double floatValue = [value floatValue];
        return @(floatValue);
    }
    
    if ([type isEqualToString:@"{CGSize=dd}"]) {
        CGSize size = [value CGSizeValue];
        NSMutableDictionary *sizeDictionary = [NSMutableDictionary dictionary];
        [sizeDictionary setValue:@(size.width) forKey:@"width"];
        [sizeDictionary setValue:@(size.height) forKey:@"height"];
        return sizeDictionary;
    }
    
    if ([type isEqualToString:@"{CGRect={CGPoint=dd}{CGSize=dd}}"]) {
        CGRect rect = [value CGRectValue];
        NSMutableDictionary *rectDictionary = [NSMutableDictionary dictionary];
        NSMutableDictionary *sizeDictionary = [NSMutableDictionary dictionary];
        [sizeDictionary setValue:@(rect.size.width) forKey:@"width"];
        [sizeDictionary setValue:@(rect.size.height) forKey:@"height"];
        NSMutableDictionary *originDictionary = [NSMutableDictionary dictionary];
        [originDictionary setValue:@(rect.origin.x) forKey:@"x"];
        [originDictionary setValue:@(rect.origin.y) forKey:@"y"];
        [rectDictionary setValue:sizeDictionary forKey:@"size"];
        [rectDictionary setValue:originDictionary forKey:@"origin"];
        return rectDictionary;
    }
    
    if ([type isEqualToString:@"{CGPoint=dd}"]) {
        CGPoint point = [value CGPointValue];
        NSMutableDictionary *pointDictionary = [NSMutableDictionary dictionary];
        [pointDictionary setValue:@(point.x) forKey:@"x"];
        [pointDictionary setValue:@(point.y) forKey:@"y"];
        return pointDictionary;
    }
    
    if ([type isEqualToString:@"NSString"]) {
        return value;
    }
    // Add more value serializer here.
    
    return value;
}

- (BOOL)isInitiated {
    return _initiated;
}

- (void)setIsInitiated:(BOOL)initiated {
    _initiated = initiated;
}

@end
