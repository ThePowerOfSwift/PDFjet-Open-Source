import Foundation
import PDFjet


/**
 *  Example_06.swift
 *
 */
public class Example_06 {

    public init() throws {

        let stream = OutputStream(toFileAtPath: "Example_06.pdf", append: false)
        let pdf = PDF(stream!)

        let f1 = try Font(
                pdf,
                InputStream(fileAtPath: "fonts/OpenSans/OpenSans-Regular.ttf.stream")!,
                Font.STREAM)

        let f2 = try Font(
                pdf,
                InputStream(fileAtPath: "fonts/Droid/DroidSansFallback.ttf.stream")!,
                Font.STREAM)
/*
        let f1 = try Font(
                pdf,
                InputStream(fileAtPath: "fonts/OpenSans/OpenSans-Regular.ttf")!)

        let f2 = try Font(
                pdf,
                InputStream(fileAtPath: "fonts/Droid/DroidSansFallback.ttf")!)
*/
        f1.setSize(12.0)
        f2.setSize(12.0)

        var page = Page(pdf, Letter.PORTRAIT)
        var paragraphs = [Paragraph]()

        var str = try String(contentsOfFile: "data/LCG.txt", encoding: .utf8)
        var lines = str.split(separator: "\n")
        for line in lines {
            let paragraph = Paragraph()
            paragraph.add(TextLine(f1, String(line)))
            paragraphs.append(paragraph)
        }

        Text(paragraphs)
                .setLocation(50.0, 50.0)
                .setWidth(500.0)
                .drawOn(page)

        page = Page(pdf, Letter.PORTRAIT)

        paragraphs = [Paragraph]()

        str = try String(contentsOfFile: "data/CJK.txt", encoding: .utf8)
        lines = str.split(separator: "\n")
        for line in lines {
            if line == "" {
                continue
            }
            let paragraph = Paragraph()
            let textLine = TextLine(f2, String(line))
            textLine.setFallbackFont(f1)
            paragraph.add(textLine)
            paragraphs.append(paragraph)
        }
        let text = Text(paragraphs)
        text.setLocation(50.0, 50.0)
        text.setWidth(500.0)
        text.drawOn(page)

        page = Page(pdf, Letter.PORTRAIT)

        paragraphs = [Paragraph]()
        let paragraph = Paragraph()

        var textLine = TextLine(f1, "Happy New Year!")
        textLine.setFallbackFont(f2)
        textLine.setLocation(70.0, 70.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "С Новым Годом!")
        textLine.setFallbackFont(f2)
        textLine.setLocation(70.0, 100.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "Ευτυχισμένο το Νέο Έτος!")
        textLine.setFallbackFont(f2)
        textLine.setLocation(70.0, 130.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "新年快樂！")
        textLine.setFallbackFont(f2)
        textLine.setLocation(300.0, 70.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "新年快乐！")
        textLine.setFallbackFont(f2)
        textLine.setLocation(300.0, 100.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "明けましておめでとうございます！")
        textLine.setFallbackFont(f2)
        textLine.setLocation(300.0, 130.0)
        textLine.drawOn(page)

        paragraph.add(textLine)

        textLine = TextLine(f1, "새해 복 많이 받으세요!")
        textLine.setFallbackFont(f2)
        textLine.setLocation(300.0, 160.0)
        textLine.drawOn(page)

        pdf.close()
    }

}   // End of Example_06.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_06()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_06 => \(time1 - time0)")
