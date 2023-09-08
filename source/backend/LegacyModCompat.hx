package backend;

class LegacyModCompat {
    private static var classPrefixes:Array<String> = [
        "states",
        "substates",
        "backend",
        "objects"
    ];

    public static function getVarOffset(split:Array<String>):Float {
        if (split[0] == "camGame" && split[1] == "scroll") {
            if (split[2] == "x") {
                return -(FlxG.width/2);
            } else if (split[2] == "y") {
                return -(FlxG.height/2);
            }
        }
        return 0;
    }

    public static function resolveClass(classVar:String) {
        for(prefix in classPrefixes) {
            var prefixedClass:Dynamic = Type.resolveClass(prefix + '.' + classVar);
            trace(prefix + '.' + classVar);
            if(prefixedClass != null) {
                trace("[LMC] Resolved " + classVar + "!");
                PlayState.instance.isLegacyMod = true;
                return prefixedClass;
            }
        }
        return null;
    }
}