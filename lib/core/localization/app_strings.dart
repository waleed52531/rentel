import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/entities.dart';
import '../preferences/app_preferences_cubit.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isUrdu => language == AppLanguage.urdu;

  String text(String english) {
    if (!isUrdu) return english;
    return _urdu[english] ?? english;
  }
}

extension AppStringsX on BuildContext {
  AppStrings get strings =>
      AppStrings(watch<AppPreferencesCubit>().state.language);

  String tr(String english) => strings.text(english);
}

const _urdu = <String, String>{
  'Proof • Approval • Frozen History': 'ثبوت • منظوری • محفوظ ریکارڈ',
  'Proof - Approval - Frozen History': 'ثبوت - منظوری - محفوظ ریکارڈ',
  'Rentra login': 'رینٹرا لاگ اِن',
  'Sign in with your email and password. Rentra will open the right workspace for your account.':
      'اپنے ای میل اور پاس ورڈ سے لاگ اِن کریں۔ رینٹرا آپ کے اکاؤنٹ کے مطابق درست ورک اسپیس کھول دے گا۔',
  'Email': 'ای میل',
  'Password': 'پاس ورڈ',
  'Enter your email': 'اپنا ای میل درج کریں',
  'Enter your password': 'اپنا پاس ورڈ درج کریں',
  'Sign in': 'لاگ اِن',
  'Profile': 'پروفائل',
  'No active profile': 'کوئی فعال پروفائل نہیں',
  'Rentra user': 'رینٹرا صارف',
  'Owner': 'مالک',
  'Renter': 'کرایہ دار',
  'Language': 'زبان',
  'English': 'English',
  'Urdu': 'اردو',
  'Theme': 'تھیم',
  'Choose how Rentra looks': 'رینٹرا کی ظاہری شکل منتخب کریں',
  'System': 'سسٹم',
  'Light': 'لائٹ',
  'Dark': 'ڈارک',
  'App version': 'ایپ ورژن',
  'Privacy policy': 'پرائیویسی پالیسی',
  'Rentra uses your account, property, tenancy, payment-record, maintenance, and notification data only to operate the rental management workflows provided by the connected Laravel API.':
      'رینٹرا آپ کے اکاؤنٹ، پراپرٹی، کرایہ داری، ادائیگی ریکارڈ، مینٹیننس اور نوٹیفکیشن ڈیٹا کو صرف منسلک Laravel API کے رینٹل مینجمنٹ ورک فلو چلانے کے لیے استعمال کرتا ہے۔',
  'Close': 'بند کریں',
  'Logout': 'لاگ آؤٹ',
  'Properties': 'پراپرٹیز',
  'Applications': 'درخواستیں',
  'Tenancies': 'کرایہ داریاں',
  'Monthly records': 'ماہانہ ریکارڈ',
  'Maintenance': 'مینٹیننس',
  'Records': 'ریکارڈز',
  'Explore listings': 'لسٹنگز دیکھیں',
  'My rent': 'میرا کرایہ',
  'Explore': 'دیکھیں',
  'Owner access required': 'مالک اکاؤنٹ درکار ہے',
  'This screen is available only to authenticated Owner accounts.':
      'یہ اسکرین صرف تصدیق شدہ مالک اکاؤنٹس کے لیے دستیاب ہے۔',
  'Renter access required': 'کرایہ دار اکاؤنٹ درکار ہے',
  'This screen is available only to authenticated Renter accounts.':
      'یہ اسکرین صرف تصدیق شدہ کرایہ دار اکاؤنٹس کے لیے دستیاب ہے۔',
};
