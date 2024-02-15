package backend;

import flixel.util.FlxSave;
import haxe.io.Path;

class SongCacheList {
    public static var cache:Map<String,String> = [];
    public static var recordingEnabled:Bool = false;

    private static function createSave():FlxSave {
        final invalidChars = ~/[ ~%&\\;:"',<>?#]+/;
        
        var save:FlxSave = new FlxSave();
        save.bind(invalidChars.split(PlayState.SONG.song.toLowerCase()).join('-'), CoolUtil.getSavePath() + "/song-cache");

        return save;
    }

    public static function addToCache(asset:String, type:String) {
        if(recordingEnabled) {
            SongCacheList.cache[asset] = type;
            trace("added " + asset + " to cache as type " + type);
        }
    }

    public static function loadSongCache() {
        var save:FlxSave = createSave();
        if(save.data != null && save.data.cache != null) {
            var precacheList:Map<String,String> = save.data.cache;
            for (key => type in precacheList) {
                switch(type)
                {
                    case 'image':
                        trace("precached image " + key + " from song cache");
                        Paths.image(key);
                    case 'sound':
                        trace("precached sound " + key + " from song cache");
                        Paths.sound(key);
                    case 'music':
                        trace("precached music " + key + " from song cache");
                        Paths.music(key);
                }
            }
            cache = precacheList;
        }
    }

    public static function saveSongCache() {
        trace("save called");
        backend.Threader.wait();

        var save:FlxSave = createSave();
        save.data.cache = cache;
        save.flush();
    }

    public static function reset() {
        backend.Threader.wait();

        cache = [];
        loadSongCache();
        recordingEnabled = false;
    }
}
