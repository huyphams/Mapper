This is Mapper for class (can integrate with Swift probject as example) to Unmarshal JSON to Class without manual mapping. It's very simple and easy to use.

```
    // Create model inheritance Mapper class
    let model = Model()
   
   // Init it with json
   model.initData(["Name": "Carrot", "ID": "A2jsdk"]) 
```

Or you can set selector trigger whatever field change value.

```
   // Setup selector trigger
   model.property("Name", target: self, selector: #selector(ChangeName), on: .onChange)

   // Change value then ChangeName will be called
   model.name = "New name"
```

#### Limitations

- Can't init property of super class.
- Can't setup selector with params.

#### Prop

- Easy to use and define
- Reduce bugs by typo and boring manual mapping code.
- Reduce bugs by null, nil, NSNull and optional wrapping when handle Json from server.
- Included networking and many utils.
- Work fine with Objective-C and Swift.

#### Cons

- Still Objective-C.
- Still have some limitations.

#### Improvement

- Try to resolve limitation (but seems no luck).
- Cached properties list to speedup initData (in case we need to init millions objects).
