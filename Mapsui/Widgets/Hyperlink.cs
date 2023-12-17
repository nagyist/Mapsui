﻿using System;

namespace Mapsui.Widgets;

public class Hyperlink : TextBox
{
    public string? Url { get; set; }

    public event EventHandler<HyperlinkWidgetArguments>? Touched;

    public override bool HandleWidgetTouched(Navigator navigator, MPoint position)
    {
        var args = new HyperlinkWidgetArguments();

        Touched?.Invoke(this, args);

        return args.Handled;
    }

    public override bool Touchable => true;
}

public class HyperlinkWidgetArguments
{
    public bool Handled = false;
}
