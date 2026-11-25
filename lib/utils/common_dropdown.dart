import 'config_packages.dart';

class CommonDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? Function(T?)? validator;
  final double? radius;
  final double? height;

  const CommonDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.radius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      valueListenable: ValueNotifier<T?>(value),
      hint: hintText != null
          ? Text(
              hintText!,
              style: TextStyles.regular(12, fontColor: AppColors.greyColor),
            )
          : null,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.getTextFieldColor(context),
        contentPadding: EdgeInsets.zero,
        errorStyle: TextStyle(fontSize: 12.sp, height: 1.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.getSecondaryTextColor(context),
            size: 20.sp,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      ),
      style: TextStyles.medium(14, fontColor: AppColors.getTextColor(context)),
      items: items
          .map(
            (item) => DropdownItem<T>(
              value: item,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  itemToString(item),
                  style: TextStyles.medium(
                    14,
                    fontColor: AppColors.getTextColor(context),
                  ),
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (BuildContext context) {
        return items
            .map(
              (item) => Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  itemToString(item),
                  style: TextStyles.medium(
                    14,
                    fontColor: AppColors.getTextColor(context),
                  ),
                ),
              ),
            )
            .toList();
      },
      validator: validator,
      onChanged: onChanged,
      buttonStyleData: FormFieldButtonStyleData(
        padding: EdgeInsets.only(left: 16.w, right: 40.w),
        height: height ?? 56.h,
      ),
      iconStyleData: const IconStyleData(
        icon: SizedBox.shrink(),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 14.r),
          color: AppColors.getCardColor(context),
        ),
        elevation: 8,
        offset: const Offset(0, -4),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.zero,
      ),
    );
  }
}
