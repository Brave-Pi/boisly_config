package boisly;

import haxe.macro.Printer;
import tink.macro.Sisyphus;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

class AppSettings {
	static var configFile(get, never):String;

	static function get_configFile() {
		var configFile = Context.getDefines().get("boisly.appSettings.configFile");
		if (configFile == null)
			configFile = 'haxe.config.json';
		return configFile;
	}

	public static function setup() {
		var fields = Context.getBuildFields();
		var cfgType = State.configType;
		if (cfgType == null)
			throw 'no config found';

		var path = new haxe.io.Path(configFile);

		var appSettingsDecl = switch path.ext {
			case 'json':
				macro class {
					static var _config:tink.core.Lazy<$cfgType> = boisly.AppSettings.fromFile.bind($v{configFile});
					public static var config(get, never):$cfgType;

					public static function get_config()
						return _config.get();

					public static function fromFile(file):$cfgType {
						var ret:$cfgType = tink.Json.parse(sys.io.File.getContent(file));
						return ret;
					}
				}
			case 'xml':
				macro class {
					static var _config:tink.core.Lazy<$cfgType> = boisly.AppSettings.fromFile.bind($v{configFile});
					public static var config(get, never):$cfgType;

					public static function get_config()
						return _config.get();

					public static function fromFile(file):$cfgType {
						var structure = new tink.xml.Structure<$cfgType>();
						return tink.core.Outcome.OutcomeTools.sure(structure.read((sys.io.File.getContent(file))));
					}
				}
			case 'yaml':
				macro class {
					static var _config:tink.core.Lazy<$cfgType> = boisly.AppSettings.fromFile.bind($v{configFile});
					public static var config(get, never):$cfgType;

					public static function get_config()
						return _config.get();

					public static function fromFile(file):$cfgType {
						var ret = yaml.Yaml.parse(sys.io.File.getContent(file), yaml.Parser.options().useObjects());
						return ret;
					}
				}
			default: throw 'Invalid config file type. Only JSON, XML and YAML are supported.';
		}

		return appSettingsDecl.fields;
	}

	public static function checkForConfig():Array<haxe.macro.Field> {
		var type = Context.getLocalType();
		var fields = Context.getBuildFields();
		var path = new haxe.io.Path(configFile);
		switch type {
			case TType(_.get() => t, params) if (t.meta.has(":config")):
				State.configType = type.toComplex();
			case TInst(_.get() => t, params) if (t.meta.has(":config")):
				final ct = type.toComplex();
				final setup = EBlock([
					for (f in fields) {
						var fName = f.name;
						macro @:pos(f.pos) ret.$fName = obj.$fName;
					}
				]).at(t.pos);
				var tName = t.name; // if (t.name != t.module) '${t.module}.${t.name}' else t.name;
				tName = t.pack.concat([tName]).join('.');
				if (path.ext == 'json' && !t.meta.has(':jsonParse')) {
					final jsonParse = macro function(obj) {
						var ret:$ct = untyped Type.createEmptyInstance(Type.resolveClass($v{tName}));
						$setup;
						return ret;
					};
					t.meta.add(':jsonParse', [jsonParse], t.pos);
				}
				State.configType = ct;
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
