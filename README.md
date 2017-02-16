
## Why
I know many of open source out there have feature JSON deserialization, but you need to keep implement boring mapping functions by your hand. I created Mapper with objetive-c runtime so you don't need to do it anymore. It's awesome.

Mapper can integrate with Swift probject (as example), map JSON to objects and map objects to JSON without manual implementation. It's very simple and easy to use.

## Installation

```
  pod "HPMapper"
```

## How it works

#### Create model

```
    // Create model inheritance Mapper class and that's all
    // Objective-C (Recommended)
    #import "Mapper.h"

    @interface BaseModel : Mapper
        @property (nonatomic, copy) NSString *ID;
        @property (nonatomic, copy) NSString *Name;
    @end

    // Or Swift
    class Carrot: Mapper {  
      dynamic var ID: NSString!
      dynamic var Name: NSString!
    }

    let model = Model()   
   // Init it with json
    model.initData(["Name": "Carrot", "ID": "A2jsdk"])

   // Or simple
    let model = Model(dictionary: ["Name": "This name", "ID": "This is ID from super class"])
```

#### Sometimes you need to convert it back to JSON

```
    model.toDictionary()
```

#### You can set selector trigger whatever field change value.

```
   // Setup selector trigger
   model.property("Name", target: self, selector: #selector(ChangeName), on: .onChange)

   // Change value then ChangeName will be called
   model.name = "New name"
```

## Limitations

- Can't setup selector with params.
- Field name must be matched with json field name, we should have field description for customize mapping.

## Prop
- Support both iOS and OSX.
- Easy to use and define.
- Reduce bugs by typo and boring manual mapping code.
- Reduce bugs by null, nil, NSNull and optional wrapping when handle Json from server.
- Included networking and many utils.
- Work fine with Objective-C and Swift.
- Have binding and it will not crash when you forgot remove KVO before release object.
- Mapper uses runtime functions but super fast because it cached all properties when init Model for the first time.

## Cons

- Still Objective-C.
- Still have some limitations.

## Improvement

- Support selector with params.
