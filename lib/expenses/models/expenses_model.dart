import 'package:cloud_firestore/cloud_firestore.dart'; // Importe para usar Timestamp

class DespesaModel {
  final String id; // ID do documento no Firestore
  final String descricao; // Descrição da despesa
  final double valor; // Valor da despesa
  final String categoria; // Categoria da despesa
  final DateTime data; // Data da despesa
  final String usuarioId; // ID do usuário associado à despesa
  final DateTime? dataCriacao; // Data de criação do registro no Firestore

  DespesaModel({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.usuarioId,
    this.dataCriacao,
  });

  // Converte um objeto DespesaModel para um mapa (para salvar no Firestore)
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

  // Cria um objeto DespesaModel a partir de um mapa do Firestore
  factory DespesaModel.fromMap(String id, Map<String, dynamic> map) {
    return DespesaModel(
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
  DespesaModel copyWith({
    String? id,
    String? descricao,
    double? valor,
    String? categoria,
    DateTime? data,
    String? usuarioId,
    DateTime? dataCriacao,
  }) {
    return DespesaModel(
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
