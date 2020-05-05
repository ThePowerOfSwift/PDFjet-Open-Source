using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

using PDFjet.NET;


/**
 *  Example_09.cs
 *
 */
public class Example_09 {

    private Exception e = null;

    public Example_09() {

        PDF pdf = new PDF(new BufferedStream(
                new FileStream("Example_09.pdf", FileMode.Create)));

        Page page = new Page(pdf, Letter.PORTRAIT);

        Font f1 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        Font f2 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        Font f3 = new Font(pdf, CoreFont.HELVETICA_BOLD);
        Font f4 = new Font(pdf, CoreFont.HELVETICA);

        f1.SetSize(10f);
        f2.SetSize(8f);
        f3.SetSize(7f);
        f4.SetSize(7f);

        Chart chart = new Chart(f1, f2);
        chart.SetLocation(70f, 50f);
        chart.SetSize(500f, 300f);
        chart.SetTitle("World View - Communications");
        chart.SetXAxisTitle("Cell phones per capita");
        chart.SetYAxisTitle("Internet users % of the population");
        chart.SetData(GetData("data/world-communications.txt", "|"));
        addTrendLine(chart);
        chart.DrawOn(page);

        AddTableToChart(page, chart, f3, f4);

        pdf.Close();
    }


    public void addTrendLine(Chart chart) {
        List<Point> points = chart.GetData()[0];

        double m = chart.Slope(points);
        double b = chart.Intercept(points, m);

        List<Point> trendline = new List<Point>();
        double x = 0.0;
        double y = m * x + b;
        Point p1 = new Point(x, y);
        p1.SetStartOfPath();
        p1.SetColor(Color.blue);
        p1.SetShape(Point.INVISIBLE);

        x = 1.5;
        y = m * x + b;
        Point p2 = new Point(x, y);
        p2.SetColor(Color.blue);
        p2.SetShape(Point.INVISIBLE);
        trendline.Add(p1);
        trendline.Add(p2);

        chart.GetData().Add(trendline);
    }


    public void AddTableToChart(
            Page page, Chart chart, Font f3, Font f4) {
        Table table = new Table();
        List<List<Cell>> tableData = new List<List<Cell>>();
        List<Point> points = chart.GetData()[0];
        for (int i = 0; i < points.Count; i++) {
            Point point = points[i];
            if (point.GetShape() != Point.CIRCLE) {
                List<Cell> tableRow = new List<Cell>();

                point.SetRadius(2f);
                point.SetFillShape(true);
                point.SetAlignment(Align.LEFT);

                Cell cell = new Cell(f4);
                cell.SetPoint(point);
                tableRow.Add(cell);

                cell = new Cell(f4);
                cell.SetText(point.GetText());
                tableRow.Add(cell);

                cell = new Cell(f4);
                cell.SetText(point.GetURIAction());
                tableRow.Add(cell);

                tableData.Add(tableRow);
            }
        }
        table.SetData(tableData);
        table.AutoAdjustColumnWidths();
        table.SetCellBordersWidth(0.2f);
        table.SetLocation(70f, 360f);
        table.SetColumnWidth(0, 9f);
        table.DrawOn(page);
    }


    public List<List<Point>> GetData(
            String fileName,
            String delimiter) {
        List<List<Point>> chartData = new List<List<Point>>();

        StreamReader reader =
                new StreamReader(fileName);
        List<Point> points = new List<Point>();
        String line = null;
        while ((line = reader.ReadLine()) != null) {
            String[] cols = null;
            if (delimiter.Equals("|")) {
                cols = line.Split(new Char[] {'|'});
            } else if (delimiter.Equals("\t")) {
                cols = line.Split(new Char[] {'\t'});
            } else {
                throw new Exception(
                    "Only pipes and tabs can be used as delimiters");
            }

            Point point = new Point();
            try {
                double population =
                        Double.Parse(cols[1].Replace(",", ""));
                point.SetText(cols[0].Trim());
                String country_name = point.GetText();
                country_name = country_name.Replace(" ", "_");
                country_name = country_name.Replace("'", "_");
                country_name = country_name.Replace(",", "_");
                country_name = country_name.Replace("(", "_");
                country_name = country_name.Replace(")", "_");
                point.SetURIAction(
                        "http://pdfjet.com/country/" + country_name + ".txt");
                point.SetX(Double.Parse(
                        cols[5].Replace(",", "")) / population);
                point.SetY(Double.Parse(
                        cols[7].Replace(",", "")) / population * 100);
                point.SetRadius(2.0);

                if (point.GetX() > 1.25) {
                    point.SetShape(Point.RIGHT_ARROW);
                    point.SetColor(Color.black);
                }
                if (point.GetY() > 80) {
                    point.SetShape(Point.UP_ARROW);
                    point.SetColor(Color.blue);
                }
                if (point.GetText().Equals("France")) {
                    point.SetShape(Point.MULTIPLY);
                    point.SetColor(Color.black);
                }
                if (point.GetText().Equals("Canada")) {
                    point.SetShape(Point.BOX);
                    point.SetColor(Color.darkolivegreen);
                }
                if (point.GetText().Equals("United States")) {
                    point.SetShape(Point.STAR);
                    point.SetColor(Color.red);
                }

                points.Add(point);
            } catch (Exception e) {
                // Don't print or log the exceptions and
                // prevent csc from generating warnings
                this.e = e;
            }
        }
        reader.Close();
        chartData.Add(points);

        return chartData;
    }


    public static void Main(String[] args) {
        Stopwatch sw = Stopwatch.StartNew();
        long time0 = sw.ElapsedMilliseconds;
        new Example_09();
        long time1 = sw.ElapsedMilliseconds;
        sw.Stop();
        Console.WriteLine("Example_09 => " + (time1 - time0));
    }

}   // End of Example_09.cs
