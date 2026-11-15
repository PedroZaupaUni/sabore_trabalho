import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/main.dart';

void main() {
  test('Converte os dados JSON em uma receita', () {
    final receita = Receita.fromJson({
      'id': 1,
      'name': 'Classic Margherita Pizza',
      'ingredients': ['Massa de pizza', 'Molho de tomate'],
      'instructions': ['Preaqueça o forno.'],
      'prepTimeMinutes': 20,
      'cookTimeMinutes': 15,
      'servings': 4,
      'rating': 4.6,
    });

    expect(receita.id, 1);
    expect(receita.nome, 'Classic Margherita Pizza');
    expect(receita.ingredientes.length, 2);
    expect(receita.instrucoes.length, 1);
    expect(receita.tempo, 35);
    expect(receita.porcoes, 4);
    expect(receita.avaliacao, 4.6);
  });

  test('Rejeita receitas sem nome', () {
    expect(
      () => Receita.fromJson({'id': 2, 'name': ''}),
      throwsFormatException,
    );
  });
}
