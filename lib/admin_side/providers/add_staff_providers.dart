import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for managing state
final currentStepProvider = StateProvider<int>((ref) => 0);

final joinDateControllerProvider =
    Provider((ref) => TextEditingController());
final staffNameControllerProvider =
    Provider((ref) => TextEditingController());
final genderControllerProvider = Provider((ref) => TextEditingController());
final textNumberControllerProvider =
    Provider((ref) => TextEditingController());
final whatsAppControllerProvider =
    Provider((ref) => TextEditingController());
final addressControllerProvider =
    Provider((ref) => TextEditingController());
final idControllerProvider = Provider((ref) => TextEditingController());
final passwordControllerProvider =
    Provider((ref) => TextEditingController());
final classControllerProvider = Provider((ref) => TextEditingController());
final salaryControllerProvider = Provider((ref) => TextEditingController());
final qualificationControllerProvider =
    Provider((ref) => TextEditingController());

// Form keys providers
final basicInfoFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final contactInfoFormKeyProvider = Provider((ref) => GlobalKey<FormState>());
final instituteInfoFormKeyProvider = Provider((ref) => GlobalKey<FormState>());

// PageController provider
final pageControllerProvider = Provider((ref) => PageController());
