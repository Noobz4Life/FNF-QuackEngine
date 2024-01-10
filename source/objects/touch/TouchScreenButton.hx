#if (TOUCHSCREEN_SUPPORT && FLX_TOUCH)
package objects.touch;

class TouchScreenButton extends FlxSprite
{
    public var justPressed = false;
    public var justReleased = false;
    public var pressed = false;

    public function updateTouch():Void {
        var newJustPressed = false;
        var newJustReleased = false;
        var newPressed = false;

        for (touch in FlxG.touches.list) {
            var pixel = getPixelAtScreen(touch.getScreenPosition(camera),camera);
            if(pixel != null) { // we're touching the strum!!
                newPressed = (touch.pressed || newPressed);
            }
        }

        // mouse support for debugging purposes
        #if (debug && !mobile)
        FlxG.mouse.visible = true;
        var pixel = getPixelAtScreen(FlxG.mouse.getScreenPosition(camera),camera);
        if(pixel != null) { // we're touching the strum!!
            newPressed = (FlxG.mouse.pressed || newPressed);
        }
        #end

        newJustPressed = (!pressed && newPressed);
        newJustReleased = (pressed && !newPressed);

        pressed = newPressed;
        justPressed = newJustPressed;
        justReleased = newJustReleased;
    }

    public override function update(elapsed:Float) {
        updateTouch();
        super.update(elapsed);
    }
}
#end