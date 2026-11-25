import 'config_packages.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final TextStyle? style;
  final bool? readOnly;
  final TextStyle? hintStyle;
  final Function()? onTap;
  final Color? borderColor;
  final Color? fillColor;
  final double? radius;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final bool? isDense;
  final int? minLines;
  final Color? cursorColor;

  final bool? autocorrect;
  final bool? enableSuggestions;

  const CommonTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.maxLines,
    this.keyboardType,
    this.validator,
    this.obscureText,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.inputFormatters,
    this.readOnly,
    this.fillColor,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.hintStyle,
    this.borderColor,
    this.radius,
    this.style,
    this.isDense,
    this.minLines,
    this.cursorColor,
    this.autocorrect,
    this.enableSuggestions,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool _showError = true;
  bool _isInternalValidate = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {}

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      onChanged: (val) {
        if (widget.onChanged != null) {
          widget.onChanged!(val);
        }
        if (_errorText != null) {
          setState(() {
            _showError = false;
            _errorText = null;
          });
          _isInternalValidate = true;
          _fieldKey.currentState?.validate();
          _isInternalValidate = false;
        }
      },
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      focusNode: _effectiveFocusNode,
      cursorColor: widget.cursorColor ?? AppColors.blackColor,
      readOnly: widget.readOnly ?? false,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      autocorrect: widget.autocorrect ?? false,
      enableSuggestions:
          widget.enableSuggestions ??
          (widget.keyboardType != TextInputType.emailAddress &&
              widget.keyboardType != TextInputType.visiblePassword),
      controller: widget.controller,
      obscureText: widget.obscureText ?? false,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines ?? 1,
      style:
          widget.style ??
          TextStyle(
            fontSize: 14.sp,
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.w500,
          ).copyWith(decorationThickness: 0),
      textCapitalization: (widget.keyboardType == TextInputType.name)
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      decoration: InputDecoration(
        isDense: widget.isDense ?? false,
        errorStyle: TextStyle(fontSize: 12.sp, height: 1.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.borderColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.borderColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        suffixIcon: widget.suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: widget.suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: widget.prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        filled: true,
        fillColor:
            widget.fillColor ??
            ((widget.readOnly == true)
                ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9))
                : AppColors.getTextFieldColor(context)),
        hintText: widget.hintText ?? "",
        hintStyle:
            widget.hintStyle ??
            TextStyles.regular(
              12,
              fontColor: AppColors.greyColor,
              textOverflow: TextOverflow.ellipsis,
            ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      ),
      validator: (value) {
        if (widget.validator != null) {
          if (!_isInternalValidate) {
            _showError = true;
          }
          final err = widget.validator!(value);
          if (err != null) {
            if (_showError) {
              if (err != _errorText) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _errorText = err;
                    });
                  }
                });
              }
              return err;
            }
          } else {
            if (_errorText != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _errorText = null;
                    _showError = false;
                  });
                }
              });
            }
          }
        }
        return null;
      },
      onFieldSubmitted: widget.onFieldSubmitted,
      inputFormatters:
          widget.inputFormatters ?? [MultipleSpaceBlockingFormatter()],
    );
  }
}
