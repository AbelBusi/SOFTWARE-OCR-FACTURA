import re


class InvoiceExtractor:

    def extraer_total(self, textos):

        for texto in textos:

            if "TOTAL" in texto.upper():
                continue

            if re.match(r"^\d+\.\d{2}$", texto):
                return texto

        return None


    def extraer_subtotal(self, textos):

        for i, texto in enumerate(textos):

            if "SUBTOTAL" in texto.upper():

                if i + 1 < len(textos):
                    return textos[i + 1]

        return None