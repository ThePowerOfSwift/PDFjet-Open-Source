import Foundation
import PDFjet


/**
 *  Example_03.swift
 *
 */
public class Example_03 {

    public init() throws {

        let stream = OutputStream(toFileAtPath: "Example_03.pdf", append: false)

        let pdf = PDF(stream!)

        let page = Page(pdf, A4.PORTRAIT)

        let f1 = Font(pdf, CoreFont.HELVETICA)

        let image1 = try Image(
                pdf,
                InputStream(fileAtPath: "images/ee-map.png")!,
                ImageType.PNG)

        let image2 = try Image(
                pdf,
                InputStream(fileAtPath: "images/fruit.jpg")!,
                ImageType.JPG)

        let image3 = try Image(
                pdf,
                InputStream(fileAtPath: "images/mt-map.bmp")!,
                ImageType.BMP)

        TextLine(f1,
                "The map below is an embedded PNG image")
                .setLocation(90.0, 30.0)
                .drawOn(page)

        image1.setLocation(90.0, 40.0)
                .scaleBy(2.0/3.0)
                .drawOn(page)

        TextLine(f1,
                "JPG image file embedded once and drawn 3 times")
                .setLocation(90.0, 550.0)
                .drawOn(page)

        image2.setLocation(90.0, 560.0)
                .scaleBy(0.5)
                .drawOn(page)

        image2.setLocation(260.0, 560.0)
                .scaleBy(0.5)
                .setRotate(ClockWise._90_degrees)
                // .setRotate(ClockWise._180_degrees)
                // .setRotate(ClockWise._270_degrees)
                .drawOn(page)

        image2.setLocation(350.0, 560.0)
                .setRotate(ClockWise._0_degrees)
                .scaleBy(0.5)
                .drawOn(page)

        TextLine(f1,
                "The map on the right is an embedded BMP image")
                .setUnderline(true)
                .setVerticalOffset(3.0)
                .setStrikeout(true)
                .setTextDirection(15)
                .setLocation(90.0, 800.0)
                .drawOn(page)

        image3.setLocation(390.0, 630.0)
                .scaleBy(0.5)
                .drawOn(page)

        let page2 = Page(pdf, A4.PORTRAIT)
        let xy = image1.drawOn(page2)

        Box()
                .setLocation(xy[0], xy[1])
                .setSize(20.0, 20.0)
                .drawOn(page2)

        pdf.close()
    }

}   // End of Example_03.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_03()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_03 => \(time1 - time0)")
