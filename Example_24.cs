using System;
using System.IO;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_24.cs
 *
 */
public class Example_24 {

    public Example_24() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_24.pdf", FileMode.Create)));

        Font font = new Font(pdf, CoreFont.HELVETICA);

        Image image_00 = new Image(pdf, new FileStream(
                "images/gr-map.jpg", FileMode.Open, FileAccess.Read), ImageType.JPG);

        Image image_01 = new Image(pdf, new FileStream(
                "images/linux-logo.jet", FileMode.Open, FileAccess.Read), ImageType.JET);

        Image image_02 = new Image(pdf, new FileStream(
                "images/ee-map.png", FileMode.Open, FileAccess.Read), ImageType.PNG);

        Image image_03 = new Image(pdf, new FileStream(
                "images/rgb24pal.bmp", FileMode.Open, FileAccess.Read), ImageType.BMP);

        Page page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is JPEG image.")
                .SetTextDirection(0)
                .SetLocation(50f, 50f)
                .DrawOn(page);
        image_00.SetLocation(50f, 60f).ScaleBy(0.25f).DrawOn(page);

        page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is JET image.")
                .SetTextDirection(0)
                .SetLocation(50f, 50f)
                .DrawOn(page);
        image_01.SetLocation(50f, 60f).DrawOn(page);

        page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is PNG image.")
                .SetTextDirection(0)
                .SetLocation(50f, 50f)
                .DrawOn(page);
        image_02.SetLocation(50f, 60f).ScaleBy(0.75f).DrawOn(page);

        new TextLine(font,
                "This is BMP image.")
                .SetTextDirection(0)
                .SetLocation(50f, 620f)
                .DrawOn(page);
        image_03.SetLocation(50f, 630f).ScaleBy(0.75f).DrawOn(page);

        Image image1 = new Image(pdf,
                new FileStream("images/fruit.jpg", FileMode.Open, FileAccess.Read),
                ImageType.JPG);

        Image image2 = new Image(pdf, new FileStream(
                "images/linux-logo.jet", FileMode.Open, FileAccess.Read), ImageType.JET);

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_24();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_24 => " + (time1 - time0));
    }

}   // End of Example_24.cs
