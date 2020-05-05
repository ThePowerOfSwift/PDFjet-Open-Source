/**
 *  Font.swift
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
/// Used to create font objects.
/// The font objects must added to the PDF before they can be used to draw text.
///
public class Font {

    // Chinese (Traditional) font
    public static let AdobeMingStd_Light = "AdobeMingStd-Light"

    // Chinese (Simplified) font
    public static let STHeitiSC_Light = "STHeitiSC-Light"

    // Japanese font
    public static let KozMinProVI_Regular = "KozMinProVI-Regular"

    // Korean font
    public static let AdobeMyungjoStd_Medium = "AdobeMyungjoStd-Medium"

    public static var STREAM: Bool = true

    var name: String = "? - hello - ?"
    var info: String = "? - world - ?"
    var objNumber = 0

    // The object number of the embedded font file
    var fileObjNumber = -1

    // Font attributes
    var unitsPerEm = 1000
    var size: Float = 12.0
    var ascent: Float = 0.0
    var descent: Float = 0.0
    var capHeight: Float = 0.0
    var body_height: Float = 0.0

    // Font metrics
    var metrics: [[Int16]]?

    // Don't change the following default values!
    var isCoreFont = false
    var isCJK = false
    var firstChar = 32
    var lastChar = 255
    var skew15 = false
    var kernPairs = false

    // Font bounding box
    var bBoxLLx: Float = 0.0
    var bBoxLLy: Float = 0.0
    var bBoxURx: Float = 0.0
    var bBoxURy: Float = 0.0
    var underlinePosition: Float = 0.0
    var underlineThickness: Float = 0.0

    var compressed_size: Int?
    var uncompressed_size: Int?

    var advanceWidth: [UInt16]?
    var glyphWidth: [Int]?
    var unicodeToGID: [Int]?
    var cff: Bool?

    var fontID: String?

    private var fontDescriptorObjNumber = -1
    private var cMapObjNumber = -1
    private var cidFontDictObjNumber = -1
    private var toUnicodeCMapObjNumber = -1
    private var widthsArrayObjNumber = -1
    private var encodingObjNumber = -1
    private var codePage = CodePage.UNICODE
    private var fontUnderlinePosition = 0
    private var fontUnderlineThickness = 0


    ///
    /// Constructor for the 14 standard fonts.
    /// Creates a font object and adds it to the PDF.
    ///
    /// <pre>
    /// Examples:
    ///     Font font1 = Font(pdf, CoreFont.HELVETICA)
    ///     Font font2 = Font(pdf, CoreFont.TIMES_ITALIC)
    ///     Font font3 = Font(pdf, CoreFont.ZAPF_DINGBATS)
    ///     ...
    /// </pre>
    ///
    /// @param pdf the PDF to add this font to.
    /// @param coreFont the core font. Must be one the names defined in the CoreFont class.
    ///
    public init(_ pdf: PDF, _ coreFont: CoreFont) {
        self.isCoreFont = true
        let font = StandardFont.getInstance(coreFont)
        self.name = font.name!
        self.bBoxLLx = Float(font.bBoxLLx!)
        self.bBoxLLy = Float(font.bBoxLLy!)
        self.bBoxURx = Float(font.bBoxURx!)
        self.bBoxURy = Float(font.bBoxURy!)
        self.metrics = font.metrics
        self.ascent = self.bBoxURy * self.size / Float(self.unitsPerEm)
        self.descent = self.bBoxLLy * self.size / Float(self.unitsPerEm)
        self.body_height = self.ascent - self.descent
        self.fontUnderlinePosition = Int(font.underlinePosition!)
        self.fontUnderlineThickness = Int(font.underlineThickness!)
        self.underlineThickness = Float(self.fontUnderlineThickness) * self.size / Float(self.unitsPerEm)
        self.underlinePosition = Float(self.fontUnderlinePosition) *
                self.size / Float(-self.unitsPerEm) + Float(self.underlineThickness) / Float(2.0)

        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /Font\n")
        pdf.append("/Subtype /Type1\n")
        pdf.append("/BaseFont /")
        pdf.append(self.name)
        pdf.append("\n")
        if self.name != "Symbol" && self.name != "ZapfDingbats" {
            pdf.append("/Encoding /WinAnsiEncoding\n")
        }
        pdf.append(">>\n")
        pdf.endobj()
        self.objNumber = pdf.objNumber

        pdf.fonts.append(self)
    }


    // Used by PDFobj
    init(_ coreFont: CoreFont) {
        self.isCoreFont = true
        let font = StandardFont.getInstance(coreFont)
        self.name = font.name!
        self.bBoxLLx = Float(font.bBoxLLx!)
        self.bBoxLLy = Float(font.bBoxLLy!)
        self.bBoxURx = Float(font.bBoxURx!)
        self.bBoxURy = Float(font.bBoxURy!)
        self.metrics = font.metrics
        self.ascent = Float(self.bBoxURy) * self.size / Float(self.unitsPerEm)
        self.descent = Float(self.bBoxLLy) * self.size / Float(self.unitsPerEm)
        self.body_height = self.ascent - self.descent
        self.fontUnderlinePosition = Int(font.underlinePosition!)
        self.fontUnderlineThickness = Int(font.underlineThickness!)
        self.underlineThickness = Float(self.fontUnderlineThickness) * self.size / Float(self.unitsPerEm)
        self.underlinePosition = Float(self.fontUnderlinePosition) *
                self.size / Float(-self.unitsPerEm) + Float(self.underlineThickness) / Float(2.0)
    }


    public convenience init(_ pdf: PDF, _ fontName: String) {
        self.init(pdf, fontName, CodePage.UNICODE)
    }


    ///
    /// Constructor for CJK - Chinese, Japanese and Korean fonts.
    /// Please see Example_04.
    ///
    /// @param pdf the PDF to add this font to.
    /// @param fontName the font name. Please see Example_04.
    /// @param codePage the code page. Must be: CodePage.UNICODE
    ///
    public init(_ pdf: PDF, _ fontName: String, _ codePage: Int) {
        self.name = fontName
        self.isCJK = true

        self.firstChar = 0x0020
        self.lastChar = 0xFFEE

        // Font Descriptor
        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /FontDescriptor\n")
        pdf.append("/FontName /")
        pdf.append(fontName)
        pdf.append("\n")
        pdf.append("/Flags 4\n")
        pdf.append("/FontBBox [0 0 0 0]\n")
        pdf.append(">>\n")
        pdf.endobj()

        // CIDFont Dictionary
        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /Font\n")
        pdf.append("/Subtype /CIDFontType0\n")
        pdf.append("/BaseFont /")
        pdf.append(fontName)
        pdf.append("\n")
        pdf.append("/FontDescriptor ")
        pdf.append(pdf.objNumber - 1)
        pdf.append(" 0 R\n")
        pdf.append("/CIDSystemInfo <<\n")
        pdf.append("/Registry (Adobe)\n")
        if fontName.hasPrefix("AdobeMingStd") {
            pdf.append("/Ordering (CNS1)\n")
            pdf.append("/Supplement 4\n")
        } else if fontName.hasPrefix("AdobeSongStd")
                || fontName.hasPrefix("STHeitiSC") {
            pdf.append("/Ordering (GB1)\n")
            pdf.append("/Supplement 4\n")
        } else if fontName.hasPrefix("KozMinPro") {
            pdf.append("/Ordering (Japan1)\n")
            pdf.append("/Supplement 4\n")
        } else if fontName.hasPrefix("AdobeMyungjoStd") {
            pdf.append("/Ordering (Korea1)\n")
            pdf.append("/Supplement 1\n")
        } else {
            // TODO:
            print("Unsupported font: " + fontName)
        }
        pdf.append(">>\n")
        pdf.append(">>\n")
        pdf.endobj()

        // Type0 Font Dictionary
        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /Font\n")
        pdf.append("/Subtype /Type0\n")
        pdf.append("/BaseFont /")
        if fontName.hasPrefix("AdobeMingStd") {
            pdf.append(fontName + "-UniCNS-UTF16-H\n")
            pdf.append("/Encoding /UniCNS-UTF16-H\n")
        } else if fontName.hasPrefix("AdobeSongStd")
                || fontName.hasPrefix("STHeitiSC") {
            pdf.append(fontName + "-UniGB-UTF16-H\n")
            pdf.append("/Encoding /UniGB-UTF16-H\n")
        } else if fontName.hasPrefix("KozMinPro") {
            pdf.append(fontName + "-UniJIS-UCS2-H\n")
            pdf.append("/Encoding /UniJIS-UCS2-H\n")
        } else if fontName.hasPrefix("AdobeMyungjoStd") {
            pdf.append(fontName + "-UniKS-UCS2-H\n")
            pdf.append("/Encoding /UniKS-UCS2-H\n")
        } else {
            // TODO:
            print("Unsupported font: " + fontName)
        }
        pdf.append("/DescendantFonts [")
        pdf.append(pdf.objNumber - 1)
        pdf.append(" 0 R]\n")
        pdf.append(">>\n")
        pdf.endobj()
        self.objNumber = pdf.objNumber

        self.ascent = self.size
        self.descent = -self.ascent/4.0
        self.body_height = self.ascent - self.descent

        pdf.fonts.append(self)
    }


    // Constructor for .ttf.stream fonts:
    public init(_ pdf: PDF, _ stream: InputStream, _ flag: Bool) throws {
        try FastFont.register(pdf, self, stream)
        self.ascent = self.bBoxURy * self.size / Float(self.unitsPerEm)
        self.descent = self.bBoxLLy * self.size / Float(self.unitsPerEm)
        self.body_height = self.ascent - self.descent
        self.underlineThickness = Float(self.fontUnderlineThickness) * self.size / Float(self.unitsPerEm)
        self.underlinePosition = Float(self.fontUnderlinePosition) * self.size /
                Float(-self.unitsPerEm) + self.underlineThickness / Float(2.0)
        pdf.fonts.append(self)
    }


    // Constructor for .ttf.stream fonts:
    public init(_ objects: inout [PDFobj], _ stream: InputStream, _ flag: Bool) throws {
        try FastFont2.register(&objects, self, stream)
        self.ascent = self.bBoxURy * self.size / Float(self.unitsPerEm)
        self.descent = self.bBoxLLy * self.size / Float(self.unitsPerEm)
        self.body_height = self.ascent - self.descent
        self.underlineThickness = Float(self.fontUnderlineThickness) * self.size / Float(self.unitsPerEm)
        self.underlinePosition = Float(self.fontUnderlinePosition) * self.size /
                Float(-self.unitsPerEm) + Float(self.underlineThickness) / Float(2.0)
    }


    func getFontDescriptorObjNumber() -> Int {
        return self.fontDescriptorObjNumber
    }


    func getCMapObjNumber() -> Int {
        return self.cMapObjNumber
    }


    func getCidFontDictObjNumber() -> Int {
        return self.cidFontDictObjNumber
    }


    func getToUnicodeCMapObjNumber() -> Int {
        return self.toUnicodeCMapObjNumber
    }


    func getWidthsArrayObjNumber() -> Int {
        return self.widthsArrayObjNumber
    }


    func getEncodingObjNumber() -> Int {
        return self.encodingObjNumber
    }


    public func getUnderlinePosition() -> Float {
        return self.underlinePosition
    }


    public func getUnderlineThickness() -> Float {
        return self.underlineThickness
    }


    func setFontDescriptorObjNumber(_ fontDescriptorObjNumber: Int) {
        self.fontDescriptorObjNumber = fontDescriptorObjNumber
    }


    func setCMapObjNumber(_ cMapObjNumber: Int) {
        self.cMapObjNumber = cMapObjNumber
    }


    func setCidFontDictObjNumber(_ cidFontDictObjNumber: Int) {
        self.cidFontDictObjNumber = cidFontDictObjNumber
    }


    func setToUnicodeCMapObjNumber(_ toUnicodeCMapObjNumber: Int) {
        self.toUnicodeCMapObjNumber = toUnicodeCMapObjNumber
    }


    func setWidthsArrayObjNumber(_ widthsArrayObjNumber: Int) {
        self.widthsArrayObjNumber = widthsArrayObjNumber
    }


    func setEncodingObjNumber(_ encodingObjNumber: Int) {
        self.encodingObjNumber = encodingObjNumber
    }


    ///
    /// Sets the size of this font.
    ///
    /// @param fontSize specifies the size of this font.
    /// @return the font.
    ///
    @discardableResult
    public func setSize(_ fontSize: Float) -> Font {
        self.size = fontSize
        if isCJK {
            self.ascent = self.size
            self.descent = -self.ascent/4.0
            return self
        }
        self.ascent = Float(self.bBoxURy) * self.size / Float(self.unitsPerEm)
        self.descent = Float(self.bBoxLLy) * self.size / Float(self.unitsPerEm)
        self.body_height = self.ascent - self.descent
        self.underlineThickness = Float(self.fontUnderlineThickness) * self.size / Float(self.unitsPerEm)
        self.underlinePosition = Float(self.fontUnderlinePosition) *
                self.size / Float(-self.unitsPerEm) + Float(self.underlineThickness) / Float(2.0)
        return self
    }


    ///
    /// Returns the current font size.
    ///
    /// @return the current size of the font.
    ///
    public func getSize() -> Float {
        return self.size
    }


    ///
    /// Sets the kerning for the selected font to 'true' or 'false'
    /// depending on the passed value of kernPairs parameter.
    ///
    /// The kerning is implemented only for the 14 standard fonts.
    ///
    /// @param kernPairs if 'true' the kerning for this font is enabled.
    ///
    @discardableResult
    public func setKernPairs(_ kernPairs: Bool) -> Font {
        self.kernPairs = kernPairs
        return self
    }


    ///
    /// Returns the width of the specified string when drawn on the page with this font using the current font size.
    ///
    /// @param str the specified string.
    ///
    /// @return the width of the string when draw on the page with this font using the current selected size.
    ///
    public func stringWidth(_ str: String?) -> Float {
        if str == nil {
            return 0.0
        }

        if isCJK {
            return Float(str!.count) * self.ascent
        }

        var scalars = Array(str!.unicodeScalars)
        var width = 0
        var i = 0
        while i < scalars.count {
            var c1 = Int(scalars[i].value)
            if self.isCoreFont {
                if c1 < self.firstChar || c1 > self.lastChar {
                    c1 = 0x20
                }
                c1 -= 32
                width += Int(metrics![c1][1])
                if self.kernPairs && i < (scalars.count - 1) {
                    var c2 = scalars[i + 1].value
                    if c2 < self.firstChar || c2 > self.lastChar {
                        c2 = 32
                    }

                    var j: Int = 2
                    while j < metrics![c1].count {
                        if metrics![c1][j] == c2 {
                            width += Int(metrics![c1][j + 1])
                            break
                        }
                        j += 2
                    }
                }
            }
            else {
                if c1 < firstChar || c1 > lastChar {
                    width += Int(advanceWidth![0])
                }
                else {
                    width += glyphWidth![c1]
                }
            }
            i += 1
        }

        return Float(width) * self.size / Float(self.unitsPerEm)
    }


    ///
    /// Returns the ascent of this font.
    ///
    /// @return the ascent of the font.
    ///
    public func getAscent() -> Float {
        return self.ascent
    }


    ///
    /// Returns the descent of this font.
    ///
    /// @return the descent of the font.
    ///
    public func getDescent() -> Float {
        return -self.descent
    }


    ///
    /// Returns the height of this font.
    ///
    /// @return the height of the font.
    ///
    public func getHeight() -> Float {
        return self.ascent - self.descent
    }


    ///
    /// Returns the height of the body of the font.
    ///
    /// @return float the height of the body of the font.
    ///
    public func getBodyHeight() -> Float {
        return self.body_height
    }


    ///
    /// Returns the number of characters from the specified string that will fit within the specified width.
    ///
    /// @param str the specified string.
    /// @param width the specified width.
    ///
    /// @return the number of characters that will fit.
    ///
    public func getFitChars(
            _ str: String,
            _ width: Float) -> Int {

        var w = width * Float(unitsPerEm) / size

        if isCJK {
            return Int(w / Float(self.ascent))
        }

        if isCoreFont {
            return getStandardFontFitChars(str, w)
        }

        var i = 0
        for scalar in str.unicodeScalars {
            let c1 = Int(scalar.value)
            if c1 < firstChar || c1 > lastChar {
                w -= Float(advanceWidth![0])
            }
            else {
                w -= Float(glyphWidth![c1])
            }
            if w < 0 {
                break
            }
            i += 1
        }

        return i
    }


    private func getStandardFontFitChars(
            _ str: String,
            _ width: Float) -> Int {

        var w: Float = width

        var scalars = Array(str.unicodeScalars)
        var i: Int = 0
        for scalar in scalars {
            var c1 = Int(scalar.value)
            if c1 < firstChar || c1 > lastChar {
                c1 = 32
            }

            c1 -= 32
            w -= Float(metrics![c1][1])
            if w < 0 {
                return i
            }

            if kernPairs && i < (scalars.count - 1) {
                var c2 = scalars[i + 1].value
                if c2 < firstChar || c2 > lastChar {
                    c2 = 32
                }

                var j: Int = 2
                while j < metrics![c1].count {
                    if metrics![c1][j] == c2 {
                        w -= Float(metrics![c1][j + 1])
                        if w < 0 {
                            return i
                        }
                        break
                    }
                    j += 2
                }
            }
            i += 1
        }

        return i
    }


    ///
    /// Sets the skew15 private variable.
    /// When the variable is set to 'true' all glyphs in the font are skewed on 15 degrees.
    /// This makes a regular font look like an italic type font.
    /// Use this method when you don't have real italic font in the font family,
    /// or when you want to generate smaller PDF files.
    /// For example you could embed only the Regular and Bold fonts and synthesize the RegularItalic and BoldItalic.
    ///
    /// @param skew15 the skew flag.
    ///
    public func setItalic(_ skew15: Bool) {
        self.skew15 = skew15
    }


    ///
    /// Returns the width of a string drawn using two fonts.
    ///
    /// @param font2 the fallback font.
    /// @param str the string.
    /// @return the width.
    ///
    public func stringWidth(_ fallbackFont: Font?, _ str: String?) -> Float {
        if fallbackFont == nil {
            return stringWidth(str)
        }
        var width: Float = 0.0

        var usePrimaryFont: Bool = true
        var scalars = Array(str!.unicodeScalars)
        var buf = String()
        var i: Int = 0
        while i < scalars.count {
            let scalar = scalars[i]
            if (isCJK && scalar.value >= 0x4E00 && scalar.value <= 0x9FCC)
                    || (!isCJK && unicodeToGID![Int(scalar.value)] != 0) {
                if !usePrimaryFont {
                    width += fallbackFont!.stringWidth(buf)
                    buf = ""
                    usePrimaryFont = true
                }
            }
            else {
                if usePrimaryFont {
                    width += stringWidth(buf)
                    buf = ""
                    usePrimaryFont = false
                }
            }
            buf.append(Character(scalar))
            i += 1
        }
        if usePrimaryFont {
            width += stringWidth(buf)
        }
        else {
            width += fallbackFont!.stringWidth(buf)
        }

        return width
    }

}   // End of Font.swift
