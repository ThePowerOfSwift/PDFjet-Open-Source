using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_47.cs
 *
 */
public class Example_47 {

    public Example_47() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_47.pdf", FileMode.Create)),
                Compliance.PDF_UA);

        Font f1 = new Font(pdf, new FileStream(
               "fonts/OpenSans/OpenSans-Regular.ttf.stream",
                FileMode.Open,
                FileAccess.Read), Font.STREAM);

        Font f2 = new Font(pdf, new FileStream(
                // "fonts/OpenSans/OpenSans-Regular.ttf.stream",
                "fonts/OpenSans/OpenSans-Italic.ttf.stream",
                FileMode.Open,
                FileAccess.Read), Font.STREAM);

        f1.SetSize(14f);
        f2.SetSize(14f);
        // f2.SetItalic(true);

        Page page = new Page(pdf, Letter.PORTRAIT);

        List<Paragraph> paragraphs = new List<Paragraph>();

        Paragraph paragraph = new Paragraph()
                .Add(new TextLine(f1,
"The centres also offer free one-on-one consultations with business advisors who can review your business plan and make recommendations to improve it. The small business centres offer practical resources, from step-by-step info on setting up your business to sample business plans to a range of business-related articles and books in our resource libraries."))
                .Add(new TextLine(f2,
"This text is blue color and is written using italic font.").SetColor(Color.blue));

        paragraphs.Add(paragraph);

        float height = 82f;

        Line line = new Line(70f, 150f, 70f, 150f + height);
        line.DrawOn(page);

        TextFrame frame = new TextFrame(paragraphs);
        frame.SetLocation(70f, 150f);
        frame.SetWidth(500f);
        frame.SetHeight(height);
        frame = frame.DrawOn(page);

        if (frame.GetParagraphs() != null) {
            frame.SetLocation(70f, 450f);
            frame.SetWidth(500f);
            frame.SetHeight(90f);
            frame = frame.DrawOn(page);
        }

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_47();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_47 => " + (time1 - time0));
    }

}   // End of Example_47.cs
