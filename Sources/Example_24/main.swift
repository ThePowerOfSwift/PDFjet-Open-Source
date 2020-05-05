import Foundation
import PDFjet


/**
 *  Example_24.swift
 *
 */
public class Example_24 {

    public init() throws {
        let stream = OutputStream(toFileAtPath: "Example_24.pdf", append: false)
        let pdf = PDF(stream!)
        let font = Font(pdf, CoreFont.HELVETICA)

        let image_00 = try Image(
                pdf,
                InputStream(fileAtPath: "images/gr-map.jpg")!,
                ImageType.JPG)

        let image_01 = try Image(
                pdf,
                InputStream(fileAtPath: "images/linux-logo.jet")!,
                ImageType.JET)

        let image_02 = try Image(
                pdf,
                InputStream(fileAtPath: "images/ee-map.png")!,
                ImageType.PNG)

        let image_03 = try Image(
                pdf,
                InputStream(fileAtPath: "images/rgb24pal.bmp")!,
                ImageType.BMP)

        var page = Page(pdf, Letter.PORTRAIT)
        TextLine(font,
                "This is JPEG image.")
                .setTextDirection(0)
                .setLocation(50.0, 50.0)
                .drawOn(page)
        image_00.setLocation(50.0, 60.0).scaleBy(0.25).drawOn(page)

        page = Page(pdf, Letter.PORTRAIT)
        TextLine(font,
                "This is JET image.")
                .setTextDirection(0)
                .setLocation(50.0, 50.0)
                .drawOn(page)
        image_01.setLocation(50.0, 60.0).drawOn(page)

        page = Page(pdf, Letter.PORTRAIT)
        TextLine(font,
                "This is PNG image.")
                .setTextDirection(0)
                .setLocation(50.0, 50.0)
                .drawOn(page)
        image_02.setLocation(50.0, 60.0).scaleBy(0.75).drawOn(page)

        TextLine(font,
                "This is BMP image.")
                .setTextDirection(0)
                .setLocation(50.0, 620.0)
                .drawOn(page)
        image_03.setLocation(50.0, 630.0).scaleBy(0.75).drawOn(page)

        pdf.close()
    }

}   // End of Example_24.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_24()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_24 => \(time1 - time0)")
