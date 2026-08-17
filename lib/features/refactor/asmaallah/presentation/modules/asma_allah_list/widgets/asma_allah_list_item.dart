import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';

/// A single name-of-Allah card. Equivalent of the legacy `AsmaAllah` widget,
/// but stateless — expand/collapse state now lives in
/// [AsmaAllahListViewModel] instead of being duplicated locally.
class AsmaAllahListItem extends StatelessWidget {
  const AsmaAllahListItem({
    super.key,
    required this.asmaAllah,
    required this.fontSize,
    required this.showDescription,
    required this.onTap,
  });

  final AsmaAllahEntity asmaAllah;
  final double fontSize;
  final bool showDescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: size.width,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: teal[100],
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: _buildNumberField(),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 10.0, left: 10.0, right: 10.0),
                  child: Column(
                    children: <Widget>[
                      _buildNameField(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildDescriptionButton(),
                      ),
                      if (showDescription) _buildDescriptionField(size),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[200],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Text(
        '${asmaAllah.id}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal[700],
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        asmaAllah.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildDescriptionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: showDescription ? teal[200] : Colors.transparent,
        border: Border.all(color: teal[200] ?? const Color(0xFFCEEDEA)),
        borderRadius: showDescription
            ? const BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))
            : BorderRadius.circular(10),
      ),
      child: Text(
        'المعني',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal[700],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          asmaAllah.description,
          style: TextStyle(
            color: teal[600],
            fontSize: fontSize - 2,
          ),
        ),
      ),
    );
  }
}
