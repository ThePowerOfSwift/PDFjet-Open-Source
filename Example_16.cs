using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_16.cs
 *
 */
public class Example_16 {

    public Example_16() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_16.pdf", FileMode.Create)));

        Font f1 = new Font(pdf, CoreFont.HELVETICA);
        f1.SetSize(14f);

        Page page = new Page(pdf, Letter.PORTRAIT);

        Box bg_flag = new Box();
        bg_flag.SetLocation(50f, 50f);
        bg_flag.SetSize(200f, 120f);
        bg_flag.SetColor(Color.black);
        bg_flag.SetLineWidth(1.5f);
        bg_flag.DrawOn(page);

        float stripe_width = 120f / 3;

        Line white_stripe = new Line(0.0f, 0.0f, 200.0f, 0.0f);
        white_stripe.SetWidth(stripe_width);
        white_stripe.SetColor(Color.white);
        white_stripe.PlaceIn(bg_flag, 0.0f, stripe_width / 2);
        white_stripe.DrawOn(page);

        Line green_stripe = new Line(0.0f, 0.0f, 200.0f, 0.0f);
        green_stripe.SetWidth(stripe_width);
        green_stripe.SetColor(0x00966e);
        green_stripe.PlaceIn(bg_flag, 0.0f, (3 * stripe_width) / 2);
        green_stripe.DrawOn(page);

        Line red_stripe = new Line(0.0f, 0.0f, 200.0f, 0.0f);
        red_stripe.SetWidth(stripe_width);
        red_stripe.SetColor(0xd62512);
        red_stripe.PlaceIn(bg_flag, 0.0f, (5 * stripe_width) / 2);
        red_stripe.DrawOn(page);

        Dictionary<String, Int32> colors = new Dictionary<String, Int32>();
        colors["Lorem"] = Color.blue;
        colors["ipsum"] = Color.red;
        colors["dolor"] = Color.green;
        colors["ullamcorper"] = Color.gray;

        f1.SetSize(72f);

        GraphicsState gs = new GraphicsState();
        gs.Set_CA(0.5f);                            // Stroking alpha
        gs.Set_ca(0.5f);                            // Nonstroking alpha
        page.SetGraphicsState(gs);

        TextLine text = new TextLine(f1, "Hello, World");
        text.SetLocation(50f, 300f);
        text.DrawOn(page);

        f1.SetSize(14f);

        StringBuilder buf = new StringBuilder();
        buf.Append("    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla elementum interdum elit, quis vehicula urna interdum quis. Phasellus gravida ligula quam, nec blandit nulla. Sed posuere, lorem eget feugiat placerat, ipsum nulla euismod nisi, in semper mi nibh sed elit. Mauris libero est, sodales dignissim congue sed, pulvinar non ipsum. Sed risus nisi, ultrices nec eleifend at, viverra sed neque. Integer vehicula massa non arcu viverra ullamcorper. Ut id tellus id ante mattis commodo. Donec dignissim aliquam tortor, eu pharetra ipsum ullamcorper in. Vivamus ultrices imperdiet iaculis.\n\n");

        buf.Append("    Donec a urna ac ipsum fringilla ultricies non vel diam. Morbi vitae lacus ac elit luctus dignissim. Quisque rutrum egestas facilisis. Curabitur tempus, tortor ac fringilla fringilla, libero elit gravida sem, vel aliquam leo nibh sed libero. Proin pretium, augue quis eleifend hendrerit, leo libero auctor magna, vitae porttitor lorem urna eget urna. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tincidunt venenatis odio in dignissim. Ut cursus egestas eros, ac blandit nisi ullamcorper a."); 

        TextBox textBox = new TextBox(f1, buf.ToString());
        textBox.SetLocation(50f, 200f);
        textBox.SetWidth(400f);
        textBox.SetHeight(400f);

        // If no height is specified the height will be calculated based on the text.
        // textBox.SetHeight(363f);
        // textBox.SetHeight(362f);
        // textBox.SetVerticalAlignment(Align.TOP);
        // textBox.SetVerticalAlignment(Align.BOTTOM);
        // textBox.SetVerticalAlignment(Align.CENTER);

        textBox.SetBgColor(Color.whitesmoke);
        textBox.SetTextColors(colors);

        // Find x and y without actually drawing the text box.
        // float[] xy = textBox.DrawOn(page, false);
        float[] xy = textBox.DrawOn(page);

        page.SetGraphicsState(new GraphicsState()); // Reset GS

        Box box = new Box();
        box.SetLocation(xy[0], xy[1]);
        box.SetSize(20f, 20f);
        box.DrawOn(page);

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_16();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_16 => " + (time1 - time0));
    }

}   // End of Example_16.cs
