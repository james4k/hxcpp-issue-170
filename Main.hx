package;


@:cppFileCode("
extern \"C\" char **environ;
")
class Main {


	public static function main ():Void {

#if 0

		var sys_env = cpp.Lib.load("std","sys_env",0);
		var vars:Array<String> = sys_env ();
		sys.io.File.saveContent ("env.json", haxe.Json.stringify (vars, null, "\t"));

#else

		// override `environ` values which libstd will read
		untyped __cpp__ ("char envMem [20480]; char *nextMem = envMem");
		var fakeEnv:Array<String> = haxe.Json.parse (sys.io.File.getContent ("env.json"));
		untyped __cpp__ ("environ = (char **)&envMem[0]; nextMem += {0}*sizeof(void *)", fakeEnv.length + 1);
		for (i in 0...Std.int(fakeEnv.length / 2)) {
			untyped __cpp__ ("int n = sprintf (nextMem, \"%s=%s\", (const char *){0}, (const char *){1})", fakeEnv[i*2+0], fakeEnv[i*2+1]);
			untyped __cpp__ ("environ[{0}] = nextMem; nextMem += n + 1", Std.int (i/2));
		}
		untyped __cpp__ ("environ[{0}] = 0", Std.int (fakeEnv.length/2));

		var env = Sys.environment ();

		for (i in 0...100) {
			for (j in 0...Std.int(Math.random () * 5)) {
				env = Sys.environment ();
			}
		}

		// prevent elision
		trace ('$env'.substring (0, 1));
		//trace (env);

#end

	}


}
