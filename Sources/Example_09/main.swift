import Foundation
import PDFjet


///
/// Example_09.swift
///
public class Example_09 {

    public init() throws {

        if let stream = OutputStream(toFileAtPath: "Example_09.pdf", append: false) {

            let pdf = PDF(stream)
            let page = Page(pdf, Letter.PORTRAIT)

            let f1 = Font(pdf, CoreFont.HELVETICA_BOLD)
            let f2 = Font(pdf, CoreFont.HELVETICA_BOLD)
            let f3 = Font(pdf, CoreFont.HELVETICA_BOLD)
            let f4 = Font(pdf, CoreFont.HELVETICA)

            f1.setItalic(true)
            f2.setItalic(true)
            f3.setItalic(true)
            f4.setItalic(true)

            f1.setSize(10.0)
            f2.setSize(8.0)
            f3.setSize(7.0)
            f4.setSize(7.0)

            let chart = Chart(f1, f2)
            chart.setLocation(70.0, 50.0)
            chart.setSize(500.0, 300.0)
            chart.setTitle("World View - Communications")
            chart.setXAxisTitle("Cell phones per capita")
            chart.setYAxisTitle("Internet users % of the population")
            chart.setData(try getData("data/world-communications.txt", "|"))
            addTrendLine(chart)
            chart.drawOn(page)

            try addTableToChart(page, chart, f3, f4)

            pdf.close()
        }

    }


    public func addTrendLine(_ chart: Chart) {
        let points = chart.getData()![0]

        let m = chart.slope(points)
        let b = chart.intercept(points, m)

        var trendline = [Point]()
        var x: Float = 0.0
        var y: Float = m * x + b
        let p1 = Point(x, y)
        p1.setStartOfPath()
        p1.setColor(Color.blue)
        p1.setShape(Point.INVISIBLE)

        x = 1.5
        y = m * x + b
        let p2 = Point(x, y)
        p2.setShape(Point.INVISIBLE)

        trendline.append(p1)
        trendline.append(p2)

        chart.chartData!.append(trendline)
    }


    public func addTableToChart(
            _ page: Page,
            _ chart: Chart,
            _ f3: Font,
            _ f4: Font) throws {
        let table = Table()
        var tableData = [[Cell]]()
        let points = chart.getData()![0]
        for point in points {
            if point.getShape() != Point.CIRCLE {
                var tableRow = [Cell]()

                point.setRadius(2.0)
                point.setFillShape(true)
                point.setAlignment(Align.LEFT)

                var cell = Cell(f4)
                cell.setPoint(point)
                cell.setText("")

                tableRow.append(cell)

                cell = Cell(f4)
                cell.setText(point.getText())
                tableRow.append(cell)

                cell = Cell(f4)
                cell.setText(point.getURIAction())
                tableRow.append(cell)

                tableData.append(tableRow)
            }
        }
        table.setData(tableData)
        table.autoAdjustColumnWidths()
        table.setCellBordersWidth(0.2)
        table.setLocation(70.0, 360.0)
        table.setColumnWidth(0, 9.0)
        table.drawOn(page)
    }


    public func getData(
            _ fileName: String,
            _ delimiter: String) throws -> [[Point]] {

        var chartData = [[Point]]()
        var points = [Point]()

        let text = (try String(contentsOfFile:
                fileName, encoding: .utf8)).trimmingCharacters(in: .newlines)
        let lines = text.components(separatedBy: "\n")
        for line1 in lines {
            let line = line1.trimmingCharacters(in: .whitespacesAndNewlines)
            var cols: [String]?
            if delimiter == "|" {
                cols = line.components(separatedBy: "|")
            }
            else if delimiter == "\t" {
                cols = line.components(separatedBy: "\t")
            }
            else {
                // TODO:
                // print("Only pipes and tabs can be used as delimiters")
            }

            var country_name = cols![0].trimmingCharacters(in: .whitespacesAndNewlines)
            let population = Float(cols![1].filter({ $0 != "," }))
            let x = Float(cols![5].filter({ $0 != "," }))
            let y = Float(cols![7].filter({ $0 != "," }).trimmingCharacters(in: .whitespacesAndNewlines))

            if population != nil && x != nil && y != nil {
/*
print(country_name)
print(population!)
print(x!)
print(y!)
print()
*/
                let point = Point()
                point.setRadius(2.0)
                point.setText(country_name)
                point.setX(x! / population!)
                point.setY((y! / population!) * Float(100.0))

                country_name = country_name.replacingOccurrences(of: " ", with: "_")
                country_name = country_name.replacingOccurrences(of: "'", with: "_")
                country_name = country_name.replacingOccurrences(of: ",", with: "_")
                country_name = country_name.replacingOccurrences(of: "(", with: "_")
                country_name = country_name.replacingOccurrences(of: ")", with: "_")
                point.setURIAction("http://pdfjet.com/country/\(country_name).txt")

                if point.getX() > 1.25 {
                    point.setShape(Point.RIGHT_ARROW)
                    point.setColor(Color.black)
                }
                if point.getY() > 80.0 {
                    point.setShape(Point.UP_ARROW)
                    point.setColor(Color.blue)
                }
                if point.getText() == "France" {
                    point.setShape(Point.MULTIPLY)
                    point.setColor(Color.black)
                }
                if point.getText() == "Canada" {
                    point.setShape(Point.BOX)
                    point.setColor(Color.darkolivegreen)
                }
                if point.getText() == "United States" {
                    point.setShape(Point.STAR)
                    point.setColor(Color.red)
                }
                points.append(point)
            }
        }
        chartData.append(points)

        return chartData
    }

}   // End of Example_09.swift

let time0 = Int64(Date().timeIntervalSince1970 * 1000)
_ = try Example_09()
let time1 = Int64(Date().timeIntervalSince1970 * 1000)
print("Example_09 => \(time1 - time0)")
