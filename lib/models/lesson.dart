class Lesson {
  final String skillId;
  final String titulo;
  final String contenido;
  final String? datoClave;

  const Lesson({
    required this.skillId,
    required this.titulo,
    required this.contenido,
    this.datoClave,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        skillId: map['skill_id'] as String,
        titulo: map['titulo'] as String,
        contenido: map['contenido'] as String,
        datoClave: map['dato_clave'] as String?,
      );

  List<String> get parrafos => contenido.split('\n\n');
}
