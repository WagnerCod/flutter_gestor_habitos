import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp

import '../../widgets_utils/clear_field.dart'; // Importe seu widget ClearField
import '../service/expense_service.dart'; // Importe o ExpenseService
import '../models/expenses_model.dart'; // Importe o DespesaModel

// O modal será um StatefulWidget para gerenciar o estado dos campos do formulário.
class AddEditExpenseModal extends StatefulWidget {
  // Parâmetro opcional para edição: o modelo completo da despesa, se for edição.
  final DespesaModel? despesaParaEditar;

  const AddEditExpenseModal({super.key, this.despesaParaEditar});

  @override
  State<AddEditExpenseModal> createState() => _AddEditExpenseModalState();
}

class _AddEditExpenseModalState extends State<AddEditExpenseModal> {
  // Controladores para os campos de texto (NOMES EM PORTUGUÊS).
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  // Variáveis de estado para o formulário (NOMES EM PORTUGUÊS).
  String _categoriaSelecionada = 'Alimentação'; // Categoria padrão.
  DateTime _dataSelecionada = DateTime.now(); // Data padrão.
  bool _isLoading = false; // Indicador de carregamento.

  // Instância do serviço de despesas.
  final ExpenseService _expenseService = ExpenseService();

  // Lista de categorias de despesas (conforme CU06).
  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Moradia',
    'Educação',
    'Lazer',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    // Se 'despesaParaEditar' não for nula, estamos no modo de edição. Pré-preenche os campos.
    if (widget.despesaParaEditar != null) {
      _descricaoController.text = widget.despesaParaEditar!.descricao;
      // Formata o valor para exibir com vírgula se necessário.
      _valorController.text = widget.despesaParaEditar!.valor
          .toString()
          .replaceAll('.', ',');
      _categoriaSelecionada = widget.despesaParaEditar!.categoria;
      _dataSelecionada = widget.despesaParaEditar!.data;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // Método para exibir o DatePicker e permitir que o usuário selecione uma data.
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000), // Data mínima
      lastDate: DateTime(2101), // Data máxima
      locale: const Locale(
        'pt',
        'BR',
      ), // Define o idioma do DatePicker para português
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(
                    context,
                  ).colorScheme.primary, // Cor principal do tema
              onPrimary: Colors.white, // Cor do texto/ícones na cor principal
              onSurface: Colors.black, // Cor do texto no surface (dias do mês)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // Cor dos botões (OK, CANCELAR)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dataEscolhida != null && dataEscolhida != _dataSelecionada) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  // Método para lidar com o salvamento ou atualização da despesa.
  Future<void> _handleSalvarDespesa() async {
    // Tira o foco para fechar o teclado
    FocusScope.of(context).unfocus();

    // Validação dos campos (CU06 e CU07)
    if (_descricaoController.text.trim().isEmpty) {
      _mostrarSnackBar('A descrição é obrigatória.', Colors.red);
      return;
    }
    // Trata vírgula como separador decimal para o valor
    final double? valor = double.tryParse(
      _valorController.text.replaceAll(',', '.'),
    );
    if (valor == null || valor <= 0) {
      _mostrarSnackBar(
        'O valor deve ser um número positivo e válido.',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    String? mensagemErro; // Renomeado para português
    if (widget.despesaParaEditar == null) {
      // MODO ADICIONAR NOVA DESPESA
      mensagemErro = await _expenseService.adicionarDespesa(
        descricao: _descricaoController.text.trim(),
        valor: valor,
        categoria: _categoriaSelecionada,
        data: _dataSelecionada,
      );
    } else {
      // MODO EDITAR DESPESA EXISTENTE (CU07)
      final Map<String, dynamic> dadosAtualizados = {
        // Renomeado para português
        'descricao': _descricaoController.text.trim(),
        'valor': valor,
        'categoria': _categoriaSelecionada,
        'data': Timestamp.fromDate(_dataSelecionada),
        // 'createdAt' e 'usuarioId' não precisam ser atualizados aqui.
        // O despesaParaEditar já contém o id.
      };

      mensagemErro = await _expenseService.atualizarDespesa(
        idDespesa: widget.despesaParaEditar!.id, // Passa o ID da despesa
        dadosAtualizados: dadosAtualizados,
      );
    }

    setState(() {
      _isLoading = false; // Desativa o indicador de carregamento
    });

    if (mensagemErro == null) {
      _mostrarSnackBar(
        widget.despesaParaEditar == null
            ? 'Despesa adicionada com sucesso!'
            : 'Despesa atualizada com sucesso!',
        Colors.green,
      );
      Navigator.of(context).pop(); // Fecha o modal após sucesso.
    } else {
      _mostrarSnackBar(mensagemErro, Colors.red);
    }
  }

  // Helper para exibir SnackBar (renomeado para português)
  void _mostrarSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define um estilo base para os campos de input
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: Colors.grey[700]),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      prefixIconColor: Colors.grey[600], // Cor padrão para ícones de prefixo
    );

    return SingleChildScrollView(
      // Permite rolagem quando o teclado está ativo
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              20, // Ajusta padding para teclado
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ocupa o mínimo de espaço vertical necessário
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Estica os elementos horizontalmente
          children: [
            // Título do Modal (Adicionar ou Editar)
            Text(
              widget.despesaParaEditar == null
                  ? 'Registrar Nova Despesa'
                  : 'Editar Despesa',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Cor para o título do modal
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Campo Descrição
            ClearField(
              label: 'Descrição (ex: Conta de Luz)', // Label em português
              controller: _descricaoController, // Controlador em português
              onLimpar: () => setState(() => _descricaoController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Valor
            ClearField(
              label: 'Valor (ex: 150,75)', // Label em português
              controller: _valorController, // Controlador em português
              onLimpar: () => setState(() => _valorController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ), // Teclado numérico com decimal
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.attach_money),
              ), // Ícone de dinheiro
            ),
            const SizedBox(height: 16),

            // Dropdown Categoria
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada, // Variável em português
              decoration: inputDecoration.copyWith(
                labelText: 'Categoria', // Label em português
                prefixIcon: const Icon(Icons.category),
              ),
              items:
                  _categorias.map((String categoria) {
                    // Lista de categorias em português
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
              onChanged: (String? novoValor) {
                setState(() {
                  _categoriaSelecionada =
                      novoValor!; // Atualiza variável em português
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo de Data (com DatePicker)
            GestureDetector(
              onTap:
                  () => _selecionarData(context), // Abre o DatePicker ao tocar
              child: AbsorbPointer(
                // Impede que o TextField receba foco diretamente
                child: ClearField(
                  label: 'Data da Despesa', // Label em português
                  controller: TextEditingController(
                    // Cria um controlador apenas para exibição da data formatada
                    text: DateFormat(
                      'dd/MM/yyyy',
                      'pt_BR',
                    ).format(_dataSelecionada),
                  ),
                  onLimpar: () {
                    // Não faz sentido limpar a data, então não há ação para onLimpar
                  },
                  maxLines: 1,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Data da Despesa',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : _handleSalvarDespesa, // Desabilita enquanto carrega
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save),
              label: Text(
                widget.despesaParaEditar == null
                    ? 'Salvar Despesa'
                    : 'Salvar Alterações', // Labels em português
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // Usa a cor primária do tema
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16), // Espaçamento extra abaixo do botão
          ],
        ),
      ),
    );
  }
}
