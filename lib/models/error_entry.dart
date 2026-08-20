/// Ficha del Error Engine — Blueprint sección 10:
/// Error → Causa → Consecuencia → Explicación → Corrección.
class ErrorEntry {
  final String codigo;
  final String causa;
  final String consecuencia;
  final String explicacion;
  final String correccion;

  const ErrorEntry({
    required this.codigo,
    required this.causa,
    required this.consecuencia,
    required this.explicacion,
    required this.correccion,
  });

  factory ErrorEntry.fromMap(Map<String, dynamic> map) => ErrorEntry(
        codigo: map['codigo'] as String,
        causa: map['causa'] as String,
        consecuencia: map['consecuencia'] as String,
        explicacion: map['explicacion'] as String,
        correccion: map['correccion'] as String,
      );
}
