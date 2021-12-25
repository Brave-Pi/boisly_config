# boisly_config

`boisly_config` brings app config files into your app with zero hassle.

Simply add `--library boisly_config` to your .hxml, tag a class with `@:config` and `boisly.AppSettings.config` will point to an instance* of the class you decorated with `@:config`, populated from `haxe.config.json` (in the current working directory from which you executed the compiled Haxe program).

Example:
```haxe
@:config 
class Configly {
  var boisly:{
    is:Dynamic<Bool>,
    createdBy:String,
    utility:Int,
    niftToGriftRatio:Float,
    binaryBlurb:haxe.io.Bytes
  };
}
class Test {
  public static function main() {
    trace(AppSettings.config);
    $type(AppSettings.config);
    // { boisly : { utility : Int, niftToGriftRatio : Float, is : Dynamic<Bool>, createdBy : String, binaryBlurb : haxe.io.Bytes } }
  }
}
```
Output:
```
src/Test.hx:18: {
  boisly: {
    binaryBlurb: { length: 48, b: [Uint8Array] },
    createdBy: 'piboistudios',
    is: { cool: true, convenient: true, opinionated: false },
    niftToGriftRatio: 0.9,
    utility: 10
  }
}
```
## Custom config file name

Use the compiler flag `-D boisly.appSettings.configFile=<your config file path>` to set the config file name/path to whatever you desire.

## Caveats

You have to use fully qualified type names. This is also why there's an asterisk (*) next to "instance" above... this really turns the class into an anonymous type so that `tink_json` can parse it without complaining about there not being a `@:jsonParse` tag.

Probably, it will be better to actually use an instance of a class (and I guess generate a `@:jsonParse` tag by default if the class doesn't have one).. but for now this works.