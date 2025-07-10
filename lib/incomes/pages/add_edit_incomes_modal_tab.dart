import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp

import '../../widgets_utils/clear_field.dart'; // Importe seu widget ClearField
import '../models/incomes.model.dart'; // Importe o ReceitaModel
import '../services/incomes.service.dart'; // Importe o ReceitaService

// O modal será um StatefulWidget para gerenciar o estado dos campos do formulário.
class AddEditReceitaModal extends StatefulWidget {
  // Parâmetro opcional para edição: o modelo completo da receita, se for edição.
  final ReceitaModel? receitaParaEditar;

  const AddEditReceitaModal({
    // Construtor corrigido e alinhado com o nome da classe
    super.key,
    this.receitaParaEditar,
  });

  @override
  State<AddEditReceitaModal> createState() => _AddEditReceitaModalState(); // Nome do State corrigido
}

class _AddEditReceitaModalState extends State<AddEditReceitaModal> {
  // Nome do State corrigido
  // Controladores para os campos de texto.
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  // Variáveis de estado para o formulário.
  String _categoriaSelecionada = 'Salário'; // Categoria padrão para receitas
  DateTime _dataSelecionada = DateTime.now(); // Data padrão
  bool _isLoading = false; // Indicador de carregamento

  // Instância do serviço de receitas
  final ReceitaService _receitaService = ReceitaService();

  // Lista de categorias de receitas (conforme CU09).
  final List<String> _categorias = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Presente',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    // Se 'receitaParaEditar' não for nula, estamos no modo de edição. Pré-preenche os campos.
    if (widget.receitaParaEditar != null) {
      _descricaoController.text = widget.receitaParaEditar!.descricao;
      _valorController.text = widget.receitaParaEditar!.valor
          .toString()
          .replaceAll('.', ','); // Formata para PT-BR
      _categoriaSelecionada = widget.receitaParaEditar!.categoria;
      _dataSelecionada = widget.receitaParaEditar!.data;
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
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
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

  // Método para lidar com o salvamento ou atualização da receita.
  Future<void> _handleSalvarReceita() async {
    // Tira o foco para fechar o teclado
    FocusScope.of(context).unfocus();

    // Validação dos campos (CU09 e CU10)
    if (_descricaoController.text.trim().isEmpty) {
      _mostrarSnackBar('A descrição é obrigatória.', Colors.red);
      return;
    }
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

    String? mensagemErro;
    if (widget.receitaParaEditar == null) {
      // MODO ADICIONAR NOVA RECEITA
      mensagemErro = await _receitaService.adicionarReceita(
        descricao: _descricaoController.text.trim(),
        valor: valor,
        categoria: _categoriaSelecionada,
        data: _dataSelecionada,
      );
    } else {
      // MODO EDITAR RECEITA EXISTENTE (CU10)
      // Cria um novo ReceitaModel com os dados atualizados do formulário
      final ReceitaModel receitaAtualizada = widget.receitaParaEditar!.copyWith(
        descricao: _descricaoController.text.trim(),
        valor: valor,
        categoria: _categoriaSelecionada,
        data: _dataSelecionada,
      );

      mensagemErro = await _receitaService.atualizarReceita(
        idReceita: widget.receitaParaEditar!.id, // Passa o ID da receita
        receitaAtualizada: receitaAtualizada,
      );
    }

    setState(() {
      _isLoading = false; // Desativa o indicador de carregamento
    });

    if (mensagemErro == null) {
      _mostrarSnackBar(
        widget.receitaParaEditar == null
            ? 'Receita adicionada com sucesso!'
            : 'Receita atualizada com sucesso!',
        Colors.green,
      );
      Navigator.of(context).pop(); // Fecha o modal após sucesso.
    } else {
      _mostrarSnackBar(mensagemErro, Colors.red);
    }
  }

  // Helper para exibir SnackBar
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
              widget.receitaParaEditar == null
                  ? 'Registrar Nova Receita'
                  : 'Editar Receita',
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
              label: 'Descrição (ex: Salário Mensal)',
              controller: _descricaoController,
              onLimpar: () => setState(() => _descricaoController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.description),
                labelText: 'Descrição',
              ),
            ),
            const SizedBox(height: 16),

            // Campo Valor
            ClearField(
              label: 'Valor (ex: 1500,00)',
              controller: _valorController,
              onLimpar: () => setState(() => _valorController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.attach_money),
                labelText: 'Valor (ex: 1500,00)'
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown Categoria
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: inputDecoration.copyWith(
                labelText: 'Categoria',
                prefixIcon: const Icon(Icons.category),
              ),
              items:
                  _categorias.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
              onChanged: (String? novoValor) {
                setState(() {
                  _categoriaSelecionada = novoValor!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo de Data (com DatePicker)
            GestureDetector(
              onTap: () => _selecionarData(context),
              child: AbsorbPointer(
                child: ClearField(
                  label: 'Data da Receita',
                  controller: TextEditingController(
                    text: DateFormat(
                      'dd/MM/yyyy',
                      'pt_BR',
                    ).format(_dataSelecionada),
                  ),
                  onLimpar: () {
                    /* Não faz sentido limpar a data */
                  },
                  maxLines: 1,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Data da Receita',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSalvarReceita,
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
              label: const Text(
                'Salvar Receita',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
