import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para FieldValue.serverTimestamp
import 'package:intl/intl.dart'; // Para formatação de data, se necessário para exibição

import '../../widgets_utils/clear_field.dart'; // Importe seu widget ClearField
import '../services/habits_services.dart';
import '../models/habits_model.dart'; // Importe o HabitoModel

class AddEditHabitModal extends StatefulWidget {
  final HabitoModel?
  habitoParaEditar; // Modelo completo do hábito, se for edição

  const AddEditHabitModal({super.key, this.habitoParaEditar});

  @override
  State<AddEditHabitModal> createState() => _AddEditHabitModalState();
}

class _AddEditHabitModalState extends State<AddEditHabitModal> {
  // Controladores para os campos do formulário (NOMES EM PORTUGUÊS)
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();

  // Variáveis de estado para o formulário (NOMES EM PORTUGUÊS)
  String _frequenciaSelecionada = 'Diária'; // Frequência padrão
  bool _feitoHoje = false; // Estado "feito hoje" (relevante para edição)
  bool _isLoading = false; // Indicador de carregamento

  // Instância do serviço de hábitos
  final HabitService _habitService = HabitService();

  // Lista de frequências para o Dropdown
  final List<String> _frequencias = ['Diária', 'Semanal', 'Mensal'];

  @override
  void initState() {
    super.initState();
    // Se 'habitoParaEditar' não for nulo, estamos no modo de edição. Pré-preenche os campos.
    if (widget.habitoParaEditar != null) {
      _tituloController.text = widget.habitoParaEditar!.titulo;
      _descricaoController.text = widget.habitoParaEditar!.descricao;
      _metaController.text = widget.habitoParaEditar!.meta ?? '';
      _frequenciaSelecionada = widget.habitoParaEditar!.frequencia;
      _feitoHoje = widget.habitoParaEditar!.feitoHoje;
    }
  }

  @override
  void dispose() {
    // Libera os controladores quando o widget é descartado
    _tituloController.dispose();
    _descricaoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  // Método para lidar com o salvamento ou atualização do hábito
  Future<void> _handleSalvarHabito() async {
    // Renomeado para português
    // Tira o foco para fechar o teclado
    FocusScope.of(context).unfocus();

    // Validação básica
    if (_tituloController.text.trim().isEmpty ||
        _descricaoController.text.trim().isEmpty) {
      _mostrarSnackBar('Título e Descrição são obrigatórios.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    String? mensagemErro; // Renomeado para português
    if (widget.habitoParaEditar == null) {
      // MODO ADICIONAR NOVO HÁBITO
      mensagemErro = await _habitService.adicionarHabito(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        frequencia: _frequenciaSelecionada,
        meta:
            _metaController.text.trim().isNotEmpty
                ? _metaController.text.trim()
                : null,
      );
    } else {
      // MODO EDITAR HÁBITO EXISTENTE
      // Cria um novo HabitoModel com os dados atualizados do formulário
      final HabitoModel habitoAtualizado = widget.habitoParaEditar!.copyWith(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        frequencia: _frequenciaSelecionada,
        meta:
            _metaController.text.trim().isNotEmpty
                ? _metaController.text.trim()
                : null,
        feitoHoje: _feitoHoje,
        // Atualiza ultimaConclusao se o status 'feitoHoje' mudou para true, ou zera se for false.
        ultimaConclusao:
            _feitoHoje
                ? (widget.habitoParaEditar!.ultimaConclusao ?? DateTime.now())
                : null,
      );

      mensagemErro = await _habitService.atualizarHabito(
        idHabito: widget.habitoParaEditar!.id,
        habitoAtualizado: habitoAtualizado,
      );
    }

    setState(() {
      _isLoading = false; // Desativa o indicador de carregamento
    });

    if (mensagemErro == null) {
      _mostrarSnackBar(
        widget.habitoParaEditar == null
            ? 'Hábito adicionado com sucesso!'
            : 'Hábito atualizado com sucesso!',
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
              widget.habitoParaEditar == null
                  ? 'Adicionar Novo Hábito'
                  : 'Editar Hábito',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Cor para o título do modal
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Checkbox "Feito hoje" (apenas no modo de edição)
            if (widget.habitoParaEditar != null) ...[
              CheckboxListTile(
                title: const Text('Concluído hoje?'), // Label em português
                value: _feitoHoje, // Variável em português
                onChanged: (val) {
                  setState(() {
                    _feitoHoje = val ?? false;
                  });
                },
                activeColor: Colors.green,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
            ],

            // Campo Título
            ClearField(
              label: 'Título do Hábito', // Label em português
              controller: _tituloController, // Controlador em português
              onLimpar: () => setState(() => _tituloController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.title),
                labelText: 'Título', // Label em português
              ),
            ),
            const SizedBox(height: 16),

            // Campo Descrição
            ClearField(
              label: 'Descrição (opcional)', // Label em português
              controller: _descricaoController, // Controlador em português
              onLimpar: () => setState(() => _descricaoController.clear()),
              maxLines: 3, // Permite múltiplas linhas
              keyboardType: TextInputType.multiline,
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.description),
                labelText: 'Descrição', // Label em português
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown Frequência
            DropdownButtonFormField<String>(
              value: _frequenciaSelecionada, // Variável em português
              decoration: inputDecoration.copyWith(
                labelText: 'Frequência', // Label em português
                prefixIcon: const Icon(Icons.repeat),
              ),
              items:
                  _frequencias.map((String frequencia) {
                    // Lista de frequências em português
                    return DropdownMenuItem<String>(
                      value: frequencia,
                      child: Text(frequencia),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _frequenciaSelecionada =
                      newValue!; // Atualiza variável em português
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo Meta
            ClearField(
              label:
                  'Meta (opcional - ex: 2000 ml, 3 livros)', // Label em português
              controller: _metaController, // Controlador em português
              onLimpar: () => setState(() => _metaController.clear()),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: inputDecoration.copyWith(
                prefixIcon: const Icon(Icons.track_changes),
                labelText: 'Meta (opcional - ex: 2000 ml, 3 livros'
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : _handleSalvarHabito, // Desabilita enquanto carrega
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
                widget.habitoParaEditar == null
                    ? 'Salvar Hábito'
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
