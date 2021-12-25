package boisly;

import tink.macro.Sisyphus;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using tink.MacroApi;

class AppSettings {
	public static function setup() {
		var fields = Context.getBuildFields();
		var cfgType = State.configType;
		if (cfgType == null)
			throw 'no config found';
		var configFile = Context.getDefines().get("boisly.appSettings.configFile");
		if (configFile == null)
			configFile = 'haxe.config.json';
		var appSettingsDecl = macro class {
			static var _config:tink.core.Lazy<$cfgType> = boisly.AppSettings.fromFile.bind($v{configFile});
            public static var config(get, never):$cfgType;
            public static function get_config() return _config.get();

			public static function fromFile(file):$cfgType {
				var ret:$cfgType = tink.Json.parse(sys.io.File.getContent(file));
				return ret;
			}
		}
		return appSettingsDecl.fields;
	}

	public static function checkForConfig():Array<haxe.macro.Field> {
		var type = Context.getLocalType();
        var fields = Context.getBuildFields();
		// trace(new haxe.macro.Printer().printComplexType(type.toComplex()));
		// trace(type);
		switch type {
			case TType(_.get() => t, params) if (t.meta.has(":config")):
				State.configType = type.toComplex();
			case TInst(_.get() => t, params) if (t.meta.has(":config")):
                final anon = {
                    fields: fields,
                    status: AClosed
                };
				State.configType =  TAnonymous(fields);
			default:
		}
		return fields;
	}

	public static function configure() {
		Compiler.addGlobalMetadata('', '@:build(boisly.AppSettings.checkForConfig())', true, true, false);
	}
}

#if macro
class State {
	public static var configType:ComplexType;
}
#end
