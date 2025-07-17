Gestor de Hábitos & Finanças
Descrição do Projeto
O "Gestor de Hábitos & Finanças" é um aplicativo Flutter multifuncional desenvolvido para auxiliar usuários na organização e acompanhamento de seus hábitos diários, bem como no gerenciamento de suas finanças pessoais, registrando despesas e receitas.

Funcionalidades Principais:

Autenticação de Usuário:

Registro de novos usuários com e-mail e senha.

Login seguro com e-mail e senha.

Persistência de sessão (usuário permanece logado até fazer logout).

(Opcional) Integração com Google Sign-In (necessita de configuração adicional de credenciais OAuth no Google Cloud Console).

Gestão de Hábitos:

Visualização de uma lista de hábitos cadastrados.

Adição de novos hábitos via modal (título, descrição, frequência, meta).

Edição de hábitos existentes via modal (alterar dados, marcar como "feito hoje").

Exclusão de hábitos.

Filtragem de hábitos por usuário logado.

Gestão de Despesas:

Visualização de uma lista de despesas registradas.

Contabilizador de Despesas: Exibe o total das despesas do usuário.

Adição de novas despesas via modal (descrição, valor, categoria, data).

Edição de despesas existentes via modal.

Exclusão de despesas.

Filtragem de despesas por usuário logado.

Gestão de Receitas:

Visualização de uma lista de receitas registradas.

Contabilizador de Receitas: Exibe o total das receitas do usuário.

Adição de novas receitas via modal (descrição, valor, categoria, data).

Edição de receitas existentes via modal.

Exclusão de receitas.

Filtragem de receitas por usuário logado.

Página de Perfil:

Visualização do email do usuário logado.

Atualização do nome de usuário.

Adição, atualização e remoção de foto de perfil (armazenada no Firebase Storage).

Botão de Logout.

Navegação:

Barra de navegação inferior (BottomNavigationBar) para alternar entre as seções de Hábitos, Despesas, Receitas e Perfil.

Internacionalização (Localização):

Configuração básica para pt_BR (Português do Brasil) para widgets como DatePicker.

Como Rodar o Projeto Localmente
Siga estas instruções detalhadas para configurar e executar o aplicativo em seu ambiente de desenvolvimento.

Pré-requisitos
Flutter SDK: Versão 3.7.2 ou superior.

Android Studio / VS Code: Com os plugins Flutter e Dart instalados.

Java Development Kit (JDK): Versão 17 ou superior (ex: OpenJDK 17).

Conta Google: Para configurar o Firebase.