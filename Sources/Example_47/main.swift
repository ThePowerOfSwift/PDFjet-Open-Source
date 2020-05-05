import Foundation
import PDFjet


///
/// Example_47.swift
///
public class Example_47 {

    public init() throws {

        let stream = OutputStream(toFileAtPath: "Example_47.pdf", append: false)
        let pdf = PDF(stream!)

        let f1 = try Font(
                pdf,
                InputStream(fileAtPath: "fonts/OpenSans/OpenSans-Regular.ttf.stream")!,
                Font.STREAM)

        let f2 = try Font(
                pdf,
                // InputStream(fileAtPath: "fonts/OpenSans/OpenSans-Regular.ttf.stream")!,
                InputStream(fileAtPath: "fonts/OpenSans/OpenSans-Italic.ttf.stream")!,
                Font.STREAM)

        f1.setSize(14.0)
        f2.setSize(14.0)
        // f2.setItalic(true)

        let page = Page(pdf, Letter.PORTRAIT)

        var paragraphs = [Paragraph]()

        let paragraph = Paragraph()
        paragraph.add(TextLine(f1,
"The centres also offer free one-on-one consultations with business advisors who can review your business plan and make recommendations to improve it. The small business centres offer practical resources, from step-by-step info on setting up your business to sample business plans to a range of business-related articles and books in our resource libraries."))
        paragraph.add(TextLine(f2,
"This text is blue color and is written using italic font.").setColor(Color.blue))

        paragraphs.append(paragraph)

        let height: Float = 82.0

        let line = Line(70.0, 150.0, 70.0, 150.0 + height)
        line.drawOn(page)

        var frame = TextFrame(paragraphs)
        frame.setLocation(70.0, 150.0)
        frame.setWidth(500.0)
        frame.setHeight(height)
        frame = frame.drawOn(page)

        if frame.getParagraphs() != nil {
            frame.setLocation(70.0, 450.0)
            frame.setWidth(500.0)
            frame.setHeight(90.0)
            frame = frame.drawOn(page)
        }

        pdf.close()
    }

}   // End of Example_47.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_47()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_47 => \(time1 - time0)")
