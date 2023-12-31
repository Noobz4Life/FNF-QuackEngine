package input;

import objects.*;

class KadeInputSystem extends InputSystem {
    public var closestNotes:Array<Note> = [];
    private var currentTimingShown:FlxText;

    public override function updateNote(note:Note,elapsed:Float) {
        var mustPress = note.mustPress;
        var strumTime = note.strumTime;
        var tooLate = note.tooLate;
        var wasGoodHit = note.wasGoodHit;
        var lateHitMult = note.lateHitMult;
        var earlyHitMult = note.earlyHitMult;
        var isSustainNote = note.isSustainNote;
        var sustainActive = note.sustainActive;
        var prevNote = note.prevNote;
        var inEditor = note.inEditor;
        
        var songMultiplier = PlayState.instance.playbackRate;
        var timeScale:Float = Conductor.safeZoneOffset / 166;

        if (!sustainActive)
		{
			note.alpha = 0.3;
		}

        if (mustPress)
        {
            if (isSustainNote)
            {
                if (strumTime - Conductor.songPosition <= (((166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1) * 0.5))
                    && strumTime - Conductor.songPosition >= (((-166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
                    note.canBeHit = true;
                else
                    note.canBeHit = false;
            }
            else
            {
                if (strumTime - Conductor.songPosition <= (((166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1)))
                    && strumTime - Conductor.songPosition >= (((-166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
                    note.canBeHit = true;
                else
                    note.canBeHit = false;
            }
            /*if (strumTime - Conductor.songPosition < (-166 * Conductor.timeScale) && !wasGoodHit)
                tooLate = true; */
        }
        else
        {
            note.canBeHit = false;
            // if (strumTime <= Conductor.songPosition)
            //	wasGoodHit = true;
        }

        if (tooLate && !wasGoodHit)
        {
            if (note.multAlpha > 0.3)
                note.multAlpha = 0.3;
        }
    }

    private function showCurrentTiming(msTiming: Float) {
        if (currentTimingShown != null)
            PlayState.instance.remove(currentTimingShown);

        currentTimingShown = new FlxText(0, 0, 0, "0ms");
        currentTimingShown.borderStyle = OUTLINE;
        currentTimingShown.borderSize = 1;
        currentTimingShown.borderColor = FlxColor.BLACK;
        currentTimingShown.text = msTiming + "ms";
        currentTimingShown.size = 20;
        currentTimingShown.color = FlxColor.CYAN;
        currentTimingShown.alpha = 1;

        var ratingX = (FlxG.width * 0.55) - 125;
        var ratingY = -50;
        
        currentTimingShown.screenCenter();
		currentTimingShown.x = ratingX + 100;
		currentTimingShown.y = ratingY + 100;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y = -300;

        currentTimingShown.updateHitbox();
        currentTimingShown.cameras = [PlayState.instance.camHUD];

        /*
        FlxTween.tween(currentTimingShown, {alpha: 0}, 0.2, {
            startDelay: Conductor.crochet * 0.001
        });
        */
    }

    public override function keyPressed(key:Int) {
        var boyfriend = PlayState.instance.boyfriend;
        var notes = PlayState.instance.notes;

        var canMiss:Bool = !ClientPrefs.data.ghostTapping;

        var data = key;

        closestNotes = [];

        notes.forEachAlive(function(daNote:Note)
        {
            if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
                closestNotes.push(daNote);
        });

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        if (dataNotes.length > 0)
        {
            var coolNote = null;

            for (i in dataNotes)
            {
                coolNote = i;
                break;
            }

            if (dataNotes.length > 1) // stacked notes or really close ones
            {
                for (i in 0...dataNotes.length)
                {
                    if (i == 0) // skip the first note
                        continue;

                    var note = dataNotes[i];

                    if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
                    {
                        trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
                        // just fuckin remove it since it's a stacked note and shouldn't be there
                        note.kill();
                        notes.remove(note, true);
                        note.destroy();
                    }
                }
            }

            boyfriend.holdTimer = 0;
            var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);

            //showCurrentTiming(noteDiff);
            goodNoteHit(coolNote);
        }
        else
        {
            PlayState.instance.callOnScripts('onGhostTap', [key]);
            if (canMiss && !boyfriend.stunned) noteMissPress(key);
        }
    }

    public override function keysCheck():Void {
        if (holdArray.contains(true))
        {
            var notes = PlayState.instance.notes;
            notes.forEachAlive(function(daNote:Note)
            {
                // TODO: add sustainactive
                if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
                {
                    goodNoteHit(daNote);
                }
            });
        }
    }

    private function addMiss() {
        var practiceMode = PlayState.instance.practiceMode;
        var endingSong = PlayState.instance.endingSong;

        if(!practiceMode) PlayState.instance.songScore -= 10;
        if(!endingSong) PlayState.instance.songMisses++;
        PlayState.instance.totalPlayed++;
        PlayState.instance.RecalculateRating(true);
    }

    public override function noteMissed(daNote:Note) {
        if (daNote.tail.length > 0)
        {
            for (i in daNote.tail)
            {
                i.multAlpha = 0.3;
                i.sustainActive = false;

                addMiss();

                PlayState.instance.health -= 0.15;
            }
        } else {
            if (!daNote.wasGoodHit
                && daNote.isSustainNote
                && daNote.sustainActive
                && daNote != daNote.parent.tail[daNote.parent.tail.length])
            {
                // health -= 0.05; // give a health punishment for failing a LN
                for (i in daNote.parent.tail)
                {
                    i.multAlpha = 0.3;
                    i.sustainActive = false;

                    addMiss();
                }
            }
        }
    }

    public function calculateRank(sicks:Int, goods:Int, bads:Int, shits:Int, misses:Int) {
        var ranking:String = "N/A";
        var accuracy = PlayState.instance.ratingPercent;

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0) // Marvelous (SICK) Full Combo
			ranking = "MFC";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "GFC";
		else if (misses == 0) // Regular FC
			ranking = "FC";
		else if (misses < 10) // Single Digit Combo Breaks
			ranking = "SDCB";
		else
			ranking = "Clear";

        if (accuracy == 0)
			ranking = "N/A";

        return ranking;
    }
}