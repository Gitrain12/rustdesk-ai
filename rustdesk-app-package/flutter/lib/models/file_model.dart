enum TransferStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

enum TransferType {
  upload,
  download,
}

class FileTransferModel {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final TransferType type;
  final TransferStatus status;
  final double progress;
  final String? error;
  final DateTime startTime;
  final DateTime? endTime;
  final String remotePeerId;

  FileTransferModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.type,
    this.status = TransferStatus.pending,
    this.progress = 0.0,
    this.error,
    required this.startTime,
    this.endTime,
    required this.remotePeerId,
  });

  factory FileTransferModel.fromJson(Map<String, dynamic> json) {
    return FileTransferModel(
      id: json['id'] ?? '',
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileSize: json['file_size'] ?? 0,
      type: json['type'] == 'upload'
          ? TransferType.upload
          : TransferType.download,
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      progress: (json['progress'] ?? 0.0).toDouble(),
      error: json['error'],
      startTime: DateTime.parse(
          json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      remotePeerId: json['remote_peer_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'type': type.name,
      'status': status.name,
      'progress': progress,
      'error': error,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'remote_peer_id': remotePeerId,
    };
  }

  FileTransferModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    TransferType? type,
    TransferStatus? status,
    double? progress,
    String? error,
    DateTime? startTime,
    DateTime? endTime,
    String? remotePeerId,
  }) {
    return FileTransferModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      remotePeerId: remotePeerId ?? this.remotePeerId,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  double get transferSpeed {
    final dur = duration;
    if (dur == null || dur.inSeconds == 0) return 0;
    return fileSize / dur.inSeconds;
  }
}