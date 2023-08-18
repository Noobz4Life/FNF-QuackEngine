package options;

class CacheSettingsSubState extends BaseOptionsMenu
{
    public function new()
    {
        title = 'Caching';

        var option:Option = new Option('Clear Memory between Songs', //Name
			"If unchecked, don't clear memory unless going back to main menu\nChecking can lead to less loading time, but might cause a memory leak! Be careful!", //Description
			'clearMemoryBetweenSongs',
			'bool');
		addOption(option);

		var option:Option = new Option('Precache Base Game', //Name
			"If checked, precaches every base game asset when loading a mod\n(higher memory usage, less stutters)", //Description
			'precacheBase',
			'bool');
		addOption(option);

		var option:Option = new Option('Precache Mods', //Name
			"If checked, precaches EVERY asset from loaded mods.\n(higher memory usage, less stutters)", //Description
			'precacheMods',
			'bool');
		addOption(option);

        super();
    }
}