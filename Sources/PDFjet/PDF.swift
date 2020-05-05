/**
 *  PDF.swift
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
/// Used to create PDF objects that represent PDF documents.
///
///
public class PDF {

    private let eval = false

    var objNumber = 0
    var metadataObjNumber = 0
    var outputIntentObjNumber = 0
    var fonts = [Font]()
    var images = [Image]()
    var pages = [Page]()
    var destinations = [String : Destination]()
    var groups = [OptionalContentGroup]()
    var states = [String : Int]()
    let formatter = NumberFormatter()
    var compliance = 0
    var embeddedFiles = [EmbeddedFile]()
    var toc: Bookmark?
    var importedFonts = [String]()
    var extGState = ""

    private var os: OutputStream?
    private var objOffset = [Int]()
    private var title: String = ""
    private var author: String = ""
    private var subject: String = ""
    private var keywords: String = ""
    private var creator: String = ""
    private var producer = "PDFjet v6.05 (http://pdfjet.com)"
    private var creationDate: String?
    private var modDate: String?
    private var createDate: String?
    private var byte_count = 0
    private var pagesObjNumber = -1
    private var pageLayout: String?
    private var pageMode: String?
    private var language: String = "en-US"


    ///
    /// The default constructor - use when reading PDF files.
    ///
    public init() {
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 3
    }


    ///
    /// Creates a PDF object that represents a PDF document.
    ///
    /// - Parameter os the associated output stream.
    ///
    public convenience init(_ os: OutputStream) {
        self.init(os, 0)
    }


    /// Here is the layout of the PDF document:
    ///
    /// Metadata Object
    /// Output Intent Object
    /// Fonts
    /// Images
    /// Resources Object
    /// Content1
    /// Content2
    /// ...
    /// ContentN
    /// Annot1
    /// Annot2
    /// ...
    /// AnnotN
    /// Page1
    /// Page2
    /// ...
    /// PageN
    /// Pages
    /// StructElem1
    /// StructElem2
    /// ...
    /// StructElemN
    /// StructTreeRoot
    /// Info
    /// Root
    /// xref table
    /// Trailer
    ///
    /// Creates a PDF object that represents a PDF document.
    /// Use this constructor to create PDF/A compliant PDF documents.
    /// Please note: PDF/A compliance requires all fonts to be embedded in the PDF.
    ///
    /// - Parameter os the associated output stream.
    /// - Parameter compliance must be: Compliance.PDF_A_1B
    ///
    public init(_ os: OutputStream, _ compliance: Int) {
        os.open()
        self.os = os
        self.compliance = compliance

        let date = Date()

        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyyMMddhhmmss"

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"

        self.creationDate = dateFormatter1.string(from: date)
        self.modDate = dateFormatter1.string(from: date)
        self.createDate = dateFormatter2.string(from: date)

        append("%PDF-1.5\n")
        append("%")
        append(UInt8(0x00F2))
        append(UInt8(0x00F3))
        append(UInt8(0x00F4))
        append(UInt8(0x00F5))
        append(UInt8(0x00F6))
        append("\n")

        if compliance == Compliance.PDF_A_1B ||
                compliance == Compliance.PDF_UA {
            metadataObjNumber = addMetadataObject("", false)
            outputIntentObjNumber = addOutputIntentObject()
        }
    }


    func newobj() {
        objOffset.append(byte_count)
        objNumber += 1
        append(objNumber)
        append(" 0 obj\n")
    }


    func endobj() {
        append("endobj\n")
    }


    func addMetadataObject(_ notice: String, _ fontMetadataObject: Bool) -> Int {
        var sb = String()
        sb.append("<?xpacket begin='\u{FEFF}' id=\"W5M0MpCehiHzreSzNTczkc9d\"?>\n")
        sb.append("<x:xmpmeta xmlns:x=\"adobe:ns:meta/\">\n")
        sb.append("<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n")

        if fontMetadataObject {
            sb.append("<rdf:Description rdf:about=\"\" xmlns:xmpRights=\"http://ns.adobe.com/xap/1.0/rights/\">\n")
            sb.append("<xmpRights:UsageTerms>\n")
            sb.append("<rdf:Alt>\n")
            sb.append("<rdf:li xml:lang=\"x-default\">\n")
            sb.append(notice)
            sb.append("</rdf:li>\n")
            sb.append("</rdf:Alt>\n")
            sb.append("</xmpRights:UsageTerms>\n")
            sb.append("</rdf:Description>\n")
        }
        else {
            sb.append("<rdf:Description rdf:about=\"\" xmlns:pdf=\"http://ns.adobe.com/pdf/1.3/\" pdf:Producer=\"")
            sb.append(producer)
            sb.append("\">\n</rdf:Description>\n")

            sb.append("<rdf:Description rdf:about=\"\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\">\n")
            sb.append("  <dc:format>application/pdf</dc:format>\n")
            sb.append("  <dc:title><rdf:Alt><rdf:li xml:lang=\"x-default\">")
            sb.append(title)
            sb.append("</rdf:li></rdf:Alt></dc:title>\n")
            sb.append("  <dc:creator><rdf:Seq><rdf:li>")
            sb.append(author)
            sb.append("</rdf:li></rdf:Seq></dc:creator>\n")
            sb.append("  <dc:description><rdf:Alt><rdf:li xml:lang=\"x-default\">")
            sb.append(subject)
            sb.append("</rdf:li></rdf:Alt></dc:description>\n")
            sb.append("</rdf:Description>\n")

            sb.append("<rdf:Description rdf:about=\"\" xmlns:pdfaid=\"http://www.aiim.org/pdfa/ns/id/\">\n")
            sb.append("  <pdfaid:part>1</pdfaid:part>\n")
            sb.append("  <pdfaid:conformance>B</pdfaid:conformance>\n")
            sb.append("</rdf:Description>\n")

            if compliance == Compliance.PDF_UA {
                sb.append("<rdf:Description rdf:about=\"\" xmlns:pdfuaid=\"http://www.aiim.org/pdfua/ns/id/\">\n")
                sb.append("  <pdfuaid:part>1</pdfuaid:part>\n")
                sb.append("</rdf:Description>\n")
            }

            sb.append("<rdf:Description rdf:about=\"\" xmlns:xmp=\"http://ns.adobe.com/xap/1.0/\">\n")
            sb.append("<xmp:CreateDate>")
            sb.append(createDate! + "Z")
            sb.append("</xmp:CreateDate>\n")
            sb.append("</rdf:Description>\n")
        }

        sb.append("</rdf:RDF>\n")
        sb.append("</x:xmpmeta>\n")

        if !fontMetadataObject {
            // Add the recommended 2000 bytes padding
            for _ in 0..<20 {
                for _ in 0..<10 {
                    sb.append("          ")
                }
                sb.append("\n")
            }
        }

        sb.append("<?xpacket end=\"w\"?>")

        // This is the metadata object
        newobj()
        append("<<\n")
        append("/Type /Metadata\n")
        append("/Subtype /XML\n")
        append("/Length ")
        append(sb.count)
        append("\n")
        append(">>\n")
        append("stream\n")
        append(sb)
        append("\nendstream\n")
        endobj()

        return self.objNumber
    }


    func addOutputIntentObject() -> Int {
        newobj()
        append("<<\n")
        append("/N 3\n")

        append("/Length ")
        append(ICCBlackScaled.profile.count)
        append("\n")

        append("/Filter /FlateDecode\n")
        append(">>\n")
        append("stream\n")
        append(ICCBlackScaled.profile, 0, ICCBlackScaled.profile.count)
        append("\nendstream\n")
        endobj()

        // OutputIntent object
        newobj()
        append("<<\n")
        append("/Type /OutputIntent\n")
        append("/S /GTS_PDFA1\n")
        append("/OutputCondition (sRGB IEC61966-2.1)\n")
        append("/OutputConditionIdentifier (sRGB IEC61966-2.1)\n")
        append("/Info (sRGB IEC61966-2.1)\n")
        append("/DestOutputProfile ")
        append(objNumber - 1)
        append(" 0 R\n")
        append(">>\n")
        endobj()

        return self.objNumber
    }


    private func addResourcesObject() -> Int {
        newobj()
        append("<<\n")

        if extGState != "" {
            append(extGState)
        }
        if fonts.count > 0 || importedFonts.count > 0 {
            append("/Font\n")
            append("<<\n")
            for token in importedFonts {
                append(token)
                if token == "R" {
                    append("\n")
                }
                else {
                    append(" ")
                }
            }
            for font in fonts {
                append("/F")
                append(font.objNumber)
                append(" ")
                append(font.objNumber)
                append(" 0 R\n")
            }
            append(">>\n")
        }

        if images.count > 0 {
            append("/XObject\n")
            append("<<\n")
            for image in images {
                append("/Im")
                append(image.objNumber!)
                append(" ")
                append(image.objNumber!)
                append(" 0 R\n")
            }
            append(">>\n")
        }

        if groups.count > 0 {
            append("/Properties\n")
            append("<<\n")
            for i in 0..<groups.count {
                let ocg = groups[i]
                append("/OC")
                append(i + 1)
                append(" ")
                append(ocg.objNumber)
                append(" 0 R\n")
            }
            append(">>\n")
        }

        // String state = "/CA 0.5 /ca 0.5"
        if states.count > 0 {
            append("/ExtGState <<\n")
            for state in states.keys {
                append("/GS")
                append(states[state]!)
                append(" << ")
                append(state)
                append(" >>\n")
            }
            append(">>\n")
        }

        append(">>\n")
        endobj()
        return objNumber
    }


    @discardableResult
    private func addPagesObject() -> Int {
        newobj()
        append("<<\n")
        append("/Type /Pages\n")
        append("/Kids [\n")
        for page in pages {
            if compliance == Compliance.PDF_UA {
                page.setStructElementsPageObjNumber(page.objNumber)
            }
            append(page.objNumber)
            append(" 0 R\n")
        }
        append("]\n")
        append("/Count ")
        append(pages.count)
        append("\n")
        append(">>\n")
        endobj()
        return objNumber
    }


    private func addInfoObject() -> Int {
        // Add the info object
        newobj()
        append("<<\n")
        append("/Title <")
        append(toHex(title))
        append(">\n")
        append("/Author <")
        append(toHex(author))
        append(">\n")
        append("/Subject <")
        append(toHex(subject))
        append(">\n")
        append("/Keywords <")
        append(toHex(keywords))
        append(">\n")
        append("/Creator <")
        append(toHex(creator))
        append(">\n")
        append("/Producer (")
        append(producer)
        append(")\n")
        append("/CreationDate (D:")
        append(self.creationDate!)
        append("Z)\n")
        append("/ModDate (D:")
        append(self.modDate!)
        append("Z)\n")
        append(">>\n")
        endobj()
        return self.objNumber
    }


    private func addStructTreeRootObject() -> Int {
        newobj()
        append("<<\n")
        append("/Type /StructTreeRoot\n")
        append("/K [\n")
        for page in pages {
            for structure in page.structures {
                append(structure.objNumber!)
                append(" 0 R\n")
            }
        }
        append("]\n")
        append("/ParentTree ")
        append(objNumber + 1)
        append(" 0 R\n")
        append(">>\n")
        endobj()
        return self.objNumber
    }


    private func addStructElementObjects() {
        var structTreeRootObjNumber = objNumber + 1
        for page in pages {
            structTreeRootObjNumber += page.structures.count
        }

        for page in pages {
            for element in page.structures {
                newobj()
                element.objNumber = objNumber
                append("<<\n")
                append("/Type /StructElem\n")
                append("/S /")
                append(element.structure!)
                append("\n")
                append("/P ")
                append(structTreeRootObjNumber)
                append(" 0 R\n")
                append("/Pg ")
                append(element.pageObjNumber!)
                append(" 0 R\n")
                if element.annotation == nil {
                    append("/K ")
                    append(element.mcid)
                    append("\n")
                }
                else {
                    append("/K <<\n")
                    append("/Type /OBJR\n")
                    append("/Obj ")
                    append(element.annotation!.objNumber)
                    append(" 0 R\n")
                    append(">>\n")
                }
                if element.language != nil {
                    append("/Lang (")
                    append(element.language!)
                    append(")\n")
                }
                append("/Alt <")
                append(toHex(element.altDescription!))
                append(">\n")
                append("/ActualText <")
                append(toHex(element.actualText!))
                append(">\n")
                append(">>\n")
                endobj()
            }
        }
    }


    private func addNumsParentTree() {
        newobj()
        append("<<\n")
        append("/Nums [\n")
        for i in 0..<pages.count {
            let page = pages[i]
            append(i)
            append(" [\n")
            for element in page.structures {
                if element.annotation == nil {
                    append(element.objNumber!)
                    append(" 0 R\n")
                }
            }
            append("]\n")
        }

        var index = pages.count
        for page in pages {
            for element in page.structures {
                if element.annotation != nil {
                    append(index)
                    append(" ")
                    append(element.objNumber!)
                    append(" 0 R\n")
                    index += 1
                }
            }
        }
        append("]\n")
        append(">>\n")
        endobj()
    }


    private func addRootObject(
            _ structTreeRootObjNumber: Int,
            _ outlineDictNumber: Int) -> Int {
        // Add the root object
        newobj()
        append("<<\n")
        append("/Type /Catalog\n")

        if compliance == Compliance.PDF_UA {
            append("/Lang (")
            append(language)
            append(")\n")

            append("/StructTreeRoot ")
            append(structTreeRootObjNumber)
            append(" 0 R\n")

            append("/MarkInfo <</Marked true>>\n")
            append("/ViewerPreferences <</DisplayDocTitle true>>\n")
        }

        if pageLayout != nil {
            append("/PageLayout /")
            append(pageLayout!)
            append("\n")
        }

        if pageMode != nil {
            append("/PageMode /")
            append(pageMode!)
            append("\n")
        }

        if !groups.isEmpty {
            addOCProperties()
        }

        append("/Pages ")
        append(pagesObjNumber)
        append(" 0 R\n")

        if compliance == Compliance.PDF_A_1B ||
                compliance == Compliance.PDF_UA {
            append("/Metadata ")
            append(metadataObjNumber)
            append(" 0 R\n")

            append("/OutputIntents [")
            append(outputIntentObjNumber)
            append(" 0 R]\n")
        }

        if outlineDictNumber > 0 {
            append("/Outlines ")
            append(outlineDictNumber)
            append(" 0 R\n")
        }

        append(">>\n")
        endobj()
        return objNumber
    }


    private func addPageBox(
            _ boxName: String,
            _ page: Page,
            _ rect: [Float]) {
        append("/")
        append(boxName)
        append(" [")
        append(rect[0])
        append(" ")
        append(page.height - rect[3])
        append(" ")
        append(rect[2])
        append(" ")
        append(page.height - rect[1])
        append("]\n")
    }


    private func setDestinationObjNumbers() {
        var numberOfAnnotations = 0
        for page in pages {
            numberOfAnnotations += page.annots!.count
        }
        for i in 0..<pages.count {
            let page = pages[i]
            for destination in page.destinations! {
                destination.pageObjNumber = objNumber + numberOfAnnotations + i + 1
                destinations[destination.name!] = destination
            }
        }
    }


    private func addAllPages(_ resObjNumber: Int) {

        setDestinationObjNumbers()
        addAnnotDictionaries()

        // Calculate the object number of the Pages object
        pagesObjNumber = objNumber + pages.count + 1

        for i in 0..<pages.count {
            let page = pages[i]

            // Page object
            newobj()
            page.objNumber = objNumber
            append("<<\n")
            append("/Type /Page\n")
            append("/Parent ")
            append(pagesObjNumber)
            append(" 0 R\n")
            append("/MediaBox [0 0 ")
            append(Int(page.width))
            append(" ")
            append(Int(page.height))
            append("]\n")

            if page.cropBox != nil {
                addPageBox("CropBox", page, page.cropBox!)
            }
            if page.bleedBox != nil {
                addPageBox("BleedBox", page, page.bleedBox!)
            }
            if page.trimBox != nil {
                addPageBox("TrimBox", page, page.trimBox!)
            }
            if page.artBox != nil {
                addPageBox("ArtBox", page, page.artBox!)
            }

            append("/Resources ")
            append(resObjNumber)
            append(" 0 R\n")

            append("/Contents [ ")
            for n in page.contents {
                append(n)
                append(" 0 R ")
            }
            append("]\n")
            if page.annots!.count > 0 {
                append("/Annots [ ")
                for annot in page.annots! {
                    append(annot.objNumber)
                    append(" 0 R ")
                }
                append("]\n")
            }

            if compliance == Compliance.PDF_UA {
                append("/Tabs /S\n")
                append("/StructParents ")
                append(i)
                append("\n")
            }

            append(">>\n")
            endobj()
        }
    }

/*
    // Use this method on systems that don't have Deflater stream or when troubleshooting.
    private func addPageContent(_ page: inout Page) {
        newobj()
        append("<<\n")
        append("/Length ")
        append(page.buf.count)
        append("\n")
        append(">>\n")
        append("stream\n")
        append(page.buf)
        append("\nendstream\n")
        endobj()
        page.contents.append(objNumber)
    }
*/

    private func addPageContent(_ page: inout Page) {
        var buffer = [UInt8]()
        // let time0 = Int64(Date().timeIntervalSince1970 * 1000)
        _ = LZWEncode(&buffer, &page.buf)
        // _ = FlateEncode(&buffer, &page.buf, RLE: false)
        // let time1 = Int64(Date().timeIntervalSince1970 * 1000)
        // print(time1 - time0)
        page.buf.removeAll()   // Release the page content memory!

        newobj()
        append("<<\n")
        append("/Filter /LZWDecode\n")
        // append("/Filter /FlateDecode\n")
        append("/Length ")
        append(buffer.count)
        append("\n")
        append(">>\n")
        append("stream\n")
        append(buffer)
        append("\nendstream\n")
        endobj()
        page.contents.append(objNumber)
    }


    @discardableResult
    private func addAnnotationObject(
            _ annot: Annotation,
            _ index: Int) -> Int {
        var index2 = index
        newobj()
        annot.objNumber = objNumber
        append("<<\n")
        append("/Type /Annot\n")
        if annot.fileAttachment != nil {
            append("/Subtype /FileAttachment\n")
            append("/T (")
            append(annot.fileAttachment!.title)
            append(")\n")
            append("/Contents (")
            append(annot.fileAttachment!.contents)
            append(")\n")
            append("/FS ")
            append(annot.fileAttachment!.embeddedFile!.objNumber)
            append(" 0 R\n")
            append("/Name /")
            append(annot.fileAttachment!.icon)
            append("\n")
        }
        else {
            append("/Subtype /Link\n")
        }
        append("/Rect [")
        append(annot.x1)
        append(" ")
        append(annot.y1)
        append(" ")
        append(annot.x2)
        append(" ")
        append(annot.y2)
        append("]\n")
        append("/Border [0 0 0]\n")
        if annot.uri != nil {
            append("/F 4\n")
            append("/A <<\n")
            append("/S /URI\n")
            append("/URI (")
            append(annot.uri!)
            append(")\n")
            append(">>\n")
        }
        else if annot.key != nil {
            let destination = destinations[annot.key!]
            if destination != nil {
                append("/F 4\n")    // No Zoom
                append("/Dest [")
                append(destination!.pageObjNumber)
                append(" 0 R /XYZ 0 ")
                append(destination!.yPosition)
                append(" 0]\n")
            }
        }
        if index2 != -1 {
            append("/StructParent ")
            append(index2)
            index2 += 1
            append("\n")
        }
        append(">>\n")
        endobj()

        return index2
    }


    private func addAnnotDictionaries() {
        var index = self.pages.count
        for page in self.pages {
            if page.structures.count > 0 {
                for element in page.structures {
                    if element.annotation != nil {
                        index = addAnnotationObject(element.annotation!, index)
                    }
                }
            }
            else if page.annots!.count > 0 {
                for annotation in page.annots! {
                    addAnnotationObject(annotation, -1)
                }
            }
        }
    }


    private func addOCProperties() {
        var buf = String()
        for ocg in self.groups {
            buf.append(" ")
            buf.append(String(ocg.objNumber))
            buf.append(" 0 R")
        }

        append("/OCProperties\n")
        append("<<\n")
        append("/OCGs [")
        append(buf)
        append(" ]\n")
        append("/D <<\n")

        append("/AS [\n")
        append("<< /Event /View /Category [/View] /OCGs [")
        append(buf)
        append(" ] >>\n")
        append("<< /Event /Print /Category [/Print] /OCGs [")
        append(buf)
        append(" ] >>\n")
        append("<< /Event /Export /Category [/Export] /OCGs [")
        append(buf)
        append(" ] >>\n")
        append("]\n")

        append("/Order [[ ()")
        append(buf)
        append(" ]]\n")

        append(">>\n")
        append(">>\n")
    }


    public func addPage(_ page: Page) {
        let n = pages.count
        if n > 0 {
            addPageContent(&pages[n - 1])
        }
        pages.append(page)
    }


    ///
    /// Writes the PDF object to the output stream.
    /// Does not close the underlying output stream.
    ///
    public func flush() {
        flush(false)
    }


    ///
    /// Writes the PDF object to the output stream and closes it.
    ///
    public func close() {
        flush(true)
    }


    private func flush(_ close: Bool) {
        if pagesObjNumber == -1 {
            addPageContent(&pages[pages.count - 1])
            addAllPages(addResourcesObject())
            addPagesObject()
        }

        var structTreeRootObjNumber = 0
        if compliance == Compliance.PDF_UA {
            addStructElementObjects()
            structTreeRootObjNumber = addStructTreeRootObject()
            addNumsParentTree()
        }

        var outlineDictNum = 0
        if toc != nil && toc!.getChildren() != nil {
            var list: [Bookmark] = toc!.toArrayList()
            outlineDictNum = addOutlineDict(toc!)
            var i = 1
            while i < list.count {
                let bookmark = list[i]
                addOutlineItem(outlineDictNum, i, bookmark)
                i += 1
            }
        }

        let infoObjNumber = addInfoObject()
        let rootObjNumber = addRootObject(structTreeRootObjNumber, outlineDictNum)

        let startxref = byte_count

        // Create the xref table
        append("xref\n")
        append("0 ")
        append(rootObjNumber + 1)
        append("\n")

        append("0000000000 65535 f \n")
        for offset in objOffset {
            let str = String(offset)
            for _ in 0..<(10 - str.count) {
                append("0")
            }
            append(str)
            append(" 00000 n \n")
        }
        append("trailer\n")
        append("<<\n")
        append("/Size ")
        append(rootObjNumber + 1)
        append("\n")

        let id: String = Salsa20().getID()
        append("/ID[<")
        append(id)
        append("><")
        append(id)
        append(">]\n")

        append("/Info ")
        append(infoObjNumber)
        append(" 0 R\n")

        append("/Root ")
        append(rootObjNumber)
        append(" 0 R\n")

        append(">>\n")
        append("startxref\n")
        append(startxref)
        append("\n")
        append("%%EOF\n")

        if close {
            os!.close()
        }
    }


    ///
    /// Set the "Title" document property of the PDF file.
    /// - Parameter title The title of this document.
    ///
    public func setTitle(_ title: String) {
        self.title = title
    }


    ///
    /// Set the "Author" document property of the PDF file.
    /// - Parameter author The author of this document.
    ///
    public func setAuthor(_ author: String) {
        self.author = author
    }


    ///
    /// Set the "Subject" document property of the PDF file.
    /// - Parameter subject The subject of this document.
    ///
    public func setSubject(_ subject: String) {
        self.subject = subject
    }


    ///
    /// Set the "Keywords" document property of the PDF file.
    /// - Parameter keywords The author of this document.
    ///
    public func setKeywords(_ keywords: String) {
        self.keywords = keywords
    }


    ///
    /// Set the "Creator" document property of the PDF file.
    /// - Parameter creator The author of this document.
    ///
    public func setCreator(_ creator: String) {
        self.creator = creator
    }


    public func setPageLayout(_ pageLayout: String) {
        self.pageLayout = pageLayout
    }


    public func setPageMode(_ pageMode: String) {
        self.pageMode = pageMode
    }


    func append(_ number: UInt8) {
        var buffer = number
        if os!.write(&buffer, maxLength: 1) == 1 {
            self.byte_count += 1
        }
    }


    func append(_ number: Int) {
        append(String(number))
    }


    func append(_ number: Int32) {
        append(String(number))
    }


    func append(_ number: UInt32) {
        append(String(number))
    }


    func append(_ val: Float) {
        append(formatter.string(from: NSNumber(value: val))!)
    }


    func append(_ str: String) {
        append(Array(str.utf8))
    }


    func append(_ buf: [UInt8], _ off: Int, _ len: Int) {
        if os!.write(buf, maxLength: len) == len {
            self.byte_count += len
        }
    }


    func append(_ buf: [UInt8]) {
        if os!.write(buf, maxLength: buf.count) == buf.count {
            self.byte_count += buf.count
        }
    }


    ///
    /// Returns a list of objects of type PDFobj read from input stream.
    ///
    /// - Parameter inputStream the PDF input stream.
    ///
    /// - Returns: [PDFobj] the list of PDF objects.
    ///
    public func read(_ pdfObjects: inout [PDFobj], from stream: InputStream) throws {

        var buffer1 = [UInt8]()
        var buffer2 = [UInt8](repeating: 0, count: 8192)
        stream.open()
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer2, maxLength: buffer2.count)
            if count > 0 {
                buffer1.append(contentsOf:  buffer2[0..<count])
            }
        }
        stream.close()

        var objects1 = [PDFobj]()
        let xref = getStartXRef(&buffer1)
        let obj1 = getObject(&buffer1, xref, buffer1.count)
        if obj1.dict[0] == "xref" {
            // Get the objects using xref table
            getObjects1(&buffer1, obj1, &objects1)
        }
        else {
            // Get the objects using XRef stream
            try getObjects2(&buffer1, obj1, &objects1)
        }

        var objects2 = [PDFobj]()
        for obj in objects1 {
            if obj.dict.contains("stream") {
                let length = obj.getLength(&objects1)!
                obj.setStream(&buffer1, length)
                if obj.getValue("/Filter") == "/FlateDecode" {
                    _ = try Puff(output: &obj.data, input: &obj.stream, inflate: false)
                    _ = try Puff(output: &obj.data, input: &obj.stream, inflate: true)
                }
                else {
                    // Assume no compression
                    obj.data = obj.stream
                }
            }

            if obj.getValue("/Type") == "/ObjStm" {
                let first = Int(obj.getValue("/First"))!
                let o2 = getObject(&obj.data, 0, first)
                var i = 0
                while i < o2.dict.count {
                    let num = o2.dict[i]
                    let off = o2.dict[i + 1]
                    var end = obj.data.count
                    if i <= o2.dict.count - 4 {
                        end = first + Int(o2.dict[i + 3])!
                    }
                    let o3 = getObject(&obj.data, first + Int(off)!, end)
                    o3.number = Int(num)!
                    o3.dict.insert(contentsOf: [num, "0", "obj"], at: 0)
                    objects2.append(o3)
                    i += 2
                }
            }
            else if obj.getValue("/Type") == "/XRef" {
                // Skip the stream XRef object.
            }
            else {
                objects2.append(obj)
            }
        }

        var maxObjNumber = 0
        for object in objects2 {
            if object.number > maxObjNumber {
                maxObjNumber = object.number
            }
        }

        for number in 1...maxObjNumber {
            let object = PDFobj()
            object.setNumber(number)
            pdfObjects.append(object)
        }

        for object in objects2 {
            if object.number > 0 {
                pdfObjects[object.number - 1] = object
            }
        }
    }


    private func process(
            _ obj: inout PDFobj,
            _ token: inout [UInt8],
            _ buffer: [UInt8],
            _ offset: Int) -> Bool {
        if token.count == 0 {
            return false
        }
        let str = String(bytes: token, encoding: .ascii)!.trim()
        if str != "" {
            obj.dict.append(str)
        }
        token.removeAll()

        if str == "endobj" {
            return true
        }
        if str == "stream" {
            obj.stream_offset = offset
            if buffer[offset] == 0x0A {     // "\n"
                obj.stream_offset += 1
            }
            return true
        }
        if str == "startxref" {
            return true
        }
        return false
    }


    private func getObject(
            _ buf: inout [UInt8],
            _ off: Int,
            _ len: Int) -> PDFobj {

        var offset = off

        var obj = PDFobj(offset)
        var token = [UInt8]()

        var p1 = 0
        var c1: UInt8 = 0x20            // Space
        var done = false
        while !done && offset < len {
            let c2 = buf[offset]
            offset += 1
            if c2 == 0x28 {             // "("
                if p1 == 0 {
                    done = process(&obj, &token, buf, offset)
                }
                if !done {
                    token.append(c2)
                    p1 += 1
                }
            }
            else if c2 == 0x29 {        // ")"
                token.append(c2)
                p1 -= 1
                if p1 == 0 {
                    done = process(&obj, &token, buf, offset)
                }
            }
            else if c2 == 0x00          // NULL
                    || c2 == 0x09       // Horizontal Tab
                    || c2 == 0x0A       // Line Feed (LF)
                    || c2 == 0x0C       // Form Feed
                    || c2 == 0x0D       // Carriage Return (CR)
                    || c2 == 0x20 {     // Space
                done = process(&obj, &token, buf, offset)
                if !done {
                    c1 = 0x20
                }
            }
            else if c2 == 0x2F {        // "/"
                done = process(&obj, &token, buf, offset)
                if !done {
                    token.append(c2)
                    c1 = c2
                }
            }
            else if c2 == 0x3C ||       // "<"
                    c2 == 0x3E ||       // ">"
                    c2 == 0x25 {        // "%"
                if c2 != c1 {
                    done = process(&obj, &token, buf, offset)
                    if !done {
                        token.append(c2)
                        c1 = c2
                    }
                }
                else {
                    token.append(c2)
                    done = process(&obj, &token, buf, offset)
                    if !done {
                        c1 = 0x20       // Space
                    }
                }
            }
            else if c2 == 0x5B ||       // "["
                    c2 == 0x5D ||       // "]"
                    c2 == 0x7B ||       // "{"
                    c2 == 0x7D {        // "}"
                done = process(&obj, &token, buf, offset)
                if !done {
                    if c2 == 0x5B {
                        obj.dict.append("[")
                    }
                    else if c2 == 0x5D {
                        obj.dict.append("]")
                    }
                    else if c2 == 0x7B {
                        obj.dict.append("{")
                    }
                    else if c2 == 0x7D {
                        obj.dict.append("}")
                    }
                    c1 = c2
                }
            }
            else {
                token.append(c2)
                if p1 == 0 {
                    c1 = c2
                }
            }
        }

        return obj
    }


    ///
    /// Converts an array of bytes to an integer.
    /// - Parameter buf byte[]
    /// - Returns: int
    ///
    private func toInt(
            _ buf: inout [UInt8],
            _ off: Int,
            _ len: Int) -> Int {
        var n = 0
        var i = 0
        while i < len {
            n |= Int(buf[off + i]) & 0xFF
            if i < (len - 1) {
                n = n &<< 8
            }
            i += 1
        }
        return n
    }


    private func getObjects1(
            _ pdf: inout [UInt8],
            _ obj: PDFobj,
            _ objects: inout [PDFobj]) {

        let xref = obj.getValue("/Prev")
        if xref != "" {
            getObjects1(
                    &pdf,
                    getObject(&pdf, Int(xref)!, pdf.count),
                    &objects)
        }

        var i = 1
        while true {
            let token = obj.dict[i]
            i += 1
            if token == "trailer" {
                break
            }
            let n = Int(obj.dict[i])!       // Number of entries
            i += 1
            for _ in 0..<n {
                let offset = obj.dict[i]    // Object offset
                i += 1
                _ = obj.dict[i]             // Generation number
                i += 1
                let status = obj.dict[i]    // Status keyword
                i += 1
                if status != "f" {
                    let o2 = getObject(&pdf, Int(offset)!, pdf.count)
                    o2.number = Int(o2.dict[0])!
                    objects.append(o2)
                }
            }
        }

    }


    private func getObjects2(
            _ pdf: inout [UInt8],
            _ obj: PDFobj,
            _ objects: inout [PDFobj]) throws {

        let prev = obj.getValue("/Prev")
        if !prev.isEmpty {
            try getObjects2(
                    &pdf,
                    getObject(&pdf, Int(prev)!, pdf.count),
                    &objects)
        }

        obj.setStream(&pdf, obj.getLength(&objects)!)
        if obj.getValue("/Filter") == "/FlateDecode" {
            _ = try Puff(output: &obj.data, input: &obj.stream, inflate: false)
            _ = try Puff(output: &obj.data, input: &obj.stream, inflate: true)
        }
        else {
            // Assume no compression
            obj.data = obj.stream
        }

        var p1 = 0  // Predictor byte
        var f1 = 0  // Field 1
        var f2 = 0  // Field 2
        var f3 = 0  // Field 3
        for i in 0..<obj.dict.count {
            // let token = obj.dict[i]
            if obj.dict[i] == "/Predictor" {
                if obj.dict[i + 1] == "12" {
                    p1 = 1
                }
            }
            if obj.dict[i] == "/W" {
                // "/W [ 1 3 1 ]"
                f1 = Int(obj.dict[i + 2])!
                f2 = Int(obj.dict[i + 3])!
                f3 = Int(obj.dict[i + 4])!
            }
        }

        let n = p1 + f1 + f2 + f3       // Number of bytes per entry
        var entry = [UInt8](repeating: 0, count: n)
        var i = 0
        while i < obj.data.count {
            // Apply the "Up" filter.
            var j = 0
            while j < n {
                entry[j] = entry[j] &+ obj.data[i + j]
                j += 1
            }
            // Process the entries in a cross-reference stream
            // Page 51 in PDF32000_2008.pdf
            if entry[p1] == 1 {         // Type 1 entry
                let o2 = getObject(&pdf, toInt(&entry, p1 + f1, f2), pdf.count)
                o2.number = Int(o2.dict[0])!
                objects.append(o2)
            }
            i += n
        }
    }


    private func getStartXRef(_ buf: inout [UInt8]) -> Int {
        var bytes = [UInt8]()
        var i = buf.count - 10
        while i > 10 {
            if buf[i] == 0x73 &&                // "s"
                    buf[i + 1] == 0x74 &&       // "t"
                    buf[i + 2] == 0x61 &&       // "a"
                    buf[i + 3] == 0x72 &&       // "r"
                    buf[i + 4] == 0x74 &&       // "t"
                    buf[i + 5] == 0x78 &&       // "x"
                    buf[i + 6] == 0x72 &&       // "r"
                    buf[i + 7] == 0x65 &&       // "e"
                    buf[i + 8] == 0x66 {        // "f"
                i += 10                 // Skip over "startxref" and the first EOL character
                while buf[i] < 0x30 {   // Skip over possible second EOL character and spaces
                    i += 1
                }
                while buf[i] >= 0x30 && buf[i] <= 0x39 {
                    bytes.append(buf[i])
                    i += 1
                }
                break
            }
            i -= 1
        }
        return Int(String(bytes: bytes, encoding: .ascii)!)!
    }


    public func addOutlineDict(_ toc: Bookmark) -> Int {
        let numOfChildren = getNumOfChildren(0, toc)
        newobj()
        append("<<\n")
        append("/Type /Outlines\n")
        append("/First ")
        append(objNumber + 1)
        append(" 0 R\n")
        append("/Last ")
        append(objNumber + numOfChildren)
        append(" 0 R\n")
        append("/Count ")
        append(numOfChildren)
        append("\n")
        append(">>\n")
        endobj()
        return self.objNumber
    }


    public func addOutlineItem(
            _ parent: Int,
            _ i: Int,
            _ bm1: Bookmark) {

        var prev = 0
        if bm1.getPrevBookmark() != nil {
            prev = parent + (i - 1)
        }
        var next = 0
        if bm1.getNextBookmark() != nil {
            next = parent + (i + 1)
        }

        var first = 0
        var last = 0
        var count = 0
        if bm1.getChildren() != nil && bm1.getChildren()!.count > 0 {
            first = parent + bm1.getFirstChild()!.objNumber
            last  = parent + bm1.getLastChild()!.objNumber
            count = (-1) * getNumOfChildren(0, bm1)
        }

        newobj()
        append("<<\n")
        append("/Title <")
        append(toHex(bm1.getTitle()))
        append(">\n")
        append("/Parent ")
        append(parent)
        append(" 0 R\n")
        if prev > 0 {
            append("/Prev ")
            append(prev)
            append(" 0 R\n")
        }
        if next > 0 {
            append("/Next ")
            append(next)
            append(" 0 R\n")
        }
        if first > 0 {
            append("/First ")
            append(first)
            append(" 0 R\n")
        }
        if last > 0 {
            append("/Last ")
            append(last)
            append(" 0 R\n")
        }
        if count != 0 {
            append("/Count ")
            append(count)
            append("\n")
        }
        append("/F 4\n")        // No Zoom
        append("/Dest [")
        append(bm1.getDestination()!.pageObjNumber)
        append(" 0 R /XYZ 0 ")
        append(bm1.getDestination()!.yPosition)
        append(" 0]\n")
        append(">>\n")
        endobj()
    }


    private func getNumOfChildren(
            _ numOfChildren: Int,
            _ bm1: Bookmark) -> Int {
        var numberOfChildren = numOfChildren
        if let children = bm1.getChildren() {
            for bm2 in children {
                numberOfChildren += 1
                numberOfChildren = getNumOfChildren(numberOfChildren, bm2)
            }
        }
        return numberOfChildren
    }


    public func removePages(
            _ pageNumbers: Set<Int>,
            _ objects: inout [PDFobj]) {
        var pageObjectNumbers = Set<Int>()
        var temp = [String]()
        let pages = getPagesObject(&objects)!
        var dict = pages.getDict()
        var i = 0
        while i < dict.count {
            if dict[i] == "/Kids" {
                temp.append(dict[i])
                i += 1
                temp.append(dict[i])
                i += 1
                var pageNumber = 1
                while dict[i] != "]" {
                    if !pageNumbers.contains(pageNumber) {
                        temp.append(dict[i])
                        i += 1
                        temp.append(dict[i])
                        i += 1
                        temp.append(dict[i])
                        i += 1
                    }
                    else {
                        pageObjectNumbers.insert(Int(dict[i])!)
                        i += 3
                    }
                    pageNumber += 1
                }
                temp.append(dict[i])
            }
            else if dict[i] == "/Count" {
                temp.append(dict[i])
                i += 1
                let count = Int(dict[i])! - pageNumbers.count
                temp.append(String(count))
            }
            else {
                temp.append(dict[i])
            }

            i += 1
        }
        pages.setDict(&temp)

        for pageObjectNumber in pageObjectNumbers {
            objects[pageObjectNumber - 1] = PDFobj()
        }
    }


    public func addObjects(_ objects: inout [PDFobj]) {
        self.pagesObjNumber = Int(getPagesObject(&objects)!.dict[0])!
        addObjectsToPDF(&objects)
    }


    public func getPagesObject(
            _ objects: inout [PDFobj]) -> PDFobj? {
        for object in objects {
            if object.getValue("/Type") == "/Pages" &&
                    object.getValue("/Parent").isEmpty {
                return object
            }
        }
        return nil
    }


    public func getPageObjects(
            _ pageObjects: inout [PDFobj], from objects: inout [PDFobj]) {
        let pagesObject = getPagesObject(&objects)!
        getPageObjects(pagesObject, &pageObjects, &objects)
    }


    private func getPageObjects(
            _ pdfObj: PDFobj,
            _ pages: inout [PDFobj],
            _ objects: inout [PDFobj]) {
        let kids = pdfObj.getObjectNumbers("/Kids")
        for number in kids {
            let object = objects[number - 1]
            if isPageObject(object) {
                pages.append(object)
            }
            else {
                getPageObjects(object, &pages, &objects)
            }
        }
    }


    private func isPageObject(_ object: PDFobj) -> Bool {
        var isPage = false
        for i in 0..<object.dict.count {
            if object.dict[i] == "/Type" &&
                    object.dict[i + 1] == "/Page" {
                isPage = true
            }
        }
        return isPage
    }


    private func getExtGState(
            _ resources: PDFobj,
            _ objects: inout [PDFobj]) -> String {
        var buf = String()
        var dict = resources.getDict()
        var level = 0
        var i = 0
        while i < dict.count {
            if dict[i] == "/ExtGState" {
                buf.append("/ExtGState << ")
                i += 1
                level += 1
                while level > 0 {
                    i += 1
                    let token = dict[i]
                    if token == "<<" {
                        level += 1
                    }
                    else if token == ">>" {
                        level -= 1
                    }
                    buf.append(token)
                    if level > 0 {
                        buf.append(" ")
                    }
                    else {
                        buf.append("\n")
                    }
                }
                break
            }
            i += 1
        }
        return buf
    }


    private func getFontObjects(
            _ resources: PDFobj,
            _ objects: inout [PDFobj]) -> [PDFobj] {
        var fonts = [PDFobj]()
        var dict = resources.getDict()
        for i in 0..<dict.count {
            if dict[i] == "/Font" {
                if dict[i + 2] != ">>" {
                    fonts.append(objects[Int(dict[i + 3])! - 1])
                }
            }
        }

        if fonts.count == 0 {
            return fonts
        }

        var i = 4
        while true {
            if dict[i] == "/Font" {
                i += 2
                break
            }
            i += 1
        }
        while dict[i] != ">>" {
            importedFonts.append(dict[i])
            i += 1
        }

        return fonts
    }


    private func getDescendantFonts(
            _ font: PDFobj,
            _ objects: inout [PDFobj]) -> [PDFobj] {
        var descendantFonts = [PDFobj]()
        var dict = font.getDict()
        for i in 0..<dict.count {
            if dict[i] == "/DescendantFonts" {
                if dict[i + 2] != "]" {
                    let object = objects[Int(dict[i + 2])! - 1]
                    descendantFonts.append(object)
                }
            }
        }
        return descendantFonts
    }


    private func getObject(
            _ name: String,
            _ object: PDFobj,
            _ objects: inout [PDFobj]) -> PDFobj? {
        var dict = object.getDict()
        for i in 0..<dict.count {
            if dict[i] == name {
                return objects[Int(dict[i + 1])! - 1]
            }
        }
        return nil
    }


    public func addResourceObjects(_ objects: inout [PDFobj]) {
        var resources = [PDFobj]()
        var pages = [PDFobj]()
        getPageObjects(&pages, from: &objects)
        for page in pages {
            let resObj = page.getResourcesObject(&objects)!
            let fonts = getFontObjects(resObj, &objects)
            for font in fonts {
                resources.append(font)
                if let obj = getObject("/ToUnicode", font, &objects) {
                    resources.append(obj)
                }
                let descendantFonts = getDescendantFonts(font, &objects)
                for descendantFont in descendantFonts {
                    resources.append(descendantFont)
                    if let obj = getObject("/FontDescriptor", descendantFont, &objects) {
                        resources.append(obj)
                        if let obj = getObject("/FontFile2", obj, &objects) {
                            resources.append(obj)
                        }
                    }
                }
            }
            extGState = getExtGState(resObj, &objects)
        }
        if resources.count > 0 {
            resources.sort(by: { $0.number < $1.number })
            addObjectsToPDF(&resources)
        }
    }


    private func addObjectsToPDF(_ objects: inout [PDFobj]) {
        for obj in objects {
            objNumber = obj.number
            objOffset.append(byte_count)
            if obj.offset == 0 {
                append(obj.number)
                append(" 0 obj\n")
                if !obj.dict.isEmpty {
                    for obj in obj.dict {
                        append(obj)
                        append(" ")
                    }
                }
                if !obj.stream.isEmpty {
                    if obj.dict.count == 0 {
                        append("<< /Length ")
                        append(obj.stream.count)
                        append(" >>")
                    }
                    append("\nstream\n")
                    for obj in obj.stream {
                        append(obj)
                    }
                    append("\nendstream\n")
                }
                append("endobj\n")
            }
            else {
                var link = false
                let n = obj.dict.count
                var token: String?
                for i in 0..<n {
                    token = obj.dict[i]
                    append(token!)
                    if token!.hasPrefix("(http:") {
                        link = true
                    }
                    else if token!.hasSuffix(")") {
                        link = false
                    }
                    if i < (n - 1) {
                        if !link {
                            append(" ")
                        }
                    }
                    else {
                        append("\n")
                    }
                }
                if !obj.stream.isEmpty {
                    for obj in obj.stream {
                        append(obj)
                    }
                    append("\nendstream\n")
                }
                if token! != "endobj" {
                    append("endobj\n")
                }
            }
        }
    }


    private func toHex(_ str: String) -> String {
        var buffer = String("FEFF")
        for scalar in str.unicodeScalars {
            let str2 = String(scalar.value, radix: 16, uppercase: true)
            if str2.count == 1 {
                buffer.append("000" + str2)
            }
            else if str2.count == 2 {
                buffer.append("00" + str2)
            }
            else if str2.count == 3 {
                buffer.append("0" + str2)
            }
        }
        return buffer
    }

}   // End of PDF.swift
