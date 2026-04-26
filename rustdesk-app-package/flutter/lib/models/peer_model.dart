class PeerModel {
  final String id;
  final String name;
  final String? hostname;
  final String? ipAddress;
  final String? platform;
  final bool isOnline;
  final bool isTrusted;
  final DateTime? lastSeen;
  final Map<String, dynamic>? tags;

  PeerModel({
    required this.id,
    required this.name,
    this.hostname,
    this.ipAddress,
    this.platform,
    this.isOnline = false,
    this.isTrusted = false,
    this.lastSeen,
    this.tags,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    return PeerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      hostname: json['hostname'],
      ipAddress: json['ip_address'],
      platform: json['platform'],
      isOnline: json['is_online'] ?? false,
      isTrusted: json['is_trusted'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostname': hostname,
      'ip_address': ipAddress,
      'platform': platform,
      'is_online': isOnline,
      'is_trusted': isTrusted,
      'last_seen': lastSeen?.toIso8601String(),
      'tags': tags,
    };
  }

  PeerModel copyWith({
    String? id,
    String? name,
    String? hostname,
    String? ipAddress,
    String? platform,
    bool? isOnline,
    bool? isTrusted,
    DateTime? lastSeen,
    Map<String, dynamic>? tags,
  }) {
    return PeerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostname: hostname ?? this.hostname,
      ipAddress: ipAddress ?? this.ipAddress,
      platform: platform ?? this.platform,
      isOnline: isOnline ?? this.isOnline,
      isTrusted: isTrusted ?? this.isTrusted,
      lastSeen: lastSeen ?? this.lastSeen,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PeerModel(id: $id, name: $name, isOnline: $isOnline)';
  }
}