from datetime import date

from pydantic import BaseModel

from app.schemas.detalle_factura import DetalleFacturaResponse


class FacturaCreate(BaseModel):

    id_empresa: int | None = None

    tipo_comprobante: str

    numero_comprobante: str

    fecha_emision: date

    subtotal: float

    igv: float

    total: float

    imagen_url: str | None = None



class FacturaResponse(BaseModel):

    id_factura: int

    id_usuario: int

    id_empresa: int | None

    tipo_comprobante: str

    numero_comprobante: str

    fecha_emision: date

    subtotal: float

    igv: float

    total: float


    class Config:
        from_attributes = True

class FacturaDetalleResponse(BaseModel):

    id_factura: int

    id_usuario: int

    id_empresa: int | None

    tipo_comprobante: str

    numero_comprobante: str

    fecha_emision: date

    subtotal: float

    igv: float

    total: float

    detalles: list[DetalleFacturaResponse]


    class Config:
        from_attributes = True