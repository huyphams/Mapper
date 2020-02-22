//
//  Mapper.m
//  Mapper
//
//  Created by Huy Pham on 3/26/15.
//  Copyright (c) 2015 Katana. All rights reserved.
//

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

@interface Decoder()

@property (nonatomic, getter=isInitiated) BOOL initiated;

@end

static NSDictionary *_attributes = nil;

@implementation Decoder

+ (NSArray<Attribute *> *)attributesForClass:(Class)class {
    NSString *classIdent = NSStringFromClass(class);
    @synchronized (self) {
        return [_attributes valueForKey:classIdent];
    }
}

+ (void)setAttributes:(NSArray<Attribute *> *)attributes forClass:(Class)class {
    NSString *classIdent = NSStringFromClass(class);
    @synchronized (self) {
        if (_attributes) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:attributes, classIdent, nil];
            [dic addEntriesFromDictionary:_attributes];
            _attributes = dic;
            return;
        }
        _attributes = [NSDictionary dictionaryWithObjectsAndKeys:attributes, classIdent, nil];
    }
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
    _initiated = NO;
    self = [super init];
    if (!self) {
        return nil;
    }
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
    _initiated = YES;
    return self;
}

- (NSArray<Attribute *> *)attributes {
    Class class = [self class];
    NSArray<Attribute *> *existedAttributes = [Decoder attributesForClass:class];
    if (existedAttributes) {
        return existedAttributes;
    }
    NSMutableArray<Attribute *> *attributes = [NSMutableArray array];

    Class superClass = class;
    while ([superClass superclass] != [Decoder class] && [superClass isSubclassOfClass:[Decoder class]]) {
        NSArray *attrs = [Decoder getAttributeForClass:superClass];
        [attributes addObjectsFromArray:attrs];
        superClass = [superClass superclass];
    }

    [Decoder setAttributes:attributes
                  forClass:class];
    return attributes;
}

- (void)initData:(NSDictionary *)dictionary {
    // Automic
    @synchronized (self) {
        @autoreleasepool {
            for(Attribute *attribute in [[self attributes] copy]) {
                id value = [dictionary objectForKey:attribute.nameWithoutUnderscore];
                [self setProperty:attribute.name
                     propertyType:attribute.type
                            value:value];
            }
        }
    }
}

- (void)setProperty:(NSString *)propertyName
       propertyType:(NSString *)propertyType
              value:(id)value {
    id instanceType = [self valueForKey:propertyName];

    // Init instance
    if (!instanceType) {
        if ([NSClassFromString(propertyType) isSubclassOfClass:[Decoder class]]) {
            instanceType = [[NSClassFromString(propertyType) alloc] initWithDictionary:value];
            return [self setValue:instanceType
                           forKey:propertyName];
        }
        instanceType = [NSClassFromString(propertyType) alloc];
    }

    // Alloc instance
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

    // Check value
    if (value && value != [NSNull null]) {
        if ([propertyType respondsToSelector:@selector(initData:)]) {
            return [instanceType initData:value];
        }
        if ([instanceType respondsToSelector:@selector(initWithArray:)]) {
            return [self setValue:[instanceType initWithArray:value]
                           forKey:propertyName];
        }
        if ([instanceType respondsToSelector:@selector(initWithDictionary:)]) {
            return [self setValue:[instanceType initWithDictionary:value]
                           forKey:propertyName];
        }
        // Safe convert
        if ([[NSString stringWithFormat:@"%@", [instanceType class]] isEqualToString:@"__NSCFNumber"]) {
            return [self setValue:@([value floatValue])
                           forKey:propertyName];
        }
        return [self setValue:value
                       forKey:propertyName];
    }

    // Call default function
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@", propertyName]);
    if ([self respondsToSelector:selector]) {
        ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
    } else {
        [self setValue:[instanceType init]
                forKey:propertyName];
    }
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    for (Attribute *attribute in [[self attributes] copy]) {
        id value = [self valueForKey:attribute.name];
        if ([[value class] isSubclassOfClass:[Decoder class]]) {
            [mutableDictionary setObject:[value toDictionary]
                                  forKey:attribute.name];
            continue;
        }
        if ([value isKindOfClass:[NSArray class]]){
            [mutableDictionary setObject:[self toArray:value]
                                  forKey:attribute.name];
            continue;
        }
        [mutableDictionary setObject:[self toValue:value
                                               key:attribute.name
                                              type: attribute.type]
                              forKey:attribute.name];

    }
    return mutableDictionary;
}

- (NSArray *)toArray:(NSArray *)array {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id value in array) {
        if ([[value class] isSubclassOfClass:[Decoder class]]) {
            [mutableArray addObject:[value toDictionary]];
            continue;
        }
        if ([value isKindOfClass:[NSArray class]]){
            [mutableArray addObject:[self toArray:value]];
            continue;
        }
        [mutableArray addObject:value];
    }
    return mutableArray;
}

- (id)toValue:(id)value key:(NSString *)key type:(NSString *)type {
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

    if ([type isEqualToString:@"NSString"]) {
        return value;
    }
    // Add more value serializer here.

    return value;
}

- (BOOL)isInitiated {
    return _initiated;
}

@end
