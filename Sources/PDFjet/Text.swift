/**
 *  Text.swift
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
/// Please see Example_45
///
public class Text {

    private var paragraphs: [Paragraph]?
    private var font: Font?
    private var fallbackFont: Font?
    private var x: Float = 0.0
    private var y: Float = 0.0
    private var w: Float = 0.0
    private var x_text: Float = 0.0
    private var y_text: Float = 0.0
    private var leading: Float = 0.0
    private var paragraphLeading: Float = 0.0
    private var beginParagraphPoints: [[Float]]?
    private var endParagraphPoints: [[Float]]?
    private var spaceBetweenTextLines: Float = 0.0


    public init(_ paragraphs: [Paragraph]) {
        self.paragraphs = paragraphs
        self.font = paragraphs[0].list![0].getFont()
        self.fallbackFont = paragraphs[0].list![0].getFallbackFont()
        self.leading = font!.getBodyHeight()
        self.paragraphLeading = 2*leading
        self.beginParagraphPoints = [[Float]]()
        self.endParagraphPoints = [[Float]]()
        self.spaceBetweenTextLines = font!.stringWidth(fallbackFont, Single.space)
    }

    @discardableResult
    public func setLocation(_ x: Float, _ y: Float) -> Text {
        self.x = x
        self.y = y
        return self
    }


    @discardableResult
    public func setWidth(_ w: Float) -> Text {
        self.w = w
        return self
    }


    @discardableResult
    public func setLeading(_ leading: Float) -> Text {
        self.leading = leading
        return self
    }


    @discardableResult
    public func setParagraphLeading(
            _ paragraphLeading: Float) -> Text {
        self.paragraphLeading = paragraphLeading
        return self
    }


    public func getBeginParagraphPoints() -> [[Float]] {
        return self.beginParagraphPoints!
    }


    public func getEndParagraphPoints() -> [[Float]] {
        return self.endParagraphPoints!
    }


    @discardableResult
    public func setSpaceBetweenTextLines(
            _ spaceBetweenTextLines: Float) -> Text {
        self.spaceBetweenTextLines = spaceBetweenTextLines
        return self
    }


    @discardableResult
    public func drawOn(_ page: Page) -> [Float] {
        return drawOn(page, true)
    }


    @discardableResult
    public func drawOn(_ page: Page, _ draw: Bool) -> [Float] {
        self.x_text = x
        self.y_text = y + font!.getAscent()
        for paragraph in paragraphs! {
            let numberOfTextLines = paragraph.list!.count
            var buf = String()
            for i in 0..<numberOfTextLines {
                let textLine = paragraph.list![i]
                buf.append(textLine.getText()!)
            }
            for i in 0..<numberOfTextLines {
                let textLine = paragraph.list![i]
                if i == 0 {
                    beginParagraphPoints!.append([x_text, y_text])
                }
                if i == 0 {
                    textLine.setAltDescription(buf)
                    textLine.setActualText(buf)
                }
                else {
                    textLine.setAltDescription(Single.space)
                    textLine.setActualText(Single.space)
                }
                var point = drawTextLine(
                        page, &x_text, &y_text, textLine, draw)
                if i == (numberOfTextLines - 1) {
                    endParagraphPoints!.append([point[0], point[1]])
                }
                x_text = point[0]
                if textLine.getTrailingSpace() {
                    x_text += spaceBetweenTextLines
                }
                y_text = point[1]
            }
            x_text = x
            y_text += paragraphLeading
        }
        return [x_text, y_text + font!.getDescent()]
    }


    private func drawTextLine(
            _ page: Page,
            _ x_text: inout Float,
            _ y_text: inout Float,
            _ textLine: TextLine,
            _ draw: Bool) -> [Float] {

        let font = textLine.getFont()
        let fallbackFont = textLine.getFallbackFont()
        let color = textLine.getColor()

        var tokens: [String]
        let str = textLine.getText()!
        if stringIsCJK(str) {
            tokens = tokenizeCJK(str, self.w)
        }
        else {
            tokens = str.components(separatedBy: .whitespaces)
        }

        var buf = String()
        var firstTextSegment: Bool = true
        for i in 0..<tokens.count {
            let token = (i == 0) ?
                    tokens[i] : (Single.space + tokens[i])
            if font.stringWidth(fallbackFont, token) < (self.w - (x_text - x)) {
                buf.append(token)
                x_text += font.stringWidth(fallbackFont, token)
            }
            else {
                if draw {
                    var altDescription = Single.space
                    var actualText = Single.space
                    if firstTextSegment {
                        altDescription = textLine.getAltDescription()!
                    }
                    if firstTextSegment {
                        actualText = textLine.getActualText()!
                    }
                    TextLine(font, buf)
                            .setFallbackFont(fallbackFont)
                            .setLocation(x_text - font.stringWidth(fallbackFont, buf),
                                    y_text + textLine.getVerticalOffset())
                            .setColor(color)
                            .setUnderline(textLine.getUnderline())
                            .setStrikeout(textLine.getStrikeout())
                            .setLanguage(textLine.getLanguage())
                            .setAltDescription(altDescription)
                            .setActualText(actualText)
                            .drawOn(page)
                    firstTextSegment = false
                }
                x_text = x + font.stringWidth(fallbackFont, tokens[i])
                y_text += leading
                buf = ""
                buf.append(tokens[i])
            }
        }

        if draw {
            var altDescription = Single.space
            var actualText = Single.space
            if firstTextSegment {
                altDescription = textLine.getAltDescription()!
            }
            if firstTextSegment {
                actualText = textLine.getActualText()!
            }
            TextLine(font, buf)
                    .setFallbackFont(fallbackFont)
                    .setLocation(x_text - font.stringWidth(fallbackFont, buf),
                            y_text + textLine.getVerticalOffset())
                    .setColor(color)
                    .setUnderline(textLine.getUnderline())
                    .setStrikeout(textLine.getStrikeout())
                    .setLanguage(textLine.getLanguage())
                    .setAltDescription(altDescription)
                    .setActualText(actualText)
                    .drawOn(page)
            firstTextSegment = false
        }

        return [x_text, y_text]
    }


    private func stringIsCJK(_ str: String) -> Bool {
        // CJK Unified Ideographs Range: 4E00–9FD5
        // Hiragana Range: 3040–309F
        // Katakana Range: 30A0–30FF
        // Hangul Jamo Range: 1100–11FF
        var numOfCJK = 0
        let scalars = [UnicodeScalar](str.unicodeScalars)
        for scalar in scalars {
            if (scalar.value >= 0x4E00 && scalar.value <= 0x9FD5) ||
                    (scalar.value >= 0x3040 && scalar.value <= 0x309F) ||
                    (scalar.value >= 0x30A0 && scalar.value <= 0x30FF) ||
                    (scalar.value >= 0x1100 && scalar.value <= 0x11FF) {
                numOfCJK += 1
            }
        }
        return (numOfCJK > (scalars.count / 2))
    }


    private func tokenizeCJK(
            _ str: String,
            _ textWidth: Float) -> [String] {
        var list = [String]()
        var buf = String()
        let scalars = Array(str.unicodeScalars)
        for scalar in scalars {
            if font!.stringWidth(fallbackFont, buf) < textWidth {
                buf.append(String(scalar))
            }
            else {
                list.append(buf)
                buf = ""
            }
        }
        if buf != "" {
            list.append(buf)
        }
        return list
    }

}   // End of Text.swift
