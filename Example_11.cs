using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_11.cs
 *
 */
public class Example_11 {

    public Example_11() {

        PDF pdf = new PDF( new BufferedStream(
                new FileStream("Example_11.pdf", FileMode.Create)));

        // Font f1 = new Font(pdf, CoreFont.HELVETICA);
        Font f1 = new Font(pdf,
                new FileStream(
                        "fonts/Droid/DroidSans.ttf",
                        FileMode.Open,
                        FileAccess.Read));

        Page page = new Page(pdf, Letter.PORTRAIT);

        BarCode code = new BarCode(BarCode.CODE128, "Hello, World!");
        code.SetLocation(170f, 70f);
        code.SetModuleLength(0.75f);
        code.SetFont(f1);
        float[] xy = code.DrawOn(page);
/*
        Box box = new Box();
        box.SetLocation(xy[0], xy[1]);
        box.SetSize(20f, 20f);
        box.DrawOn(page);
*/
        code = new BarCode(BarCode.CODE128, "G86513JVW0C");
        code.SetLocation(170f, 170f);
        code.SetModuleLength(0.75f);
        code.SetDirection(BarCode.TOP_TO_BOTTOM);
        code.SetFont(f1);
        xy = code.DrawOn(page);

        code = new BarCode(BarCode.CODE39, "WIKIPEDIA");
        code.SetLocation(270f, 370f);
        code.SetModuleLength(0.75f);
        code.SetFont(f1);
        xy = code.DrawOn(page);

        code = new BarCode(BarCode.CODE39, "CODE39");
        code.SetLocation(400f, 70f);
        code.SetModuleLength(0.75f);
        code.SetDirection(BarCode.TOP_TO_BOTTOM);
        code.SetFont(f1);
        xy = code.DrawOn(page);

        code = new BarCode(BarCode.CODE39, "CODE39");
        code.SetLocation(450f, 70f);
        code.SetModuleLength(0.75f);
        code.SetDirection(BarCode.BOTTOM_TO_TOP);
        code.SetFont(f1);
        xy = code.DrawOn(page);

        code = new BarCode(BarCode.UPC, "712345678904");
        code.SetLocation(450f, 270f);
        code.SetModuleLength(0.75f);
        code.SetDirection(BarCode.BOTTOM_TO_TOP);
        code.SetFont(f1);
        xy = code.DrawOn(page);

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_11();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_11 => " + (time1 - time0));
    }

}   // End of Example_11.cs
