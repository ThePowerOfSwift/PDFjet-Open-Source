/**
 *  Form.swift
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


/**
 *  Please see Example_45
 */
public class Form : Drawable {

    private var fields: [Field]
    private var x: Float?
    private var y: Float?
    private var f1: Font?
    private var labelFontSize: Float = 8.0
    private var f2: Font?
    private var valueFontSize: Float = 10.0
    private var numberOfRows = 0
    private var rowLength: Float = 500.0
    private var rowHeight: Float = 12.0
    private var labelColor: UInt32 = Color.black
    private var valueColor: UInt32 = Color.blue
    private var endOfLinePoints: [[Float]]


    public init(_ fields: [Field]) {
        self.fields = fields
        self.endOfLinePoints = [[Float]]()
    }


    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> Form {
        self.x = x
        self.y = y
        return self
    }


    @discardableResult
    public func setRowLength(_ rowLength: Float) -> Form {
        self.rowLength = rowLength
        return self
    }


    @discardableResult
    public func setRowHeight(_ rowHeight: Float) -> Form {
        self.rowHeight = rowHeight
        return self
    }


    @discardableResult
    public func setLabelFont(_ f1: Font) -> Form {
        self.f1 = f1
        return self
    }


    @discardableResult
    public func setLabelFontSize(_ labelFontSize: Float) -> Form {
        self.labelFontSize = labelFontSize
        return self
    }


    @discardableResult
    public func setValueFont(_ f2: Font) -> Form {
        self.f2 = f2
        return self
    }


    @discardableResult
    public func setValueFontSize(_ valueFontSize: Float) -> Form {
        self.valueFontSize = valueFontSize
        return self
    }


    @discardableResult
    public func setLabelColor(_ labelColor: UInt32) -> Form {
        self.labelColor = labelColor
        return self
    }


    @discardableResult
    public func setValueColor(_ valueColor: UInt32) -> Form {
        self.valueColor = valueColor
        return self
    }


    public func getEndOfLinePoints() -> [[Float]] {
        return endOfLinePoints
    }


    /**
     *  Draws this Form on the specified page.
     *
     *  @param page the page to draw this form on.
     *  @return x and y coordinates of the bottom right corner of this component.
     *  @throws Exception
     */
    @discardableResult
    public func drawOn(_ page: Page) -> [Float] {
        for field in fields {
            if field.format {
                field.values = format(field.values[0], field.values[1], self.f2!, self.rowLength)
                field.altDescription = [String]()
                field.actualText  = [String]()
                for value in field.values {
                    field.altDescription.append(value)
                    field.actualText.append(value)
                }
            }
            if field.x == 0.0 {
                numberOfRows += field.values.count
            }
        }

        if numberOfRows == 0 {
            return [x!, y!]
        }

        let boxHeight = rowHeight * Float(numberOfRows)

        let box = Box()
                .setLocation(x!, y!)
                .setSize(rowLength, boxHeight)
        box.drawOn(page)

        var field_y: Float = 0.0
        var row_span = 1
        var row_y: Float = 0
        for field in fields {
            if field.x == 0.0 {
                row_y += Float(row_span) * rowHeight
                row_span = field.values.count
            }
            field_y = Float(row_y)
/*
            Line(0.0, 0.0, rowLength, 0.0)
                    .placeIn(box, 0.0, field_y + rowHeight)
                    .drawOn(page)
*/
            for i in 0..<field.values.count {
                let font: Font = (i == 0) ? f1! : f2!
                let fontSize: Float = (i == 0) ? labelFontSize : valueFontSize
                let color = (i == 0) ? labelColor : valueColor
                TextLine(font, field.values[i])
                        .setFontSize(fontSize)
                        .setColor(color)
                        .placeIn(box, field.x + f1!.getDescent(), field_y - font.getDescent())
                        .setAltDescription((i == 0) ? field.altDescription[i] : (field.altDescription[i] + ","))
                        .setActualText((i == 0) ? field.actualText[i] : (field.actualText[i] + ","))
                        .drawOn(page)
                endOfLinePoints.append([
                        field.x + f1!.getDescent() + font.stringWidth(field.values[i]),
                        field_y - font.getDescent()])
                if i == (field.values.count - 1) {
                    Line(0.0, 0.0, rowLength, 0.0)
                            .placeIn(box, 0.0, field_y)
                            .drawOn(page);
                    if field.x != 0.0 {
                        Line(0.0, -Float(field.values.count - 1) * rowHeight, 0.0, 0.0)
                                .placeIn(box, field.x, field_y)
                                .drawOn(page)
                    }
                }
                field_y += rowHeight
            }
        }

        return [x! + rowLength, y! + boxHeight]
    }


    public func format(
            _ title: String,
            _ text: String,
            _ font: Font,
            _ width: Float) -> [String] {

        let original = text.components(separatedBy: "\n")
        var lines = [String]()
        for line1 in original {
            let line = line1.trim()
            if font.stringWidth(line) < width {
                lines.append(line)
            }
            else {
                var buffer = String()
                var characters = Array(line)
                var j = 0
                while j < characters.count {
                    buffer.append(characters[j])
                    if font.stringWidth(buffer) > (width - font.stringWidth("   ")) {
                        if (characters[j] == " ") {
                            while j > 0 && characters[j] != " " {
                                j += 1
                            }
                        }
                        else {
                            while j > 0 && characters[j] != " " {
                                j -= 1
                                buffer.removeLast()
                            }
                        }
                        lines.append(buffer)
                        buffer.removeAll()
                    }
                    j += 1
                }
                if !buffer.isEmpty {
                    lines.append(buffer)
                }
            }
        }
        lines.insert(title, at: 0)

        return lines
    }

}   // End of Form.swift
