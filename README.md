# Saborê — Aplicativo de Receitas

## Sobre o projeto

O Saborê é um aplicativo desenvolvido em Flutter para consultar receitas culinárias. O usuário pode visualizar receitas, pesquisar pelo nome, consultar ingredientes e modo de preparo e adicionar receitas aos favoritos.

O projeto foi desenvolvido como atividade acadêmica, utilizando a API pública DummyJSON Recipes.

## Funcionalidades

- Listagem de receitas com imagens e informações.
- Pesquisa de receitas pelo nome.
- Visualização de ingredientes e modo de preparo.
- Adição e remoção de favoritos durante a sessão.
- Indicador de carregamento.
- Mensagens de erro e opção de tentar novamente.
- Tratamento de pesquisas sem resultados.
- Navegação entre receitas, detalhes e favoritos.

## Tecnologias utilizadas

- **Flutter e Dart:** desenvolvimento do aplicativo.
- **Android Studio:** ambiente de desenvolvimento.
- **Biblioteca http:** requisições à API.
- **DummyJSON Recipes:** fornecimento dos dados das receitas.

API: https://dummyjson.com/docs/recipes

SDK utilizado: Flutter SDK (consultar versão com `flutter --version`).

## Como executar

É necessário ter o Flutter e o Android Studio configurados.

1. Abra o projeto no Android Studio.
2. No terminal, execute `flutter pub get` para instalar as dependências.
3. Inicie um emulador Android.
4. Execute `flutter run` para iniciar o aplicativo.

Para verificar o código, utilize `flutter analyze` e `flutter test`.

## Organização do código

O arquivo `lib/main.dart` contém as principais classes:

- **SaboreApp:** configuração inicial e aparência do aplicativo.
- **Receita:** representação dos dados das receitas.
- **ReceitasApi:** comunicação com a API.
- **InicioPage:** listagem, pesquisa e favoritos.
- **DetalhePage:** ingredientes e modo de preparo.

## Observações

As receitas são obtidas pela internet. Os favoritos são armazenados somente durante a sessão do aplicativo, sem banco de dados.