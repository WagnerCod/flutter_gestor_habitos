import 'package:flutter/material.dart';

// Este widget é um StatelessWidget, o que significa que ele não gerencia seu próprio estado interno.
// Ele apenas exibe informações e delega ações aos widgets pais.
class ClearField extends StatelessWidget {
  final String label; // Rótulo (hint) para o campo de texto
  final TextEditingController
  controller; // Controlador para gerenciar o texto do campo
  final VoidCallback?
  onLimpar; // Callback para quando o botão de limpar for pressionado
  final int? maxLines; // Novo parâmetro: número máximo de linhas.
  // Null permite múltiplas linhas automaticamente.
  final TextInputType?
  keyboardType; // Novo parâmetro: tipo de teclado a ser exibido.
  final InputDecoration?
  decoration; // Novo parâmetro: para customizar a decoração do campo.

  // Construtor do widget ClearField.
  // 'super.key' é passado para o construtor da classe pai.
  // 'required' indica que esses parâmetros são obrigatórios.
  // 'this.maxLines = 1' define 1 como valor padrão se não for especificado.
  const ClearField({
    super.key,
    required this.label,
    required this.controller,
    this.onLimpar,
    this.maxLines = 1, // Definido como 1 por padrão.
    this.keyboardType,
    this.decoration, // Aceita uma decoração externa.
  });

  @override
  // O método build descreve a parte da interface do usuário representada por este widget.
  // Ele retorna uma árvore de widgets que será renderizada na tela.
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Associa o controlador ao campo de texto.
      maxLines: maxLines, // Define o número máximo de linhas.
      keyboardType: keyboardType, // Define o tipo de teclado.
      // Define a decoração do campo de texto.
      // Se uma 'decoration' personalizada for fornecida, ela será usada.
      // Caso contrário, uma decoração padrão com borda arredondada será aplicada.
      decoration:
          decoration ??
          InputDecoration(
            labelText: label, // O rótulo do campo.
            border: const OutlineInputBorder(
              // Define uma borda ao redor do campo.
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ), // Cantos arredondados para a borda.
            ),
            // O 'suffixIcon' (ícone no final do campo) será um botão de limpar.
            // Ele só aparecerá se 'onLimpar' for fornecido E o campo de texto não estiver vazio.
            suffixIcon:
                onLimpar != null && controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ), // Ícone de "X" para limpar.
                      onPressed: onLimpar, // Ação ao pressionar o ícone.
                    )
                    : null, // Se não houver 'onLimpar' ou o campo estiver vazio, não mostra ícone.
          ),
      // O onChanged é chamado sempre que o texto do campo muda.
      // É importante para que o suffixIcon de limpar possa ser atualizado dinamicamente.
      // Embora ClearField seja StatelessWidget, a reconstrução do widget pai (AddEditExpenseModal)
      // ao chamar setState() irá reavaliar este build() e atualizar o ícone.
      onChanged: (text) {
        // Isso força o widget pai a reconstruir, o que é necessário para o suffixIcon
        // reagir à mudança de texto em um StatelessWidget como ClearField.
        // O setState do widget pai (AddEditExpenseModal) já lida com isso.
      },
    );
  }
}
