// import 'package:digit_components/digit_components.dart';
// import 'package:digit_components/widgets/atoms/digit_divider.dart';
// import 'package:digit_components/widgets/atoms/searchable_dropdown_field.dart';
// import 'package:flutter/material.dart';
// import 'package:reactive_forms/reactive_forms.dart';

// class DigitReactiveSearchDropdown<T> extends StatefulWidget {
//   final String label;
//   final List<T> menuItems;
//   final FormGroup form;
//   final String formControlName;
//   final bool isRequired;
//   final bool enabled;
//   final String Function(T value) valueMapper;
//   final String? validationMessage;
//   final EdgeInsets? padding;
//   final void Function(dynamic)? onSelected;
//   final void Function(dynamic)? onFieldTap;
//   final String emptyText;

//   const DigitReactiveSearchDropdown({
//     Key? key,
//     required this.label,
//     required this.form,
//     required this.menuItems,
//     required this.formControlName,
//     this.isRequired = false,
//     required this.valueMapper,
//     this.validationMessage,
//     this.padding,
//     this.onSelected,
//     this.onFieldTap,
//     this.emptyText = 'No Matches Found',
//     this.enabled = true,
//   }) : super(key: key);

//   @override
//   State<DigitReactiveSearchDropdown> createState() =>
//       _DigitReactiveSearchDropdownState();
// }

// class _DigitReactiveSearchDropdownState<T>
//     extends State<DigitReactiveSearchDropdown<T>> {
//   SearchDropdownEditingController<T>? controller =
//       SearchDropdownEditingController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LabeledField(
//       padding: widget.padding ?? const EdgeInsets.only(top: kPadding * 2),
//       label: '${widget.label}${widget.isRequired ? '*' : ''}',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SearchDropdownFormField<T>(
//             form: widget.form,
//             controller: controller,
//             enabled: widget.enabled,
//             formControlName: widget.formControlName,
//             emptyText: widget.emptyText,
//             displayItemFn: (dynamic str) => Text(
//               str != null ? widget.valueMapper(str) : '',
//               style: TextStyle(
//                   fontSize: 14,
//                   color: !widget.enabled
//                       ? const DigitColors().hintGrey
//                       : const DigitColors().woodsmokeBlack),
//             ),
//             findFn: (dynamic str) async => widget.menuItems,
//             filterFn: (dynamic item, str) => widget
//                 .valueMapper(item)
//                 .toLowerCase()
//                 .contains(str.toLowerCase()),
//             dropdownItemSeparator: const DigitDivider(),
//             dropdownItemFn:
//                 (dynamic item, position, focused, selected, onTap) => ListTile(
//               title: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Text(
//                     widget.valueMapper(item),
//                     style: TextStyle(
//                         color: selected
//                             ? DigitTheme.instance.colorScheme.secondary
//                             : DigitTheme.instance.colorScheme.onSurface,
//                         fontSize: 16),
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                 ],
//               ),
//               dense: true,
//               style: ListTileStyle.list,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               visualDensity: const VisualDensity(
//                   horizontal: VisualDensity.minimumDensity,
//                   vertical: VisualDensity.minimumDensity),
//               tileColor: focused
//                   ? DigitTheme.instance.colorScheme.surface
//                   : Colors.transparent,
//               onTap: !widget.enabled
//                   ? null
//                   : () {
//                       widget.form.control(widget.formControlName).value = item;
//                       onTap();
//                       if (widget.onSelected != null) {
//                         widget.onSelected!(item);
//                       }
//                     },
//             ),
//             onFieldTap: !widget.enabled
//                 ? null
//                 : () {
//                     widget.form.control(widget.formControlName).value = null;
//                     if (widget.isRequired) {
//                       widget.form
//                           .control(widget.formControlName)
//                           .setErrors({'': true});
//                     }
//                     if (widget.onFieldTap != null) {
//                       widget.onFieldTap!(null);
//                     }
//                   },
//           ),
//           ReactiveFormConsumer(
//             builder: (context, form, child) {
//               final formControl = widget.form.control(widget.formControlName);
//               if (formControl.hasErrors) {
//                 return Text(
//                   widget.validationMessage ?? '',
//                   style: TextStyle(
//                     color: DigitTheme.instance.colorScheme.error,
//                     fontSize: 12,
//                   ),
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }



// integration of voice commnad in the digit reactive search dropdown

// // import 'package:digit_components/digit_components.dart';
// // import 'package:digit_components/widgets/atoms/digit_divider.dart';
// // import 'package:digit_components/widgets/atoms/searchable_dropdown_field.dart';
// // import 'package:flutter/material.dart';
// // import 'package:reactive_forms/reactive_forms.dart';

// // class DigitReactiveSearchDropdown<T> extends StatefulWidget {
// //   final String label;
// //   final List<T> menuItems;
// //   final FormGroup form;
// //   final String formControlName;
// //   final bool isRequired;
// //   final bool enabled;
// //   final String Function(T value) valueMapper;
// //   final String? validationMessage;
// //   final EdgeInsets? padding;
// //   final void Function(dynamic)? onSelected;
// //   final void Function(dynamic)? onFieldTap;
// //   final String emptyText;

// //   const DigitReactiveSearchDropdown({
// //     Key? key,
// //     required this.label,
// //     required this.form,
// //     required this.menuItems,
// //     required this.formControlName,
// //     this.isRequired = false,
// //     required this.valueMapper,
// //     this.validationMessage,
// //     this.padding,
// //     this.onSelected,
// //     this.onFieldTap,
// //     this.emptyText = 'No Matches Found',
// //     this.enabled = true,
// //   }) : super(key: key);

// //   @override
// //   State<DigitReactiveSearchDropdown> createState() =>
// //       _DigitReactiveSearchDropdownState();
// // }

// // class _DigitReactiveSearchDropdownState<T>
// //     extends State<DigitReactiveSearchDropdown<T>> {
// //   SearchDropdownEditingController<T>? controller =
// //       SearchDropdownEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return LabeledField(
// //       padding: widget.padding ?? const EdgeInsets.only(top: kPadding * 2),
// //       label: '${widget.label}${widget.isRequired ? '*' : ''}',
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SearchDropdownFormField<T>(
// //             form: widget.form,
// //             controller: controller,
// //             enabled: widget.enabled,
// //             formControlName: widget.formControlName,
// //             emptyText: widget.emptyText,
// //             displayItemFn: (dynamic str) => Text(
// //               str != null ? widget.valueMapper(str) : '',
// //               style: TextStyle(
// //                   fontSize: 14,
// //                   color: !widget.enabled
// //                       ? const DigitColors().hintGrey
// //                       : const DigitColors().woodsmokeBlack),
// //             ),
// //             findFn: (dynamic str) async => widget.menuItems,
// //             filterFn: (dynamic item, str) => widget
// //                 .valueMapper(item)
// //                 .toLowerCase()
// //                 .contains(str.toLowerCase()),
// //             dropdownItemSeparator: const DigitDivider(),
// //             dropdownItemFn:
// //                 (dynamic item, position, focused, selected, onTap) => ListTile(
// //               title: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   const SizedBox(
// //                     height: 8,
// //                   ),
// //                   Text(
// //                     widget.valueMapper(item),
// //                     style: TextStyle(
// //                         color: selected
// //                             ? DigitTheme.instance.colorScheme.secondary
// //                             : DigitTheme.instance.colorScheme.onSurface,
// //                         fontSize: 16),
// //                   ),
// //                   const SizedBox(
// //                     height: 8,
// //                   ),
// //                 ],
// //               ),
// //               dense: true,
// //               style: ListTileStyle.list,
// //               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
// //               visualDensity: const VisualDensity(
// //                   horizontal: VisualDensity.minimumDensity,
// //                   vertical: VisualDensity.minimumDensity),
// //               tileColor: focused
// //                   ? DigitTheme.instance.colorScheme.surface
// //                   : Colors.transparent,
// //               onTap: !widget.enabled
// //                   ? null
// //                   : () {
// //                       widget.form.control(widget.formControlName).value = item;
// //                       onTap();
// //                       if (widget.onSelected != null) {
// //                         widget.onSelected!(item);
// //                       }
// //                     },
// //             ),
// //             onFieldTap: !widget.enabled
// //                 ? null
// //                 : () {
// //                     widget.form.control(widget.formControlName).value = null;
// //                     if (widget.isRequired) {
// //                       widget.form
// //                           .control(widget.formControlName)
// //                           .setErrors({'': true});
// //                     }
// //                     if (widget.onFieldTap != null) {
// //                       widget.onFieldTap!(null);
// //                     }
// //                   },
// //           ),
// //           ReactiveFormConsumer(
// //             builder: (context, form, child) {
// //               final formControl = widget.form.control(widget.formControlName);
// //               if (formControl.hasErrors) {
// //                 return Text(
// //                   widget.validationMessage ?? '',
// //                   style: TextStyle(
// //                     color: DigitTheme.instance.colorScheme.error,
// //                     fontSize: 12,
// //                   ),
// //                 );
// //               } else {
// //                 return const SizedBox.shrink();
// //               }
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_divider.dart';
import 'package:digit_components/widgets/atoms/searchable_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DigitReactiveSearchDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> menuItems;
  final FormGroup form;
  final String formControlName;
  final bool isRequired;
  final bool enabled;
  final String Function(T value) valueMapper;
  final String? validationMessage;
  final EdgeInsets? padding;
  final void Function(dynamic)? onSelected;
  final void Function(dynamic)? onFieldTap;
  final String emptyText;
  final bool enableVoiceCommand;

  const DigitReactiveSearchDropdown({
    Key? key,
    required this.label,
    required this.form,
    required this.menuItems,
    required this.formControlName,
    this.isRequired = false,
    required this.valueMapper,
    this.validationMessage,
    this.padding,
    this.onSelected,
    this.onFieldTap,
    this.emptyText = 'No Matches Found',
    this.enabled = true,
    this.enableVoiceCommand = false,
  }) : super(key: key);

  @override
  State<DigitReactiveSearchDropdown> createState() =>
      _DigitReactiveSearchDropdownState();
}

class _DigitReactiveSearchDropdownState<T>
    extends State<DigitReactiveSearchDropdown<T>> {
  SearchDropdownEditingController<T>? controller =
      SearchDropdownEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    if (widget.enableVoiceCommand) {
      _speech = stt.SpeechToText();
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _selectDropdownItem();
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _selectDropdownItem() {
    final matchedItem = widget.menuItems.cast<T?>().firstWhere(
      (item) => widget.valueMapper(item!).toLowerCase() == _text.toLowerCase(),
      orElse: () => null,
    );

    if (matchedItem != null) {
      widget.form.control(widget.formControlName).value = matchedItem;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching item found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      padding: widget.padding ?? const EdgeInsets.only(top: kPadding * 2),
      label: '${widget.label}${widget.isRequired ? '*' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SearchDropdownFormField<T>(
            form: widget.form,
            controller: controller,
            enabled: widget.enabled,
            formControlName: widget.formControlName,
            emptyText: widget.emptyText,
            displayItemFn: (dynamic str) => Text(
              str != null ? widget.valueMapper(str) : '',
              style: TextStyle(
                  fontSize: 14,
                  color: !widget.enabled
                      ? const DigitColors().hintGrey
                      : const DigitColors().woodsmokeBlack),
            ),
            findFn: (dynamic str) async => widget.menuItems,
            filterFn: (dynamic item, str) => widget
                .valueMapper(item)
                .toLowerCase()
                .contains(str.toLowerCase()),
            dropdownItemSeparator: const DigitDivider(),
            dropdownItemFn:
                (dynamic item, position, focused, selected, onTap) => ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.valueMapper(item),
                    style: TextStyle(
                        color: selected
                            ? DigitTheme.instance.colorScheme.secondary
                            : DigitTheme.instance.colorScheme.onSurface,
                        fontSize: 16),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              dense: true,
              style: ListTileStyle.list,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity),
              tileColor: focused
                  ? DigitTheme.instance.colorScheme.surface
                  : Colors.transparent,
              onTap: !widget.enabled
                  ? null
                  : () {
                      widget.form.control(widget.formControlName).value = item;
                      onTap();
                      if (widget.onSelected != null) {
                        widget.onSelected!(item);
                      }
                    },
            ),
            onFieldTap: !widget.enabled
                ? null
                : () {
                    widget.form.control(widget.formControlName).value = null;
                    if (widget.isRequired) {
                      widget.form
                          .control(widget.formControlName)
                          .setErrors({'': true});
                    }
                    if (widget.onFieldTap != null) {
                      widget.onFieldTap!(null);
                    }
                  },
          ),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              final formControl = widget.form.control(widget.formControlName);
              if (formControl.hasErrors) {
                return Text(
                  widget.validationMessage ?? '',
                  style: TextStyle(
                    color: DigitTheme.instance.colorScheme.error,
                    fontSize: 12,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          if (widget.enableVoiceCommand)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _listen,
              ),
            ),
        ],
      ),
    );
  }
}
