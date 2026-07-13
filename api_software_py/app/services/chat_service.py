from sqlalchemy.orm import Session

from app.repositories.factura_repository import FacturaRepository
from app.services.ai_provider import obtener_proveedor

MAX_FACTURAS_CONTEXTO = 40
MAX_PRODUCTOS_POR_FACTURA = 15
MAX_HISTORIAL = 6


class ChatService:

    def __init__(self):
        self.provider = obtener_proveedor()
        self.repository = FacturaRepository()

    def responder(self, db: Session, id_usuario: int, pregunta: str, historial=None) -> str:
        contexto = self._construir_contexto(db, id_usuario)

        mensajes = [{"role": "system", "content": self._system_prompt(contexto)}]

        for mensaje in (historial or [])[-MAX_HISTORIAL:]:
            rol = "assistant" if mensaje.get("rol") == "assistant" else "user"
            texto = (mensaje.get("texto") or "").strip()
            if texto:
                mensajes.append({"role": rol, "content": texto})

        mensajes.append({"role": "user", "content": pregunta})

        return self.provider.responder(mensajes)

    def _ruc_visible(self, empresa):
        if empresa and empresa.ruc and not empresa.ruc.startswith("SINRUC-"):
            return empresa.ruc
        return "-"

    def _nombre_empresa(self, empresa):
        if empresa and empresa.razon_social:
            return empresa.razon_social
        return "Sin proveedor"

    def _construir_contexto(self, db: Session, id_usuario: int) -> str:
        filas = self.repository.listar_con_empresa(db, id_usuario)

        if not filas:
            return "El usuario no tiene facturas registradas en el sistema."

        total_general = 0.0
        por_empresa = {}

        for factura, empresa in filas:
            total = float(factura.total or 0)
            total_general += total
            nombre = self._nombre_empresa(empresa)
            por_empresa[nombre] = por_empresa.get(nombre, 0.0) + total

        resumen = [
            f"Total de facturas registradas: {len(filas)}",
            f"Suma total: S/ {total_general:,.2f}",
            "Gasto por empresa:",
        ]
        for nombre, monto in sorted(por_empresa.items(), key=lambda x: x[1], reverse=True):
            resumen.append(f"  - {nombre}: S/ {monto:,.2f}")

        detalle = ["Facturas (más recientes primero):"]
        for factura, empresa in filas[:MAX_FACTURAS_CONTEXTO]:
            fecha = factura.fecha_emision.strftime("%Y-%m-%d") if factura.fecha_emision else "-"
            productos = [
                f"{(d.descripcion or '').strip()} x{float(d.cantidad or 0):g} (S/ {float(d.subtotal or 0):,.2f})"
                for d in factura.detalles[:MAX_PRODUCTOS_POR_FACTURA]
            ]
            prod_txt = "; ".join(productos) if productos else "sin productos detallados"
            detalle.append(
                f"- {factura.tipo_comprobante or 'Comprobante'} N° {factura.numero_comprobante or '-'} | "
                f"Empresa: {self._nombre_empresa(empresa)} | RUC: {self._ruc_visible(empresa)} | "
                f"Fecha: {fecha} | Subtotal: S/ {float(factura.subtotal or 0):,.2f} | "
                f"IGV: S/ {float(factura.igv or 0):,.2f} | Total: S/ {float(factura.total or 0):,.2f} | "
                f"Productos: {prod_txt}"
            )

        if len(filas) > MAX_FACTURAS_CONTEXTO:
            detalle.append(f"(Se listan las {MAX_FACTURAS_CONTEXTO} más recientes de {len(filas)} en total.)")

        return "\n".join(resumen + [""] + detalle)

    def _system_prompt(self, contexto: str) -> str:
        return (
            "Eres un asistente virtual integrado en un sistema de gestión de facturas (OCR Factura). "
            "Respondes en español, de forma clara, breve y amable. Usa 'S/' para los montos.\n\n"
            "Dispones de los datos del usuario en la sección CONTEXTO DEL SISTEMA. "
            "Para preguntas sobre sus facturas, empresas, RUC, totales, productos, fechas, reportes o "
            "estadísticas, responde ÚNICAMENTE con esa información.\n"
            "Si la información solicitada NO se encuentra en el CONTEXTO DEL SISTEMA, puedes responder con tu "
            "conocimiento general, pero debes indicarlo claramente comenzando con: "
            "'Nota: esta información no proviene de tus datos registrados.'\n"
            "No inventes facturas, montos ni datos que no estén en el contexto.\n\n"
            f"CONTEXTO DEL SISTEMA:\n{contexto}"
        )
