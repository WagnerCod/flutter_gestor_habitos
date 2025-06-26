import 'package:cloud_firestore/cloud_firestore.dart'; // Importe para usar Timestamp

class HabitoModel {
  final String id; // ID do documento no Firestore
  final String titulo; // Título do hábito
  final String descricao; // Descrição do hábito
  final String
  frequencia; // Frequência do hábito (ex: 'Diária', 'Semanal', 'Mensal')
  final bool feitoHoje; // Indica se o hábito foi feito hoje
  final DateTime? dataCriacao; // Data de criação do hábito
  final String? meta; // Meta opcional (ex: "2000 ml de água")
  final String usuarioId; // ID do usuário associado ao hábito
  final String? corHex; // Cor em formato hexadecimal (ex: '#4CAF50')
  final DateTime? ultimaConclusao; // Data da última conclusão do hábito

  HabitoModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.frequencia,
    this.feitoHoje = false,
    this.dataCriacao,
    this.meta,
    required this.usuarioId, // UsuarioId agora é obrigatório no construtor
    this.corHex,
    this.ultimaConclusao,
  });

  // Converte um objeto HabitoModel para um mapa (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'frequencia': frequencia,
      'feitoHoje': feitoHoje,
      // Usar Timestamp.fromDate para DateTime e FieldValue.serverTimestamp para nova criação se dataCriacao for nula
      'dataCriacao':
          dataCriacao != null
              ? Timestamp.fromDate(dataCriacao!)
              : FieldValue.serverTimestamp(),
      'meta': meta,
      'usuarioId': usuarioId,
      'corHex': corHex,
      'ultimaConclusao':
          ultimaConclusao != null ? Timestamp.fromDate(ultimaConclusao!) : null,
    };
  }

  // Cria um objeto HabitoModel a partir de um mapa do Firestore
  factory HabitoModel.fromMap(String id, Map<String, dynamic> map) {
    return HabitoModel(
      id: id,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      frequencia: map['frequencia'] ?? 'Diária',
      feitoHoje: map['feitoHoje'] ?? false,
      dataCriacao: (map['dataCriacao'] as Timestamp?)?.toDate(),
      meta: map['meta'],
      usuarioId: map['usuarioId'] ?? '', // Garante que usuarioId não seja nulo
      corHex: map['corHex'],
      ultimaConclusao: (map['ultimaConclusao'] as Timestamp?)?.toDate(),
    );
  }

  // Método opcional para criar uma cópia mutável (útil para formulários de edição)
  HabitoModel copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? frequencia,
    bool? feitoHoje,
    DateTime? dataCriacao,
    String? meta,
    String? usuarioId,
    String? corHex,
    DateTime? ultimaConclusao,
  }) {
    return HabitoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      frequencia: frequencia ?? this.frequencia,
      feitoHoje: feitoHoje ?? this.feitoHoje,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      meta: meta ?? this.meta,
      usuarioId: usuarioId ?? this.usuarioId,
      corHex: corHex ?? this.corHex,
      ultimaConclusao: ultimaConclusao ?? this.ultimaConclusao,
    );
  }
}
