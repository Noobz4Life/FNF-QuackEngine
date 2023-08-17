package input;

import haxe.macro.Type.AbstractType;
import objects.*;

class InputSystem {
    public var holdArray:Array<Bool> = [];
    public var pressArray:Array<Bool> = [];
    public var releaseArray:Array<Bool> = [];

    public function new() {
    }

    public function goodNoteHit(note) {
        Reflect.field(PlayState.instance,"goodNoteHit")(note);
    }

    public function noteMissPress(key) {
        Reflect.field(PlayState.instance,"noteMissPress")(key);
    }

    public function callOnScripts(script,args) {
        Reflect.field(PlayState.instance,"callOnScripts")(script,args);
    }

    public function noteMissed(note:Note) {
    }

    public function updateNote(note:Note,elapsed:Float) {
        // we make these so i can easily just copy+paste any changes directly in with very slight modifications
        // lazy i know, but it works doesn't it?
        trace("updating note with InputSystem.hx");

        var mustPress = note.mustPress;
        var strumTime = note.strumTime;
        var tooLate = note.tooLate;
        var wasGoodHit = note.wasGoodHit;
        var lateHitMult = note.lateHitMult;
        var earlyHitMult = note.earlyHitMult;
        var isSustainNote = note.isSustainNote;
        var prevNote = note.prevNote;
        var inEditor = note.inEditor;

        if (mustPress)
        {
            note.canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) &&
                        strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));

            if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
                tooLate = true;
        }
        else
        {
            note.canBeHit = false;

            if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
            {
                if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
                    note.wasGoodHit = true;
            }
        }

        if (tooLate && !inEditor)
        {
            if (note.alpha > 0.3)
                note.alpha = 0.3;
        }
    }

    public function keyPressed(key:Int) {
        var boyfriend = PlayState.instance.boyfriend;
        var notes = PlayState.instance.notes;
        var strumsBlocked = PlayState.instance.strumsBlocked;

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
        sortedNotesList.sort(Reflect.field(PlayState.instance,"sortHitNotes"));

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
                    Reflect.field(PlayState.instance,"goodNoteHit")(epicNote);
                    pressNotes.push(epicNote);
                }

            }
        }
        else {
            PlayState.instance.callOnScripts('onGhostTap', [key]);
            if (canMiss && !boyfriend.stunned) noteMissPress(key);
        }
    }

    public function keysCheck():Void {
        var notes = PlayState.instance.notes;
        if(notes.length > 0)
        {
            var notes = PlayState.instance.notes;
            var strumsBlocked = PlayState.instance.strumsBlocked;
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
