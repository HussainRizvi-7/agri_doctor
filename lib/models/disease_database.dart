import 'disease.dart';

// Maps every label index from labels.txt → a Disease object.
// Index order must match labels.txt exactly (0-based).
final Map<int, Disease> mlDiseaseMap = {
  // ── APPLE ──────────────────────────────────────────────────────
  0: Disease(
    name: 'Apple Scab',
    description:
        'Apple scab is a fungal disease caused by Venturia inaequalis. '
        'It produces olive-green to dark brown lesions on leaves and '
        'fruits, leading to premature defoliation and scarred, '
        'unmarketable fruit. It thrives in cool, wet spring weather.',
    solution:
        '• Apply fungicides (captan, myclobutanil) from green-tip stage.\n'
        '• Remove and destroy fallen infected leaves.\n'
        '• Prune trees to improve air circulation.\n'
        '• Plant scab-resistant apple varieties.\n'
        '• Avoid overhead irrigation.',
    iconEmoji: '🍎',
    severity: 'Medium',
    color: '#6D4C41',
  ),
  1: Disease(
    name: 'Apple Black Rot',
    description:
        'Black rot is a destructive fungal disease caused by '
        'Botryosphaeria obtusa. It causes circular reddish-brown lesions '
        'on leaves and dark, rotting spots on fruit. Infected wood '
        'develops cankers that can kill entire branches.',
    solution:
        '• Prune and destroy infected branches during dry weather.\n'
        '• Remove all mummified and fallen fruits from the orchard.\n'
        '• Apply fungicides (captan, thiophanate-methyl) at bloom.\n'
        '• Sanitize pruning tools between cuts.\n'
        '• Maintain good orchard drainage.',
    iconEmoji: '🍎',
    severity: 'High',
    color: '#3E2723',
  ),
  2: Disease(
    name: 'Apple Cedar Rust',
    description:
        'Cedar apple rust is caused by Gymnosporangium juniperi-virginianae. '
        'It alternates between apple and cedar/juniper trees, producing '
        'bright orange-yellow spots on apple leaves with tube-shaped '
        'structures on the underside. Causes premature defoliation.',
    solution:
        '• Remove nearby cedar or juniper host plants where possible.\n'
        '• Apply protective fungicides (myclobutanil, triadimefon) from bud break.\n'
        '• Continue spraying through petal fall every 7–10 days.\n'
        '• Plant rust-resistant apple varieties.\n'
        '• Monitor forecasts for spore release periods.',
    iconEmoji: '🍎',
    severity: 'Medium',
    color: '#E65100',
  ),
  3: Disease(
    name: 'Healthy Apple',
    description:
        'The apple plant shows no signs of disease or pest damage. '
        'Leaves are vibrant green with no spots, lesions, or discoloration. '
        'The plant is thriving and fruit development is normal.',
    solution:
        '• Continue regular watering schedule at the base.\n'
        '• Apply balanced fertilizer in early spring.\n'
        '• Prune annually for open canopy structure.\n'
        '• Monitor weekly for early signs of scab or rust.\n'
        '• Thin fruit clusters for better size and quality.',
    iconEmoji: '🍎',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── BLUEBERRY ──────────────────────────────────────────────────
  4: Disease(
    name: 'Healthy Blueberry',
    description:
        'The blueberry plant appears healthy with no disease symptoms. '
        'Leaves are bright green and undamaged. The plant is growing '
        'vigorously and producing good fruit.',
    solution:
        '• Maintain soil pH between 4.5 and 5.5 (acidic).\n'
        '• Apply sulfur-based fertilizer for acidic conditions.\n'
        '• Water consistently; blueberries need even moisture.\n'
        '• Mulch with pine bark or wood chips to retain moisture.\n'
        '• Prune oldest canes every 3–4 years.',
    iconEmoji: '🫐',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── CHERRY ─────────────────────────────────────────────────────
  5: Disease(
    name: 'Cherry Powdery Mildew',
    description:
        'Powdery mildew in cherry is caused by Podosphaera clandestina. '
        'It appears as white powdery growth on young leaves and shoots, '
        'causing curling, distortion, and reduced photosynthesis. '
        'Severe infections lower fruit quality and yield.',
    solution:
        '• Apply sulfur-based or potassium bicarbonate fungicide.\n'
        '• Remove and destroy infected shoots immediately.\n'
        '• Ensure good air circulation through pruning.\n'
        '• Avoid excessive nitrogen fertilization.\n'
        '• Spray neem oil weekly as an organic alternative.',
    iconEmoji: '🍒',
    severity: 'Medium',
    color: '#6B8E6B',
  ),
  6: Disease(
    name: 'Healthy Cherry',
    description:
        'Cherry plant shows no signs of disease. Leaves are healthy '
        'green with no spots or deformities. The plant is developing '
        'normally with good fruit set.',
    solution:
        '• Water regularly, especially during fruit development.\n'
        '• Apply balanced fertilizer after harvest.\n'
        '• Prune for open canopy structure to reduce fungal risk.\n'
        '• Thin fruit clusters to improve berry size.\n'
        '• Monitor for cherry leaf spot disease.',
    iconEmoji: '🍒',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── CORN / MAIZE ───────────────────────────────────────────────
  7: Disease(
    name: 'Gray Leaf Spot (Corn)',
    description:
        'Gray leaf spot is caused by Cercospora zeae-maydis. It produces '
        'rectangular, gray-brown lesions running parallel to leaf veins. '
        'Lesions can merge to cover entire leaves, significantly '
        'reducing photosynthesis and causing premature senescence.',
    solution:
        '• Plant resistant corn hybrids.\n'
        '• Apply foliar fungicides (azoxystrobin, propiconazole) at VT stage.\n'
        '• Rotate with non-host crops (soybeans, wheat) for 1–2 seasons.\n'
        '• Till infected crop residue after harvest.\n'
        '• Avoid continuous corn production.',
    iconEmoji: '🌽',
    severity: 'High',
    color: '#78909C',
  ),
  8: Disease(
    name: 'Corn Common Rust',
    description:
        'Common rust is caused by Puccinia sorghi. Small, brick-red to '
        'brown pustules form on both surfaces of corn leaves. '
        'Heavy infection causes premature leaf death and can '
        'significantly reduce grain yield.',
    solution:
        '• Plant rust-resistant corn hybrids.\n'
        '• Apply fungicides (propiconazole, trifloxystrobin) early.\n'
        '• Scout fields regularly during warm, humid weather.\n'
        '• Ensure adequate plant spacing for air circulation.\n'
        '• Avoid late planting when rust pressure is highest.',
    iconEmoji: '🌽',
    severity: 'Medium',
    color: '#BF360C',
  ),
  9: Disease(
    name: 'Northern Leaf Blight (Corn)',
    description:
        'Northern leaf blight is caused by Exserohilum turcicum. It '
        'produces long, gray-green to tan cigar-shaped lesions on corn '
        'leaves. Lesions expand and merge, killing large portions of '
        'leaf tissue and severely reducing photosynthesis.',
    solution:
        '• Plant resistant corn hybrids with Ht resistance genes.\n'
        '• Apply fungicides at V8 stage or at first symptom detection.\n'
        '• Rotate with non-corn crops for at least one season.\n'
        '• Till infected crop debris in autumn.\n'
        '• Scout fields after any humid weather event.',
    iconEmoji: '🌽',
    severity: 'High',
    color: '#5D4037',
  ),
  10: Disease(
    name: 'Healthy Corn',
    description:
        'Corn plant shows no signs of disease. Leaves are bright green, '
        'upright, and undamaged. The plant is developing normally '
        'through all growth stages.',
    solution:
        '• Irrigate consistently, especially during silking (VT–R2).\n'
        '• Apply balanced NPK fertilizer at proper growth stages.\n'
        '• Side-dress with nitrogen at V6 stage.\n'
        '• Scout weekly for early pest or disease signs.\n'
        '• Ensure adequate plant spacing (30 cm within row).',
    iconEmoji: '🌽',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── GRAPE ──────────────────────────────────────────────────────
  11: Disease(
    name: 'Grape Black Rot',
    description:
        'Grape black rot is caused by Guignardia bidwellii. It causes '
        'circular, tan leaf lesions with dark borders and turns berries '
        'hard, black, and shriveled (mummies). Untreated infections '
        'can destroy an entire harvest.',
    solution:
        '• Remove all mummified berries and infected leaves.\n'
        '• Apply fungicides (mancozeb, myclobutanil) from bud break.\n'
        '• Maintain good canopy air circulation through pruning.\n'
        '• Destroy all infected plant material after harvest.\n'
        '• Repeat fungicide applications every 10–14 days in wet weather.',
    iconEmoji: '🍇',
    severity: 'High',
    color: '#1A237E',
  ),
  12: Disease(
    name: 'Grape Esca (Black Measles)',
    description:
        'Esca is a complex fungal disease caused by multiple pathogens '
        '(Phaeomoniella, Phaeoacremonium species). It causes tiger-stripe '
        'patterns on leaves and black, hard spots on berries. '
        'Infected wood shows internal brown discoloration.',
    solution:
        '• Prune infected wood during dry weather only.\n'
        '• Apply wound protectants immediately after pruning.\n'
        '• Remove and destroy severely infected vines.\n'
        '• Avoid vine stress (waterlogging, over-cropping).\n'
        '• No fully effective chemical cure — prevention is key.',
    iconEmoji: '🍇',
    severity: 'High',
    color: '#4A148C',
  ),
  13: Disease(
    name: 'Grape Leaf Blight',
    description:
        'Grape leaf blight (Isariopsis leaf spot) is caused by '
        'Pseudocercospora vitis. It produces irregular dark brown to '
        'purplish lesions on leaves that coalesce, causing defoliation '
        'and reduced fruit quality.',
    solution:
        '• Apply copper-based fungicides preventively.\n'
        '• Remove and destroy infected leaves promptly.\n'
        '• Ensure good canopy air circulation through shoot positioning.\n'
        '• Avoid overhead irrigation; drip irrigate instead.\n'
        '• Mulch around the base to reduce soil splash.',
    iconEmoji: '🍇',
    severity: 'Medium',
    color: '#880E4F',
  ),
  14: Disease(
    name: 'Healthy Grape',
    description:
        'Grapevine shows no signs of disease. Leaves are deeply lobed '
        'and rich green with no spots or lesions. The vine is growing '
        'vigorously with good canopy development.',
    solution:
        '• Train vines on trellis properly for sun exposure.\n'
        '• Thin clusters at berry set for better berry size.\n'
        '• Apply potassium-rich fertilizer before veraison.\n'
        '• Irrigate consistently but reduce during ripening.\n'
        '• Monitor for powdery mildew and downy mildew.',
    iconEmoji: '🍇',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── ORANGE ─────────────────────────────────────────────────────
  15: Disease(
    name: 'Citrus Greening (HLB)',
    description:
        'Huanglongbing (citrus greening) is a devastating bacterial disease '
        'spread by the Asian citrus psyllid. Infected trees show blotchy '
        'mottling on leaves, asymmetric yellowing, stunted growth, and '
        'produce small, lopsided, bitter fruits. There is currently no cure.',
    solution:
        '• Control Asian citrus psyllid with systemic insecticides.\n'
        '• Remove and destroy infected trees immediately.\n'
        '• Plant only disease-free certified nursery stock.\n'
        '• Apply micronutrient sprays (zinc, manganese) to manage symptoms.\n'
        '• Report confirmed outbreaks to local agricultural authorities.',
    iconEmoji: '🍊',
    severity: 'High',
    color: '#E65100',
  ),

  // ── PEACH ──────────────────────────────────────────────────────
  16: Disease(
    name: 'Peach Bacterial Spot',
    description:
        'Bacterial spot in peach is caused by Xanthomonas arboricola pv. '
        'pruni. It causes water-soaked leaf lesions that become dark and '
        'fall out (shothole appearance), and shallow pits or cracks on '
        'fruits. Severe infections cause defoliation and fruit loss.',
    solution:
        '• Apply copper-based bactericides starting at bud swell.\n'
        '• Choose bacterial-spot-resistant peach varieties.\n'
        '• Avoid overhead irrigation to keep foliage dry.\n'
        '• Ensure good air circulation with proper pruning.\n'
        '• Remove fallen leaves and infected fruit mummies.',
    iconEmoji: '🍑',
    severity: 'High',
    color: '#BF360C',
  ),
  17: Disease(
    name: 'Healthy Peach',
    description:
        'Peach tree shows no disease symptoms. Leaves are lance-shaped '
        'and bright green with no spots, lesions, or deformities. '
        'The tree is in excellent condition.',
    solution:
        '• Apply delayed dormant copper spray in early spring.\n'
        '• Thin fruits to 15–20 cm apart for best size and quality.\n'
        '• Fertilize with balanced NPK after fruit set.\n'
        '• Monitor weekly for aphids, borers, and brown rot.\n'
        '• Irrigate deeply but infrequently.',
    iconEmoji: '🍑',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── PEPPER ─────────────────────────────────────────────────────
  18: Disease(
    name: 'Bell Pepper Bacterial Spot',
    description:
        'Bacterial spot in pepper is caused by Xanthomonas euvesicatoria. '
        'It produces water-soaked spots on leaves that become dark and '
        'necrotic, and raised, scabby spots on fruits. Spreads rapidly '
        'in warm, wet conditions.',
    solution:
        '• Use pathogen-free certified seeds.\n'
        '• Apply copper-based bactericides weekly during wet weather.\n'
        '• Avoid overhead irrigation — use drip systems.\n'
        '• Practice crop rotation (avoid solanaceae for 2–3 years).\n'
        '• Remove and destroy all infected plant debris at season end.',
    iconEmoji: '🫑',
    severity: 'High',
    color: '#C62828',
  ),
  19: Disease(
    name: 'Healthy Bell Pepper',
    description:
        'Bell pepper plant appears healthy with no signs of disease. '
        'Leaves are dark green and glossy, stems are strong, and '
        'fruit development is progressing normally.',
    solution:
        '• Water consistently at the base, avoiding foliage wetting.\n'
        '• Apply calcium fertilizer to prevent blossom-end rot.\n'
        '• Support plants with stakes as they grow.\n'
        '• Scout for aphids and mites weekly.\n'
        '• Mulch around base to conserve moisture.',
    iconEmoji: '🫑',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── POTATO ─────────────────────────────────────────────────────
  20: Disease(
    name: 'Potato Early Blight',
    description:
        'Early blight in potato is caused by Alternaria solani. It '
        'produces dark brown, concentric ring lesions (target-board '
        'pattern) on older leaves first. Infected leaves yellow and '
        'die early, reducing photosynthetic capacity and tuber yield.',
    solution:
        '• Apply fungicides (chlorothalonil, mancozeb) preventively.\n'
        '• Remove and destroy infected foliage.\n'
        '• Avoid overhead irrigation.\n'
        '• Practice 3-year crop rotation with non-solanaceous crops.\n'
        '• Use certified, disease-free seed potatoes.',
    iconEmoji: '🥔',
    severity: 'Medium',
    color: '#6D4C41',
  ),
  21: Disease(
    name: 'Potato Late Blight',
    description:
        'Late blight, caused by Phytophthora infestans, is one of the '
        'most destructive plant diseases in history. It produces '
        'water-soaked, dark lesions on leaves with white mold visible '
        'on undersides. It spreads explosively in wet, cool conditions '
        'and can destroy an entire field within days.',
    solution:
        '• Apply systemic fungicides (metalaxyl, cymoxanil) immediately.\n'
        '• Remove and destroy ALL infected plants completely.\n'
        '• Avoid overhead irrigation entirely.\n'
        '• Harvest tubers before or immediately after vine death.\n'
        '• Plant late-blight-resistant potato varieties next season.',
    iconEmoji: '🥔',
    severity: 'High',
    color: '#37474F',
  ),
  22: Disease(
    name: 'Healthy Potato',
    description:
        'Potato plant appears healthy with upright stems and dark '
        'green compound leaves. No signs of blight, mosaic, or '
        'other diseases detected. Tuber development is progressing '
        'normally.',
    solution:
        '• Hill soil around stems as the plant grows.\n'
        '• Apply balanced fertilizer at hilling time.\n'
        '• Water consistently, avoiding waterlogging.\n'
        '• Scout for Colorado potato beetle and aphids weekly.\n'
        '• Harvest when vines naturally die back.',
    iconEmoji: '🥔',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── RASPBERRY ──────────────────────────────────────────────────
  23: Disease(
    name: 'Healthy Raspberry',
    description:
        'Raspberry canes appear healthy with no signs of disease. '
        'Leaves are bright green and undamaged. The plant is '
        'producing good primocane growth.',
    solution:
        '• Train canes on a trellis system for support.\n'
        '• Remove old floricanes immediately after fruiting.\n'
        '• Apply balanced fertilizer in early spring.\n'
        '• Mulch to retain moisture and suppress weeds.\n'
        '• Scout for cane blight and raspberry mosaic virus.',
    iconEmoji: '🫐',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── SOYBEAN ────────────────────────────────────────────────────
  24: Disease(
    name: 'Healthy Soybean',
    description:
        'Soybean plant shows no disease signs. Trifoliate leaves are '
        'healthy green with no spots, lesions, or discoloration. '
        'The plant is nodulating and fixing nitrogen effectively.',
    solution:
        '• Inoculate seeds with Bradyrhizobium for nitrogen fixation.\n'
        '• Apply phosphorus and potassium based on soil test.\n'
        '• Scout for soybean aphid and stink bugs weekly.\n'
        '• Monitor for sudden death syndrome in wet seasons.\n'
        '• Harvest promptly at physiological maturity (R7 stage).',
    iconEmoji: '🌱',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── SQUASH ─────────────────────────────────────────────────────
  25: Disease(
    name: 'Squash Powdery Mildew',
    description:
        'Powdery mildew in squash is caused by Podosphaera xanthii. '
        'It appears as white, powdery fungal growth on leaf surfaces, '
        'causing yellowing and premature leaf death. Thrives in warm '
        'days with cool nights and moderate humidity.',
    solution:
        '• Apply potassium bicarbonate or sulfur fungicide.\n'
        '• Spray diluted neem oil (2%) weekly as prevention.\n'
        '• Remove severely infected leaves.\n'
        '• Ensure adequate plant spacing for airflow.\n'
        '• Plant powdery mildew-resistant squash varieties.',
    iconEmoji: '🥒',
    severity: 'Medium',
    color: '#6B8E6B',
  ),

  // ── STRAWBERRY ─────────────────────────────────────────────────
  26: Disease(
    name: 'Strawberry Leaf Scorch',
    description:
        'Leaf scorch in strawberry is caused by Diplocarpon earlianum. '
        'It produces small, irregular dark purple spots that coalesce '
        'and give a scorched appearance to leaves. Severe infections '
        'reduce plant vigor, crown size, and fruit yield.',
    solution:
        '• Remove and destroy all infected leaves.\n'
        '• Apply fungicides (captan, thiram) at symptom onset.\n'
        '• Avoid overhead irrigation to keep foliage dry.\n'
        '• Plant in well-draining soil with good air circulation.\n'
        '• Use certified disease-free transplants and rotate beds every 3–4 years.',
    iconEmoji: '🍓',
    severity: 'Medium',
    color: '#880E4F',
  ),
  27: Disease(
    name: 'Healthy Strawberry',
    description:
        'Strawberry plant shows no disease symptoms. Leaves are bright '
        'green, trifoliate, and undamaged. The plant is producing '
        'healthy runners and normal fruit development.',
    solution:
        '• Renovate bed by mowing and thinning after harvest.\n'
        '• Apply balanced fertilizer after renovation.\n'
        '• Keep bed weed-free with straw mulch.\n'
        '• Irrigate consistently but avoid waterlogging.\n'
        '• Scout for two-spotted spider mites and aphids.',
    iconEmoji: '🍓',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── TOMATO ─────────────────────────────────────────────────────
  28: Disease(
    name: 'Tomato Bacterial Spot',
    description:
        'Tomato bacterial spot is caused by the Xanthomonas vesicatoria '
        'complex. Small, water-soaked spots on leaves turn dark brown '
        'with yellow halos; fruits develop raised, scabby spots. '
        'Spreads rapidly in warm, wet conditions.',
    solution:
        '• Use pathogen-free certified seeds.\n'
        '• Apply copper-based bactericides preventively.\n'
        '• Never handle plants when leaves are wet.\n'
        '• Practice 2-year crop rotation with non-solanaceous crops.\n'
        '• Remove and destroy all infected plant debris at season end.',
    iconEmoji: '🍅',
    severity: 'High',
    color: '#D32F2F',
  ),
  29: Disease(
    name: 'Tomato Early Blight',
    description:
        'Early blight in tomato is caused by Alternaria solani. It '
        'creates dark brown, target-board lesions with concentric rings '
        'on lower leaves first. The disease progresses up the plant, '
        'causing premature defoliation and fruit sunscald.',
    solution:
        '• Stake plants to improve air circulation.\n'
        '• Apply fungicides (chlorothalonil, mancozeb) preventively.\n'
        '• Remove infected lower leaves immediately.\n'
        '• Mulch heavily to prevent soil splash onto leaves.\n'
        '• Practice 3-year crop rotation.',
    iconEmoji: '🍅',
    severity: 'Medium',
    color: '#6D4C41',
  ),
  30: Disease(
    name: 'Tomato Late Blight',
    description:
        'Late blight in tomato, caused by Phytophthora infestans, '
        'produces large, water-soaked, dark brown lesions on leaves '
        'with white mold on undersides in humid conditions. Infected '
        'fruits develop firm, brown, greasy lesions. Spreads explosively '
        'in cool, wet weather.',
    solution:
        '• Remove and destroy infected plants immediately.\n'
        '• Apply systemic fungicides (metalaxyl, cymoxanil) preventively.\n'
        '• Avoid all overhead watering — use drip irrigation.\n'
        '• Improve air circulation by staking and pruning.\n'
        '• Plant late-blight-resistant tomato varieties.',
    iconEmoji: '🍅',
    severity: 'High',
    color: '#37474F',
  ),
  31: Disease(
    name: 'Tomato Leaf Mold',
    description:
        'Leaf mold in tomato is caused by Passalora fulva. Infected '
        'leaves show pale green to yellow spots on the upper surface '
        'and olive-green to grayish-brown velvety mold on the underside. '
        'Thrives in humid greenhouse conditions and causes defoliation.',
    solution:
        '• Increase ventilation in greenhouses significantly.\n'
        '• Reduce humidity by heating and improving airflow.\n'
        '• Apply fungicides (chlorothalonil, mancozeb).\n'
        '• Remove infected leaves promptly.\n'
        '• Plant leaf-mold-resistant tomato varieties.',
    iconEmoji: '🍅',
    severity: 'Medium',
    color: '#558B2F',
  ),
  32: Disease(
    name: 'Tomato Septoria Leaf Spot',
    description:
        'Septoria leaf spot is caused by Septoria lycopersici. It '
        'appears as numerous small, circular spots with dark brown '
        'borders and lighter centers (often with dark specks). '
        'Infection starts on lower leaves and moves up, causing '
        'severe defoliation.',
    solution:
        '• Apply fungicides (chlorothalonil, mancozeb, copper) preventively.\n'
        '• Remove infected leaves as soon as spots appear.\n'
        '• Stake plants for good air circulation.\n'
        '• Mulch heavily to reduce soil splash.\n'
        '• Rotate with non-solanaceous crops for 2–3 years.',
    iconEmoji: '🍅',
    severity: 'Medium',
    color: '#795548',
  ),
  33: Disease(
    name: 'Tomato Spider Mites',
    description:
        'Two-spotted spider mites (Tetranychus urticae) are tiny '
        'arachnids causing stippled, bronze or yellow appearance on '
        'leaves. Heavy infestations produce webbing between leaves '
        'and cause premature defoliation. Thrive in hot, dry conditions.',
    solution:
        '• Dislodge mites with strong water jets on leaf undersides.\n'
        '• Apply miticides or insecticidal soap.\n'
        '• Increase irrigation to raise relative humidity.\n'
        '• Introduce predatory mites (Phytoseiidae) as biocontrol.\n'
        '• Avoid broad-spectrum insecticides that kill natural predators.',
    iconEmoji: '🍅',
    severity: 'Medium',
    color: '#E65100',
  ),
  34: Disease(
    name: 'Tomato Target Spot',
    description:
        'Target spot in tomato is caused by Corynespora cassiicola. '
        'It produces circular, brown lesions with concentric rings '
        '(like a target) on leaves, stems, and fruits. Lesions on '
        'fruits cause significant quality and marketability loss.',
    solution:
        '• Apply fungicides (azoxystrobin, chlorothalonil).\n'
        '• Remove infected plant parts promptly.\n'
        '• Improve air circulation around plants.\n'
        '• Avoid overhead irrigation.\n'
        '• Rotate crops annually with non-solanaceous species.',
    iconEmoji: '🍅',
    severity: 'Medium',
    color: '#8D6E63',
  ),
  35: Disease(
    name: 'Tomato Yellow Leaf Curl Virus',
    description:
        'TYLCV is a viral disease transmitted by the silverleaf whitefly '
        '(Bemisia tabaci). Infected plants show upward leaf curling, '
        'yellowing, stunted growth, and dramatically reduced fruit set. '
        'There is no cure once a plant is infected.',
    solution:
        '• Control whitefly populations with yellow sticky traps.\n'
        '• Apply systemic insecticides (imidacloprid) to kill vectors.\n'
        '• Remove and destroy infected plants immediately.\n'
        '• Use insect-proof nets during early plant establishment.\n'
        '• Plant TYLCV-resistant tomato varieties.',
    iconEmoji: '🍅',
    severity: 'High',
    color: '#F9A825',
  ),
  36: Disease(
    name: 'Tomato Mosaic Virus',
    description:
        'Tomato mosaic virus (ToMV) causes mosaic patterns of light '
        'and dark green on leaves, leaf distortion, and stunted growth. '
        'It spreads mechanically through tools, hands, and plant debris. '
        'Infected fruits may show color abnormalities and undersizing.',
    solution:
        '• Sanitize all tools with 10% bleach solution before use.\n'
        '• Wash hands thoroughly before handling plants.\n'
        '• Remove infected plants immediately to prevent spread.\n'
        '• Plant TMV-resistant tomato varieties.\n'
        '• Avoid tobacco products near plants (ToMV source).',
    iconEmoji: '🍅',
    severity: 'High',
    color: '#558B2F',
  ),
  37: Disease(
    name: 'Healthy Tomato',
    description:
        'Tomato plant shows no signs of disease. Leaves are deep green '
        'and undamaged, stems are sturdy, and fruit development is '
        'normal. The plant is thriving with current care.',
    solution:
        '• Stake or cage plants for support as they grow.\n'
        '• Water at the base consistently (1–2 inches per week).\n'
        '• Apply calcium fertilizer to prevent blossom-end rot.\n'
        '• Prune suckers for better airflow and larger fruit.\n'
        '• Scout weekly for early pest and disease signs.',
    iconEmoji: '🍅',
    severity: 'None',
    color: '#2E7D32',
  ),

  // ── BACKGROUND ─────────────────────────────────────────────────
  38: Disease(
    name: 'No Leaf Detected',
    description:
        'No plant leaf was clearly identified in this image. The photo '
        'may be blurry, too dark, too far away, or may not show a plant '
        'leaf. Please retake the photo for a valid analysis.',
    solution:
        '• Take a close-up photo of a single leaf.\n'
        '• Ensure the leaf fills most of the frame.\n'
        '• Use good lighting — natural daylight works best.\n'
        '• Hold the camera steady to avoid blur.\n'
        '• Place the leaf on a plain background if possible.',
    iconEmoji: '📷',
    severity: 'None',
    color: '#9E9E9E',
  ),
};
