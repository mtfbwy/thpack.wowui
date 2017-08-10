T.ask("widget.Color", "widget.Div", "widget.Bar", "widget.Button", "widget.Image", "widget.Text")
    .answer("widget", function(Color, Div, Bar, Button, Image, Text)

    return {
        Color = Color,
        Div = Div,
        Bar = Bar,
        Button = Button,
        Image = Image,
        Text = Text,
    };
end);
