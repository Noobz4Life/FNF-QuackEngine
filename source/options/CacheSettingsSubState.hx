package options;

class CacheSettingsSubState extends BaseOptionsMenu
{
    public function new()
    {
        title = 'Caching';

		var option:Option = new Option('Precache List', //Name
			"If checked, saves a list of every asset a song loads, so it can be precached next time.", //Description
			'precacheList',
			'bool');
		addOption(option);
		/*
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
		*/

        super();
    }
}