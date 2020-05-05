using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_08.cs
 *
 */
public class Example_08 {

    public Example_08() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_08.pdf", FileMode.Create)), Compliance.PDF_A_1B);

        Page page = new Page(pdf, Letter.PORTRAIT);

        Font f1 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        f1.SetSize(7f);

        Font f2 = new Font(pdf, CoreFont.HELVETICA);
        f2.SetSize(7f);

        Font f3 = new Font(pdf, CoreFont.HELVETICA_BOLD_OBLIQUE);
        f3.SetSize(7f);

        Image image1 = new Image(
                pdf,
                new BufferedStream(new FileStream(
                        "images/fruit.jpg", FileMode.Open, FileAccess.Read)),
                ImageType.JPG);
        image1.ScaleBy(0.25f);

        Table table = new Table();
        List<List<Cell>> tableData = GetData(
        		"data/world-communications.txt", "|", Table.DATA_HAS_2_HEADER_ROWS, f1, f2);
        tableData[2][3].SetImage(image1);
        tableData[2][2].SetURIAction("http://pdfjet.com");

        // tableData[2][3].SetVerTextAlignment(Align.CENTER);

        table.SetData(tableData, Table.DATA_HAS_2_HEADER_ROWS);
        // table.SetCellBordersWidth(1.2f);
        table.SetCellBordersWidth(0.2f);
        table.SetLocation(70f, 30f);
        table.SetTextColorInRow(6, Color.blue);
        table.SetTextColorInRow(39, Color.red);
        table.SetFontInRow(26, f3);
        table.RemoveLineBetweenRows(0, 1);  
        table.AutoAdjustColumnWidths();
        table.SetColumnWidth(0, 120f);
        table.RightAlignNumbers();
        table.WrapAroundCellText();
        // table.MergeOverlaidBorders();

        int numOfPages = table.GetNumberOfPages(page);
        while (true) {
            table.DrawOn(page);
            // TO DO: Draw "Page 1 of N" here
            if (!table.HasMoreData()) {
                // Allow the table to be drawn again later:
                table.ResetRenderedPagesCount();
                break;
            }
            page = new Page(pdf, Letter.PORTRAIT);
        }

        pdf.Close();
    }
    
    
    public List<List<Cell>> GetData(
            String fileName,
            String delimiter,
            int numOfHeaderRows,
            Font f1,
            Font f2) {

        List<List<Cell>> tableData = new List<List<Cell>>();

        int currentRow = 0;
        StreamReader reader = new StreamReader(fileName);
        String line = null;
        while ((line = reader.ReadLine()) != null) {
            List<Cell> row = new List<Cell>();
            String[] cols = null;
            if (delimiter.Equals("|")) {
                cols = line.Split(new Char[] {'|'});
            }
            else if (delimiter.Equals("\t")) {
                cols = line.Split(new Char[] {'\t'});
            }
            else {
                throw new Exception(
                		"Only pipes and tabs can be used as delimiters");
            }
            for (int i = 0; i < cols.Length; i++) {
                String text = cols[i].Trim();
                Cell cell = null;
                if (currentRow < numOfHeaderRows) {
                    cell = new Cell(f1, text);
                }
                else {
                    cell = new Cell(f2, text);
                }

                // WITH:
                cell.SetTopPadding(2f);
                cell.SetBottomPadding(2f);
                cell.SetLeftPadding(2f);
                cell.SetRightPadding(2f);

                row.Add(cell);
            }
            tableData.Add(row);
            currentRow++;
        }
        reader.Close();

        AppendMissingCells(tableData, f2);
        
        return tableData;
    }
    

    private void AppendMissingCells(List<List<Cell>> tableData, Font f2) {
        List<Cell> firstRow = tableData[0];
        int numOfColumns = firstRow.Count;
        for (int i = 0; i < tableData.Count; i++) {
            List<Cell> dataRow = tableData[i];
            int dataRowColumns = dataRow.Count;
            if (dataRowColumns < numOfColumns) {
                for (int j = 0; j < (numOfColumns - dataRowColumns); j++) {
                    dataRow.Add(new Cell(f2));
                }
                dataRow[dataRowColumns - 1].SetColSpan(
                        (numOfColumns - dataRowColumns) + 1);
            }
        }
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_08();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_08 => " + (time1 - time0));
    }

}   // End of Example_08.cs
