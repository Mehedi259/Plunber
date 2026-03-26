import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../global/service/report/report_service.dart';
import '../../../global/models/report_model.dart';

class ReportFormScreen extends StatefulWidget {
  final String jobReportId;
  final String reportType;
  final String reportTypeDisplay;

  const ReportFormScreen({
    super.key,
    required this.jobReportId,
    required this.reportType,
    required this.reportTypeDisplay,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final ReportService _reportService = ReportService();
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReportFormData?> reportForm = Rx<ReportFormData?>(null);
  final Map<String, dynamic> _formData = {};
  final Map<String, List<XFile>> _imageFiles = {}; // Store XFile instead of File for web compatibility
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchReportForm();
  }

  Future<void> _fetchReportForm() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _reportService.getReportFormFields(widget.jobReportId);

      if (response.success && response.data != null) {
        reportForm.value = response.data;
        
        // Initialize form data
        for (var field in response.data!.fields) {
          if (field.type == 'datetime') {
            _formData[field.name] = DateTime.now().toIso8601String();
          } else {
            _formData[field.name] = '';
          }
        }
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _submitReport() async {
    final form = reportForm.value;
    if (form == null) return;

    // Validate required fields
    for (var field in form.fields) {
      if (field.required) {
        final value = _formData[field.name];
        final hasImages = _imageFiles[field.name]?.isNotEmpty == true;
        
        if ((value == null || value.toString().isEmpty) && !hasImages) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${field.displayName} is required'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
    }

    isSubmitting.value = true;

    try {
      // Prepare form data (non-file fields only)
      final submitData = <String, dynamic>{};
      _formData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          submitData[key] = value;
        }
      });

      final response = await _reportService.submitReport(
        widget.jobReportId,
        widget.reportType,
        submitData,
        _imageFiles.isNotEmpty ? _imageFiles : null,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _pickImage(String fieldName, bool multiple) async {
    try {
      if (multiple) {
        // Pick multiple images
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          setState(() {
            _imageFiles[fieldName] = images;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${images.length} image(s) selected'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Pick single image
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _imageFiles[fieldName] = [image];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto(String fieldName) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (_imageFiles[fieldName] == null) {
            _imageFiles[fieldName] = [];
          }
          _imageFiles[fieldName]!.add(image);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(String fieldName, int index) {
    setState(() {
      _imageFiles[fieldName]?.removeAt(index);
      if (_imageFiles[fieldName]?.isEmpty == true) {
        _imageFiles.remove(fieldName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.reportTypeDisplay,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          );
        }

        if (errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchReportForm,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final form = reportForm.value;
        if (form == null) {
          return const Center(
            child: Text('No form data available'),
          );
        }

        if (form.isSubmitted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Report already submitted',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: form.fields.length,
                itemBuilder: (context, index) {
                  final field = form.fields[index];
                  return _buildFormField(field);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting.value ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFormField(ReportFormField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF323232),
                  ),
                ),
              ),
              if (field.required)
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (field.helpText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              field.helpText,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildFieldInput(field),
        ],
      ),
    );
  }

  Widget _buildFieldInput(ReportFormField field) {
    switch (field.type.toLowerCase()) {
      case 'text':
        return TextField(
          onChanged: (value) {
            setState(() {
              _formData[field.name] = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter ${field.displayName.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        );

      case 'textarea':
        return TextField(
          onChanged: (value) {
            setState(() {
              _formData[field.name] = value;
            });
          },
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter ${field.displayName.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        );

      case 'datetime':
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final dateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                setState(() {
                  _formData[field.name] = dateTime.toIso8601String();
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Text(
                  _formData[field.name]?.toString().isNotEmpty == true
                      ? DateTime.parse(_formData[field.name]).toString().substring(0, 16)
                      : 'Select date and time',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Color(0xFF323232),
                  ),
                ),
              ],
            ),
          ),
        );

      case 'select':
        if (field.choices != null && field.choices!.isNotEmpty) {
          return DropdownButtonFormField<String>(
            initialValue: _formData[field.name]?.toString().isEmpty == true ? null : _formData[field.name],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
            items: field.choices!.map((choice) {
              return DropdownMenuItem<String>(
                value: choice.value,
                child: Text(choice.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _formData[field.name] = value ?? '';
              });
            },
            hint: Text('Select ${field.displayName.toLowerCase()}'),
          );
        }
        return const Text('No options available');

      case 'boolean':
        return CheckboxListTile(
          value: _formData[field.name] == true || _formData[field.name] == 'true',
          onChanged: (value) {
            setState(() {
              _formData[field.name] = value ?? false;
            });
          },
          title: const Text(
            'Yes',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF2563EB),
          contentPadding: EdgeInsets.zero,
        );

      case 'photo':
      case 'photos':
        final isMultiple = field.multiple == true;
        final images = _imageFiles[field.name] ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(field.name, isMultiple),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: Text(
                      isMultiple ? 'Select Photos' : 'Select Photo',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _takePhoto(field.name),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text(
                      'Take Photo',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: file.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(field.name, index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        );

      default:
        return TextField(
          onChanged: (value) {
            setState(() {
              _formData[field.name] = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter ${field.displayName.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        );
    }
  }
}
