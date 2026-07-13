import io
from datetime import datetime

from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate,
    Table,
    TableStyle,
    Paragraph,
    Spacer,
)


# Encabezados de las columnas del reporte (información mostrada en la consulta,
# enriquecida con proveedor y RUC).
COLUMNAS = [
    "Proveedor",
    "RUC",
    "Tipo",
    "N° Comprobante",
    "Fecha",
    "Subtotal",
    "IGV",
    "Total",
]

_COLOR_CABECERA = colors.HexColor("#263238")
_COLOR_FILA = colors.HexColor("#F2F5F9")
_COLOR_BORDE = colors.HexColor("#CFD8DC")
_COLOR_TEXTO = colors.HexColor("#263238")


class ExportService:
    """Genera reportes del listado de facturas en PDF y Excel."""

    def _valor(self, dato):
        return dato if dato is not None else 0

    def _proveedor(self, empresa):
        if empresa and empresa.razon_social:
            return empresa.razon_social
        return "-"

    def _ruc(self, empresa):
        # Oculta los identificadores internos SINRUC-* (no son un RUC real).
        if empresa and empresa.ruc and not empresa.ruc.startswith("SINRUC-"):
            return empresa.ruc
        return "-"

    def _fecha(self, factura):
        return factura.fecha_emision.strftime("%Y-%m-%d") if factura.fecha_emision else "-"

    def _subtitulo_filtros(self, q, fecha):
        partes = []
        if q:
            partes.append(f"Búsqueda: \"{q}\"")
        if fecha:
            partes.append(f"Fecha: {fecha}")
        return " | ".join(partes) if partes else "Sin filtros aplicados"

    # ------------------------------------------------------------------ PDF
    def generar_pdf(self, filas, q=None, fecha=None) -> bytes:
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=landscape(A4),
            leftMargin=15 * mm,
            rightMargin=15 * mm,
            topMargin=15 * mm,
            bottomMargin=15 * mm,
            title="Reporte de Comprobantes",
        )

        estilo_titulo = ParagraphStyle(
            "titulo", fontName="Helvetica-Bold", fontSize=16,
            textColor=_COLOR_TEXTO, spaceAfter=2,
        )
        estilo_meta = ParagraphStyle(
            "meta", fontName="Helvetica", fontSize=9,
            textColor=colors.HexColor("#607D8B"), leading=13,
        )
        estilo_celda = ParagraphStyle(
            "celda", fontName="Helvetica", fontSize=8,
            textColor=_COLOR_TEXTO, leading=10,
        )
        estilo_celda_der = ParagraphStyle(
            "celda_der", parent=estilo_celda, alignment=TA_RIGHT,
        )
        estilo_cab = ParagraphStyle(
            "cab", fontName="Helvetica-Bold", fontSize=8.5,
            textColor=colors.white, alignment=TA_LEFT,
        )
        estilo_cab_der = ParagraphStyle(
            "cab_der", parent=estilo_cab, alignment=TA_RIGHT,
        )

        generado = datetime.now().strftime("%Y-%m-%d %H:%M")

        story = [
            Paragraph("Reporte de Comprobantes", estilo_titulo),
            Paragraph(f"Generado: {generado}", estilo_meta),
            Paragraph(self._subtitulo_filtros(q, fecha), estilo_meta),
            Paragraph(f"Total de comprobantes: {len(filas)}", estilo_meta),
            Spacer(1, 8 * mm),
        ]

        # Cabecera de tabla.
        cabecera = [
            Paragraph(c, estilo_cab_der if c in ("Subtotal", "IGV", "Total") else estilo_cab)
            for c in COLUMNAS
        ]
        tabla = [cabecera]

        total_general = 0.0
        for factura, empresa in filas:
            subtotal = float(self._valor(factura.subtotal))
            igv = float(self._valor(factura.igv))
            total = float(self._valor(factura.total))
            total_general += total

            tabla.append([
                Paragraph(self._proveedor(empresa), estilo_celda),
                Paragraph(self._ruc(empresa), estilo_celda),
                Paragraph(factura.tipo_comprobante or "-", estilo_celda),
                Paragraph(factura.numero_comprobante or "-", estilo_celda),
                Paragraph(self._fecha(factura), estilo_celda),
                Paragraph(f"S/ {subtotal:,.2f}", estilo_celda_der),
                Paragraph(f"S/ {igv:,.2f}", estilo_celda_der),
                Paragraph(f"S/ {total:,.2f}", estilo_celda_der),
            ])

        # Fila de total general.
        tabla.append([
            Paragraph("TOTAL", ParagraphStyle("tot", parent=estilo_celda, fontName="Helvetica-Bold")),
            "", "", "", "", "", "",
            Paragraph(
                f"S/ {total_general:,.2f}",
                ParagraphStyle("tot_der", parent=estilo_celda_der, fontName="Helvetica-Bold"),
            ),
        ])

        anchos = [70 * mm, 28 * mm, 22 * mm, 32 * mm, 24 * mm, 28 * mm, 26 * mm, 28 * mm]
        t = Table(tabla, colWidths=anchos, repeatRows=1)
        t.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), _COLOR_CABECERA),
            ("TOPPADDING", (0, 0), (-1, 0), 6),
            ("BOTTOMPADDING", (0, 0), (-1, 0), 6),
            ("ROWBACKGROUNDS", (0, 1), (-1, -2), [colors.white, _COLOR_FILA]),
            ("GRID", (0, 0), (-1, -1), 0.4, _COLOR_BORDE),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("TOPPADDING", (0, 1), (-1, -1), 4),
            ("BOTTOMPADDING", (0, 1), (-1, -1), 4),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            # Fila de total.
            ("SPAN", (0, -1), (-2, -1)),
            ("BACKGROUND", (0, -1), (-1, -1), colors.HexColor("#E3F2FD")),
            ("LINEABOVE", (0, -1), (-1, -1), 0.8, _COLOR_CABECERA),
        ]))

        story.append(t)
        doc.build(story, onFirstPage=self._pie, onLaterPages=self._pie)

        return buffer.getvalue()

    def _pie(self, canvas, doc):
        canvas.saveState()
        canvas.setFont("Helvetica", 7.5)
        canvas.setFillColor(colors.HexColor("#90A4AE"))
        canvas.drawString(15 * mm, 8 * mm, "OCR Factura - Reporte de Comprobantes")
        canvas.drawRightString(
            doc.pagesize[0] - 15 * mm, 8 * mm, f"Página {canvas.getPageNumber()}"
        )
        canvas.restoreState()

    # ---------------------------------------------------------------- Excel
    def generar_excel(self, filas, q=None, fecha=None) -> bytes:
        wb = Workbook()
        ws = wb.active
        ws.title = "Comprobantes"

        fill_cab = PatternFill("solid", fgColor="263238")
        font_cab = Font(bold=True, color="FFFFFF", size=10)
        font_titulo = Font(bold=True, size=14, color="263238")
        font_meta = Font(size=9, color="607D8B")
        borde = Border(*[Side(style="thin", color="CFD8DC")] * 4)
        centro = Alignment(horizontal="center", vertical="center")
        derecha = Alignment(horizontal="right")
        n_col = len(COLUMNAS)

        # Título y metadatos.
        ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=n_col)
        ws.cell(row=1, column=1, value="Reporte de Comprobantes").font = font_titulo

        generado = datetime.now().strftime("%Y-%m-%d %H:%M")
        ws.merge_cells(start_row=2, start_column=1, end_row=2, end_column=n_col)
        ws.cell(row=2, column=1, value=f"Generado: {generado}").font = font_meta
        ws.merge_cells(start_row=3, start_column=1, end_row=3, end_column=n_col)
        ws.cell(row=3, column=1, value=self._subtitulo_filtros(q, fecha)).font = font_meta

        fila_cab = 5
        for col, nombre in enumerate(COLUMNAS, start=1):
            celda = ws.cell(row=fila_cab, column=col, value=nombre)
            celda.font = font_cab
            celda.fill = fill_cab
            celda.alignment = centro
            celda.border = borde

        total_general = 0.0
        fila = fila_cab + 1
        for factura, empresa in filas:
            subtotal = float(self._valor(factura.subtotal))
            igv = float(self._valor(factura.igv))
            total = float(self._valor(factura.total))
            total_general += total

            valores = [
                self._proveedor(empresa),
                self._ruc(empresa),
                factura.tipo_comprobante or "-",
                factura.numero_comprobante or "-",
                self._fecha(factura),
                subtotal,
                igv,
                total,
            ]
            for col, valor in enumerate(valores, start=1):
                celda = ws.cell(row=fila, column=col, value=valor)
                celda.border = borde
                if col >= 6:  # columnas monetarias
                    celda.number_format = '"S/ "#,##0.00'
                    celda.alignment = derecha
            fila += 1

        # Fila de total.
        ws.cell(row=fila, column=1, value="TOTAL").font = Font(bold=True)
        celda_total = ws.cell(row=fila, column=n_col, value=total_general)
        celda_total.font = Font(bold=True)
        celda_total.number_format = '"S/ "#,##0.00'
        celda_total.alignment = derecha

        # Anchos de columna.
        anchos = [34, 16, 14, 18, 14, 14, 12, 14]
        for i, ancho in enumerate(anchos, start=1):
            ws.column_dimensions[get_column_letter(i)].width = ancho

        ws.freeze_panes = f"A{fila_cab + 1}"

        buffer = io.BytesIO()
        wb.save(buffer)
        return buffer.getvalue()
