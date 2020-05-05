using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_30.cs
 */
public class Example_30 {

    public Example_30() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_30.pdf", FileMode.Create)));

        Page page = new Page(pdf, Letter.PORTRAIT);
    
        Font font = new Font(pdf, CoreFont.HELVETICA);

        Image image = new Image(
                pdf,
                new BufferedStream(new FileStream(
                        "images/map407.png", FileMode.Open, FileAccess.Read)),
                ImageType.PNG);
        image.SetLocation(10f, 100f);

        TextLine textLine = new TextLine(font);
        textLine.SetText("© OpenStreetMap contributors");
        textLine.SetLocation(430f, 655f);
        textLine.DrawOn(page);

        textLine = new TextLine(font);
        textLine.SetText("http://www.openstreetmap.org/copyright");
        textLine.SetURIAction("http://www.openstreetmap.org/copyright");
        textLine.SetLocation(380f, 665f);
        textLine.DrawOn(page);

        OptionalContentGroup group = new OptionalContentGroup("Map");
        group.Add(image);
        group.SetVisible(true);
        // group.SetPrintable(true);
        group.DrawOn(page);

        TextBox tb = new TextBox(font);
        tb.SetText("Hello Text");
        tb.SetLocation(300f, 100f);

        tb = new TextBox(font);
        tb.SetText("Hello Blue Layer Text");
        tb.SetLocation(300f, 200f);

        Line line = new Line();
        line.SetPointA(300f, 250f);
        line.SetPointB(500f, 250f);
        line.SetWidth(2f);
        line.SetColor(Color.blue);

        group = new OptionalContentGroup("Blue");
        group.Add(tb);
        group.Add(line);
        // group.SetVisible(true);
        group.DrawOn(page);

        line = new Line();
        line.SetPointA(300f, 260f);
        line.SetPointB(500f, 260f);
        line.SetWidth(2f);
        line.SetColor(Color.red);

        image = new Image(
                pdf,
                new BufferedStream(new FileStream(
                        "images/BARCODE.PNG", FileMode.Open, FileAccess.Read)),
                ImageType.PNG);
        image.SetLocation(10f, 100f);

        group = new OptionalContentGroup("Barcode");
        group.Add(image);
        group.Add(line);
        group.SetVisible(true);
        group.SetPrintable(true);
        group.DrawOn(page);

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_30();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_30 => " + (time1 - time0));
    }

}   // End of Example_30.cs
