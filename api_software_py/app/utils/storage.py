import os
import time

from sqlalchemy.orm import Session

from app.models.factura import Factura


def limpiar_imagenes_huerfanas(db: Session, upload_dir: str, max_edad_horas: int = 12) -> int:
    """Elimina imágenes del directorio de subidas que no están asociadas a ninguna
    factura y que superan la antigüedad indicada.

    Esto ocurre cuando un usuario procesa una imagen pero abandona la revisión sin
    confirmar el guardado, dejando el archivo huérfano.

    Es una limpieza best-effort: nunca debe interrumpir el flujo principal. La
    antigüedad mínima protege las imágenes de una revisión en curso (aún no guardada).

    Devuelve la cantidad de archivos eliminados.
    """
    if not os.path.isdir(upload_dir):
        return 0

    referencias = {
        os.path.basename(ruta)
        for (ruta,) in db.query(Factura.imagen_url).all()
        if ruta
    }

    limite = time.time() - max_edad_horas * 3600
    eliminados = 0

    for nombre in os.listdir(upload_dir):
        ruta = os.path.join(upload_dir, nombre)

        if not os.path.isfile(ruta):
            continue

        if nombre in referencias:
            continue

        try:
            if os.path.getmtime(ruta) < limite:
                os.remove(ruta)
                eliminados += 1
        except OSError:
            continue

    return eliminados
