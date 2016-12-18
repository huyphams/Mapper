This is Mapper for Objective class (can integrate with Swift probject as example). It's very simple and easy to use.

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

- Can not init property of supper class.
- Can not setup selector with params

#### Prop

- Easy to use and define
- Reduce bugs by typo and boring manual mapping code.
- Deduce bugs by null, nil and optional wrapping.
- Have many utils.
- Work fine with Objective-C and Swift.

#### Cons

- Still Objective-C

#### Improvement

- Try to resolve limitation (but seems no luck).
- Cached properties list to speedup initData (in case we need to init millions objects).
