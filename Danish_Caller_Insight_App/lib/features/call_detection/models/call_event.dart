/// Model representing a call event
class CallEvent {
  final String? phoneNumber;
  final DateTime timestamp;
  final CallEventType type;
  final String? callId;
  
  const CallEvent({
    this.phoneNumber,
    required this.timestamp,
    required this.type,
    this.callId,
  });
  
  factory CallEvent.fromMap(Map<String, dynamic> map) {
    return CallEvent(
      phoneNumber: map['phoneNumber'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: CallEventType.values[map['type']],
      callId: map['callId'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'callId': callId,
    };
  }
}

/// Types of call events
enum CallEventType {
  incoming,      // Incoming call detected
  answered,      // Call answered
  ended,         // Call ended
  missed,        // Missed call
  rejected,      // Call rejected
  blocked,       // Call blocked (spam)
}