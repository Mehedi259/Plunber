class SafetyFormTemplateResponse {
  final bool success;
  final String message;
  final SafetyFormTemplate? template;

  SafetyFormTemplateResponse({
    required this.success,
    required this.message,
    this.template,
  });
}

class SafetyFormTemplate {
  final String jobId;
  final String jobName;
  final String clientAddress;
  final bool alreadySubmitted;
  final TemplateData template;

  SafetyFormTemplate({
    required this.jobId,
    required this.jobName,
    required this.clientAddress,
    required this.alreadySubmitted,
    required this.template,
  });

  factory SafetyFormTemplate.fromJson(Map<String, dynamic> json) {
    return SafetyFormTemplate(
      jobId: json['job_id'] ?? '',
      jobName: json['job_name'] ?? '',
      clientAddress: json['client_address'] ?? '',
      alreadySubmitted: json['already_submitted'] ?? false,
      template: TemplateData.fromJson(json['template'] ?? {}),
    );
  }
}

class TemplateData {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final List<SafetyFormField> fields;
  final String createdAt;
  final String updatedAt;

  TemplateData({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      fields: (json['fields'] as List?)
              ?.map((field) => SafetyFormField.fromJson(field))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class SafetyFormField {
  final String id;
  final String label;
  final String fieldType;
  final String options;
  final List<String> optionsList;
  final bool isRequired;
  final int order;
  final String helperText;
  final String createdAt;
  final String updatedAt;

  SafetyFormField({
    required this.id,
    required this.label,
    required this.fieldType,
    required this.options,
    required this.optionsList,
    required this.isRequired,
    required this.order,
    required this.helperText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafetyFormField.fromJson(Map<String, dynamic> json) {
    return SafetyFormField(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      fieldType: json['field_type'] ?? '',
      options: json['options'] ?? '',
      optionsList: (json['options_list'] as List?)
              ?.map((option) => option.toString())
              .toList() ??
          [],
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      helperText: json['helper_text'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class SafetyFormSubmitResponse {
  final bool success;
  final String message;
  final SubmittedFormData? data;

  SafetyFormSubmitResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class SubmittedFormData {
  final String id;
  final String jobId;
  final String jobName;
  final String templateId;
  final String templateName;
  final String submittedAt;

  SubmittedFormData({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.templateId,
    required this.templateName,
    required this.submittedAt,
  });

  factory SubmittedFormData.fromJson(Map<String, dynamic> json) {
    return SubmittedFormData(
      id: json['id'] ?? '',
      jobId: json['job_id'] ?? '',
      jobName: json['job_name'] ?? '',
      templateId: json['template'] ?? '',
      templateName: json['template_name'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}
