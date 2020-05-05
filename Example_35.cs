using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_35.cs
 *
 */
public class Example_35 {

    public Example_35() {
        StreamReader reader = new StreamReader(
                new FileStream(
                        "data/chinese-english.txt", FileMode.Open, FileAccess.Read));
        String text = reader.ReadLine();

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_35.pdf", FileMode.Create)));

        Page page = new Page(pdf, A4.PORTRAIT);

        Font mainFont = new Font(pdf, "AdobeMingStd", CodePage.UNICODE);
        Font fallbackFont = new Font(pdf,
                new FileStream("fonts/Roboto/Roboto-Regular.ttf",
                        FileMode.Open,
                        FileAccess.Read));

        TextLine textLine = new TextLine(mainFont);
        textLine.SetText(text);
        textLine.SetLocation(50f, 50f);
        textLine.DrawOn(page);

        textLine = new TextLine(mainFont);
        textLine.SetFallbackFont(fallbackFont);
        textLine.SetText(text);
        textLine.SetLocation(50f, 80f);
        textLine.DrawOn(page);

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_35();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_35 => " + (time1 - time0));
    }

}   // End of Example_35.cs
