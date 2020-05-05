/**
 *  PDFobj.swift
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
/// Used to create Java or .NET objects that represent the objects in PDF document.
/// See the PDF specification for more information.
///
public class PDFobj {

    var number = 0                  // The object number
    var offset = 0                  // The object offset
    var dict = [String]()
    var stream_offset = 0
    var stream = [UInt8]()          // The compressed stream
    var data = [UInt8]()            // The decompressed data
    var gsNumber = -1


    init(_ offset: Int) {
        self.offset = offset
    }


    init() {
    }


    func getNumber() -> Int {
        return self.number
    }


    ///
    /// Returns the object dictionary.
    ///
    /// @return the object dictionary.
    ///
    public func getDict() -> [String] {
        return self.dict
    }


    func setDict(_ dict: inout [String]) {
        self.dict = dict
    }


    ///
    /// Returns the uncompressed stream data.
    ///
    /// @return the uncompressed stream data.
    ///
    public func getData() -> [UInt8] {
        return self.data
    }


    public func setData(_ data: inout [UInt8]) {
        self.data = data
    }


    public func getStream() -> [UInt8] {
        return self.stream
    }


    func setStream(_ pdf: inout [UInt8], _ length: Int) {
        stream = [UInt8]()
        var i = 0
        while i < length {
            stream.append(pdf[stream_offset + i])
            i += 1
        }
    }


    public func setStream(_ stream: inout [UInt8]) {
        self.stream = stream
    }


    func setNumber(_ number: Int) {
        self.number = number
    }


    ///
    /// Returns the dictionary value for the specified key.
    ///
    /// @param key the specified key.
    ///
    /// @return the value.
    ///
    public func getValue(_ key: String) -> String {
        var i = 0
        while i < dict.count {
            if key == dict[i] {
                if dict[i + 1] == "<<" {
                    var buffer = String()
                    buffer.append("<<")
                    buffer.append(" ")
                    i += 2
                    while dict[i] != ">>" {
                        buffer.append(dict[i])
                        buffer.append(" ")
                        i += 1
                    }
                    buffer.append(">>")
                    return buffer
                }
                if dict[i + 1] == "[" {
                    var buffer = String()
                    buffer.append("[")
                    buffer.append(" ")
                    i += 2
                    while dict[i] != "]" {
                        buffer.append(dict[i])
                        buffer.append(" ")
                        i += 1
                    }
                    buffer.append("]")
                    return buffer
                }
                return dict[i + 1]
            }
            i += 1
        }
        return ""
    }


    func getObjectNumbers(_ key: String) -> [Int] {
        var numbers = [Int]()
        var i = 0
        while i < dict.count {
            let token = dict[i]
            if token == key {
                i += 1
                if dict[i] == "[" {
                    while true {
                        i += 1
                        if dict[i] == "]" {
                            break
                        }
                        numbers.append(Int(dict[i])!)
                        i += 1  // 0
                        i += 1  // R
                    }
                }
                else {
                    numbers.append(Int(dict[i])!)
                }
                break

            }
            i += 1
        }
        return numbers
    }


    func getPageSize() -> [Float] {
        for i in 0..<dict.count {
            if dict[i] == "/MediaBox" {
                return [Float(dict[i + 4])!, Float(dict[i + 5])!]
            }
        }
        return Letter.PORTRAIT
    }


    func getLength(_ objects: inout [PDFobj]) -> Int? {
        for i in 0..<dict.count {
            if dict[i] == "/Length" {
                let number = Int(dict[i + 1])!
                if dict[i + 2] == "0" &&
                        dict[i + 3] == "R" {
                    return getLength(number, from: &objects)
                }
                else {
                    return number
                }
            }
        }
        return nil
    }


    private func getLength(
            _ number: Int,
            from objects: inout [PDFobj]) -> Int? {
        return Int(objects[number - 1].dict[3])
    }


    private func getObject(
            number: Int,
            from objects: inout [PDFobj]) -> PDFobj? {
        return objects[number - 1]
    }


    public func getContentsObject(_ objects: inout [PDFobj]) -> PDFobj? {
        for i in 0..<dict.count {
            if dict[i] == "/Contents" {
                if dict[i + 1] == "[" {
                    return getObject(number: Int(dict[i + 2])!, from: &objects)
                }
                return getObject(number: Int(dict[i + 1])!, from: &objects)
            }
        }
        return nil
    }


    func getResourcesObject(_ objects: inout [PDFobj]) -> PDFobj? {
        var i = 0
        while i < dict.count {
            if dict[i] == "/Resources" {
                var token = dict[i + 1]
                if token == "<<" {
                    let obj = PDFobj()
                    obj.dict.append("0")
                    obj.dict.append("0")
                    obj.dict.append("obj")
                    obj.dict.append(token)
                    var level: Int = 1
                    i += 1
                    while i < dict.count && level > 0 {
                        token = dict[i]
                        obj.dict.append(token)
                        if token == "<<" {
                            level += 1
                        }
                        else if token == ">>" {
                            level -= 1
                        }
                        i += 1
                    }
                    return obj
                }
                return getObject(number: Int(token)!, from: &objects)
            }
            i += 1
        }
        return nil
    }


    func addResource(
            _ coreFont: CoreFont,
            _ objects: inout [PDFobj]) -> Font {
        let font = Font(coreFont)
        font.fontID = font.name.replacingOccurrences(of: "-", with: "_").uppercased()

        let obj = PDFobj()
        obj.number = objects.last!.number + 1
        obj.dict.append("<<")
        obj.dict.append("/Type")
        obj.dict.append("/Font")
        obj.dict.append("/Subtype")
        obj.dict.append("/Type1")
        obj.dict.append("/BaseFont")
        obj.dict.append("/" + font.name)
        if font.name != "Symbol" && font.name != "ZapfDingbats" {
            obj.dict.append("/Encoding")
            obj.dict.append("/WinAnsiEncoding")
        }
        obj.dict.append(">>")

        objects.append(obj)

        var i = 0
        while i < dict.count {
            if dict[i] == "/Resources" {
                i += 1
                let token = dict[i]
                if token == "<<" {                  // Direct resources object
                    addFontResource(self, &objects, font.fontID!, obj.number)
                }
                else if firstCharIsDigit(token) {   // Indirect resources object
                    let object = getObject(number: Int(token)!, from: &objects)!
                    addFontResource(object, &objects, font.fontID!, obj.number)
                }
            }
            i += 1
        }

        return font
    }


    private func addFontResource(
            _ obj: PDFobj,
            _ objects: inout [PDFobj],
            _ fontID: String,
            _ number: Int) {

        var fonts: Bool = false
        var i = 0
        while i < obj.dict.count {
            if obj.dict[i] == "/Font" {
                fonts = true
            }
            i += 1
        }
        if !fonts {
            i = 0
            while i < obj.dict.count {
                if obj.dict[i] == "/Resources" {
                    obj.dict.insert("/Font", at: i + 2)
                    obj.dict.insert("<<", at: i + 3)
                    obj.dict.insert(">>", at: i + 4)
                    break
                }
                i += 1
            }
        }

        i = 0
        while i < obj.dict.count {
            if obj.dict[i] == "/Font" {
                let token = obj.dict[i + 1]
                if token == "<<" {
                    obj.dict.insert("/" + fontID, at: i + 2)
                    obj.dict.insert(String(number), at: i + 3)
                    obj.dict.insert("0", at: i + 4)
                    obj.dict.insert("R", at: i + 5)
                    return
                }
                else if firstCharIsDigit(token) {
                    let o2 = getObject(number: Int(token)!, from: &objects)!
                    var j = 0
                    while j < o2.dict.count {
                        if o2.dict[j] == "<<" {
                            o2.dict.insert("/" + fontID, at: j + 1)
                            o2.dict.insert(String(number), at: j + 2)
                            o2.dict.insert("0", at: j + 3)
                            o2.dict.insert("R", at: j + 4)
                            return
                        }
                        j += 1
                    }
                }
            }
            i += 1
        }
    }


    private func insertNewObject(
            _ dict: inout [String],
            _ list: inout [String],
            _ type: String) {
        for i in 0..<dict.count {
            if dict[i] == type {
                dict.insert(contentsOf: list, at: i + 2)
                return
            }
        }
        if dict[3] == "<<" {
            dict.insert(contentsOf: list, at: 4)
            return
        }
    }


    private func addResource(
            _ type: String,
            _ obj: PDFobj,
            _ objects: inout [PDFobj],
            _ objNumber: Int) {
        let tag = (type == "/Font") ? "/F" : "/Im"
        let number = String(objNumber)
        var list = [tag + number, number, "0", "R"]
        for i in 0..<obj.dict.count {
            if obj.dict[i] == type {
                let token = obj.dict[i + 1]
                if token == "<<" {
                    insertNewObject(&obj.dict, &list, type)
                }
                else {
                    let object = getObject(number: Int(token)!, from: &objects)!
                    insertNewObject(&object.dict, &list, type)
                }
                return
            }
        }

        // Handle the case where the page originally does not have any font resources.
        list = [type, "<<", tag + number, number, "0", "R", ">>"]
        for i in 0..<obj.dict.count {
            if obj.dict[i] == "/Resources" {
                obj.dict.insert(contentsOf: list, at: i + 2)
                return
            }
        }
        for i in 0..<obj.dict.count {
            if obj.dict[i] == "<<" {
                obj.dict.insert(contentsOf: list, at: i + 1)
                return
            }
        }
    }


    func addResource(
            _ image: Image,
            _ objects: inout [PDFobj]) {
        for i in 0..<dict.count {
            if dict[i] == "/Resources" {
                let token = dict[i + 1]
                if token == "<<" {      // Direct resources object
                    addResource("/XObject", self, &objects, image.objNumber!)
                }
                else {                  // Indirect resources object
                    let object = getObject(number: Int(token)!, from: &objects)!
                    addResource("/XObject", object, &objects, image.objNumber!)
                }
                return
            }
        }
    }


    func addResource(
            _ font: Font,
            _ objects: inout [PDFobj]) {
        for i in 0..<dict.count {
            if dict[i] == "/Resources" {
                let token = dict[i + 1]
                if token == "<<" {      // Direct resources object
                    addResource("/Font", self, &objects, font.objNumber)
                }
                else {                  // Indirect resources object
                    let object = getObject(number: Int(token)!, from: &objects)!
                    addResource("/Font", object, &objects, font.objNumber)
                }
                return
            }
        }
    }


    private func firstCharIsDigit(_ str: String) -> Bool {
        for scalar in str.unicodeScalars {
            if CharacterSet.decimalDigits.contains(scalar) {
                return true
            }
            break
        }
        return false
    }


    public func addContent(_ content: inout [UInt8], _ objects: inout [PDFobj]) {
        let obj = PDFobj()
        obj.setNumber(objects.last!.number + 1)
        obj.setStream(&content)
        objects.append(obj)

        let objNumber = String(obj.number)
        var i = 0
        while i < dict.count {
            if dict[i] == "/Contents" {
                i += 1
                var token = dict[i]
                if token == "[" {
                    while true {
                        i += 1
                        token = dict[i]
                        if token == "]" {
                            dict.insert("R", at: i)
                            dict.insert("0", at: i)
                            dict.insert(objNumber, at: i)
                            return
                        }
                        i += 2  // Skip the 0 and R
                    }
                }
                else {
                    // Single content object
                    let obj2 = objects[Int(token)! - 1]
                    if obj2.data.count == 0 && obj2.stream.count == 0 {
                        // This is not a stream object!
                        var j = 0
                        while j < obj2.dict.count {
                            if obj2.dict[j] == "]" {
                                obj2.dict.insert("R", at: j)
                                obj2.dict.insert("0", at: j)
                                obj2.dict.insert(objNumber, at: j)
                                return
                            }
                            j += 1
                        }
                    }
                    dict.insert("[", at: i)
                    dict.insert("]", at: i + 4)
                    dict.insert("R", at: i + 4)
                    dict.insert("0", at: i + 4)
                    dict.insert(objNumber, at: i + 4)
                    return
                }
            }
            i += 1
        }
    }


    ///
    /// Adds new content object before the existing content objects.
    /// The original code was provided by Stefan Ostermann author of ScribMaster and HandWrite Pro.
    /// Additional code to handle PDFs with indirect array of stream objects was written by EDragoev.
    ///
    /// @param content
    /// @param objects
    ///
    public func addPrefixContent(_ content: inout [UInt8], _ objects: inout [PDFobj]) {
        let obj = PDFobj()
        obj.setNumber(objects.last!.number + 1)
        obj.setStream(&content)
        objects.append(obj)

        let objNumber = String(obj.number)
        var i = 0
        while i < dict.count {
            if dict[i] == "/Contents" {
                i += 1
                let token = dict[i]
                if token == "[" {
                    // Array of content object streams
                    i += 1
                    dict.insert("R", at: i)
                    dict.insert("0", at: i)
                    dict.insert(objNumber, at: i)
                    return
                }
                else {
                    // Single content object
                    let obj2 = objects[Int(token)! - 1]
                    if obj2.data.count == 0 && obj2.stream.count == 0 {
                        // This is not a stream object!
                        var j = 0
                        while j < obj2.dict.count {
                            if obj2.dict[j] == "[" {
                                j += 1
                                obj2.dict.insert("R", at: j)
                                obj2.dict.insert("0", at: j)
                                obj2.dict.insert(objNumber, at: j)
                                return
                            }
                            j += 1
                        }
                    }
                    dict.insert("[", at: i)
                    dict.insert("]", at: i + 4)
                    i += 1
                    dict.insert("R", at: i)
                    dict.insert("0", at: i)
                    dict.insert(objNumber, at: i)
                    return
                }
            }
            i += 1
        }
    }


    private func getMaxGSNumber(_ obj: PDFobj) -> Int {
        var numbers = [Int]()
        for token in obj.dict {
            if token == "/GS" {
                numbers.append(Int(String(token.dropFirst(3)))!)
            }
        }
        if numbers.count == 0 {
            return 0
        }
        return numbers.last!
    }


    public func setGraphicsState(_ gs: GraphicsState, _ objects: inout [PDFobj]) {
        var obj: PDFobj?
        var index = -1
        var i = 0
        while i < dict.count {
            if dict[i] == "/Resources" {
                let token = dict[i + 1]
                if token == "<<" {
                    obj = self
                    index = i + 2
                }
                else {
                    obj = objects[Int(token)! - 1]
                    var j = 0
                    while j < obj!.dict.count {
                        if obj!.dict[j] == "<<" {
                            index = j + 1
                            break
                        }
                        j += 1
                    }
                }
                break
            }
            i += 1
        }

        gsNumber = getMaxGSNumber(obj!)
        if gsNumber == 0 {                              // No existing ExtGState dictionary
            obj!.dict.insert("/ExtGState", at: index)   // Add ExtGState dictionary
            index += 1
            obj!.dict.insert("<<", at: index)
        }
        else {
            while index < obj!.dict.count {
                let token = obj!.dict[index]
                if token == "/ExtGState" {
                    index += 1
                    break
                }
                index += 1
            }
        }
        index += 1
        obj!.dict.insert("/GS" + String(gsNumber + 1), at: index)
        index += 1
        obj!.dict.insert("<<", at: index)
        index += 1
        obj!.dict.insert("/CA", at: index)
        index += 1
        obj!.dict.insert(String(gs.get_CA()), at: index)
        index += 1
        obj!.dict.insert("/ca", at: index)
        index += 1
        obj!.dict.insert(String(gs.get_ca()), at: index)
        index += 1
        obj!.dict.insert(">>", at: index)
        if gsNumber == 0 {
            index += 1
            obj!.dict.insert(">>", at: index)
        }

        var buf = String()
        buf.append("q\n")
        buf.append("/GS" + String(gsNumber + 1) + " gs\n")
        var array = Array(buf.utf8)
        addPrefixContent(&array, &objects)
    }

}
