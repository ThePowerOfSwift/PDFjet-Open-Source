import Foundation
import PDFjet


/**
 *  Example_30.swift
 *
 */
public class Example_30 {

    public init() throws {

        if let stream = OutputStream(toFileAtPath: "Example_30.pdf", append: false) {

            let pdf = PDF(stream)
            let page = Page(pdf, Letter.PORTRAIT)

            let font = Font(pdf, CoreFont.HELVETICA)

            let image1 = try Image(
                    pdf,
                    InputStream(fileAtPath: "images/map407.png")!,
                    ImageType.PNG)
            image1.setLocation(10.0, 100.0)

            var textLine = TextLine(font)
            textLine.setText("© OpenStreetMap contributors")
            textLine.setLocation(430.0, 655.0)
            textLine.drawOn(page)

            textLine = TextLine(font)
            textLine.setText("http://www.openstreetmap.org/copyright")
            textLine.setURIAction("http://www.openstreetmap.org/copyright")
            textLine.setLocation(380.0, 665.0)
            textLine.drawOn(page)

            var group = OptionalContentGroup("Map")
            group.add(image1)
            group.setVisible(true)
            // group.setPrintable(true)
            group.drawOn(page)

            var tb = TextBox(font)
            tb.setText("Hello Text")
            tb.setLocation(300.0, 100.0)

            tb = TextBox(font)
            tb.setText("Hello Blue Layer Text")
            tb.setLocation(300.0, 200.0)

            var line = Line()
            line.setPointA(300.0, 250.0)
            line.setPointB(500.0, 250.0)
            line.setWidth(2.0)
            line.setColor(Color.blue)

            group = OptionalContentGroup("Blue")
            group.add(tb)
            group.add(line)
            // group.setVisible(true)
            group.drawOn(page)

            line = Line()
            line.setPointA(300.0, 260.0)
            line.setPointB(500.0, 260.0)
            line.setWidth(2.0)
            line.setColor(Color.red)
            line.drawOn(page)

            let image2 = try Image(
                    pdf,
                    InputStream(fileAtPath: "images/BARCODE.PNG")!,
                    ImageType.PNG)
            image2.setLocation(10.0, 100.0)

            group = OptionalContentGroup("Barcode")
            group.add(image2)
            group.add(line)
            group.setVisible(true)
            group.setPrintable(true)
            group.drawOn(page)

            pdf.close()
        }
    }

}   // End of Example_30.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_30()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_30 => \(time1 - time0)")
