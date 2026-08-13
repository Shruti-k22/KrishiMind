/// All 36 districts of Maharashtra, grouped by the state's six revenue
/// divisions.
///
/// Why grouped: a flat list of 36 names is a long, tiring scroll. Grouping by
/// region means a farmer from Kolhapur looks under "Pune Division" and scans
/// five names instead of thirty-six.
///
/// Each district carries its name in Devanagari and in English. Only one is
/// shown at a time — whichever matches the language chosen on the previous
/// screen.
class District {
  final String id; // stable key saved to the phone, never shown
  final String en; // English name
  final String mr; // Devanagari name (same for Marathi and Hindi)
  final double lat; // district headquarters, used to fetch the weather
  final double lon;

  const District({
    required this.id,
    required this.en,
    required this.mr,
    required this.lat,
    required this.lon,
  });
}

class DistrictGroup {
  final String en; // division name in English
  final String mr; // division name in Devanagari
  final String region; // agro-climatic region — this is what the crop data is keyed by
  final List<District> districts;

  const DistrictGroup({
    required this.en,
    required this.mr,
    required this.region,
    required this.districts,
  });
}

const List<DistrictGroup> maharashtraDistricts = [
  DistrictGroup(
    en: 'Pune Division',
    region: 'Western Maharashtra',
    mr: 'पुणे विभाग',
    districts: [
      District(id: 'pune', en: 'Pune', mr: 'पुणे', lat: 18.52, lon: 73.86),
      District(id: 'satara', en: 'Satara', mr: 'सातारा', lat: 17.69, lon: 74.0),
      District(id: 'sangli', en: 'Sangli', mr: 'सांगली', lat: 16.85, lon: 74.58),
      District(id: 'solapur', en: 'Solapur', mr: 'सोलापूर', lat: 17.66, lon: 75.91),
      District(id: 'kolhapur', en: 'Kolhapur', mr: 'कोल्हापूर', lat: 16.7, lon: 74.24),
    ],
  ),
  DistrictGroup(
    en: 'Nashik Division',
    region: 'North Maharashtra',
    mr: 'नाशिक विभाग',
    districts: [
      District(id: 'nashik', en: 'Nashik', mr: 'नाशिक', lat: 20.0, lon: 73.79),
      District(id: 'dhule', en: 'Dhule', mr: 'धुळे', lat: 20.9, lon: 74.77),
      District(id: 'nandurbar', en: 'Nandurbar', mr: 'नंदुरबार', lat: 21.37, lon: 74.24),
      District(id: 'jalgaon', en: 'Jalgaon', mr: 'जळगाव', lat: 21.01, lon: 75.56),
      District(id: 'ahilyanagar', en: 'Ahilyanagar', mr: 'अहिल्यानगर', lat: 19.09, lon: 74.75),
    ],
  ),
  DistrictGroup(
    en: 'Chhatrapati Sambhajinagar Division',
    region: 'Marathwada',
    mr: 'छत्रपती संभाजीनगर विभाग',
    districts: [
      District(
        id: 'chh_sambhajinagar',
        en: 'Chhatrapati Sambhajinagar',
        mr: 'छत्रपती संभाजीनगर',
        lat: 19.88,
        lon: 75.34,
      ),
      District(id: 'jalna', en: 'Jalna', mr: 'जालना', lat: 19.84, lon: 75.89),
      District(id: 'beed', en: 'Beed', mr: 'बीड', lat: 18.99, lon: 75.76),
      District(id: 'dharashiv', en: 'Dharashiv', mr: 'धाराशिव', lat: 18.19, lon: 76.04),
      District(id: 'nanded', en: 'Nanded', mr: 'नांदेड', lat: 19.15, lon: 77.32),
      District(id: 'latur', en: 'Latur', mr: 'लातूर', lat: 18.4, lon: 76.56),
      District(id: 'parbhani', en: 'Parbhani', mr: 'परभणी', lat: 19.27, lon: 76.77),
      District(id: 'hingoli', en: 'Hingoli', mr: 'हिंगोली', lat: 19.72, lon: 77.15),
    ],
  ),
  DistrictGroup(
    en: 'Amravati Division',
    region: 'Vidarbha',
    mr: 'अमरावती विभाग',
    districts: [
      District(id: 'amravati', en: 'Amravati', mr: 'अमरावती', lat: 20.93, lon: 77.75),
      District(id: 'akola', en: 'Akola', mr: 'अकोला', lat: 20.71, lon: 77.0),
      District(id: 'washim', en: 'Washim', mr: 'वाशिम', lat: 20.11, lon: 77.13),
      District(id: 'buldhana', en: 'Buldhana', mr: 'बुलढाणा', lat: 20.53, lon: 76.18),
      District(id: 'yavatmal', en: 'Yavatmal', mr: 'यवतमाळ', lat: 20.39, lon: 78.13),
    ],
  ),
  DistrictGroup(
    en: 'Nagpur Division',
    region: 'Vidarbha',
    mr: 'नागपूर विभाग',
    districts: [
      District(id: 'nagpur', en: 'Nagpur', mr: 'नागपूर', lat: 21.15, lon: 79.09),
      District(id: 'wardha', en: 'Wardha', mr: 'वर्धा', lat: 20.75, lon: 78.6),
      District(id: 'bhandara', en: 'Bhandara', mr: 'भंडारा', lat: 21.17, lon: 79.65),
      District(id: 'gondia', en: 'Gondia', mr: 'गोंदिया', lat: 21.46, lon: 80.2),
      District(id: 'chandrapur', en: 'Chandrapur', mr: 'चंद्रपूर', lat: 19.95, lon: 79.3),
      District(id: 'gadchiroli', en: 'Gadchiroli', mr: 'गडचिरोली', lat: 20.18, lon: 80.0),
    ],
  ),
  DistrictGroup(
    en: 'Konkan Division',
    region: 'Konkan',
    mr: 'कोकण विभाग',
    districts: [
      District(id: 'thane', en: 'Thane', mr: 'ठाणे', lat: 19.22, lon: 72.98),
      District(id: 'palghar', en: 'Palghar', mr: 'पालघर', lat: 19.7, lon: 72.77),
      District(id: 'raigad', en: 'Raigad', mr: 'रायगड', lat: 18.64, lon: 72.87),
      District(id: 'ratnagiri', en: 'Ratnagiri', mr: 'रत्नागिरी', lat: 16.99, lon: 73.31),
      District(id: 'sindhudurg', en: 'Sindhudurg', mr: 'सिंधुदुर्ग', lat: 16.13, lon: 73.68),
      District(id: 'mumbai_city', en: 'Mumbai City', mr: 'मुंबई शहर', lat: 18.94, lon: 72.83),
      District(id: 'mumbai_suburban', en: 'Mumbai Suburban', mr: 'मुंबई उपनगर', lat: 19.15, lon: 72.85),
    ],
  ),
];

/// Find a district by its saved id. Returns null if it isn't found — which can
/// happen if the list ever changes between app versions.
District? findDistrictById(String? id) {
  if (id == null) return null;
  for (final group in maharashtraDistricts) {
    for (final d in group.districts) {
      if (d.id == id) return d;
    }
  }
  return null;
}

/// Which agro-climatic region a district belongs to. The crop and disease data
/// is organised by region, not by district — Kolhapur and Sangli share almost
/// all the same crops and the same problems, so storing it twice would be waste.
String? findRegionForDistrict(String? id) {
  if (id == null) return null;
  for (final group in maharashtraDistricts) {
    for (final d in group.districts) {
      if (d.id == id) return group.region;
    }
  }
  return null;
}
