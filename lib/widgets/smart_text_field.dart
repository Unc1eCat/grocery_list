import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

typedef OnEditingCompleteCallback<T extends SmartTextFieldState> = void Function(T textField);

abstract class SmartTextFieldState extends State<SmartTextField> {
  TextEditingController get controller => throw StateError("This smart text field does not support text editing controller");
  FocusNode get focusNode => throw StateError("This smart text field does not support focus node");
}

class SmartTextField extends StatefulWidget {
  /// Depending on availability of [controller] an/or [focusNode] parameters widget will behave as described below:
  /// is null or not:
  ///
  /// - Only [focusNode] is not null - will set the provided focus node for the text field. The focus node can be accessed through the state of the text field that can be accessed through the global key.
  ///
  /// - Only [controller] is not null - will set the provided text editing controller for the text field. The text editing controller can be accessed through the state of the text field that can be accessed
  /// through the global key.
  ///
  /// - Both [focusNode] and [controller] are not null - will set these for the text field. They can be accessed through the state of the text field that can be accessed through the global key.
  ///
  /// The benefit of the text field is that it automatically stores and disposes its focus node and text editing controller. So you don't need a stateful widget to do it.
  /// [onEditingComplete] callback is called in conditions that the usual Flutter text field calls it in and when the text field is unfocused if a [focusNode] parameter is not null.
  const SmartTextField({
    GlobalKey key,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    @Deprecated(
      'Use maxLengthEnforcement parameter which provides more specific '
      'behavior related to the maxLength limit. '
      'This feature was deprecated after v1.25.0-5.0.pre.',
    )
        this.maxLengthEnforced = true,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.restorationId,
    this.keyboardType,
    this.smartDashesType,
    this.smartQuotesType,
    this.toolbarOptions,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;

  final FocusNode focusNode;

  final InputDecoration decoration;

  final TextInputType keyboardType;

  final TextInputAction textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle style;

  final StrutStyle strutStyle;

  final TextAlign textAlign;

  final TextAlignVertical textAlignVertical;

  final TextDirection textDirection;

  final bool autofocus;

  final String obscuringCharacter;

  final bool obscureText;

  final bool autocorrect;

  final SmartDashesType smartDashesType;

  final SmartQuotesType smartQuotesType;

  final bool enableSuggestions;

  final int maxLines;

  final int minLines;

  final bool expands;

  final bool readOnly;

  final ToolbarOptions toolbarOptions;

  final bool showCursor;

  static const int noMaxLength = -1;

  final int maxLength;

  @Deprecated(
    'Use maxLengthEnforcement parameter which provides more specific '
    'behavior related to the maxLength limit. '
    'This feature was deprecated after v1.25.0-5.0.pre.',
  )
  final bool maxLengthEnforced;

  final MaxLengthEnforcement maxLengthEnforcement;

  final ValueChanged<String> onChanged;

  /// Is also called when unfocused
  final OnEditingCompleteCallback onEditingComplete;

  final ValueChanged<String> onSubmitted;

  final AppPrivateCommandCallback onAppPrivateCommand;

  final List<TextInputFormatter> inputFormatters;

  final bool enabled;

  final double cursorWidth;

  final double cursorHeight;

  final Radius cursorRadius;

  final Color cursorColor;

  final ui.BoxHeightStyle selectionHeightStyle;

  final ui.BoxWidthStyle selectionWidthStyle;

  final Brightness keyboardAppearance;

  final EdgeInsets scrollPadding;

  final bool enableInteractiveSelection;

  final TextSelectionControls selectionControls;

  final DragStartBehavior dragStartBehavior;

  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback onTap;

  final MouseCursor mouseCursor;

  final InputCounterWidgetBuilder buildCounter;

  final ScrollPhysics scrollPhysics;

  final ScrollController scrollController;

  final Iterable<String> autofillHints;

  final String restorationId;

  @override
  State<SmartTextField> createState() {
    if (controller != null && focusNode != null) {
      return FullSmartTextFieldState();
    } else if (controller != null) {
      return ControllerSmartTextFieldState();
    } else if (focusNode != null) {
      return FocusNodeSmartTextFieldState();
    }
  }
}

class ControllerSmartTextFieldState extends SmartTextFieldState {
  TextEditingController _controller;

  @override
  TextEditingController get controller => _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _defaultOnSubmittedCallback(ValueChanged<String> val) {
    FocusScope.of(context)?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      toolbarOptions: widget.toolbarOptions,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforced: widget.maxLengthEnforced,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onEditingComplete: () => widget.onEditingComplete?.call(this),
      onSubmitted: widget.onSubmitted ?? _defaultOnSubmittedCallback,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      restorationId: widget.restorationId,
    );
  }
}

class FocusNodeSmartTextFieldState extends SmartTextFieldState {
  FocusNode _focusNode;

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = (widget.focusNode ?? FocusNode())..addListener(_handleOnEditingComplete);
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _handleOnEditingComplete() {
    widget.onEditingComplete?.call(this);
  }

  void _defaultOnSubmittedCallback(ValueChanged<String> val) {
    FocusScope.of(context)?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      toolbarOptions: widget.toolbarOptions,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforced: widget.maxLengthEnforced,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onEditingComplete: _handleOnEditingComplete,
      onSubmitted: widget.onSubmitted ?? _defaultOnSubmittedCallback,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      restorationId: widget.restorationId,
    );
  }
}

class FullSmartTextFieldState extends SmartTextFieldState {
  TextEditingController _controller;

  TextEditingController get controller => _controller;

  @override
  FocusNode _focusNode;

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _focusNode = (widget.focusNode ?? FocusNode())..addListener(_handleOnEditingComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleOnEditingComplete)
      ..dispose();

    super.dispose();
  }

  void _handleOnEditingComplete() {
    widget.onEditingComplete?.call(this);
  } // TODO: This and the below functions are copied in every class representing a variation of the smart text field. Make it only one declaration for on  function

  void _defaultOnSubmittedCallback(ValueChanged<String> val) {
    FocusScope.of(context)?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      toolbarOptions: widget.toolbarOptions,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforced: widget.maxLengthEnforced,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onEditingComplete: _handleOnEditingComplete,
      onSubmitted: widget.onSubmitted ?? _defaultOnSubmittedCallback,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      restorationId: widget.restorationId,
    );
  }
}
