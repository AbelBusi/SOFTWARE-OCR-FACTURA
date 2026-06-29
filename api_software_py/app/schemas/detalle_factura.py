from datetime import date

from pydantic import BaseModel


class DetalleFacturaCreate(BaseModel):

    descripcion: str

    cantidad: float

    precio_unitario: float

    subtotal: float



class DetalleFacturaResponse(BaseModel):

    id_detalle: int

    id_factura: int

    descripcion: str

    cantidad: float

    precio_unitario: float

    subtotal: float


    class Config:
        from_attributes = True