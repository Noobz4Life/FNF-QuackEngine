package input;

import backend.Controls;
import objects.*;

class InputSystem {

    public function goodNoteHit(note:Note)
    {
        return Reflect.callMethod(PlayState,goodNoteHit,[note]);
    }

    public function keyPressed(key:Int,notes)
    {
        // Get variables from PlayState
        var notes = Reflect.getProperty(PlayState, "notes");
        var boyfriend = Reflect.getProperty(PlayState, "boyfriend");

        var strumsBlocked = Reflect.getProperty(PlayState, "strumsBlocked");
        var sortHitNotes = Reflect.getProperty(PlayState, "sortHitNotes");

        var noteMissPress = Reflect.getProperty(PlayState, "sortHitNotes");


        //more accurate hit time for the ratings?
        var lastTime:Float = Conductor.songPosition;
        if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

        var canMiss:Bool = !ClientPrefs.data.ghostTapping;

        // heavily based on my own code LOL if it aint broke dont fix it
        var pressNotes:Array<Note> = [];
        var notesStopped:Bool = false;
        var sortedNotesList:Array<Note> = [];
        notes.forEachAlive(function(daNote:Note)
        {
            if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress &&
                !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
            {
                if(daNote.noteData == key) sortedNotesList.push(daNote);
                canMiss = true;
            }
        });
        sortedNotesList.sort(sortHitNotes);

        if (sortedNotesList.length > 0) {
            for (epicNote in sortedNotesList)
            {
                for (doubleNote in pressNotes) {
                    if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
                        doubleNote.kill();
                        notes.remove(doubleNote, true);
                        doubleNote.destroy();
                    } else
                        notesStopped = true;
                }

                // eee jack detection before was not super good
                if (!notesStopped) {
                    Reflect.callMethod(PlayState,goodNoteHit,[epicNote]);
                    pressNotes.push(epicNote);
                }

            }
        }
        else {
            //callOnScripts('onGhostTap', [key]);
            if (canMiss && !boyfriend.stunned) noteMissPress(key);
        }
    }

    public function keysCheck():Void
    {
        var keysArray = Reflect.field(PlayState, "keysArray").getDynamic();
        var startedCountdown = Reflect.field(PlayState, "startedCountdown");

        // HOLDING
        var holdArray:Array<Bool> = [];
        var pressArray:Array<Bool> = [];
        var releaseArray:Array<Bool> = [];
        for (key in keysArray)
        {
            holdArray.push(controls.pressed(key));
            pressArray.push(controls.justPressed(key));
            releaseArray.push(controls.justReleased(key));
        }

        if (startedCountdown && !boyfriend.stunned && generatedMusic)
        {
            // rewritten inputs???
            if(notes.length > 0)
            {
                notes.forEachAlive(function(daNote:Note)
                {
                    // hold note functions
                    if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && holdArray[daNote.noteData] && daNote.canBeHit
                    && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
                        goodNoteHit(daNote);
                    }
                });
            }
        }
    }
} 
