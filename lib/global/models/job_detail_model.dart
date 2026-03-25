class JobDetailModel {
  final String id;
  final String jobId;
  final String status;
  final String priority;
  final String jobName;
  final String jobDetails;
  final String scheduledDatetime;
  final ClientInfo client;
  final AssignedEmployee? assignedTo;
  final VehicleInfo? vehicle;
  final List<ReportInfo> reports;
  final List<AttachmentInfo> attachments;
  final List<String> safetyFormIds;
  final int grandTotal;
  final bool isOverdue;
  final bool hasFleetIssue;

  JobDetailModel({
    required this.id,
    required this.jobId,
    required this.status,
    required this.priority,
    required this.jobName,
    required this.jobDetails,
    required this.scheduledDatetime,
    required this.client,
    this.assignedTo,
    this.vehicle,
    required this.reports,
    required this.attachments,
    required this.safetyFormIds,
    required this.grandTotal,
    required this.isOverdue,
    required this.hasFleetIssue,
  });

  factory JobDetailModel.fromJson(Map<String, dynamic> json) {
    return JobDetailModel(
      id: json['id'] ?? '',
      jobId: json['job_id'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      jobName: json['job_name'] ?? '',
      jobDetails: json['job_details'] ?? '',
      scheduledDatetime: json['scheduled_datetime'] ?? '',
      client: ClientInfo.fromJson(json['client_info'] ?? {}),
      assignedTo: json['assigned_employee_info'] != null
          ? AssignedEmployee.fromJson(json['assigned_employee_info'])
          : null,
      vehicle: (json['vehicle_name'] != null && json['vehicle_plate'] != null)
          ? VehicleInfo(
              id: '',
              name: json['vehicle_name'] ?? '',
              plate: json['vehicle_plate'] ?? '',
              picture: null,
              status: '',
            )
          : null,
      reports: (json['reports'] as List?)
              ?.map((r) => ReportInfo.fromJson(r))
              .toList() ??
          [],
      attachments: (json['attachments'] as List?)
              ?.map((a) => AttachmentInfo.fromJson(a))
              .toList() ??
          [],
      safetyFormIds: (json['safety_form_ids'] as List?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      grandTotal: json['grand_total'] ?? 0,
      isOverdue: json['is_overdue'] ?? false,
      hasFleetIssue: json['has_fleet_issue'] ?? false,
    );
  }

  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(scheduledDatetime);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return 'N/A';
    }
  }
}

class ClientInfo {
  final String id;
  final String name;
  final String? profilePicture;
  final String email;
  final String phone;
  final String address;
  final String? mapsUrl;
  final String? contactPersonName;

  ClientInfo({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.email,
    required this.phone,
    required this.address,
    this.mapsUrl,
    this.contactPersonName,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      mapsUrl: json['maps_url'],
      contactPersonName: json['contact_person_name'],
    );
  }
}

class AssignedEmployee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicture;

  AssignedEmployee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePicture,
  });

  factory AssignedEmployee.fromJson(Map<String, dynamic> json) {
    return AssignedEmployee(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }
}

class VehicleInfo {
  final String id;
  final String name;
  final String plate;
  final String? picture;
  final String status;

  VehicleInfo({
    required this.id,
    required this.name,
    required this.plate,
    this.picture,
    required this.status,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      plate: json['plate'] ?? '',
      picture: json['picture'],
      status: json['status'] ?? '',
    );
  }
}

class ReportInfo {
  final String jobReportId;
  final String reportType;
  final String reportTypeDisplay;
  final bool isSubmitted;
  final String? submittedAt;

  ReportInfo({
    required this.jobReportId,
    required this.reportType,
    required this.reportTypeDisplay,
    required this.isSubmitted,
    this.submittedAt,
  });

  factory ReportInfo.fromJson(Map<String, dynamic> json) {
    return ReportInfo(
      jobReportId: json['job_report_id'] ?? '',
      reportType: json['report_type'] ?? '',
      reportTypeDisplay: json['report_type_display'] ?? '',
      isSubmitted: json['is_submitted'] ?? false,
      submittedAt: json['submitted_at'],
    );
  }
}

class AttachmentInfo {
  final String id;
  final String file;
  final String fileName;
  final String uploadedBy;
  final String uploadedByName;
  final String uploadedAt;

  AttachmentInfo({
    required this.id,
    required this.file,
    required this.fileName,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
  });

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) {
    return AttachmentInfo(
      id: json['id'] ?? '',
      file: json['file'] ?? '',
      fileName: json['file_name'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      uploadedByName: json['uploaded_by_name'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }

  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(uploadedAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
