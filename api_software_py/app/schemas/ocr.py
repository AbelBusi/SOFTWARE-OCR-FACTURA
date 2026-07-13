from pydantic import BaseModel, Field


class OcrEmpresaData(BaseModel):

    ruc: str = ""
    nombre: str = ""
    direccion: str = ""


class OcrFacturaData(BaseModel):

    tipo_comprobante: str = ""
    numero_comprobante: str = ""
    fecha_emision: str = ""
    subtotal: float = 0.0
    igv: float = 0.0
    total: float = 0.0


class OcrDetalleData(BaseModel):

    descripcion: str = ""
    cantidad: float = 0.0
    precio_unitario: float = 0.0
    subtotal: float = 0.0


class GuardarFacturaRequest(BaseModel):

    id_usuario: int

    imagen_url: str | None = None

    empresa: OcrEmpresaData

    factura: OcrFacturaData

    detalles: list[OcrDetalleData] = Field(default_factory=list)
