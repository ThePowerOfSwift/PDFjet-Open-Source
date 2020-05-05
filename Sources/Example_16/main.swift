import Foundation
import PDFjet


/**
 *  Example_16.java
 *
 */
public class Example_16 {

    public init() throws {

        let stream = OutputStream(toFileAtPath: "Example_16.pdf", append: false)
        let pdf = PDF(stream!)

        let f1 = Font(pdf, CoreFont.HELVETICA)
        f1.setSize(14.0)

        let page = Page(pdf, Letter.PORTRAIT)

        let bg_flag = Box()
                .setLocation(50.0, 50.0)
                .setSize(200.0, 120.0)
                .setColor(Color.black)
                .setLineWidth(1.5)
        bg_flag.drawOn(page)

        let stripe_width = Float(120.0/3.0)

        let white_stripe = Line(0.0, 0.0, 200.0, 0.0)
        white_stripe.setWidth(stripe_width)
        white_stripe.setColor(Color.white)
        white_stripe.placeIn(bg_flag, 0.0, stripe_width / 2.0)
        white_stripe.drawOn(page)

        let green_stripe = Line(0.0, 0.0, 200.0, 0.0)
        green_stripe.setWidth(stripe_width)
        green_stripe.setColor(0x00966e)
        green_stripe.placeIn(bg_flag, 0.0, (3 * stripe_width) / 2.0)
        green_stripe.drawOn(page)

        let red_stripe = Line(0.0, 0.0, 200.0, 0.0)
        red_stripe.setWidth(stripe_width)
        red_stripe.setColor(0xd62512)
        red_stripe.placeIn(bg_flag, 0.0, (5 * stripe_width) / 2.0)
        red_stripe.drawOn(page)

        var colors = [String : UInt32]()
        colors["Lorem"] = Color.blue
        colors["ipsum"] = Color.red
        colors["dolor"] = Color.green
        colors["ullamcorper"] = Color.gray

        f1.setSize(72.0)

        let gs = GraphicsState()
        gs.set_CA(0.5)                              // Stroking alpha
        gs.set_ca(0.5)                              // Nonstroking alpha
        page.setGraphicsState(gs)

        let text = TextLine(f1, "Hello, World")
        text.setLocation(50.0, 300.0)
        text.drawOn(page)

        f1.setSize(14.0)

        var buf = String()
        buf.append("    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla elementum interdum elit, quis vehicula urna interdum quis. Phasellus gravida ligula quam, nec blandit nulla. Sed posuere, lorem eget feugiat placerat, ipsum nulla euismod nisi, in semper mi nibh sed elit. Mauris libero est, sodales dignissim congue sed, pulvinar non ipsum. Sed risus nisi, ultrices nec eleifend at, viverra sed neque. Integer vehicula massa non arcu viverra ullamcorper. Ut id tellus id ante mattis commodo. Donec dignissim aliquam tortor, eu pharetra ipsum ullamcorper in. Vivamus ultrices imperdiet iaculis.\n\n")

        buf.append("    Donec a urna ac ipsum fringilla ultricies non vel diam. Morbi vitae lacus ac elit luctus dignissim. Quisque rutrum egestas facilisis. Curabitur tempus, tortor ac fringilla fringilla, libero elit gravida sem, vel aliquam leo nibh sed libero. Proin pretium, augue quis eleifend hendrerit, leo libero auctor magna, vitae porttitor lorem urna eget urna. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tincidunt venenatis odio in dignissim. Ut cursus egestas eros, ac blandit nisi ullamcorper a.")

        let textBox = TextBox(f1, buf)
        textBox.setLocation(50.0, 200.0)
        textBox.setWidth(400.0)
        // If no height is specified the height will be calculated based on the text.
        // textBox.setHeight(400.0)

        // textBox.setVerticalAlignment(Align.TOP)
        // textBox.setVerticalAlignment(Align.BOTTOM)
        // textBox.setVerticalAlignment(Align.CENTER)

        textBox.setTextColors(colors)

        // Find x and y without actually drawing the text box.
        // var xy = textBox.drawOn(page, false)
        var xy = textBox.drawOn(page)

        page.setGraphicsState(GraphicsState())      // Reset GS

        let box = Box()
        box.setLocation(xy[0], xy[1])
        box.setSize(20.0, 20.0)
        box.drawOn(page)

        pdf.close()
    }

}   // End of Example_16.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_16()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_16 => \(time1 - time0)")
