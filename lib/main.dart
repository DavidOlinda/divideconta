import 'package:flutter/material.dart';

void main() {
  runApp(const DivideContaApp());
}

class DivideContaApp extends StatelessWidget {
  const DivideContaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DivideConta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      ),
      home: const CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  final _valorContaController = TextEditingController();
  final _quantidadePessoasController = TextEditingController();
  final _percentualComissaoController = TextEditingController();

  String? _erroValorConta;
  String? _erroQuantidadePessoas;
  String? _erroPercentualComissao;

  double? _comissaoGarcom;
  double? _valorTotalAPagar;
  double? _valorPorPessoa;

  @override
  void dispose() {
    _valorContaController.dispose();
    _quantidadePessoasController.dispose();
    _percentualComissaoController.dispose();
    super.dispose();
  }

  double? _parseDouble(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  void _validarValorConta(String texto) {
    final textoLimpo = texto.trim();
    final valor = _parseDouble(textoLimpo);
    setState(() {
      if (textoLimpo.isEmpty) {
        _erroValorConta = 'Campo obrigatório';
      } else if (valor == null) {
        _erroValorConta = 'Valor inválido';
      } else if (valor < 0) {
        _erroValorConta = 'O valor não pode ser negativo';
      } else {
        _erroValorConta = null;
      }
    });
  }

  void _validarQuantidadePessoas(String texto) {
    final textoLimpo = texto.trim();
    final quantidade = int.tryParse(textoLimpo);
    setState(() {
      if (textoLimpo.isEmpty) {
        _erroQuantidadePessoas = 'Campo obrigatório';
      } else if (quantidade == null) {
        _erroQuantidadePessoas = 'Valor inválido';
      } else if (quantidade <= 0) {
        _erroQuantidadePessoas = 'Informe pelo menos 1 pessoa';
      } else {
        _erroQuantidadePessoas = null;
      }
    });
  }

  void _validarPercentualComissao(String texto) {
    final textoLimpo = texto.trim();
    final percentual = _parseDouble(textoLimpo);
    setState(() {
      if (textoLimpo.isEmpty) {
        _erroPercentualComissao = 'Campo obrigatório';
      } else if (percentual == null) {
        _erroPercentualComissao = 'Valor inválido';
      } else if (percentual < 0 || percentual > 100) {
        _erroPercentualComissao = 'Informe um percentual entre 0 e 100';
      } else {
        _erroPercentualComissao = null;
      }
    });
  }

  bool get _formularioValido =>
      _erroValorConta == null &&
      _erroQuantidadePessoas == null &&
      _erroPercentualComissao == null &&
      _valorContaController.text.trim().isNotEmpty &&
      _quantidadePessoasController.text.trim().isNotEmpty &&
      _percentualComissaoController.text.trim().isNotEmpty;

  /// Formata um valor double como moeda brasileira (ex.: 1234.5 -> "R$ 1.234,50"),
  /// sem depender do pacote intl.
  String _formatarMoeda(double valor) {
    final valorFixado = valor.toStringAsFixed(2);
    final partes = valorFixado.split('.');
    final parteInteira = partes[0];
    final parteDecimal = partes[1];

    final buffer = StringBuffer();
    for (var i = 0; i < parteInteira.length; i++) {
      final posicaoDaDireita = parteInteira.length - i;
      if (i > 0 && posicaoDaDireita % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parteInteira[i]);
    }

    return 'R\$ $buffer,$parteDecimal';
  }

  void _calcular() {
    final valorTotalConta = _parseDouble(_valorContaController.text)!;
    final quantidadePessoas =
        int.parse(_quantidadePessoasController.text.trim());
    final percentualComissao =
        _parseDouble(_percentualComissaoController.text)!;

    final comissaoGarcom = valorTotalConta * (percentualComissao / 100);
    final valorTotalAPagar = valorTotalConta + comissaoGarcom;
    final valorPorPessoa = valorTotalAPagar / quantidadePessoas;

    setState(() {
      _comissaoGarcom = comissaoGarcom;
      _valorTotalAPagar = valorTotalAPagar;
      _valorPorPessoa = valorPorPessoa;
    });
  }

  @override
  Widget build(BuildContext context) {
    final temResultado = _valorPorPessoa != null && _formularioValido;

    return Scaffold(
      appBar: AppBar(title: const Text('DivideConta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Divida a conta do bar',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Informe os dados abaixo para calcular o valor de cada '
                'pessoa, já com a comissão do garçom incluída.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _valorContaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _validarValorConta,
                decoration: InputDecoration(
                  labelText: 'Valor total da conta',
                  hintText: 'Ex.: 150,00',
                  border: const OutlineInputBorder(),
                  errorText: _erroValorConta,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantidadePessoasController,
                keyboardType: TextInputType.number,
                onChanged: _validarQuantidadePessoas,
                decoration: InputDecoration(
                  labelText: 'Quantidade de pessoas',
                  hintText: 'Ex.: 4',
                  border: const OutlineInputBorder(),
                  errorText: _erroQuantidadePessoas,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _percentualComissaoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _validarPercentualComissao,
                decoration: InputDecoration(
                  labelText: 'Comissão do garçom (%)',
                  hintText: 'Ex.: 10',
                  border: const OutlineInputBorder(),
                  errorText: _erroPercentualComissao,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _formularioValido ? _calcular : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Calcular', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (temResultado) ...[
                const SizedBox(height: 24),
                _ResultadoCard(
                  comissaoGarcom: _formatarMoeda(_comissaoGarcom!),
                  valorTotalAPagar: _formatarMoeda(_valorTotalAPagar!),
                  valorPorPessoa: _formatarMoeda(_valorPorPessoa!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  const _ResultadoCard({
    required this.comissaoGarcom,
    required this.valorTotalAPagar,
    required this.valorPorPessoa,
  });

  final String comissaoGarcom;
  final String valorTotalAPagar;
  final String valorPorPessoa;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Comissão do garçom: $comissaoGarcom'),
            const SizedBox(height: 8),
            Text('Total a pagar: $valorTotalAPagar'),
            const SizedBox(height: 8),
            Text(
              'Valor por pessoa: $valorPorPessoa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
