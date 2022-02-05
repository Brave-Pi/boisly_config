package boisly;
#if !(js&&!nodejs)
@:build(boisly.AppSettings.setup())

class AppSettings {
    
}
#else
class AppSettings {
  public static var config:Dynamic;
}
#end