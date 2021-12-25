package;

import haxe.io.Bytes;
import boisly.AppSettings;
@:config 
class Configly {
    public var boisly:{
        is:Dynamic<Bool>,
        createdBy:String,
        utility:Int,
        niftToGriftRatio:Float,
        binaryBlurb:Bytes
    };
}
class Test {
    public static function main() {
        $type(AppSettings.config);
        trace(AppSettings.config);
        trace(AppSettings.config.boisly.binaryBlurb.toString());
    }
}
