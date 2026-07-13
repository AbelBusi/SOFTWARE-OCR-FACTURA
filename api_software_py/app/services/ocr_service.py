from paddleocr import PaddleOCR

class OCRService:
    def __init__(self):
        self.ocr = PaddleOCR(
            lang="es",
            use_angle_cls=False
        )

    def extraer_texto(self, ruta_imagen):
        resultado = self.ocr.ocr(ruta_imagen)
        textos = []

        if not resultado or not resultado[0]:
            return textos

        for linea in resultado[0]:
            texto = linea[1][0]
            confianza = linea[1][1]

            textos.append({
                "texto": texto,
                "confianza": confianza
            })

        return textos

    def confianza_promedio(self, resultado_ocr):
        if not resultado_ocr:
            return 0.0
        total = sum(item["confianza"] for item in resultado_ocr)
        return round(total / len(resultado_ocr), 4)