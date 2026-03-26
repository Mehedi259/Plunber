class ReportFormResponse {
  final bool success;
  final String message;
  final ReportFormData? data;

  ReportFormResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class ReportFormData {
  final String jobReportId;
  final String reportType;
  final String reportTypeDisplay;
  final bool isSubmitted;
  final String submitUrl;
  final List<ReportFormField> fields;

  ReportFormData({
    required this.jobReportId,
    required this.reportType,
    required this.reportTypeDisplay,
    required this.isSubmitted,
    required this.submitUrl,
    required this.fields,
  });

  factory ReportFormData.fromJson(Map<String, dynamic> json) {
    return ReportFormData(
      jobReportId: json['job_report_id'] ?? '',
      reportType: json['report_type'] ?? '',
      reportTypeDisplay: json['report_type_display'] ?? '',
      isSubmitted: json['is_submitted'] ?? false,
      submitUrl: json['submit_url'] ?? '',
      fields: (json['fields'] as List?)
              ?.map((field) => ReportFormField.fromJson(field))
              .toList() ??
          [],
    );
  }
}

class ReportFormField {
  final String name;
  final String type;
  final bool required;
  final String helpText;
  final bool? multiple;
  final List<FieldChoice>? choices;

  ReportFormField({
    required this.name,
    required this.type,
    required this.required,
    required this.helpText,
    this.multiple,
    this.choices,
  });

  factory ReportFormField.fromJson(Map<String, dynamic> json) {
    return ReportFormField(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      required: json['required'] ?? false,
      helpText: json['help_text'] ?? '',
      multiple: json['multiple'],
      choices: (json['choices'] as List?)
              ?.map((choice) => FieldChoice.fromJson(choice))
              .toList(),
    );
  }

  String get displayName {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class FieldChoice {
  final String value;
  final String label;

  FieldChoice({
    required this.value,
    required this.label,
  });

  factory FieldChoice.fromJson(Map<String, dynamic> json) {
    return FieldChoice(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class ReportSubmitResponse {
  final bool success;
  final String message;

  ReportSubmitResponse({
    required this.success,
    required this.message,
  });
}
