import 'package:cloud_firestore/cloud_firestore.dart'; // Importe para usar Timestamp

class ReceitaModel {
  final String id; // ID do documento no Firestore
  final String descricao; // Descrição da receita
  final double valor; // Valor da receita
  final String categoria; // Categoria da receita
  final DateTime data; // Data da receita
  final String usuarioId; // ID do usuário associado à receita
  final DateTime? dataCriacao; // Data de criação do registro no Firestore

  ReceitaModel({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.usuarioId,
    this.dataCriacao,
  });

  // Converte um objeto ReceitaModel para um mapa (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'categoria': categoria,
      'data': Timestamp.fromDate(data), // Converte DateTime para Timestamp
      'usuarioId': usuarioId,
      // Se dataCriacao não for fornecida, usa FieldValue.serverTimestamp() para que o Firestore defina a data de criação.
      'dataCriacao':
          dataCriacao != null
              ? Timestamp.fromDate(dataCriacao!)
              : FieldValue.serverTimestamp(),
    };
  }

  // Cria um objeto ReceitaModel a partir de um mapa do Firestore
  factory ReceitaModel.fromMap(String id, Map<String, dynamic> map) {
    return ReceitaModel(
      id: id,
      descricao: map['descricao'] ?? '',
      // Garante que o valor é double, tratando como num antes de toDouble
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      categoria: map['categoria'] ?? 'Outros',
      // Converte Timestamp para DateTime, usando DateTime.now() como fallback
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usuarioId: map['usuarioId'] ?? '',
      // Converte Timestamp para DateTime para data de criação
      dataCriacao: (map['dataCriacao'] as Timestamp?)?.toDate(),
    );
  }

  // Método opcional para criar uma cópia mutável (útil para formulários de edição)
  ReceitaModel copyWith({
    String? id,
    String? descricao,
    double? valor,
    String? categoria,
    DateTime? data,
    String? usuarioId,
    DateTime? dataCriacao,
  }) {
    return ReceitaModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      categoria: categoria ?? this.categoria,
      data: data ?? this.data,
      usuarioId: usuarioId ?? this.usuarioId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
