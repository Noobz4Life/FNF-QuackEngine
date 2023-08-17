package input;

import objects.*;

class KadeInputSystem extends InputSystem {
    public var closestNotes:Array<Note> = [];

    public override function updateNote(note:Note,elapsed:Float) {
        var mustPress = note.mustPress;
        var strumTime = note.strumTime;
        var tooLate = note.tooLate;
        var wasGoodHit = note.wasGoodHit;
        var lateHitMult = note.lateHitMult;
        var earlyHitMult = note.earlyHitMult;
        var isSustainNote = note.isSustainNote;
        var prevNote = note.prevNote;
        var inEditor = note.inEditor;
        
        var songMultiplier = PlayState.instance.playbackRate;
        var timeScale:Float = Conductor.safeZoneOffset / 166;

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
            if (note.alpha > 0.3)
                note.alpha = 0.3;
        }
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

        trace("amount of notes 1: " + closestNotes.length);

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        trace("amount of notes 2: " + closestNotes.length);

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        trace("notes able to hit for " + key + " " + dataNotes.length);

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
                if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
                {
                    goodNoteHit(daNote);
                }
            });
        }
    }
}