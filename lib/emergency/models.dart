class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String department;
  final bool isInternal; // True if it's a campus extension

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.department,
    this.isInternal = true,
  });
}

class FirstAidGuide {
  final String title;
  final String icon;
  final List<String> steps;
  final String? warning;

  FirstAidGuide({
    required this.title,
    required this.icon,
    required this.steps,
    this.warning,
  });
}

final List<EmergencyContact> campusEmergencyContacts = [
  EmergencyContact(name: 'Campus Security', phoneNumber: '+263 292 282842', department: 'Security & Safety'),
  EmergencyContact(name: 'Student Clinic', phoneNumber: 'Ext 2245', department: 'Medical'),
  EmergencyContact(name: 'Counseling Services', phoneNumber: '+263 772 123456', department: 'Mental Health'),
  EmergencyContact(name: 'Fire Brigade', phoneNumber: '993', department: 'Emergency Services', isInternal: false),
  EmergencyContact(name: 'Ambulance', phoneNumber: '994', department: 'Medical', isInternal: false),
];

final List<FirstAidGuide> firstAidGuides = [
  FirstAidGuide(
    title: 'Fainting',
    icon: '🧘',
    steps: [
      'Lay the person on their back.',
      'Raise their legs above heart level (about 12 inches).',
      'Loosen any tight clothing.',
      'Check if they are breathing.',
      'Wait for them to regain consciousness (usually 1 min).',
    ],
    warning: 'If they do not wake up within a minute, call for an ambulance immediately.',
  ),
  FirstAidGuide(
    title: 'Bleeding',
    icon: '🩸',
    steps: [
      'Apply direct pressure to the wound using a clean cloth.',
      'Maintain pressure until the bleeding stops.',
      'Elevate the injured part above heart level.',
      'Do not remove the cloth if it becomes soaked; add another on top.',
    ],
  ),
  FirstAidGuide(
    title: 'Burns',
    icon: '🔥',
    steps: [
      'Run cool (not cold) water over the burn for 10-20 minutes.',
      'Remove any jewelry or tight clothing before the area swells.',
      'Cover the burn loosely with a sterile bandage or clean cloth.',
      'Do not apply ice, butter, or ointments.',
    ],
  ),
];
