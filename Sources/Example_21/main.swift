import Foundation
import PDFjet


///
/// Example_21.swift
///
public class Example_21 {

    public init() {

        if let stream = OutputStream(toFileAtPath: "Example_21.pdf", append: false) {

            let pdf = PDF(stream)
            let font = Font(pdf, CoreFont.HELVETICA)

            let page = Page(pdf, Letter.PORTRAIT)

            TextLine(font, "QR codes")
                    .setLocation(100.0, 30.0)
                    .drawOn(page)

            // Please note:
            // The higher the error correction level - the shorter the string that you can encode.
            var qr = QRCode(
                    "https://kazuhikoarase.github.io/qrcode-generator/", ErrorCorrectLevel.L)   // Low
                    .setModuleLength(3.0)
                    .setLocation(100.0, 100.0)
            qr.drawOn(page)

            qr = QRCode(
                    "https://kazuhikoarase.github.io/qrcode-generator/", ErrorCorrectLevel.M)   // Medium
                    .setLocation(300.0, 100.0)
            qr.drawOn(page)

            qr = QRCode(
                    "https://kazuhikoarase.github.io", ErrorCorrectLevel.Q)                     // High
                    .setLocation(100.0, 300.0)
            qr.drawOn(page)
    
            qr = QRCode(
                    "https://github.com", ErrorCorrectLevel.H)                                  // Very High
                    .setLocation(300.0, 300.0)
            qr.drawOn(page)

/*
            let box = Box()
            box.setLocation(xy[0], xy[1])
            box.setSize(20.0, 20.0)
            box.drawOn(page)
*/
            pdf.close()
        }
    }

}   // End of Example_21.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = Example_21()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_21 => \(time1 - time0)")
