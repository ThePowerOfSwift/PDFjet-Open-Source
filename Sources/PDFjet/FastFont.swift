/**
 *  FastFont.swift
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


class FastFont {

    enum StreamError: Error {
        case read
        case write
    }

    static func register(
            _ pdf: PDF,
            _ font: Font,
            _ stream: InputStream) throws {

        stream.open()

        var len = try getInt8(stream)
        var fontName = [UInt8](repeating: 0, count: len)
        if stream.read(&fontName, maxLength: len) == len {
            font.name = String(bytes: fontName, encoding: .utf8)!
            // print(font.name)
        }

        len = try getInt24(stream)
        var fontInfo = [UInt8](repeating: 0, count: len)
        if stream.read(&fontInfo, maxLength: len) == len {
            font.info = String(bytes: fontInfo, encoding: .utf8)!
            // print(font.info)
        }

        let deflatedLength = Int(try getInt32(stream))
        var deflated = [UInt8](repeating: 0, count: deflatedLength)
        if stream.read(&deflated, maxLength: deflatedLength) == deflatedLength {
            // print(deflatedLength)
        }

        var inflated = [UInt8]()
        _ = try Puff(output: &inflated, input: &deflated, inflate: false)
        _ = try Puff(output: &inflated, input: &deflated, inflate: true)

        var offset = 0
        font.unitsPerEm = Int(getInt32(inflated, &offset))
        font.bBoxLLx = Float(getInt32(inflated, &offset))
        font.bBoxLLy = Float(getInt32(inflated, &offset))
        font.bBoxURx = Float(getInt32(inflated, &offset))
        font.bBoxURy = Float(getInt32(inflated, &offset))
        font.ascent = Float(getInt32(inflated, &offset))
        font.descent = Float(getInt32(inflated, &offset))
        font.firstChar = Int(getInt32(inflated, &offset))
        font.lastChar = Int(getInt32(inflated, &offset))
        font.capHeight = Float(getInt32(inflated, &offset))
        font.underlinePosition = Float(getInt32(inflated, &offset))
        font.underlineThickness = Float(getInt32(inflated, &offset))

        len = Int(getInt32(inflated, &offset))
        font.advanceWidth = [UInt16](repeating: 0, count: len)
        for i in 0..<len {
            font.advanceWidth![i] = getUInt16(inflated, &offset)
        }

        len = Int(getInt32(inflated, &offset))
        font.glyphWidth = [Int](repeating: 0, count: len)
        for i in 0..<len {
            font.glyphWidth![i] = Int(getInt16(inflated, &offset))
        }

        len = Int(getInt32(inflated, &offset))
        font.unicodeToGID = [Int](repeating: 0, count: len)
        for i in 0..<len {
            font.unicodeToGID![i] = Int(getInt16(inflated, &offset))
        }

        font.cff = false
        if String(try getInt8(stream)) == "Y" {
            font.cff = true
        }

        font.uncompressed_size = Int(try getInt32(stream))
        font.compressed_size = Int(try getInt32(stream))

        embedFontFile(pdf, font, stream)
        stream.close()

        addFontDescriptorObject(pdf, font)
        addCIDFontDictionaryObject(pdf, font)
        addToUnicodeCMapObject(pdf, font)

        // Type0 Font Dictionary
        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /Font\n")
        pdf.append("/Subtype /Type0\n")
        pdf.append("/BaseFont /")
        pdf.append(font.name)
        pdf.append("\n")
        pdf.append("/Encoding /Identity-H\n")
        pdf.append("/DescendantFonts [")
        pdf.append(font.getCidFontDictObjNumber())
        pdf.append(" 0 R]\n")
        pdf.append("/ToUnicode ")
        pdf.append(font.getToUnicodeCMapObjNumber())
        pdf.append(" 0 R\n")
        pdf.append(">>\n")
        pdf.endobj()

        font.objNumber = pdf.objNumber
    }


    private static func embedFontFile(
            _ pdf: PDF, _ font: Font, _ stream: InputStream) {

        // Check if the font file is already embedded
        for f in pdf.fonts {
            if f.name == font.name && f.fileObjNumber != -1 {
                font.fileObjNumber = f.fileObjNumber
                return
            }
        }

        let metadataObjNumber = pdf.addMetadataObject(font.info, true)

        pdf.newobj()
        pdf.append("<<\n")

        pdf.append("/Metadata ")
        pdf.append(metadataObjNumber)
        pdf.append(" 0 R\n")

        if font.cff! {
            pdf.append("/Subtype /CIDFontType0C\n")
        }
        pdf.append("/Filter /FlateDecode\n")
        pdf.append("/Length ")
        pdf.append(font.compressed_size!)
        pdf.append("\n")

        if !font.cff! {
            pdf.append("/Length1 ")
            pdf.append(font.uncompressed_size!)
            pdf.append("\n")
        }

        pdf.append(">>\n")
        pdf.append("stream\n")
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count > 0 {
                pdf.append(buffer, 0, count)
            }
        }

        pdf.append("\nendstream\n")
        pdf.endobj()

        font.fileObjNumber = pdf.objNumber
    }


    private static func addFontDescriptorObject(_ pdf: PDF, _ font: Font) {
        let factor = Float(1000.0) / Float(font.unitsPerEm)

        for f in pdf.fonts {
            if f.name == font.name && f.getFontDescriptorObjNumber() != -1 {
                font.setFontDescriptorObjNumber(f.getFontDescriptorObjNumber())
                return
            }
        }

        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /FontDescriptor\n")
        pdf.append("/FontName /")
        pdf.append(font.name)
        pdf.append("\n")
        if font.cff! {
            pdf.append("/FontFile3 ")
        }
        else {
            pdf.append("/FontFile2 ")
        }
        pdf.append(font.fileObjNumber)
        pdf.append(" 0 R\n")
        pdf.append("/Flags 32\n")
        pdf.append("/FontBBox [")
        pdf.append(Int32(font.bBoxLLx * factor))
        pdf.append(" ")
        pdf.append(Int32(font.bBoxLLy * factor))
        pdf.append(" ")
        pdf.append(Int32(font.bBoxURx * factor))
        pdf.append(" ")
        pdf.append(Int32(font.bBoxURy * factor))
        pdf.append("]\n")
        pdf.append("/Ascent ")
        pdf.append(Int32(font.ascent * factor))
        pdf.append("\n")
        pdf.append("/Descent ")
        pdf.append(Int32(font.descent * factor))
        pdf.append("\n")
        pdf.append("/ItalicAngle 0\n")
        pdf.append("/CapHeight ")
        pdf.append(Int32(font.capHeight * factor))
        pdf.append("\n")
        pdf.append("/StemV 79\n")
        pdf.append(">>\n")
        pdf.endobj()

        font.setFontDescriptorObjNumber(pdf.objNumber)
    }


    private static func addToUnicodeCMapObject(_ pdf: PDF, _ font: Font) {

        for f in pdf.fonts {
            if f.name == font.name && f.getToUnicodeCMapObjNumber() != -1 {
                font.setToUnicodeCMapObjNumber(f.getToUnicodeCMapObjNumber())
                return
            }
        }

        var sb = String()

        sb.append("/CIDInit /ProcSet findresource begin\n")
        sb.append("12 dict begin\n")
        sb.append("begincmap\n")
        sb.append("/CIDSystemInfo <</Registry (Adobe) /Ordering (Identity) /Supplement 0>> def\n")
        sb.append("/CMapName /Adobe-Identity def\n")
        sb.append("/CMapType 2 def\n")

        sb.append("1 begincodespacerange\n")
        sb.append("<0000> <FFFF>\n")
        sb.append("endcodespacerange\n")

        var list = Array<String>()
        var buf = String()
        for cid in 0...0xffff {
            let gid = font.unicodeToGID![cid]
            if gid > 0 {
                buf.append("<")
                buf.append(toHexString(Int32(gid)))
                buf.append("> <")
                buf.append(toHexString(Int32(cid)))
                buf.append(">\n")
                list.append(buf)
                buf = ""
                if list.count == 100 {
                    writeListToBuffer(&list, &sb)
                }
            }
        }
        if list.count > 0 {
            writeListToBuffer(&list, &sb)
        }

        sb.append("endcmap\n")
        sb.append("CMapName currentdict /CMap defineresource pop\n")
        sb.append("end\nend")

        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Length ")
        pdf.append(sb.count)
        pdf.append("\n")
        pdf.append(">>\n")
        pdf.append("stream\n")
        pdf.append(sb)
        pdf.append("\nendstream\n")
        pdf.endobj()

        font.setToUnicodeCMapObjNumber(pdf.objNumber)
    }


    private static func addCIDFontDictionaryObject(_ pdf: PDF, _ font: Font) {

        for f in pdf.fonts {
            if f.name == font.name && f.getCidFontDictObjNumber() != -1 {
                font.setCidFontDictObjNumber(f.getCidFontDictObjNumber())
                return
            }
        }

        pdf.newobj()
        pdf.append("<<\n")
        pdf.append("/Type /Font\n")
        if font.cff! {
            pdf.append("/Subtype /CIDFontType0\n")
        }
        else {
            pdf.append("/Subtype /CIDFontType2\n")
        }
        pdf.append("/BaseFont /")
        pdf.append(font.name)
        pdf.append("\n")
        pdf.append("/CIDSystemInfo <</Registry (Adobe) /Ordering (Identity) /Supplement 0>>\n")
        pdf.append("/FontDescriptor ")
        pdf.append(font.getFontDescriptorObjNumber())
        pdf.append(" 0 R\n")
        pdf.append("/DW ")
        pdf.append(Int32((Float(1000.0) / Float(font.unitsPerEm)) * Float(font.advanceWidth![0])))
        pdf.append("\n")
        pdf.append("/W [0[\n")
        for i in 0..<font.advanceWidth!.count {
            pdf.append(Int32((Float(1000.0) / Float(font.unitsPerEm)) * Float(font.advanceWidth![i])))
            pdf.append(" ")
        }
        pdf.append("]]\n")
        pdf.append("/CIDToGIDMap /Identity\n")
        pdf.append(">>\n")
        pdf.endobj()

        font.setCidFontDictObjNumber(pdf.objNumber)
    }


    private static func toHexString(_ code: Int32) -> String {
        let str = String(code, radix: 16)
        if str.count == 1 {
            return "000" + str
        }
        else if str.count == 2 {
            return "00" + str
        }
        else if str.count == 3 {
            return "0" + str
        }
        return str
    }


    private static func writeListToBuffer(
            _ list: inout [String], _ sb: inout String) {
        sb.append(String(list.count))
        sb.append(" beginbfchar\n")
        for str in list {
            sb.append(str)
        }
        sb.append("endbfchar\n")
        list.removeAll()
    }


    private static func getUInt16(_ stream: InputStream) throws -> UInt16 {
        var buffer = [UInt8](repeating: 0, count: 2)
        if stream.read(&buffer, maxLength: 2) == 2 {
            var value = UInt16(buffer[0]) << 8
            value |= UInt16(buffer[1])
            return value
        }
        throw StreamError.read
    }


    private static func getInt8(_ stream: InputStream) throws -> Int {
        var buffer = [UInt8](repeating: 0, count: 1)
        if stream.read(&buffer, maxLength: 1) == 1 {
            return Int(buffer[0])
        }
        throw StreamError.read
    }


    private static func getInt16(_ stream: InputStream) throws -> Int {
        var buffer = [UInt8](repeating: 0, count: 2)
        if stream.read(&buffer, maxLength: 2) == 2 {
            var value = Int(buffer[0]) << 8
            value |= Int(buffer[1])
            return value
        }
        throw StreamError.read
    }


    private static func getInt24(_ stream: InputStream) throws -> Int {
        var buffer = [UInt8](repeating: 0, count: 3)
        if stream.read(&buffer, maxLength: 3) == 3 {
            var value = Int(buffer[0]) << 16
            value |= Int(buffer[1]) << 8
            value |= Int(buffer[2])
            return value
        }
        throw StreamError.read
    }


    private static func getInt32(_ stream: InputStream) throws -> Int32 {
        var buffer = [UInt8](repeating: 0, count: 4)
        if stream.read(&buffer, maxLength: 4) == 4 {
            var value = Int32(buffer[0]) << 24
            value |= Int32(buffer[1]) << 16
            value |= Int32(buffer[2]) << 8
            value |= Int32(buffer[3])
            return value
        }
        throw StreamError.read
    }


    private static func getUInt16(
            _ buffer: [UInt8], _ offset: inout Int) -> UInt16 {
        var value = UInt16(buffer[offset]) << 8
        value |= UInt16(buffer[offset + 1])
        offset += 2
        return value
    }


    private static func getInt16(
            _ buffer: [UInt8], _ offset: inout Int) -> Int16 {
        var value = Int16(buffer[offset]) << 8
        value |= Int16(buffer[offset + 1])
        offset += 2
        return value
    }


    private static func getInt32(
            _ buffer: [UInt8], _ offset: inout Int) -> Int32 {
        var value = Int32(buffer[offset]) << 24
        value |= Int32(buffer[offset + 1]) << 16
        value |= Int32(buffer[offset + 2]) << 8
        value |= Int32(buffer[offset + 3])
        offset += 4
        return value
    }

}   // End of FastFont.swift
