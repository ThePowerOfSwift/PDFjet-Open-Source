import Foundation
import PDFjet


/**
 *  Example_08.swift
 *
 */
public class Example_08 {

    public init() throws {

        let stream = OutputStream(toFileAtPath: "Example_08.pdf", append: false)
        let pdf = PDF(stream!)

        var page = Page(pdf, Letter.PORTRAIT)

        let f1 = Font(pdf, CoreFont.HELVETICA_BOLD)
        f1.setSize(7.0)

        let f2 = Font(pdf, CoreFont.HELVETICA)
        f2.setSize(7.0)

        let f3 = Font(pdf, CoreFont.HELVETICA_BOLD_OBLIQUE)
        f3.setSize(7.0)

        let table = Table();
        let tableData = try getData(
        		"data/world-communications.txt", "|", Table.DATA_HAS_2_HEADER_ROWS, f1, f2);

        let stream2 = InputStream(fileAtPath: "images/fruit.jpg")
        let image1 = try Image(pdf, stream2!, ImageType.JPG)
        image1.scaleBy(0.25)
        tableData[2][3].setImage(image1)
        tableData[2][3].setURIAction("http://pdfjet.com")
        tableData[2][3].setVerTextAlignment(Align.CENTER)

        table.setData(tableData, Table.DATA_HAS_2_HEADER_ROWS)
        // table.setCellBordersWidth(1.2)
        table.setCellBordersWidth(0.2)
        table.setLocation(70.0, 30.0)
        table.setTextColorInRow(6, Color.blue)
        table.setTextColorInRow(39, Color.red)
        table.setFontInRow(26, f3)
        table.removeLineBetweenRows(0, 1)
        table.autoAdjustColumnWidths()
        table.setColumnWidth(0, 120.0)
        table.rightAlignNumbers()
        table.wrapAroundCellText()
        table.mergeOverlaidBorders()

        // let numOfPages = try table.getNumberOfPages(page)
        while true {
            table.drawOn(page)
            // TO DO: Draw "Page 1 of N" here
            if !table.hasMoreData() {
                // Allow the table to be drawn again later:
                table.resetRenderedPagesCount()
                break
            }
            page = Page(pdf, Letter.PORTRAIT)
            table.setLocation(70.0, 30.0)
        }

        pdf.close()
    }

    public func getData(
            _ fileName: String,
            _ delimiter: String,
            _ numOfHeaderRows: Int,
            _ f1: Font,
            _ f2: Font) throws -> [[Cell]] {

        var tableData = [[Cell]]()

        let lines = (try String(contentsOfFile:
                fileName, encoding: .utf8)).components(separatedBy: "\n")
        var currentRow = 0
        for line1 in lines {
            let line = line1.trimmingCharacters(in: .newlines)
            var row = [Cell]()
            var cols: [String]?
            if delimiter == "|" {
                cols = line.components(separatedBy: "|")
            }
            else if delimiter == "\t" {
                cols = line.components(separatedBy: "\t")
            }
            else {
                print("Only pipes and tabs can be used as delimiters.")
            }
            for i in 0..<cols!.count {
                let text = cols![i].trimmingCharacters(in: .whitespaces)
                var cell: Cell?
                if currentRow < numOfHeaderRows {
                    cell = Cell(f1, text)
                }
                else {
                    cell = Cell(f2, text)
                }
                cell!.setTopPadding(2.0)
                cell!.setBottomPadding(2.0)
                cell!.setLeftPadding(2.0)
                cell!.setRightPadding(2.0)
                row.append(cell!)
            }
            if row.count > 1 {
                tableData.append(row)
            }
            currentRow += 1
        }
        // This line is mandatory!
        appendMissingCells(&tableData, f2)

        return tableData
    }

    private func appendMissingCells(_ tableData: inout [[Cell]], _ f2: Font) {
        let numOfColumns = tableData[0].count
        var i = 0
        while i < tableData.count {
            let numOfCells = tableData[i].count
            if numOfCells < numOfColumns {
                for _ in 0..<(numOfColumns - numOfCells) {
                    tableData[i].append(Cell(f2))
                }
                tableData[i][numOfCells - 1].setColSpan(
                        UInt32(numOfColumns - numOfCells) + UInt32(1))
            }
            i += 1
        }
    }

}   // End of Example_08.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_08()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_08 => \(time1 - time0)")
