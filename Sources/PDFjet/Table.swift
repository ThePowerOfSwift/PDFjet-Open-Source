/**
 *  Table.swift
 *
Copyright (c) 2018, Innovatics Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and / or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation


///
/// Used to create table objects and draw them on a page.
///
/// Please see Example_08.
///
public class Table {

    public static let DATA_HAS_0_HEADER_ROWS = 0
    public static let DATA_HAS_1_HEADER_ROWS = 1
    public static let DATA_HAS_2_HEADER_ROWS = 2
    public static let DATA_HAS_3_HEADER_ROWS = 3
    public static let DATA_HAS_4_HEADER_ROWS = 4
    public static let DATA_HAS_5_HEADER_ROWS = 5
    public static let DATA_HAS_6_HEADER_ROWS = 6
    public static let DATA_HAS_7_HEADER_ROWS = 7
    public static let DATA_HAS_8_HEADER_ROWS = 8
    public static let DATA_HAS_9_HEADER_ROWS = 9

    private var rendered = 0
    private var numOfPages = 0
    private var tableData: [[Cell]]
    private var numOfHeaderRows = 0

    private var x1: Float?
    private var y1: Float?

    private var bottom_margin: Float = 30.0


    ///
    /// Create a table object.
    ///
    public init() {
        tableData = [[Cell]]()
    }


    ///
    /// Sets the location (x, y) of the top left corner of this table on the page.
    ///
    /// @param x the x coordinate of the top left point of the table.
    /// @param y the y coordinate of the top left point of the table.
    ///
    public func setLocation(_ x: Float, _ y: Float) {
        self.x1 = x
        self.y1 = y
    }


    ///
    /// Sets the bottom margin for this table.
    ///
    /// @param bottom_margin the margin.
    ///
    public func setBottomMargin(_ bottom_margin: Float) {
        self.bottom_margin = bottom_margin
    }


    ///
    /// Sets the table data.
    ///
    /// The table data is a perfect grid of cells.
    /// All cell should be an unique object and you can not reuse blank cell objects.
    /// Even if one or more cells have colspan bigger than zero the number of cells in the row will not change.
    ///
    /// @param tableData the table data.
    ///
    public func setData(
            _ tableData: [[Cell]]) {
        self.tableData = tableData
        self.numOfHeaderRows = 0
        self.rendered = self.numOfHeaderRows
    }


    ///
    /// Sets the table data and specifies the number of header rows in this data.
    ///
    /// @param tableData the table data.
    /// @param numOfHeaderRows the number of header rows in this data.
    ///
    public func setData(
            _ tableData: [[Cell]],
            _ numOfHeaderRows: Int) {
        self.tableData = tableData
        self.numOfHeaderRows = numOfHeaderRows
        self.rendered = numOfHeaderRows
    }


    ///
    /// Auto adjusts the widths of all columns so that they are just wide enough to hold the text without truncation.
    ///
    public func autoAdjustColumnWidths() {
        // Find the maximum text width for each column
        var max_col_widths = [Float](repeating: 0, count: (tableData[0].count))
        for row in tableData {
            for j in 0..<row.count {
                let cell = row[j]
                if cell.getColSpan() == 1 {
                    var cellWidth: Float = 0.0
                    if cell.getImage() != nil {
                        cellWidth = cell.getImage()!.getWidth()!
                    }
                    if cell.text != nil {
                        if cell.font!.stringWidth(cell.fallbackFont, cell.text) > cellWidth {
                            cellWidth = cell.font!.stringWidth(cell.fallbackFont, cell.text)
                        }
                    }
                    cell.setWidth(cellWidth + cell.left_padding + cell.right_padding)
                    if max_col_widths[j] == 0.0 ||
                            cell.getWidth() > max_col_widths[j] {
                        max_col_widths[j] = cell.getWidth()
                    }
                }
            }
        }

        for row in tableData {
            for i in 0..<row.count {
                let cell = row[i]
                cell.setWidth(max_col_widths[i])
            }
        }
    }


    ///
    /// Sets the alignment of the numbers to the right.
    ///
    public func rightAlignNumbers() {
        let digitsPlus = [UnicodeScalar]("0123456789()-.,'".unicodeScalars)
        var i = numOfHeaderRows
        while i < tableData.count {
            let row = tableData[i]
            for cell in row {
                if cell.text != nil {
                    let scalars = [UnicodeScalar](cell.text!.unicodeScalars)
                    var isNumber = true
                    for scalar in scalars {
                        if digitsPlus.index(of: scalar) == nil {
                            isNumber = false
                            break
                        }
                    }
                    if isNumber {
                        cell.setTextAlignment(Align.RIGHT)
                    }
                }
            }
            i += 1
        }
    }


    ///
    /// Removes the horizontal lines between the rows from index1 to index2.
    ///
    public func removeLineBetweenRows(
            _ index1: Int,
            _ index2: Int) {
        var j = index1
        while j < index2 {
            var row = tableData[j]
            for cell in row {
                cell.setBorder(Border.BOTTOM, false)
            }
            row = tableData[j + 1]
            for cell in row {
                cell.setBorder(Border.TOP, false)
            }
            j += 1
        }
    }


    ///
    /// Sets the text alignment in the specified column.
    /// Supported values: Align.LEFT, Align.RIGHT, Align.CENTER and Align.JUSTIFY.
    ///
    /// @param index the index of the specified column.
    /// @param alignment the specified alignment.
    ///
    public func setTextAlignInColumn(
            _ index: Int,
            _ alignment: UInt32) throws {
        for row in tableData {
            if index < row.count {
                row[index].setTextAlignment(alignment)
            }
        }
    }


    ///
    /// Sets the color of the text in the specified column.
    ///
    /// @param index the index of the specified column.
    /// @param color the color specified as an integer.
    ///
    public func setTextColorInColumn(
            _ index: Int,
            _ color: UInt32) {
        for row in tableData {
            if index < row.count {
                row[index].setBrushColor(color)
            }
        }
    }


    ///
    /// Sets the font for the specified column.
    ///
    /// @param index the column index.
    /// @param font the font.
    ///
    public func setFontInColumn(
            _ index: Int,
            _ font: Font) {
        for row in tableData {
            if index < row.count {
                row[index].font = font
            }
        }
    }


    ///
    /// Sets the color of the text in the specified row.
    ///
    /// @param index the index of the specified row.
    /// @param color the color specified as an integer.
    ///
    public func setTextColorInRow(
            _ index: Int,
            _ color: UInt32) {
        if index < tableData.count {
            let row = tableData[index]
            for cell in row {
                cell.setBrushColor(color)
            }
        }
    }


    ///
    /// Sets the font for the specified row.
    ///
    /// @param index the row index.
    /// @param font the font.
    ///
    public func setFontInRow(
            _ index: Int,
            _ font: Font) {
        if index < tableData.count {
            let row = tableData[index]
            for cell in row {
                cell.font = font
            }
        }
    }


    ///
    /// Sets the width of the column with the specified index.
    ///
    /// @param index the index of specified column.
    /// @param width the specified width.
    ///
    public func setColumnWidth(
            _ index: Int,
            _ width: Float) {
        for row in tableData {
            if index < row.count {
                row[index].setWidth(width)
            }
        }
    }


    ///
    /// Returns the column width of the column at the specified index.
    ///
    /// @param index the index of the column.
    /// @return the width of the column.
    ///
    public func getColumnWidth(
            _ index: Int) throws -> Float {
        return try getCellAtRowColumn(0, index).getWidth();
    }


    ///
    /// Returns the cell at the specified row and column.
    ///
    /// @param row the specified row.
    /// @param col the specified column.
    ///
    /// @return the cell at the specified row and column.
    ///
    public func getCellAt(
            _ row: Int,
            _ col: Int) -> Cell {
        if row >= 0 {
            return tableData[row][col]
        }
        return tableData[tableData.count + row][col]
    }


    ///
    /// Returns the cell at the specified row and column.
    ///
    /// @param row the specified row.
    /// @param col the specified column.
    ///
    /// @return the cell at the specified row and column.
    ///
    public func getCellAtRowColumn(_ row: Int, _ col: Int) throws -> Cell {
        return getCellAt(row, col)
    }


    ///
    /// Returns a list of cell for the specified row.
    ///
    /// @param index the index of the specified row.
    ///
    /// @return the list of cells.
    ///
    public func getRow(_ index: Int) -> [Cell] {
        return tableData[index]
    }


    public func getRowAtIndex(
            _ index: Int) -> [Cell] {
        return getRow(index)
    }


    ///
    /// Returns a list of cell for the specified column.
    ///
    /// @param index the index of the specified column.
    ///
    /// @return the list of cells.
    ///
    public func getColumn(_ index: Int) -> [Cell] {
        var column = [Cell]()
        for row in tableData {
            if index < row.count {
                column.append(row[index])
            }
        }
        return column
    }


    public func getColumnAtIndex(
            _ index: Int) -> [Cell] {
        return getColumn(index)
    }


    ///
    /// Returns the total number of pages that are required to draw this table on.
    ///
    /// @param page the type of pages we are drawing this table on.
    ///
    /// @return the number of pages.
    ///
    @discardableResult
    public func getNumberOfPages(_ page: Page) throws -> Int {
        self.numOfPages = 1
        while hasMoreData() {
            drawOn(page, false)
        }
        resetRenderedPagesCount()
        return self.numOfPages
    }


    ///
    /// Draws this table on the specified page.
    ///
    /// @param page the page to draw this table on.
    ///
    /// @return Point the point on the page where to draw the next component.
    ///
    @discardableResult
    public func drawOn(_ page: Page) -> Point {
        return drawOn(page, true)
    }


    ///
    /// Draws this table on the specified page.
    ///
    /// @param page the page to draw this table on.
    /// @param draw if false - do not draw the table. Use to only find out where the table ends.
    ///
    /// @return Point the point on the page where to draw the next component.
    ///
    @discardableResult
    private func drawOn(
            _ page: Page, _ draw: Bool) -> Point {
        return drawTableRows(page, draw, drawHeaderRows(page, draw))
    }


    private func drawHeaderRows(
            _ page: Page,
            _ draw: Bool) -> [Float] {
        var x = x1
        var y = y1
        var cell_w: Float = 0.0
        var cell_h: Float = 0.0

        for i in 0..<numOfHeaderRows {
            var dataRow = tableData[i]
            cell_h = getMaxCellHeight(dataRow)

            var j = 0
            while j < dataRow.count {
                let cell = dataRow[j]
                cell_w = dataRow[j].getWidth()
                let colspan = dataRow[j].getColSpan()
                var k = 1
                while k < colspan {
                    j += 1
                    cell_w += dataRow[j].width
                    k += 1
                }

                if draw {
                    page.setBrushColor(cell.getBrushColor())
                    cell.paint(page, x!, y!, cell_w, cell_h)
                }

                x! += cell_w
                j += 1
            }
            x = x1
            y! += cell_h
        }

        return [x!, y!, cell_w, cell_h]
    }


    private func drawTableRows(
            _ page: Page,
            _ draw: Bool,
            _ parameter: [Float]) -> Point {
        var x = parameter[0]
        var y = parameter[1]
        var cell_w = parameter[2]
        var cell_h = parameter[3]

        var i = rendered
        while i < tableData.count {
            var dataRow = tableData[i]
            cell_h = getMaxCellHeight(dataRow)
            var j = 0
            while j < dataRow.count {
                let cell = dataRow[j]
                cell_w = cell.getWidth()
                let colspan = dataRow[j].getColSpan()
                var k = 1
                while k < colspan {
                    j += 1
                    cell_w += dataRow[j].getWidth()
                    k += 1
                }

                if draw {
                    page.setBrushColor(cell.getBrushColor())
                    cell.paint(page, x, y, cell_w, cell_h)
                }
                x += cell_w
                j += 1
            }
            x = x1!
            y += cell_h

            // Consider the height of the next row when checking if we must go to a new page
            if i < (tableData.count - 1) {
                for cell in tableData[i + 1] {
                    if cell.getHeight() > cell_h {
                        cell_h = cell.getHeight()
                    }
                }
            }

            if (y + cell_h) > (page.height - bottom_margin) {
                if i == (tableData.count - 1) {
                    rendered = -1
                }
                else {
                    rendered = i + 1
                    numOfPages += 1
                }
                return Point(x, y)
            }

            i += 1
        }
        rendered = -1

        return Point(x, y)
    }


    private func getMaxCellHeight(_ row: [Cell]) -> Float {
        var max_cell_height: Float = 0.0
        for cell in row {
            if cell.getHeight() > max_cell_height {
                max_cell_height = cell.getHeight()
            }
        }
        return max_cell_height
    }


    ///
    /// Returns true if the table contains more data that needs to be drawn on a page.
    ///
    public func hasMoreData() -> Bool {
        return self.rendered != -1
    }


    ///
    /// Returns the width of this table when drawn on a page.
    ///
    /// @return the widht of this table.
    ///
    public func getWidth() -> Float {
        var table_width: Float = 0.0
        if tableData.count > 0 {
            let row = tableData[0]
            for cell in row {
                table_width += cell.getWidth()
            }
        }
        return table_width
    }


    ///
    /// Returns the number of data rows that have been rendered so far.
    ///
    /// @return the number of data rows that have been rendered so far.
    ///
    public func getRowsRendered() -> Int {
        return rendered == -1 ? rendered : rendered - numOfHeaderRows
    }


    ///
    /// Wraps around the text in all cells so it fits the column width.
    /// This method should be called after all calls to setColumnWidth and autoAdjustColumnWidths.
    ///
    public func wrapAroundCellText() {
        var tableData2 = [[Cell]]()
        for row in tableData {
            var maxNumVerCells = 1
            for i in 0..<row.count {
                var n = 1
                while n < row[i].getColSpan() {
                    row[i].width += row[i + n].width
                    row[i + n].width = 0.0
                    n += 1
                }
                let numVerCells = row[i].getNumVerCells()
                if numVerCells > maxNumVerCells {
                    maxNumVerCells = numVerCells
                }
            }

            for i in 0..<maxNumVerCells {
                var row2 = [Cell]()
                for cell in row {
                    let cell2 = Cell(cell.getFont(), "")
                    cell2.setFallbackFont(cell.getFallbackFont())
                    cell2.setPoint(cell.getPoint())
                    cell2.setWidth(cell.getWidth())
                    if i == 0 {
                        cell2.setTopPadding(cell.top_padding)
                    }
                    if i == (maxNumVerCells - 1) {
                        cell2.setBottomPadding(cell.bottom_padding)
                    }
                    cell2.setLeftPadding(cell.left_padding)
                    cell2.setRightPadding(cell.right_padding)
                    cell2.setLineWidth(cell.lineWidth)
                    cell2.setBgColor(cell.getBgColor())
                    cell2.setPenColor(cell.getPenColor())
                    cell2.setBrushColor(cell.getBrushColor())
                    cell2.setProperties(cell.getProperties())
                    cell2.setVerTextAlignment(cell.getVerTextAlignment())
                    cell2.setIgnoreImageHeight(cell.getIgnoreImageHeight())
                    if i == 0 {
                        cell2.setImage(cell.getImage())
                        if cell.getCompositeTextLine() != nil {
                            cell2.setCompositeTextLine(cell.getCompositeTextLine())
                        }
                        else {
                            cell2.setText(cell.getText())
                        }
                        if maxNumVerCells > 1 {
                            cell2.setBorder(Border.BOTTOM, false)
                        }
                    }
                    else  {
                        cell2.setBorder(Border.TOP, false)
                        if i < (maxNumVerCells - 1) {
                            cell2.setBorder(Border.BOTTOM, false)
                        }
                    }
                    row2.append(cell2)
                }
                tableData2.append(row2)
            }
        }

        for i in 0..<tableData2.count {
            var row = tableData2[i]
            for j in 0..<row.count {
                let cell = row[j]
                if cell.text != nil {
                    var n = 0
                    let textLines = cell.text!.trim().components(separatedBy: "\n")
                    for textLine in textLines {
                        var sb = String()
                        var tokens = textLine.trim().components(separatedBy: .whitespaces)
                        if tokens.count == 1 {
                            sb.append(tokens[0])
                        }
                        else {
                            for k in 0..<tokens.count {
                                let token = tokens[k].trim()
                                if cell.font!.stringWidth(cell.fallbackFont, sb + " " + token) >
                                        (cell.getWidth() - (cell.left_padding + cell.right_padding)) {
                                    tableData2[i + n][j].setText(sb)
                                    sb = token
                                    n += 1
                                }
                                else {
                                    if k > 0 {
                                        sb.append(" ")
                                    }
                                    sb.append(token)
                                }
                            }
                        }
                        tableData2[i + n][j].setText(sb)
                        n += 1
                    }
                }
                else {
                    tableData2[i][j].setCompositeTextLine(cell.getCompositeTextLine())
                }
            }
        }

        tableData = tableData2
    }


    ///
    /// Sets all table cells borders to <strong>false</strong>.
    ///
    public func setNoCellBorders() {
        for i in 0..<tableData.count {
            let row = tableData[i]
            for j in 0..<row.count {
                tableData[i][j].setNoBorders()
            }
        }
    }


    ///
    /// Sets the color of the cell border lines.
    ///
    /// @param color the color of the cell border lines.
    ///
    public func setCellBordersColor(_ color: UInt32) {
        for i in 0..<tableData.count {
            let row = tableData[i]
            for j in 0..<row.count {
                tableData[i][j].setPenColor(color)
            }
        }
    }


    ///
    /// Sets the width of the cell border lines.
    ///
    /// @param width the width of the border lines.
    ///
    public func setCellBordersWidth(_ width: Float) {
        for i in 0..<tableData.count {
            let row = tableData[i]
            for j in 0..<row.count {
                tableData[i][j].setLineWidth(width)
            }
        }
    }


    ///
    /// Resets the rendered pages count.
    /// Call this method if you have to draw this table more than one time.
    ///
    public func resetRenderedPagesCount() {
        self.rendered = numOfHeaderRows
    }


    ///
    /// This method removes borders that have the same color and overlap 100%.
    /// The result is improved onscreen rendering of thin border lines by some PDF viewers.
    ///
    public func mergeOverlaidBorders() {
        for i in 0..<tableData.count {
            var currentRow = tableData[i]
            for j in 0..<currentRow.count {
                let currentCell = currentRow[j]
                if j < currentRow.count - 1 {
                    let cellAtRight = currentRow[j + 1]
                    if cellAtRight.getBorder(Border.LEFT) &&
                            currentCell.getPenColor() == cellAtRight.getPenColor() &&
                            currentCell.getLineWidth() == cellAtRight.getLineWidth() &&
                            (Int(currentCell.getColSpan()) + j) < (currentRow.count - 1) {
                        currentCell.setBorder(Border.RIGHT, false)
                    }
                }
                if i < (tableData.count - 1) {
                    var nextRow = tableData[i + 1]
                    let cellBelow = nextRow[j]
                    if cellBelow.getBorder(Border.TOP) &&
                            currentCell.getPenColor() == cellBelow.getPenColor() &&
                            currentCell.getLineWidth() == cellBelow.getLineWidth() {
                        currentCell.setBorder(Border.BOTTOM, false)
                    }
                }
            }
        }
    }

}   // End of Table.swift
