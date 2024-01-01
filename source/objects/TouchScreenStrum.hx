package objects;

class TouchScreenStrum extends flixel.addons.display.shapes.FlxShapeBox
{
    public var justPressed = false;
    public var justReleased = false;
    public var pressed = false;

    private static inline final unpressedAlpha = 0.2;
    private static inline final pressedAlpha = 0.5;

    public function new(x:Float,y:Float,w:Float,h:Float,?color=FlxColor.WHITE) {
        super(x,y,w,h,{color: color, thickness: 4,jointStyle:"bevel"},FlxColor.TRANSPARENT);

        alpha = unpressedAlpha;
        redrawShape();
    }

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
        //#if debug
        //if(pressed) lineStyle.color = FlxColor.LIME else lineStyle.color = FlxColor.RED;
        //redrawShape();
        //#end

        if(justPressed || justReleased) {
            if(pressed) alpha = pressedAlpha else alpha = unpressedAlpha;
            redrawShape();
        }

        super.update(elapsed);
    }
}