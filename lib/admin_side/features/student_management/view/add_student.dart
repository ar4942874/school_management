

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/student_management/controller/student_controller.dart';
import 'package:school_management/admin_side/features/student_management/model/student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Providers for text editing controllers used in the add student form.
final studentNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final fatherNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final fatherPhoneControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final motherNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final genderControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final cnicControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final rollNoControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final addressControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final classNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());

/// StateProvider for managing the selected date.
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

/// The AddStudent page is the entry point for adding a new student.
/// It fetches a default class name from SharedPreferences and builds the view.
class AddStudent extends ConsumerWidget {
  const AddStudent({super.key});
  static const String pageName = '/Add-Student';

  // Retrieve the default class name from SharedPreferences.
  Future<String> getClassName() async {
    SharedPreferences local = await SharedPreferences.getInstance();
    return local.getString('className') ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use LayoutBuilder to adapt the layout based on screen size.
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return FutureBuilder<String>(
            future: getClassName(),
            builder: (context, snapshot) {
              // Use the retrieved class name, or default to an empty string.
              String className = snapshot.data ?? '';
              return AddStudentView(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                className: className,
              );
            },
          );
        },
      ),
    );
  }
}

/// AddStudentView defines the high-level layout (app bar, scrolling container)
/// for the add student form.
class AddStudentView extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final String className;

  const AddStudentView({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: AddStudentForm(className: className),
        ),
      ),
    );
  }
}

/// The AddStudentForm widget collects user input, validates it, handles image picking,
/// and submits the form by calling the controller’s addStudent method.
class AddStudentForm extends ConsumerStatefulWidget {
  const AddStudentForm({super.key, required this.className});
  final String className;

  @override
  ConsumerState<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends ConsumerState<AddStudentForm> {
  // Key for validating the form.
  final _formKey = GlobalKey<FormState>();

  // Local variable to store the selected image file.
  File? _selectedImage;

  // ImagePicker instance to select images.
  final ImagePicker _picker = ImagePicker();

  // Flag to indicate if the form submission (uploading) is in progress.
  bool _isUploading = false;

  /// Opens the gallery to pick an image.
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Uploads the selected image to Supabase and returns the public URL.
  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      // Get the Supabase client.
      final supabaseClient = Supabase.instance.client;
      // Define a unique file path using current time.
      String filePath = 'students/${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Upload image bytes to the specified bucket.
      final response = await supabaseClient.storage
          .from('student_images')
          .uploadBinary(filePath, await imageFile.readAsBytes());
      // Check if there was an error.
      if (response.contains('error')) {
        print('Error uploading to Supabase: $response');
        return null;
      }
      // Retrieve the public URL of the uploaded image.
      final imageUrl =
          supabaseClient.storage.from('student_images').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Exception during image upload: $e');
      return null;
    }
  }

  /// Handles the form submission.
  /// Validates the form, uploads the image (if any), creates a Student object,
  /// and calls the controller to add the student data to Firestore.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      // Upload the image to Supabase, if an image was selected.
      String? imageURL;
      if (_selectedImage != null) {
        imageURL = await _uploadImageToSupabase(_selectedImage!);
      }

      // Create a Student object using the data from the form.
      Student student = Student(
        name: ref.read(studentNameControllerProvider).text,
        rollNo: ref.read(rollNoControllerProvider).text,
        address: ref.read(addressControllerProvider).text,
        className: ref.read(classNameControllerProvider).text,
        fatherName: ref.read(fatherNameControllerProvider).text,
        fatherPhone: ref.read(fatherPhoneControllerProvider).text,
        motherName: ref.read(motherNameControllerProvider).text,
        gender: ref.read(genderControllerProvider).text,
        cnic: ref.read(cnicControllerProvider).text,
        createdAt: DateTime.now().toString(),
        dateOfBirth: ref.read(selectedDateProvider)?.toIso8601String(),
        studentPic: imageURL,
      );

      // Call the controller's addStudent method.
      bool success =
          await ref.read(studentControllerProvider).addStudent(student.toMap());

      setState(() {
        _isUploading = false;
      });

      // If adding the student was successful, reset the form.
      if (success) {
        _resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add student')),
        );
      }
    }
  }

  /// Resets the form by clearing all text controllers, the selected image, and the date.
  void _resetForm() {
    ref.read(studentNameControllerProvider).clear();
    ref.read(rollNoControllerProvider).clear();
    ref.read(addressControllerProvider).clear();
    ref.read(classNameControllerProvider).clear();
    ref.read(fatherNameControllerProvider).clear();
    ref.read(fatherPhoneControllerProvider).clear();
    ref.read(motherNameControllerProvider).clear();
    ref.read(genderControllerProvider).clear();
    ref.read(cnicControllerProvider).clear();
    setState(() {
      _selectedImage = null;
    });
    ref.read(selectedDateProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    // Read the text controllers and the selected date via Riverpod.
    return Consumer(builder: (context, ref, child) {
      final studentNameController = ref.watch(studentNameControllerProvider);
      final rollNoController = ref.watch(rollNoControllerProvider);
      final addressController = ref.watch(addressControllerProvider);
      final classNameController = ref.watch(classNameControllerProvider);
      final fatherNameController = ref.watch(fatherNameControllerProvider);
      final fatherPhoneController = ref.watch(fatherPhoneControllerProvider);
      final motherNameController = ref.watch(motherNameControllerProvider);
      final genderController = ref.watch(genderControllerProvider);
      final cnicController = ref.watch(cnicControllerProvider);
      final selectedDate = ref.watch(selectedDateProvider);

      // Pre-fill the class name if a default value was provided.
      if (widget.className.isNotEmpty) {
        classNameController.text = widget.className;
      }

      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker (CircleAvatar)
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Student name input
            _buildTextFormField(
              controller: studentNameController,
              labelText: 'Enter Student Name',
              validator: (value) =>
                  _validateRequiredField(value, "student's name"),
            ),
            const SizedBox(height: 16),
            // Roll number input
            _buildTextFormField(
              controller: rollNoController,
              labelText: 'Enter Roll Number',
              validator: (value) =>
                  _validateRequiredField(value, 'roll number'),
            ),
            const SizedBox(height: 16),
            // Date picker for Date of Birth
            _buildDatePicker(context, ref, selectedDate),
            const SizedBox(height: 16),
            // Class name input
            _buildTextFormField(
              controller: classNameController,
              labelText: "Class",
              enabled: widget.className.isEmpty,
              validator: (value) => _validateRequiredField(value, 'class name'),
            ),
            const SizedBox(height: 16),
            // Father's name input
            _buildTextFormField(
              controller: fatherNameController,
              labelText: "Enter Father's Name",
              validator: (value) =>
                  _validateRequiredField(value, "father's name"),
            ),
            const SizedBox(height: 16),
            // Father's phone input
            _buildTextFormField(
              controller: fatherPhoneController,
              labelText: "Enter Father's Phone Number",
              keyboardType: TextInputType.phone,
              validator: (value) => _validatePhone(value),
            ),
            const SizedBox(height: 16),
            // Mother's name input
            _buildTextFormField(
              controller: motherNameController,
              labelText: "Enter Mother's Name",
              validator: (value) =>
                  _validateRequiredField(value, "mother's name"),
            ),
            const SizedBox(height: 16),
            // Gender input
            _buildTextFormField(
              controller: genderController,
              labelText: 'Enter Gender',
              validator: (value) => _validateRequiredField(value, 'gender'),
            ),
            const SizedBox(height: 16),
            // CNIC input
            _buildTextFormField(
              controller: cnicController,
              labelText: 'Enter CNIC Number',
              keyboardType: TextInputType.number,
              validator: (value) => _validateCNIC(value),
            ),
            const SizedBox(height: 16),
            // Address input
            _buildTextFormField(
              controller: addressController,
              labelText: 'Enter Address',
              validator: (value) => _validateRequiredField(value, 'address'),
            ),
            const SizedBox(height: 24),
            // Submit button with loading indicator.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Helper function to build a styled text form field.
Widget _buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  bool enabled = true,
  TextInputType keyboardType = TextInputType.text,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      enabled: enabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    validator: validator,
    keyboardType: keyboardType,
  );
}

/// Helper function to build a date picker field.
Widget _buildDatePicker(
    BuildContext context, WidgetRef ref, DateTime? selectedDate) {
  return GestureDetector(
    onTap: () async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        ref.read(selectedDateProvider.notifier).state = pickedDate;
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: 'Select Date of Birth',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate)
            : 'Please select a date',
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

/// Validation function: ensures a field is not empty.
String? _validateRequiredField(String? value, String fieldName) {
  return (value == null || value.isEmpty)
      ? 'Please enter the $fieldName'
      : null;
}

/// Validation function for phone numbers.
String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the father\'s phone number';
  } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
    return 'Please enter a valid phone number';
  }
  return null;
}

/// Validation function for CNIC numbers.
String? _validateCNIC(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the CNIC number';
  } else if (!RegExp(r'^\d{13}$').hasMatch(value)) {
    return 'Please enter a valid CNIC number without dashes';
  }
  return null;
}
