using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_06.cs
 *
 */
class Example_06 {

    public Example_06() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_06.pdf", FileMode.Create)));

        // Use .ttf.stream fonts
        Font f1 = new Font(pdf, new FileStream(
                "fonts/OpenSans/OpenSans-Regular.ttf.stream",
                FileMode.Open,
                FileAccess.Read),
                Font.STREAM);
        f1.SetSize(12f);

        Font f2 = new Font(pdf, new FileStream(
                "fonts/Droid/DroidSansFallback.ttf.stream",
                FileMode.Open,
                FileAccess.Read),
                Font.STREAM);
        f2.SetSize(12f);

        Page page = new Page(pdf, Letter.PORTRAIT);

        List<Paragraph> paragraphs = new List<Paragraph>();
        Paragraph paragraph = null;

        StreamReader reader = new StreamReader(
                new FileStream("data/LCG.txt", FileMode.Open));
        String line = null;
        while ((line = reader.ReadLine()) != null) {
            if (line.Equals("")) {
                continue;
            }
            paragraph = new Paragraph();
            TextLine textLine = new TextLine(f1, line);
            textLine.SetFallbackFont(f2);
            paragraph.Add(textLine);
            paragraphs.Add(paragraph);
        }
        Text text = new Text(paragraphs);
        text.SetLocation(50f, 50f);
        text.SetWidth(500f);
        text.DrawOn(page);


        page = new Page(pdf, Letter.PORTRAIT);

        paragraphs = new List<Paragraph>();

        reader = new StreamReader(
                new FileStream("data/CJK.txt", FileMode.Open));

        while ((line = reader.ReadLine()) != null) {
            if (line.Equals("")) {
                continue;
            }
            paragraph = new Paragraph();
            TextLine textLine = new TextLine(f2, line);
            textLine.SetFallbackFont(f1);
            paragraph.Add(textLine);
            paragraphs.Add(paragraph);
        }
        text = new Text(paragraphs);
        text.SetLocation(50f, 50f);
        text.SetWidth(500f);
        text.DrawOn(page);

/*
        Page page = new Page(pdf, Letter.PORTRAIT);

        List<Paragraph> paragraphs = new List<Paragraph>();
        Paragraph paragraph = new Paragraph();

        TextLine textLine = new TextLine(f1, "Happy New Year!");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(70f, 70f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "С Новым Годом!");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(70f, 100f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "Ευτυχισμένο το Νέο Έτος!");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(70f, 130f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "新年快樂！");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(300f, 70f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "新年快乐！");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(300f, 100f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "明けましておめでとうございます！");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(300f, 130f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        textLine = new TextLine(f1, "새해 복 많이 받으세요!");
        textLine.SetFallbackFont(f2);
        textLine.SetLocation(300f, 160f);
        textLine.DrawOn(page);

        paragraph.Add(textLine);

        paragraphs.Add(paragraph);

        Text text = new Text(paragraphs);
        text.SetLocation(70f, 200f);
        text.SetWidth(500f);
        text.DrawOn(page);
*/

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_06();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_06 => " + (time1 - time0));
    }

}   // End of Example_06.cs
