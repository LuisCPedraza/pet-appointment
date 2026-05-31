import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';
import 'package:pet_appointment/widgets/semantics_wrapper.dart';

/// Tarjeta para escoger el profesional que atenderá la cita.
class ProfessionalSelectorCard extends StatefulWidget {
  const ProfessionalSelectorCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<ProfessionalSelectorCard> createState() =>
      _ProfessionalSelectorCardState();
}

class _ProfessionalSelectorCardState extends State<ProfessionalSelectorCard> {
  String _query = '';

  void _onQueryChanged(String q) => setState(() => _query = q.trim());

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final all = controller.professionals;
    final visible = _query.isEmpty
        ? all
        : all.where((p) {
            final name = (p['full_name'] ?? '').toLowerCase();
            final email = (p['email'] ?? '').toLowerCase();
            final q = _query.toLowerCase();
            return name.contains(q) || email.contains(q);
          }).toList();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Profesional'),
          const SizedBox(height: 8),
          _ProfessionalFilter(
            key: const Key('professional-filter'),
            onQueryChanged: _onQueryChanged,
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text(
              'No hay profesionales activos disponibles.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: visible.map((professional) {
                  final id = professional['id'] ?? '';
                  final name = professional['full_name'] ?? 'Profesional';
                  final email = professional['email'] ?? '';
                  final selected = controller.selectedProfessionalId == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ProfessionalChip(
                      label: name,
                      sublabel: email,
                      selected: selected,
                      onTap: () =>
                          controller.changeProfessional(selected ? null : id),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfessionalFilter extends StatefulWidget {
  const _ProfessionalFilter({super.key, required this.onQueryChanged});

  final ValueChanged<String> onQueryChanged;

  @override
  State<_ProfessionalFilter> createState() => _ProfessionalFilterState();
}

class _ProfessionalFilterState extends State<_ProfessionalFilter> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Buscar profesional por nombre o email',
            suffixIcon: SemanticsWrapper(
              label: 'Buscar profesional',
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  final q = _controller.text.trim();
                  setState(() {});
                  widget.onQueryChanged(q);
                },
              ),
            ),
          ),
          onSubmitted: (v) {
            final q = v.trim();
            setState(() {});
            widget.onQueryChanged(q);
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: const Text('Limpiar'),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onQueryChanged('');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: const Text('Solo activos'),
                  onPressed: () {
                    // placeholder: backend already filters active by default
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filtro "Solo activos" aplicado'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Replace the controller list with filtered results by mutating a view-level field
        Builder(
          builder: (ctx) {
            // Draw nothing here; the parent will still use controller.professionals.
            // We keep filtered local to the UI for now.
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ProfessionalChip extends StatelessWidget {
  const _ProfessionalChip({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : Border.all(color: AppColors.outline.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            if (sublabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
