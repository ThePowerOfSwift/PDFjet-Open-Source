import java.io.*;

import com.pdfjet.*;


/**
 *  Example_24.java
 *
 */
public class Example_24 {

    public Example_24() throws Exception {

        PDF pdf = new PDF(
                new BufferedOutputStream(
                        new FileOutputStream("Example_24.pdf")));

        Font font = new Font(pdf, CoreFont.HELVETICA);

        Image image_00 = new Image(
                pdf,
                new BufferedInputStream(new FileInputStream("images/gr-map.jpg")),
                ImageType.JPG);

        Image image_01 = new Image(
                pdf,
                new BufferedInputStream(new FileInputStream("images/linux-logo.jet")),
                ImageType.JET);

        Image image_02 = new Image(
                pdf,
                new BufferedInputStream(new FileInputStream("images/ee-map.png")),
                ImageType.PNG);

        Image image_03 = new Image(
                pdf,
                new BufferedInputStream(new FileInputStream("images/rgb24pal.bmp")),
                ImageType.BMP);

        Page page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is JPEG image.")
                .setTextDirection(0)
                .setLocation(50f, 50f)
                .drawOn(page);
        image_00.setLocation(50f, 60f).scaleBy(0.25f).drawOn(page);

        page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is JET image.")
                .setTextDirection(0)
                .setLocation(50f, 50f)
                .drawOn(page);
        image_01.setLocation(50f, 60f).drawOn(page);

        page = new Page(pdf, Letter.PORTRAIT);
        new TextLine(font,
                "This is PNG image.")
                .setTextDirection(0)
                .setLocation(50f, 50f)
                .drawOn(page);
        image_02.setLocation(50f, 60f).scaleBy(0.75f).drawOn(page);

        new TextLine(font,
                "This is BMP image.")
                .setTextDirection(0)
                .setLocation(50f, 620f)
                .drawOn(page);
        image_03.setLocation(50f, 630f).scaleBy(0.75f).drawOn(page);

        pdf.close();
    }


    public static void main(String[] args) throws Exception {
        long t0 = System.currentTimeMillis();
        new Example_24();
        long t1 = System.currentTimeMillis();
        System.out.println("Example_24 => " + (t1 - t0));
    }

}   // End of Example_24.java
