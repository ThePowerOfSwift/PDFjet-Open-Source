import Foundation
import PDFjet


/**
 *  Example_15.swift
 *
 */
public class Example_15 {

    public init() {

        if let stream = OutputStream(toFileAtPath: "Example_15.pdf", append: false) {

            let pdf = PDF(stream)

            var page = Page(pdf, Letter.PORTRAIT)

            let f1 = Font(pdf, CoreFont.HELVETICA_BOLD)
            let f2 = Font(pdf, CoreFont.HELVETICA)
            let f3 = Font(pdf, CoreFont.HELVETICA)
            let f4 = Font(pdf, CoreFont.HELVETICA_BOLD)
            let f5 = Font(pdf, CoreFont.HELVETICA)

            var tableData = [[Cell]]()
            var row = [Cell]()
            var cell = Cell(f1)
            for i in 0..<60 {
                row = [Cell]()
                for j in 0..<5 {
                    if i == 0 {
                        cell = Cell(f1)
                    }
                    else {
                        cell = Cell(f2)
                    }
                    // cell.setNoBorders()

                    cell.setTopPadding(10.0)
                    cell.setBottomPadding(10.0)
                    cell.setLeftPadding(10.0)
                    cell.setRightPadding(10.0)

                    cell.setText("Hello \(i) \(j)")

                    let composite = CompositeTextLine(0.0, 0.0)
                    composite.setFontSize(12.0)
                    let line1 = TextLine(f3, "H")
                    let line2 = TextLine(f4, "2")
                    let line3 = TextLine(f5, "O")
                    line2.setTextEffect(Effect.SUBSCRIPT)
                    composite.addComponent(line1)
                    composite.addComponent(line2)
                    composite.addComponent(line3)

                    if i == 0 || j == 0 {
                        cell.setCompositeTextLine(composite)
                        cell.setBgColor(Color.deepskyblue)
                    }
                    else {
                        cell.setBgColor(Color.dodgerblue)
                    }
                    cell.setPenColor(Color.lightgray)
                    cell.setBrushColor(Color.black)
                    row.append(cell)
                }
                tableData.append(row)
            }

            let table = Table()
            table.setData(tableData, Table.DATA_HAS_2_HEADER_ROWS)
            table.setCellBordersWidth(0.2)
            table.setLocation(70.0, 30.0)
            table.autoAdjustColumnWidths()

            while true {
                let point = table.drawOn(page)
                let text = TextLine(f1, "Hello, World.")
                text.setLocation(point.getX() + table.getWidth(), point.getY())
                text.drawOn(page)

                if !table.hasMoreData() {
                    break
                }
                page = Page(pdf, A4.PORTRAIT)
            }

            pdf.close()
        }
    }

}   // End of Example_15.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = Example_15()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_15 => \(time1 - time0)")
