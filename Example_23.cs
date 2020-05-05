using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_23.cs
 *
 */
public class Example_23 {

    public Example_23() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_23.pdf", FileMode.Create)));

        Page page = new Page(pdf, Letter.PORTRAIT);

        Font f1 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        Font f2 = new Font(pdf, CoreFont.HELVETICA);
        Font f3 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        f3.SetSize(7f * 0.583f);

        List<List<Cell>> tableData = new List<List<Cell>>();

        List<Cell> row = new List<Cell>();
        Cell cell = new Cell(f1, "Hello");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);

        cell = new Cell(f1, "World");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);

        cell = new Cell(f1, "Next Column");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);

        cell = new Cell(f1, "CompositeTextLine");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);

        row.Add(cell);

        tableData.Add(row);

        row = new List<Cell>();
        cell = new Cell(f2, "This is a test:");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);
        cell = new Cell(f2,
                "Here we are going to test the WrapAroundCellText method.\n\nWe will create a table and place it near the bottom of the page. When we draw this table the text will wrap around the column edge and stay within the column.\n\nSo - let's  see how this is working?");
        cell.SetColSpan(2);
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);
        row.Add(new Cell(f2));  // We need an empty cell here because the previous cell had colSpan == 2
        cell = new Cell(f2, "Test 456");
        cell.SetTopPadding(5f);
        cell.SetBottomPadding(5f);
        row.Add(cell);
        tableData.Add(row);

        row = new List<Cell>();
        row.Add(new Cell(f2,
                "Another row.\n\n\nMake sure that this line of text will be wrapped around correctly too."));
        row.Add(new Cell(f2, "Yahoo!"));
        row.Add(new Cell(f2, "Test 789"));

        CompositeTextLine composite = new CompositeTextLine(0f, 0f);
        composite.SetFontSize(12f);
        TextLine line1 = new TextLine(f1, "Composite Text Line");
        TextLine line2 = new TextLine(f3, "Superscript");
        TextLine line3 = new TextLine(f3, "Subscript");
        line2.SetTextEffect(Effect.SUPERSCRIPT);
        line3.SetTextEffect(Effect.SUBSCRIPT);
        composite.AddComponent(line1);
        composite.AddComponent(line2);
        composite.AddComponent(line3);

        cell = new Cell(f2);
        cell.SetCompositeTextLine(composite);
        cell.SetBgColor(Color.peachpuff);
        row.Add(cell);

        tableData.Add(row);

        Table table = new Table();
        table.SetData(tableData, Table.DATA_HAS_1_HEADER_ROWS);
        // table.SetLocation(70f, 730f);
        table.SetLocation(70f, 70f);
        table.SetColumnWidth(0, 100f);
        table.SetColumnWidth(1, 100f);
        table.SetColumnWidth(2, 100f);
        table.SetColumnWidth(3, 150f);
        table.WrapAroundCellText();

        int numOfPages = table.GetNumberOfPages(page);
        while (true) {
            table.DrawOn(page);
            if (!table.HasMoreData()) {
                break;
            }
            page = new Page(pdf, Letter.PORTRAIT);
            table.SetLocation(70f, 30f);
        }

        pdf.Close();
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_23();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_23 => " + (time1 - time0));
    }

}   // End of Example_23.cs
