enum TipoPropiedad { propia, tercero, desconocido }

TipoPropiedad tipoPropiedadFromString(String? inprp) {
  if (inprp == 'P') return TipoPropiedad.propia;
  if (inprp == 'T') return TipoPropiedad.tercero;
  return TipoPropiedad.desconocido;
}
