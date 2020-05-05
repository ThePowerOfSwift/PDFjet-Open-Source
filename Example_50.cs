using System;
using System.IO;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_50.cs
 *
 */
public class Example_50 {

    public Example_50() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_50.pdf", FileMode.Create)));

        // Font f1 = new Font(pdf, CoreFont.HELVETICA);
        // f1.SetSize(10f);

        Font f1 = new Font(pdf, new FileStream(
                "fonts/Droid/DroidSerif-Regular.ttf.stream",
                FileMode.Open,
                FileAccess.Read), Font.STREAM);
        f1.SetSize(10f);
        
        Font f2 = new Font(pdf, new FileStream(
                "fonts/Droid/DroidSansFallback.ttf.stream",
                FileMode.Open,
                FileAccess.Read), Font.STREAM);
        f2.SetSize(10f);

        Page page = new Page(pdf, Letter.PORTRAIT);

        // Columns x coordinates
        float x1 = 75f;
        float x2 = 325f;

        float y1 = 75f;

        // Width of the second column:
        float w2 = 200f;

        Image image1 = new Image(
                pdf,
                new BufferedStream(new FileStream(
                        "images/fruit.jpg", FileMode.Open, FileAccess.Read)),
                ImageType.JPG);
        image1.SetLocation(x1, y1);
        image1.ScaleBy(0.75f);
        image1.DrawOn(page);


        TextBlock textBlock = new TextBlock(f1);
        textBlock.SetText("Donec a urna ac ipsum fringilla ultricies non vel diam. Morbi vitae lacus ac elit luctus dignissim. Quisque rutrum egestas facilisis. Curabitur tempus, tortor ac fringilla fringilla, libero elit gravida sem, vel aliquam leo nibh sed libero. Proin pretium, augue quis eleifend hendrerit, leo libero auctor magna,\n\nvitae porttitor lorem urna eget urna. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tincidunt venenatis odio in dignissim. Ut cursus egestas eros, ac blandit nisi ullamcorper a.");
        textBlock.SetLocation(x2, y1);
        textBlock.SetWidth(w2);
        // textBlock.SetTextAlignment(Align.LEFT);
        // textBlock.SetTextAlignment(Align.RIGHT);
        // textBlock.SetTextAlignment(Align.CENTER);

        // We can find out the height of the block before we draw it!
        float y2 = y1 + textBlock.GetHeight();

        // Diagnostics Code:
        // Line line = new Line(x2, y2, x2 + w2, y2);
        // line.SetWidth(0.2f);
        // line.DrawOn(page);

        y2 += 10f;   // Add a bit of space between the rows.

        textBlock.DrawOn(page);


        // Draw the second row image and text:
        Image image2 = new Image(
                pdf,
                new BufferedStream(new FileStream(
                        "images/ee-map.png", FileMode.Open, FileAccess.Read)),
                ImageType.PNG);
        image2.SetLocation(x1, y2);
        image2.ScaleBy(1f/3f);
        image2.DrawOn(page);

        textBlock = new TextBlock(f1);
        textBlock.SetText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla elementum interdum elit, quis vehicula urna interdum quis. Phasellus gravida ligula quam, nec blandit nulla. Sed posuere, lorem eget feugiat placerat, ipsum nulla euismod nisi, in semper mi nibh sed elit. Mauris libero est, sodales dignissim congue sed, pulvinar non ipsum. Sed risus nisi, ultrices nec eleifend at, viverra sed neque. Integer vehicula massa non arcu viverra ullamcorper. Ut id tellus id ante mattis commodo. Donec dignissim aliquam tortor, eu pharetra ipsum ullamcorper in. Vivamus ultrices imperdiet iaculis.\n\n");
        textBlock.SetWidth(w2);
        textBlock.SetLocation(x2, y2);
        textBlock.DrawOn(page);


        textBlock = new TextBlock(f1);
        textBlock.SetFallbackFont(f2);
        textBlock.SetText("保健所によると、女性は１３日に旅行先のタイから札幌に戻り、１６日午後５～８時ごろ同店を訪れ、帰宅後に発熱などの症状が出て、２３日に医療機関ではしかと診断された。はしかのウイルスは発症日の１日前から感染者の呼吸などから放出され、本人がいなくなっても、２時間程度空気中に漂い、空気感染する。保健所は１６日午後５～１１時に同店を訪れた人に、発熱などの異常が出た場合、早期にマスクをして医療機関を受診するよう呼びかけている。（本郷由美子）");
        textBlock.SetWidth(350f);
        textBlock.SetLocation(x1, 600f);
        textBlock.DrawOn(page);


        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_50();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_50 => " + (time1 - time0));
    }

}   // End of Example_50.cs
