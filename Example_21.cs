using System;
using System.IO;
using System.Text;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_21.cs
 *
 */
public class Example_21 {

    public Example_21() {

        PDF pdf = new PDF(new FileStream("Example_21.pdf", FileMode.Create));

        Font f1 = new Font(pdf, CoreFont.HELVETICA);

        Page page = new Page(pdf, Letter.PORTRAIT);

        TextLine text = new TextLine(f1, "QR codes");
        text.SetLocation(100f, 30f);
        text.DrawOn(page);

        // Please note: The higher the error correction level - the shorter the string that you can encode.
        QRCode qr = new QRCode(
                "http://d-project.googlecode.com/svn/trunk/misc/qrcode/as3/src/sample",
                ErrorCorrectLevel.L);   // Low
        qr.SetModuleLength(3f);
        qr.SetLocation(100f, 100f);
        qr.SetLocation(0.0001f, 100f);
        qr.DrawOn(page);

        qr = new QRCode(
                "http://d-project.googlecode.com/svn/trunk/misc/qrcode",
                ErrorCorrectLevel.M);   // High
        qr.SetLocation(300f, 100f);
        qr.DrawOn(page);

        qr = new QRCode(
                "http://www.d-project.com/qrcode/index.html",
                ErrorCorrectLevel.Q);   // Medium
        qr.SetLocation(100f, 300f);
        qr.DrawOn(page);

        qr = new QRCode(
                "http://www.d-project.com",
                ErrorCorrectLevel.H);   // Very High
        qr.SetLocation(300f, 300f);
        float[] xy = qr.DrawOn(page);
/*
        Box box = new Box();
        box.SetLocation(xy[0], xy[1]);
        box.SetSize(20f, 20f);
        box.DrawOn(page);
*/
        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_21();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_21 => " + (time1 - time0));
    }

}   // End of Example_21.cs
