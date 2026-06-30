import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/tarifario/tarifario_confianza.dart';
import '../../../core/utils/credit_calculator.dart';
import '../../../core/utils/format_utils.dart';

class NuevaSolicitudView extends ConsumerStatefulWidget {
  const NuevaSolicitudView({super.key});

  @override
  ConsumerState<NuevaSolicitudView> createState() => _NuevaSolicitudViewState();
}

class _NuevaSolicitudViewState extends ConsumerState<NuevaSolicitudView> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController(text: '1000');
  final _plazoController = TextEditingController(text: '12');
  final _destinoController = TextEditingController(text: 'Capital de trabajo');
  final _ingresosController = TextEditingController();
  final _gastosController = TextEditingController();

  bool _submitting = false;
  bool _conDesgravamen = false;
  double _cuotaEstimada = 0;

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_recalcularCuota);
    _plazoController.addListener(_recalcularCuota);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillIngresos());
  }

  void _prefillIngresos() {
    final cliente = ref.read(clienteSessionProvider);
    if (cliente == null) return;
    final ingresos = cliente['ingresos_estimados'];
    if (ingresos != null) {
      _ingresosController.text = ingresos.toString();
    }
    _recalcularCuota();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _plazoController.dispose();
    _destinoController.dispose();
    _ingresosController.dispose();
    _gastosController.dispose();
    super.dispose();
  }

  void _recalcularCuota() {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final plazo = int.tryParse(_plazoController.text) ?? 0;
    final tea = _conDesgravamen
        ? TarifarioConfianza.teaConDesgravamen
        : TarifarioConfianza.teaSinDesgravamen;
    setState(() {
      _cuotaEstimada = CreditCalculator.cuotaFrancesa(
        monto: monto,
        plazoMeses: plazo,
        teaPercent: tea,
      );
    });
  }

  Future<String?> _resolverAsesorId(Map<String, dynamic> cliente) async {
    final directo = cliente['asesor_id'];
    if (directo != null) return directo.toString();

    final agenciaId = cliente['agencia_id'];
    if (agenciaId == null) return null;

    final asesor = await supabase
        .from('asesores_negocio')
        .select('id')
        .eq('agencia_id', agenciaId)
        .limit(1)
        .maybeSingle();

    return asesor?['id']?.toString();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final cliente = ref.read(clienteSessionProvider);
    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión no disponible')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final monto = double.parse(_montoController.text);
      final plazo = int.parse(_plazoController.text);
      final ingresos = double.parse(_ingresosController.text);
      final gastos = double.parse(_gastosController.text);
      final errores = TarifarioConfianza.validarSolicitud(
        monto: monto,
        plazoMeses: plazo,
        tipoNegocio: cliente['tipo_negocio']?.toString(),
      );
      if (errores.isNotEmpty) {
        throw Exception(errores.join('. '));
      }

      final tea = _conDesgravamen
          ? TarifarioConfianza.teaConDesgravamen
          : TarifarioConfianza.teaSinDesgravamen;
      final cuota = CreditCalculator.cuotaFrancesa(
        monto: monto,
        plazoMeses: plazo,
        teaPercent: tea,
      );

      final asesorId = await _resolverAsesorId(cliente);
      if (asesorId == null) {
        throw Exception('No hay asesor asignado para su agencia');
      }

      final expediente = 'EXP${DateTime.now().millisecondsSinceEpoch}';
      final solicitud = await supabase
          .from('solicitudes_credito')
          .insert({
            'cliente_id': cliente['id'],
            'asesor_id': asesorId,
            'agencia_id': cliente['agencia_id'],
            'tipo_negocio': cliente['tipo_negocio'] ?? 'microempresa',
            'nombre_negocio': cliente['nombre_negocio'],
            'antiguedad_negocio_meses': cliente['antiguedad_negocio_meses'],
            'ingresos_estimados': ingresos,
            'gastos_mensuales': gastos,
            'monto_solicitado': monto,
            'plazo_meses': plazo,
            'moneda': 'PEN',
            'tipo_cuota': 'mensual',
            'garantia': 'sin_garantia',
            'destino_credito': _destinoController.text.trim(),
            'cuota_estimada': double.parse(cuota.toStringAsFixed(2)),
            'tea_referencial': tea,
            'estado': 'enviado',
            'canal_origen': 'cliente_app',
            'pendiente_sync': true,
            'numero_expediente': expediente,
            'con_desgravamen': _conDesgravamen,
          })
          .select()
          .single();

      final solicitudId = solicitud['id'];

      try {
        await supabase.from('cartera_diaria').insert({
          'asesor_id': asesorId,
          'cliente_id': cliente['id'],
          'tipo_gestion': 'NUEVA_SOLICITUD',
          'prioridad': 'alta',
          'estado_visita': 'pendiente',
          'solicitud_id': solicitudId,
          'observaciones': 'Solicitud registrada desde app cliente',
        });
      } catch (_) {
        // Cartera puede existir; no bloquea el flujo.
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada al asesor')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = TarifarioConfianza.resolverProducto();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva solicitud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                producto.nombre,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto (S/)',
                  helperText:
                      'Mín. S/ ${producto.montoMin.toStringAsFixed(0)} · Máx. S/ ${producto.montoMax.toStringAsFixed(0)}',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plazoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Plazo (meses)',
                  helperText:
                      '${producto.plazoMinMeses} - ${producto.plazoMaxMeses} meses',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(
                  labelText: 'Destino del crédito',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingresosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ingresos mensuales (S/)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gastosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gastos mensuales (S/)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              SwitchListTile(
                title: const Text('Incluir desgravamen'),
                subtitle: Text(
                  'TEA ${TarifarioConfianza.teaConDesgravamen}% vs ${TarifarioConfianza.teaSinDesgravamen}% sin desgravamen',
                ),
                value: _conDesgravamen,
                onChanged: (v) {
                  setState(() => _conDesgravamen = v);
                  _recalcularCuota();
                },
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuota estimada',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        FormatUtils.currency(_cuotaEstimada),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_submitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _enviar,
                  child: const Text('Enviar solicitud'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
