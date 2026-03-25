import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../global/service/safety_form/safety_form_service.dart';
import '../../../global/models/safety_form_model.dart';

class SafetyCheckRequiredScreen extends StatefulWidget {
  final String jobId;
  final String address;
  final String? templateId;

  const SafetyCheckRequiredScreen({
    super.key,
    required this.jobId,
    required this.address,
    this.templateId,
  });

  @override
  State<SafetyCheckRequiredScreen> createState() => _SafetyCheckRequiredScreenState();
}

class _SafetyCheckRequiredScreenState extends State<SafetyCheckRequiredScreen> {
  final SafetyFormService _safetyFormService = SafetyFormService();
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<SafetyFormTemplate?> safetyForm = Rx<SafetyFormTemplate?>(null);
  final Map<String, dynamic> _fieldResponses = {};

  @override
  void initState() {
    super.initState();
    _fetchSafetyForm();
  }

  Future<void> _fetchSafetyForm() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Use the provided template ID or default
      final templateId = widget.templateId ?? '36a76b0d-665f-4bc0-b4ce-48dc2c4e5d80';

      final response = await _safetyFormService.getSafetyFormTemplate(
        widget.jobId,
        templateId,
      );

      if (response.success && response.template != null) {
        safetyForm.value = response.template;
        
        // Initialize field responses
        for (var field in response.template!.template.fields) {
          if (field.fieldType == 'checkbox') {
            _fieldResponses[field.id] = false;
          } else {
            _fieldResponses[field.id] = '';
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

  Future<void> _submitSafetyForm() async {
    // Validate required fields
    final form = safetyForm.value;
    if (form == null) return;

    for (var field in form.template.fields) {
      if (field.isRequired) {
        final value = _fieldResponses[field.id];
        if (value == null || value.toString().isEmpty || value == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${field.label} is required'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    isSubmitting.value = true;

    try {
      // Prepare responses
      final responses = <Map<String, String>>[];
      _fieldResponses.forEach((fieldId, value) {
        responses.add({
          'field_id': fieldId,
          'value': value.toString(),
        });
      });

      final response = await _safetyFormService.submitSafetyForm(
        widget.jobId,
        form.template.id,
        responses,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to job details
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
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
                  onPressed: _fetchSafetyForm,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final form = safetyForm.value;
        if (form == null) {
          return const Center(
            child: Text('No safety form available'),
          );
        }

        if (form.alreadySubmitted) {
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
                  'Safety form already submitted',
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

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                form.template.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    form.jobId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF323232),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      form.clientAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF323232),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (form.template.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  form.template.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Safety checks must be completed before starting the job',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: form.template.fields.length,
                  itemBuilder: (context, index) {
                    final field = form.template.fields[index];
                    return _buildFormField(field);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting.value ? null : _submitSafetyForm,
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
                              'Submit Safety Check',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormField(SafetyFormField field) {
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
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF323232),
                  ),
                ),
              ),
              if (field.isRequired)
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
          if (field.helperText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              field.helperText,
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

  Widget _buildFieldInput(SafetyFormField field) {
    switch (field.fieldType.toLowerCase()) {
      case 'text':
        return TextField(
          onChanged: (value) {
            setState(() {
              _fieldResponses[field.id] = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
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
              _fieldResponses[field.id] = value;
            });
          },
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
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

      case 'checkbox':
        return CheckboxListTile(
          value: _fieldResponses[field.id] == true || _fieldResponses[field.id] == 'true',
          onChanged: (value) {
            setState(() {
              _fieldResponses[field.id] = value ?? false;
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

      case 'radio':
      case 'select':
        if (field.optionsList.isNotEmpty) {
          return Column(
            children: field.optionsList.map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: _fieldResponses[field.id]?.toString(),
                onChanged: (value) {
                  setState(() {
                    _fieldResponses[field.id] = value ?? '';
                  });
                },
                title: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                activeColor: const Color(0xFF2563EB),
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          );
        }
        return const Text('No options available');

      case 'file':
        return ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement file picker
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File upload coming soon'),
              ),
            );
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
        );

      default:
        return TextField(
          onChanged: (value) {
            setState(() {
              _fieldResponses[field.id] = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        );
    }
  }
}
