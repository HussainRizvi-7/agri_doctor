// ============================================================
// FILE: model/disease.dart
// PURPOSE: OOP Model class for Disease data
// CONCEPT: Class & Objects, Variables, Lists
// ============================================================

/// Disease class represents a single plant disease with all its details.
/// This demonstrates OOP (Object-Oriented Programming) principles.
class Disease {
  // --- Instance Variables (Properties) ---
  String name;        // Name of the disease
  String description; // What the disease is
  String solution;    // How to treat / prevent it
  String iconEmoji;   // Emoji for visual representation
  String severity;    // Severity level: "Low", "Medium", "High"
  String color;       // Hex color code for UI theming

  // --- Constructor ---
  Disease({
    required this.name,
    required this.description,
    required this.solution,
    required this.iconEmoji,
    required this.severity,
    required this.color,
  });
}

// ============================================================
// DISEASE DATA — All disease objects stored in a List<Disease>
// CONCEPT: Lists + Objects
// ============================================================
List<Disease> diseaseList = [
  Disease(
    name: 'Wheat Rust',
    description:
        'Wheat Rust is a fungal disease that appears as orange-brown pustules '
        'on leaves and stems of wheat plants. It spreads rapidly in warm, humid '
        'conditions and can cause significant yield loss if left untreated. '
        'It is one of the most destructive wheat diseases worldwide.',
    solution:
        '• Apply fungicides such as Propiconazole or Tebuconazole early.\n'
        '• Remove and destroy infected plant debris.\n'
        '• Use rust-resistant wheat varieties.\n'
        '• Ensure proper spacing for air circulation.\n'
        '• Monitor fields weekly during humid weather.',
    iconEmoji: '🌾',
    severity: 'High',
    color: '#D4521A',
  ),
  Disease(
    name: 'Leaf Blight',
    description:
        'Leaf Blight causes rapid browning and death of leaf tissue. '
        'It is typically caused by fungal or bacterial pathogens and thrives '
        'in wet, warm environments. Affected leaves show water-soaked spots '
        'that quickly turn brown and dry out, leading to premature defoliation.',
    solution:
        '• Use copper-based bactericides or fungicides.\n'
        '• Avoid overhead irrigation; use drip irrigation instead.\n'
        '• Remove infected leaves immediately.\n'
        '• Apply neem oil as an organic solution.\n'
        '• Rotate crops each season to break disease cycles.',
    iconEmoji: '🍂',
    severity: 'Medium',
    color: '#8B4513',
  ),
  Disease(
    name: 'Powdery Mildew',
    description:
        'Powdery Mildew appears as white or gray powdery spots on leaf surfaces. '
        'It is caused by various fungal species and thrives in dry weather with '
        'high humidity. It weakens plants by blocking photosynthesis, leading '
        'to yellowing, stunted growth, and reduced crop yield.',
    solution:
        '• Spray potassium bicarbonate or sulfur-based fungicide.\n'
        '• Apply diluted neem oil spray weekly.\n'
        '• Ensure good airflow between plants.\n'
        '• Avoid excessive nitrogen fertilizers.\n'
        '• Plant resistant varieties when available.',
    iconEmoji: '🌿',
    severity: 'Medium',
    color: '#6B8E6B',
  ),
  Disease(
    name: 'Root Rot',
    description:
        'Root Rot is caused by waterlogged soil conditions that promote '
        'fungal growth around the root system. Affected plants show wilting, '
        'yellowing leaves, and stunted growth despite adequate water. '
        'The roots appear dark, mushy, and have a foul smell.',
    solution:
        '• Improve soil drainage immediately.\n'
        '• Reduce watering frequency significantly.\n'
        '• Apply Trichoderma-based bio-fungicide to the soil.\n'
        '• Uproot and destroy severely affected plants.\n'
        '• Avoid waterlogging by raised-bed cultivation.',
    iconEmoji: '🪴',
    severity: 'High',
    color: '#5C4033',
  ),
  Disease(
    name: 'Healthy Leaf',
    description:
        'This leaf shows no signs of disease or pest damage. '
        'The plant appears to be in excellent health with vibrant green color, '
        'firm texture, and no discoloration or spots. '
        'Continue with current care routine to maintain plant health.',
    solution:
        '• Continue regular watering schedule.\n'
        '• Maintain balanced fertilization (NPK).\n'
        '• Monitor weekly for early signs of disease.\n'
        '• Ensure proper sunlight exposure.\n'
        '• Keep the field clean from weeds.',
    iconEmoji: '🌱',
    severity: 'None',
    color: '#2E7D32',
  ),
  Disease(
    name: 'Yellow Mosaic Virus',
    description:
        'Yellow Mosaic Virus is a viral disease transmitted by whiteflies. '
        'It causes a mosaic pattern of yellow and green patches on leaves, '
        'leading to stunted growth and reduced productivity. '
        'There is no cure once a plant is infected, so prevention is key.',
    solution:
        '• Control whitefly population using yellow sticky traps.\n'
        '• Spray insecticides like Imidacloprid to kill vectors.\n'
        '• Remove and burn infected plants immediately.\n'
        '• Use virus-resistant seed varieties.\n'
        '• Avoid planting near infected fields.',
    iconEmoji: '🍋',
    severity: 'High',
    color: '#F9A825',
  ),
];