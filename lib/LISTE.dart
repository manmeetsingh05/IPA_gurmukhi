import 'package:flutter/material.dart'; // Serve per Rect

// List of Punjabi alphabet letters
final List<String> punjabiAlphabet = [
  "ੳ",
  "ਅ",
  "ੲ",
  "ਸ",
  "ਹ",
  "ਕ",
  "ਖ",
  "ਗ",
  "ਘ",
  "ਙ",
  "ਚ",
  "ਛ",
  "ਜ",
  "ਝ",
  "ਞ",
  "ਟ",
  "ਠ",
  "ਡ",
  "ਢ",
  "ਣ",
  "ਤ",
  "ਥ",
  "ਦ",
  "ਧ",
  "ਨ",
  "ਪ",
  "ਫ",
  "ਬ",
  "ਭ",
  "ਮ",
  "ਯ",
  "ਰ",
  "ਲ",
  "ਵ",
  "ੜ",
  "ਸ਼",
  "ਜ਼",
  "ਖ਼",
  "ਗ਼",
  "ਫ਼",
  "ਲ਼",
];
final List<String> punjabiPronunciations = [
  "Urha",
  "Èrha",
  "Irhi",
  "Sassaa",
  "Haha",
  "Kakkaa",
  "Khakkhaa",
  "Gaggaa",
  "Ghagghaa",
  "Nganga",
  "Chachaa",
  "Chhachhaa",
  "Jajjaa",
  "Jhajjhaa",
  "Gnagna",
  "Tènkaa",
  "ThaTThaa",
  "DaDDaa",
  "DdhaDdhaa",
  "nNanNa",
  "tattaa",
  "thatthaa",
  "daddaa",
  "dhaddhaa",
  "Nannaa",
  "Pappaa",
  "Faffaa",
  "Babbaa",
  "Bhabbhaa",
  "Mammaa",
  "Yayaa",
  "Rara",
  "Lallaa",
  "Vava",
  "RhaRha",
  "Shashaa",
  "Zazaa",
  "Khhakhhaa",
  "gagaa",
  "Fafaa",
  "Lalaa"
];

// Lista delle vocali
final List<Map<String, String>> segniVocali = [
  {"◌ਾ": "Kannaa"},
  {" ਿ": "Sihaari"},
  {"◌ੀ": "Bihaari"},
  {"◌ੁ": "ÒnkaRh"},
  {"◌ੂ": "DulenkaRh"},
  {"◌ੇ": "Lava(n)"},
  {"◌ੈ": "Dulavaa(n)"},
  {"◌ੋ": "HoRha"},
  {"◌ੌ": "KnòRha"},
];
final List<String> punjabiVowels = [
  "ਅ",
  "ਆ",
  "ਇ",
  "ਈ",
  "ਉ",
  "ਊ",
  "ਏ",
  "ਐ",
  "ਓ",
  "ਔ"
];
final List<String> punjabiVowelPronunciations = [
  "a",
  "aa",
  "i",
  "ii",
  "u",
  "uu",
  "e",
  "ai",
  "o",
  "au"
];

// Lista delle lettere iniziali
final List<String> MuharniBase = [
  "ਕ",
  "ਖ",
  "ਗ",
  "ਘ",
  "ਙ",
  "ਚ",
  "ਛ",
  "ਜ",
  "ਝ",
  "ਞ",
  "ਟ",
  "ਠ",
  "ਡ",
  "ਢ",
  "ਣ",
  "ਤ",
  "ਥ",
  "ਦ",
  "ਧ",
  "ਨ",
  "ਪ",
  "ਫ",
  "ਬ",
  "ਭ",
  "ਮ",
  "ਯ",
  "ਰ",
  "ਲ",
  "ਵ",
  "ੜ",
  "ਸ਼",
  "ਖ਼",
  "ਗ਼",
  "ਜ਼",
  "ਫ਼",
  "ਲ਼"
];
final Map<String, List<Map<String, String>>> muharniCombinations = {
  "ਕ": [
    {"ਕ": "ka"},
    {"ਕਾ": "kaa"},
    {"ਕਿ": "ki"},
    {"ਕੀ": "kee"},
    {"ਕੁ": "ku"},
    {"ਕੂ": "koo"},
    {"ਕੇ": "ke"},
    {"ਕੈ": "kai"},
    {"ਕੋ": "ko"},
    {"ਕੌ": "kau"},
    {"ਕੰ": "kan"},
    {"ਕਾਂ": "kaan"}
  ],
  "ਖ": [
    {"ਖ": "kha"},
    {"ਖਾ": "khaa"},
    {"ਖਿ": "khi"},
    {"ਖੀ": "khee"},
    {"ਖੁ": "khu"},
    {"ਖੂ": "khoo"},
    {"ਖੇ": "khe"},
    {"ਖੈ": "khai"},
    {"ਖੋ": "kho"},
    {"ਖੌ": "khau"},
    {"ਖੰ": "khan"},
    {"ਖਾਂ": "khaan"}
  ],
  "ਗ": [
    {"ਗ": "ga"},
    {"ਗਾ": "gaa"},
    {"ਗਿ": "gi"},
    {"ਗੀ": "gee"},
    {"ਗੁ": "gu"},
    {"ਗੂ": "goo"},
    {"ਗੇ": "ge"},
    {"ਗੈ": "gai"},
    {"ਗੋ": "go"},
    {"ਗੌ": "gau"},
    {"ਗੰ": "gan"},
    {"ਗਾਂ": "gaan"}
  ],
  "ਘ": [
    {"ਘ": "gha"},
    {"ਘਾ": "ghaa"},
    {"ਘਿ": "ghi"},
    {"ਘੀ": "ghee"},
    {"ਘੁ": "ghu"},
    {"ਘੂ": "ghoo"},
    {"ਘੇ": "ghe"},
    {"ਘੈ": "ghai"},
    {"ਘੋ": "gho"},
    {"ਘੌ": "ghau"},
    {"ਘੰ": "ghan"},
    {"ਘਾਂ": "ghaan"}
  ],
  "ਙ": [
    {"ਙ": "nga"},
    {"ਙਾ": "ngaa"},
    {"ਙਿ": "ngi"},
    {"ਙੀ": "ngee"},
    {"ਙੁ": "ngu"},
    {"ਙੂ": "ngoo"},
    {"ਙੇ": "nge"},
    {"ਙੈ": "ngai"},
    {"ਙੋ": "ngo"},
    {"ਙੌ": "ngau"},
    {"ਙੰ": "ngan"},
    {"ਙਾਂ": "ngaan"}
  ],
  "ਚ": [
    {"ਚ": "cha"},
    {"ਚਾ": "chaa"},
    {"ਚਿ": "chi"},
    {"ਚੀ": "chee"},
    {"ਚੁ": "chu"},
    {"ਚੂ": "chuu"},
    {"ਚੇ": "che"},
    {"ਚੈ": "chai"},
    {"ਚੋ": "cho"},
    {"ਚੌ": "chau"},
    {"ਚੰ": "chan"},
    {"ਚਾਂ": "chaan"}
  ],
  "ਛ": [
    {"ਛ": "chha"},
    {"ਛਾ": "chhaa"},
    {"ਛਿ": "chhi"},
    {"ਛੀ": "chhee"},
    {"ਛੁ": "chhu"},
    {"ਛੂ": "chhoo"},
    {"ਛੇ": "chhe"},
    {"ਛੈ": "chhai"},
    {"ਛੋ": "cho"},
    {"ਛੌ": "chau"},
    {"ਛੰ": "chan"},
    {"ਛਾਂ": "chhaan"}
  ],
  "ਜ": [
    {"ਜ": "ja"},
    {"ਜਾ": "jaa"},
    {"ਜਿ": "ji"},
    {"ਜੀ": "jee"},
    {"ਜੁ": "ju"},
    {"ਜੂ": "joo"},
    {"ਜੇ": "je"},
    {"ਜੈ": "jai"},
    {"ਜੋ": "jo"},
    {"ਜੌ": "jau"},
    {"ਜੰ": "jan"},
    {"ਜਾਂ": "jaan"}
  ],
  "ਝ": [
    {"ਝ": "jha"},
    {"ਝਾ": "jhaa"},
    {"ਝਿ": "jhi"},
    {"ਝੀ": "jhee"},
    {"ਝੁ": "jhu"},
    {"ਝੂ": "jhoo"},
    {"ਝੇ": "jhe"},
    {"ਝੈ": "jhai"},
    {"ਝੋ": "jho"},
    {"ਝੌ": "jhau"},
    {"ਝੰ": "jhan"},
    {"ਝਾਂ": "jhaan"}
  ],
  "ਞ": [
    {"ਞ": "nya"},
    {"ਞਾ": "nyaa"},
    {"ਞਿ": "nyi"},
    {"ਞੀ": "nyee"},
    {"ਞੁ": "nyu"},
    {"ਞੂ": "nyoo"},
    {"ਞੇ": "nye"},
    {"ਞੈ": "nyai"},
    {"ਞੋ": "nyo"},
    {"ਞੌ": "nyau"},
    {"ਞੰ": "nyan"},
    {"ਞਾਂ": "nyaan"}
  ],
  "ਟ": [
    {"ਟ": "tta"},
    {"ਟਾ": "ttaa"},
    {"ਟਿ": "tti"},
    {"ਟੀ": "ttee"},
    {"ਟੁ": "ttu"},
    {"ਟੂ": "ttoo"},
    {"ਟੇ": "tte"},
    {"ਟੈ": "ttai"},
    {"ਟੋ": "tto"},
    {"ਟੌ": "ttau"},
    {"ਟੰ": "ttan"},
    {"ਟਾਂ": "ttaan"}
  ],
  "ਠ": [
    {"ਠ": "ttha"},
    {"ਠਾ": "tthaa"},
    {"ਠਿ": "tthi"},
    {"ਠੀ": "tthee"},
    {"ਠੁ": "tthu"},
    {"ਠੂ": "tthoo"},
    {"ਠੇ": "tthe"},
    {"ਠੈ": "tthai"},
    {"ਠੋ": "ttho"},
    {"ਠੌ": "tthau"},
    {"ਠੰ": "tthan"},
    {"ਠਾਂ": "tthaan"}
  ],
  "ਡ": [
    {"ਡ": "dda"},
    {"ਡਾ": "ddaa"},
    {"ਡਿ": "ddi"},
    {"ਡੀ": "ddii"},
    {"ਡੁ": "ddu"},
    {"ਡੂ": "ddoo"},
    {"ਡੇ": "dde"},
    {"ਡੈ": "ddai"},
    {"ਡੋ": "ddo"},
    {"ਡੌ": "ddau"},
    {"ਡੰ": "ddan"},
    {"ਡਾਂ": "ddaan"}
  ],
  "ਢ": [
    {"ਢ": "ddha"},
    {"ਢਾ": "ddhaa"},
    {"ਢਿ": "ddhi"},
    {"ਢੀ": "ddhee"},
    {"ਢੁ": "ddhu"},
    {"ਢੂ": "ddhoo"},
    {"ਢੇ": "ddhe"},
    {"ਢੈ": "ddhai"},
    {"ਢੋ": "ddho"},
    {"ਢੌ": "ddhau"},
    {"ਢੰ": "ddhan"},
    {"ਢਾਂ": "ddhaan"}
  ],
  "ਣ": [
    {"ਣ": "naa"},
    {"ਣਾ": "naaa"},
    {"ਣਿ": "nii"},
    {"ਣੀ": "nee"},
    {"ਣੁ": "nuu"},
    {"ਣੂ": "noo"},
    {"ਣੇ": "ne"},
    {"ਣੈ": "nai"},
    {"ਣੋ": "no"},
    {"ਣੌ": "nau"},
    {"ਣੰ": "nan"},
    {"ਣਾਂ": "naan"}
  ],
  "ਤ": [
    {"ਤ": "ta"},
    {"ਤਾ": "taa"},
    {"ਤਿ": "ti"},
    {"ਤੀ": "tee"},
    {"ਤੁ": "tu"},
    {"ਤੂ": "too"},
    {"ਤੇ": "te"},
    {"ਤੈ": "tai"},
    {"ਤੋ": "to"},
    {"ਤੌ": "tau"},
    {"ਤੰ": "tan"},
    {"ਤਾਂ": "taan"}
  ],
  "ਥ": [
    {"ਥ": "tha"},
    {"ਥਾ": "thaa"},
    {"ਥਿ": "thi"},
    {"ਥੀ": "thee"},
    {"ਥੁ": "thu"},
    {"ਥੂ": "thoo"},
    {"ਥੇ": "the"},
    {"ਥੈ": "thai"},
    {"ਥੋ": "tho"},
    {"ਥੌ": "thau"},
    {"ਥੰ": "than"},
    {"ਥਾਂ": "thaan"}
  ],
  "ਦ": [
    {"ਦ": "da"},
    {"ਦਾ": "daa"},
    {"ਦਿ": "di"},
    {"ਦੀ": "dee"},
    {"ਦੁ": "du"},
    {"ਦੂ": "doo"},
    {"ਦੇ": "de"},
    {"ਦੈ": "dai"},
    {"ਦੋ": "do"},
    {"ਦੌ": "dau"},
    {"ਦੰ": "dan"},
    {"ਦਾਂ": "daan"}
  ],
  "ਧ": [
    {"ਧ": "dha"},
    {"ਧਾ": "dhaa"},
    {"ਧਿ": "dhi"},
    {"ਧੀ": "dhee"},
    {"ਧੁ": "dhu"},
    {"ਧੂ": "dhoo"},
    {"ਧੇ": "dhe"},
    {"ਧੈ": "dhai"},
    {"ਧੋ": "dho"},
    {"ਧੌ": "dhau"},
    {"ਧੰ": "dhan"},
    {"ਧਾਂ": "dhaan"}
  ],
  "ਨ": [
    {"ਨ": "na"},
    {"ਨਾ": "naa"},
    {"ਨਿ": "ni"},
    {"ਨੀ": "nee"},
    {"ਨੁ": "nu"},
    {"ਨੂ": "noo"},
    {"ਨੇ": "ne"},
    {"ਨੈ": "nai"},
    {"ਨੋ": "no"},
    {"ਨੌ": "nau"},
    {"ਨੰ": "nan"},
    {"ਨਾਂ": "naan"}
  ],
  "ਪ": [
    {"ਪ": "pa"},
    {"ਪਾ": "paa"},
    {"ਪਿ": "pi"},
    {"ਪੀ": "pee"},
    {"ਪੁ": "pu"},
    {"ਪੂ": "poo"},
    {"ਪੇ": "pe"},
    {"ਪੈ": "pai"},
    {"ਪੋ": "po"},
    {"ਪੌ": "pau"},
    {"ਪੰ": "pan"},
    {"ਪਾਂ": "paan"}
  ],
  "ਫ": [
    {"ਫ": "pha"},
    {"ਫਾ": "phaa"},
    {"ਫਿ": "phi"},
    {"ਫੀ": "phee"},
    {"ਫੁ": "phu"},
    {"ਫੂ": "phoo"},
    {"ਫੇ": "phe"},
    {"ਫੈ": "phai"},
    {"ਫੋ": "pho"},
    {"ਫੌ": "phau"},
    {"ਫੰ": "phan"},
    {"ਫਾਂ": "phaan"}
  ],
  "ਬ": [
    {"ਬ": "ba"},
    {"ਬਾ": "baa"},
    {"ਬਿ": "bi"},
    {"ਬੀ": "bee"},
    {"ਬੁ": "bu"},
    {"ਬੂ": "boo"},
    {"ਬੇ": "be"},
    {"ਬੈ": "bai"},
    {"ਬੋ": "bo"},
    {"ਬੌ": "bau"},
    {"ਬੰ": "ban"},
    {"ਬਾਂ": "baan"}
  ],
  "ਭ": [
    {"ਭ": "bha"},
    {"ਭਾ": "bhaa"},
    {"ਭਿ": "bhi"},
    {"ਭੀ": "bhee"},
    {"ਭੁ": "bhu"},
    {"ਭੂ": "bhoo"},
    {"ਭੇ": "bhe"},
    {"ਭੈ": "bhai"},
    {"ਭੋ": "bho"},
    {"ਭੌ": "bhau"},
    {"ਭੰ": "bhan"},
    {"ਭਾਂ": "bhaan"}
  ],
  "ਮ": [
    {"ਮ": "ma"},
    {"ਮਾ": "maa"},
    {"ਮਿ": "mi"},
    {"ਮੀ": "mee"},
    {"ਮੁ": "mu"},
    {"ਮੂ": "moo"},
    {"ਮੇ": "me"},
    {"ਮੈ": "mai"},
    {"ਮੋ": "mo"},
    {"ਮੌ": "mau"},
    {"ਮੰ": "man"},
    {"ਮਾਂ": "maan"}
  ],
  "ਯ": [
    {"ਯ": "ya"},
    {"ਯਾ": "yaa"},
    {"ਯਿ": "yi"},
    {"ਯੀ": "yee"},
    {"ਯੁ": "yu"},
    {"ਯੂ": "yoo"},
    {"ਏ": "e"},
    {"ਐ": "ai"},
    {"ਓ": "o"},
    {"ਔ": "au"},
    {"ਅੰ": "an"},
    {"ਅਂ": "ang"}
  ],
  "ਰ": [
    {"ਰ": "ra"},
    {"ਰਾ": "raa"},
    {"ਰਿ": "ri"},
    {"ਰੀ": "ree"},
    {"ਰੁ": "ru"},
    {"ਰੂ": "roo"},
    {"ਰੇ": "re"},
    {"ਰੈ": "rai"},
    {"ਰੋ": "ro"},
    {"ਰੌ": "rau"},
    {"ਰੰ": "ran"},
    {"ਰਾਂ": "raan"}
  ],
  "ਲ": [
    {"ਲ": "la"},
    {"ਲਾ": "laa"},
    {"ਲਿ": "li"},
    {"ਲੀ": "lee"},
    {"ਲੁ": "lu"},
    {"ਲੂ": "loo"},
    {"ਲੇ": "le"},
    {"ਲੈ": "lai"},
    {"ਲੋ": "lo"},
    {"ਲੌ": "lau"},
    {"ਲੰ": "lan"},
    {"ਲਾਂ": "laan"}
  ],
  "ਵ": [
    {"ਵ": "va"},
    {"ਵਾ": "vaa"},
    {"ਵਿ": "vi"},
    {"ਵੀ": "vee"},
    {"ਵੁ": "vu"},
    {"ਵੂ": "voo"},
    {"ਵੇ": "ve"},
    {"ਵੈ": "vai"},
    {"ਵੋ": "vo"},
    {"ਵੌ": "vau"},
    {"ਵੰ": "van"},
    {"ਵਾਂ": "vaan"}
  ],
  "ੜ": [
    {"ੜ": "rra"},
    {"ੜਾ": "rraa"},
    {"ੜਿ": "rri"},
    {"ੜੀ": "rree"},
    {"ੜੁ": "rru"},
    {"ੜੂ": "rruu"},
    {"ੜੇ": "rre"},
    {"ੜੈ": "rrai"},
    {"ੜੋ": "rro"},
    {"ੜੌ": "rrau"},
    {"ੜੰ": "rran"},
    {"ੜਾਂ": "rran"}
  ],
  "ਸ਼": [
    {"ਸ਼": "sha"},
    {"ਸ਼ਾ": "shaa"},
    {"ਸ਼ਿ": "shi"},
    {"ਸ਼ੀ": "shee"},
    {"ਸ਼ੁ": "shu"},
    {"ਸ਼ੂ": "shoo"},
    {"ਸ਼ੇ": "she"},
    {"ਸ਼ੈ": "shai"},
    {"ਸ਼ੋ": "sho"},
    {"ਸ਼ੌ": "shau"},
    {"ਸ਼ੰ": "shan"},
    {"ਸ਼ਾਂ": "shaan"}
  ],
  "ਖ਼": [
    {"ਖ਼": "kha"},
    {"ਖ਼ਾ": "khaa"},
    {"ਖ਼ਿ": "khi"},
    {"ਖ਼ੀ": "khee"},
    {"ਖ਼ੁ": "khu"},
    {"ਖ਼ੂ": "khoo"},
    {"ਖ਼ੇ": "khe"},
    {"ਖ਼ੈ": "khai"},
    {"ਖ਼ੋ": "kho"},
    {"ਖ਼ੌ": "khau"},
    {"ਖ਼ੰ": "khan"},
    {"ਖ਼ਾਂ": "khaan"}
  ],
  "ਗ਼": [
    {"ਗ਼": "gha"},
    {"ਗ਼ਾ": "ghaa"},
    {"ਗ਼ਿ": "ghi"},
    {"ਗ਼ੀ": "ghee"},
    {"ਗ਼ੁ": "ghu"},
    {"ਗ਼ੂ": "ghoo"},
    {"ਗ਼ੇ": "ghe"},
    {"ਗ਼ੈ": "ghai"},
    {"ਗ਼ੋ": "gho"},
    {"ਗ਼ੌ": "ghau"},
    {"ਗ਼ੰ": "ghan"},
    {"ਗ਼ਾਂ": "ghaan"}
  ],
  "ਜ਼": [
    {"ਜ਼": "za"},
    {"ਜ਼ਾ": "zaa"},
    {"ਜ਼ਿ": "zi"},
    {"ਜ਼ੀ": "zee"},
    {"ਜ਼ੁ": "zu"},
    {"ਜ਼ੂ": "zoo"},
    {"ਜ਼ੇ": "ze"},
    {"ਜ਼ੈ": "zai"},
    {"ਜ਼ੋ": "zo"},
    {"ਜ਼ੌ": "zau"},
    {"ਜ਼ੰ": "zan"},
    {"ਜ਼ਾ": "zaan"}
  ],
  "ਫ਼": [
    {"ਫ਼": "fa"},
    {"ਫ਼ਾ": "faa"},
    {"ਫ਼ਿ": "fi"},
    {"ਫ਼ੀ": "fee"},
    {"ਫ਼ੁ": "fu"},
    {"ਫ਼ੂ": "foo"},
    {"ਫ਼ੇ": "fe"},
    {"ਫ਼ੈ": "fai"},
    {"ਫ਼ੋ": "fo"},
    {"ਫ਼ੌ": "fau"},
    {"ਫ਼ੰ": "fan"},
    {"ਫ਼ਾਂ": "faan"}
  ],
  "ਲ਼": [
    {"ਲ਼": "lla"},
    {"ਲ਼ਾ": "llaa"},
    {"ਲ਼ਿ": "lli"},
    {"ਲ਼ੀ": "llee"},
    {"ਲ਼ੁ": "llu"},
    {"ਲ਼ੂ": "lloo"},
    {"ਲ਼ੇ": "lle"},
    {"ਲ਼ੈ": "llai"},
    {"ਲ਼ੋ": "llo"},
    {"ਲ਼ੌ": "llau"},
    {"ਲ਼ੰ": "llan"},
    {"ਲ਼ਾਂ": "llaan"}
  ],
};

final List<String> AdhakWords = [
  'ਬਚਿੱਤਰ',
  'ਮੱਤ',
  'ਮਿੱਤਰ',
  'ਮਿੱਤਰਤਾ',
  'ਲੱਕ',
  'ਅੱਖ',
  'ਅੱਖਰ',
  'ਅੱਧ',
  'ਸੱਜਣ',
  'ਸੱਟ',
  'ਸੱਤ',
  'ਸਪੁੱਤਰ',
  'ਸਰਬੱਤ',
  'ਸੁਣਖਾ',
  'ਸੁਲੱਖਣੀ',
  'ਗੜਗੱਜ',
  'ਘੱਟ',
  'ਚੱਕਰ',
  'ਜਗ',
  'ਟਰੱਕ ',
  'ਨਛੱਤਰ',
  'ਪੱਥਰ',
  'ਪਵਿੱਤਰ',
  'ਪੁੱਤਰ',
];
final List<String> AdhakPronunciations = [
  'Bacchitar',
  'Matt',
  'Mitter',
  'Mitterta',
  'Lakk',
  'Akh',
  'Akhar',
  'Addh',
  'Sajan',
  'Satt',
  'Satt',
  'Suputtar',
  'Sarbatt',
  'Sunakha',
  'Sulakhani',
  'Gaddgaj',
  'Ghat',
  'Chakkar',
  'Jag',
  'Truck',
  'Nachhattar',
  'Pathar',
  'Pavittar',
  'Putar',
];

final List<String> BindiWords = [
  "ਛਿਆਨਵੇਂ",
  "ਜਹਾਂਗੀਰ",
  "ਡਾਂਗ",
  "ਡਾਵਾਂ ਡੋਲ",
  "ਨਾਂਦੇੜ",
  "ਨੀਂਦ",
  "ਪਰਸੋਂ",
  "ਪਰਛਾਵਾਂ",
  "ਪੀਂਘ",
  "ਬਾਂਸ",
  "ਬਾਹ",
  "ਬਾਂਦਰ",
  "ਮਹਾਬਲੀ",
  "ਮਾਵਾਂ",
  "ਮੀਹ",
  "ਲਾਂਗਰੀ",
  "ਵਟਾਂਦਰਾ",
  "ਉਗਲ",
  "ਇਕਾਂਤ",
  "ਇੰਗਲੈਂਡ",
  "ਸੰਗਰਾਂਦ",
  "ਸਾਈ",
  "ਕਿਤਾਬਾਂ",
  "ਛਲਾਂਗ",
];
final List<String> BindiPronunciations = [
  "Chhianven",
  "Jahangir",
  "Dang",
  "Dawan Dol",
  "Nandera",
  "Neend",
  "Parson",
  "Parchhawan",
  "Peengh",
  "Baans",
  "Baah",
  "Baandar",
  "Mahabali",
  "Mawan",
  "Meeh",
  "Langri",
  "Vatandra",
  "Ugal",
  "Ikant",
  "England",
  "Sangrand",
  "Sai",
  "Kitaban",
  "Chhalang",
];

final List<String> TippiWords = [
  "ਖੰਭ",
  "ਚੰਦ",
  "ਜੰਗਲ",
  "ਜੁਗਨੂੰ",
  "ਠੰਢ",
  "ਤਲਵੰਡੀ",
  "ਥੰਮ",
  "ਨਿਰੰਕਾਰ",
  "ਬਸੰਤ",
  "ਭਗਵੰਤ",
  "ਭੁਜੰਗੀ",
  "ਮੈਨੂੰ",
  "ਰੰਕ",
  "ਰੰਗ",
  "ਲੰਗਰ",
  "ਅੰਗੂਰ",
  "ਸੰਸਾ",
  "ਸਤਸੰਗ",
  "ਸੰਦੂਕ",
  "ਸਮੁੰਦਰ",
  "ਸੁੰਦਰ",
  "ਹਰਿਬੰਸ",
  "ਹੇਮਕੁੰਟ",
  "ਕੁਲਵੰਤ",
];
final List<String> TippiPronunciations = [
  "Khambh",
  "Chand",
  "Jangal",
  "Jugnu",
  "Thand",
  "Talwandi",
  "Thamm",
  "Nirankar",
  "Basant",
  "Bhagwant",
  "Bhujangi",
  "Mainu",
  "Rank",
  "Rang",
  "Langar",
  "Angoor",
  "Sansa",
  "Satsang",
  "Sandook",
  "Samundar",
  "Sundar",
  "Haribans",
  "Hemkunt",
  "Kulwant",
];

final List<String> MuktaWords = [
  "ਹਰਮਨ",
  "ਹਲਚਲ",
  "ਕਰਮ",
  "ਗੜਬੜ",
  "ਘਰ",
  "ਚਲ",
  "ਜਗਤ",
  "ਜਨ",
  "ਜਲਥਲ",
  "ਤਪ",
  "ਦਰਸਨ",
  "ਧਰਮ",
  "ਨਫਰਤ",
  "ਪਰਬਤ",
  "ਬਲ",
  "ਭਗਤ",
  "ਭਰ",
  "ਰਸ",
  "ਰਤਨ",
  "ਅਮਰ",
  "ਸਬਰ",
  "ਸ਼ਰਮ",
  "ਹਰ",
  "ਹਰਕਤ",
];
final List<String> MuktaPronunciations = [
  "Harman",
  "Halchal",
  "Karam",
  "Garbhar",
  "Ghar",
  "Chal",
  "Jagat",
  "Jan",
  "Jalthal",
  "Tap",
  "Darsan",
  "Dharm",
  "Nafrat",
  "Parbat",
  "Bal",
  "Bhagat",
  "Bhar",
  "Ras",
  "Ratan",
  "Amar",
  "Sabar",
  "Sharm",
  "Har",
  "Harkat",
];

final List<String> KannaWords = [
  "ਹਾਰ",
  "ਕਮਰਾ",
  "ਕਰਾਮਾਤ",
  "ਕਾਦਰ",
  "ਘਾਲ",
  "ਚਾਲ",
  "ਜਾਨ",
  "ਟਕਸਾਲ",
  "ਤਾਪ",
  "ਦਸਤਾਰ",
  "ਦਰਬਾਰ ",
  "ਪਰਸ਼ਾਦ",
  "ਬਾਬਲ",
  "ਬਾਬਾ",
  "ਬਾਲ",
  "ਭਗਤਾ",
  "ਭਗਵਾਨ",
  "ਭਾਰ",
  "ਯਾਦਗਾਰ",
  "ਰਾਸ",
  "ਅਕਾਲ",
  "ਅਰਾਮ",
  "ਅਵਤਾਰ",
  "ਆਸਣ",
];
final List<String> KannaPronunciations = [
  "Haar",
  "Kamra",
  "Karamat",
  "Kadar",
  "Ghaal",
  "Chaal",
  "Jaan",
  "Taksal",
  "Taap",
  "Dastaar",
  "Darbar",
  "Parshad",
  "Babal",
  "Baba",
  "Bal",
  "Bhagta",
  "Bhagwan",
  "Bhaar",
  "Yaadgar",
  "Raas",
  "Akaal",
  "Araam",
  "Avtar",
  "Aasan",
];

final List<String> SihariWords = [
  "ਕਵਿਤਾ",
  "ਕਿਆ",
  "ਕਿਰਨ",
  "ਖਿਆਲ",
  "ਗਹਿਣਾ",
  "ਗਿਆ",
  "ਗਿਆਨ",
  "ਜਿਸ",
  "ਜ਼ਿਕਰ",
  "ਟਹਲ",
  "ਦਿਨ",
  "ਦਿਲ",
  "ਪਿਆਰ",
  "ਫਿਕਰ",
  "ਫਿਰ",
  "ਫਿਰਨ",
  "ਮਹਿਲ",
  "ਮਿਲ",
  " ਹਿਰਨ",
  "ਅਗਿਆਨ",
  "ਇਹ",
  "ਇਕ ",
  "ਸ਼ਹਿਰ",
  "ਕਹਿਣਾ",
];
final List<String> SihariPronunciations = [
  "Kavita",
  "Kiya",
  "Kiran",
  "Khiyaal",
  "Gahina",
  "Gia",
  "Gyaan",
  "Jis",
  "Zikar",
  "Tahal",
  "Din",
  "Dil",
  "Pyaar",
  "Fikar",
  "Phir",
  "Phiran",
  "Mahil",
  "Mil",
  "Hiran",
  "Agyan",
  "Ih",
  "Ik",
  "Sheher",
  "Kehna",
];

final List<String> BihariWords = [
  "ਕਾਰੀਗਰ",
  "ਕੀਰਤਨ",
  "ਗਰੀਬ",
  "ਜਸਬੀਰ",
  "ਜੀਤ",
  "ਜੀਭ",
  "ਝਰੀਟ",
  "ਠੀਕ",
  "ਨਕਲੀ",
  "ਪੀਰ",
  "ਬਲਬੀਰ",
  "ਬਾਜ਼ੀਗਰ",
  "ਬੀਰਬਲ",
  "ਮਸ਼ਕਰੀ",
  "ਮਲਾਈ",
  "ਮੀਤ",
  "ਰਜਾਈ",
  "ਰੀਤ",
  "ਲੀਕ",
  "ਵੀਰ",
  "ਅਸਲੀ",
  "ਅਮਰੀਕ",
  "ਅਮੀਰ",
  "ਸਰੀਰ",
];
final List<String> BihariPronunciations = [
  "Kaareegar",
  "Kirtan",
  "Gareeb",
  "Jasbeer",
  "Jit",
  "Jeev",
  "Jharit",
  "Theek",
  "Nakli",
  "Peer",
  "Balbeer",
  "Baazigar",
  "Birbal",
  "Mashkari",
  "Malai",
  "Meet",
  "Rajaai",
  "Reet",
  "Leak",
  "Veer",
  "Asli",
  "Amrik",
  "Ameer",
  "Shareer",
];

final List<String> OnkarhWords = [
  "ਸੁਰਮਾ ",
  "ਹਸਮੁਖ",
  "ਕੁਰਬਾਨੀ",
  "ਖੁਰਾਕ",
  "ਗੁਣ",
  "ਗੁਰ",
  "ਗੁਰਬਾਣੀ",
  "ਗੁਰਮੁਖ",
  "ਗੁਲਾਬ",
  "ਚੁਣ",
  "ਤੁਰਨਾ",
  "ਦੁਕਾਨ",
  "ਪੁਣ",
  "ਫੁਲਕਾਰੀ",
  "ਫੁਲਵਾੜੀ",
  "ਬੁਰਕੀ",
  "ਬੁਲ ਬੁਲ",
  "ਰਾਮਪੁਰ",
  "ਵਹੁਟੀ",
  "ਉਦਾਸ",
  "ਸਹੁ",
  "ਸੁਖ",
  "ਸੁਚ",
  "ਸੁਰ",
];
final List<String> OnkarhPronunciations = [
  "Surma ",
  "Hasmukh",
  "Qurbani",
  "Khuraak",
  "Gun",
  "Gur",
  "Gurbani",
  "Gurmukh",
  "Gulab",
  "Chun",
  "Turna",
  "Dukaan",
  "Pun",
  "Phulkari",
  "Phulwaari",
  "Burki",
  "Bul Bul",
  "Rampur",
  "Vahuti",
  "Udaas",
  "Sahu",
  "Sukh",
  "Such",
  "Sur",
];

final List<String> DulenkarhWords = [
  "ਕਰਤੂਤ",
  "ਕਾਰਤੂਸ",
  "ਜਰੂਰ",
  "ਜੂਠ",
  "ਝੂਠ",
  "ਡਮਰੂ",
  "ਧੂਫ",
  "ਪੂਰਬ",
  "ਫਜੂਲ",
  "ਫੂਕ",
  "ਬਾਪੂ",
  "ਬੂਹਾ",
  "ਮਜਦੂਰ",
  "ਮਨਜ਼ੂਰ",
  "ਮਾਸੂਮ",
  "ਰੂਪ",
  "ਵਾਹਿਗੁਰੂ",
  "ਸਰਦੂਲ",
  "ਸਾਧੂ",
  "ਸੁਰਖਰੂ",
  "ਸੂਰਜ",
  "ਸੂਰਬੀਰ",
  "ਹਜੂਰ",
  "ਕਸੂਰ",
];
final List<String> DulenkarhPronunciations = [
  "Kartoot",
  "Kartus",
  "Zaroor",
  "Juth",
  "Jhooth",
  "Damroo",
  "Dhoof",
  "Poorab",
  "Fazool",
  "Phook",
  "Bapu",
  "Booha",
  "Mazdoor",
  "Manzoor",
  "Masoom",
  "Roop",
  "Waheguru",
  "Sardool",
  "Sadhoo",
  "Surkhro",
  "Suraj",
  "Soorbeer",
  "Hazoor",
  "Kasoor",
];

final List<String> LavaaWords = [
  "ਸੇਬ",
  "ਸੇਵਕ",
  "ਸੇਵਾ",
  "ਕੱਪੜੇ",
  "ਕਰੇਲੇ",
  "ਕਲੇਸ਼",
  "ਕੇਸਰ",
  "ਖੇਡ",
  "ਗੁਰਦੇਵ",
  "ਗੁਰਮੇਲ",
  "ਤੇਰੇ",
  "ਦਸਮੇਸ਼",
  "ਦਰਵੇਸ਼",
  "ਨਿਤਨੇਮ",
  "ਬਨੇਰੇ",
  "ਬੇਨਤੀ",
  "ਭੇਡ",
  "ਮੇਜ਼",
  "ਮੇਰੇ",
  "ਮੇਲ",
  "ਉਪਦੇਸ਼",
  "ਸ਼ਮਸ਼ੇਰ",
  "ਸਵੇਰੇ",
  "ਸੁਖਦੇਵ",
];
final List<String> LavaaPronunciations = [
  "Seb",
  "Sevak",
  "Seva",
  "Kapde",
  "Karele",
  "Klesh",
  "Kesar",
  "Khed",
  "Gurdev",
  "Gurmela",
  "Tere",
  "Dasmesh",
  "Darvesh",
  "Nitnem",
  "Banere",
  "Benti",
  "Bhed",
  "Mez",
  "Mere",
  "Mel",
  "Updesh",
  "Shamsher",
  "Savere",
  "Sukhdev",
];

final List<String> DulaavaWords = [
  "ਸੁਖਚੈਨ",
  "ਸੁਖੈਨ",
  "ਸ਼ੈਤਾਨ",
  "ਸੈਨਾਪਤੀ",
  "ਸੈਰ",
  "ਹੈਰਾਨ",
  "ਕਵਲਨੈਣ",
  "ਕੈਦ",
  "ਖੈਰ",
  "ਜਰਨੈਲ",
  "ਜੈਕਾਰਾ",
  "ਤੈਰ",
  "ਨਿਰਵੈਰ",
  "ਨੈਣ",
  "ਬੈਠ",
  "ਭੈਣ",
  "ਭੈਰਵ",
  "ਮਧੁਰਬੈਣ",
  "ਮੈਦਾਨ",
  "ਰੈਣ",
  "ਵੈਰਾਗ",
  "ਐਤਵਾਰ",
  "ਐਲਾਨ",
  "ਸਵੈਟਰ",
];
final List<String> DulaavaPronunciations = [
  "Sukhchain",
  "Sukhain",
  "Shaitan",
  "Senapati",
  "Sair",
  "Hairan",
  "Kavlnaen",
  "Kaid",
  "Khair",
  "Jarnail",
  "Jaikara",
  "Tair",
  "Nirvair",
  "Nain",
  "Baith",
  "Bhen",
  "Bhairav",
  "Madhurbhen",
  "Maidan",
  "Rain",
  "Vairag",
  "Aitvar",
  "Ailan",
  "Sweater",
];

final List<String> HorhaWords = [
  "ਸੋਚ",
  "ਸੋਮਵਾਰ",
  "ਸ਼ੋਰ",
  "ਕਮਜ਼ੋਰ",
  "ਕਰੋਧ",
  "ਕਾਰੋਬਾਰ",
  "ਕੋਇਲ",
  "ਕੋਸ਼ਿਸ਼",
  "ਗੋਦਾਵਰੀ",
  "ਚਕੋਰ",
  "ਚੋਰ",
  "ਜੋਬਨ",
  "ਜੋਰ",
  "ਜੋਰਾਵਰ",
  "ਢੋਲ",
  "ਬੋਲ",
  "ਭਰੋਸਾ",
  "ਮਨੋਬਲ",
  "ਮੋਨ",
  "ਮੋਰਚਾ",
  "ਮੋੜ",
  "ਅਮੋਲਕ",
  "ਸਰੋਵਰ",
  "ਸਲੋਕ",
];
final List<String> HorhaPronunciations = [
  "Soch",
  "Somvar",
  "Shor",
  "Kamzor",
  "Krodh",
  "Karobar",
  "Koil",
  "Koshish",
  "Godavari",
  "Chakor",
  "Chor",
  "Joban",
  "Jor",
  "Joravar",
  "Dhol",
  "Bol",
  "Bharosa",
  "Manobal",
  "Mon",
  "Morcha",
  "Mor",
  "Amolak",
  "Sarovar",
  "Slok",
];

final List<String> KnaurhaWords = [
  "ਚੌਰ",
  "ਚੌਰਾਹਾ",
  "ਤੌਲੀਆ",
  "ਧੌਣ",
  "ਨੌ ਬਰ ਨੌ",
  "ਨੌਕਰ",
  "ਨੌਜਵਾਨ",
  "ਪਕੌੜੇ",
  "ਪੌਣ",
  "ਪੌਦਾ",
  "ਫੌਜ",
  "ਬਖਤੌਰ",
  "ਬਲਾਚੌਰ",
  "ਮਖੌਲ",
  "ਮੌਸਮ",
  "ਮੌਜ",
  "ਸੌਦਾਗਰ",
  "ਹੌਸਲਾ",
  "ਕੌਣ",
  "ਕੌਰ",
  "ਖੌਫਨਾਕ",
  "ਚਮਕੌਰ",
  "ਚੌਂਕੀਦਾਰ",
  "ਚੌਬਾਰਾ",
];
final List<String> KnaurhaPronunciations = [
  "Chor",
  "Choraha",
  "Tolia",
  "Dhaun",
  "Nau Bar Nau",
  "Naukar",
  "Naujawan",
  "Pakore",
  "Pauṇ",
  "Pauda",
  "Fauj",
  "Bakhtaur",
  "Balachor",
  "Makhol",
  "Mausam",
  "Mauj",
  "Sodagar",
  "Hausla",
  "Kaun",
  "Kaur",
  "Khofnak",
  "Chamakor",
  "Chonkidar",
  "Chobara",
];

//Liste usate nei giochi per generare le parole
final Map<String, String> categoryPaths = {
  "AdhakWords": "assets/SUONI/ACCENTO-PESANTE(Addhak)",
  "BindiWords": "assets/SUONI/NASALE_GENERALE(Bindi)",
  "TippiWords": "assets/SUONI/NASALE-PARTICOLARE(Tippi)",
  "MuktaWords": "assets/SUONI/Mukta",
  "KannaWords": "assets/SUONI/Kanna",
  "SihariWords": "assets/SUONI/Sihari",
  "BihariWords": "assets/SUONI/Bihari",
  "OnkarhWords": "assets/SUONI/Onkarh",
  "DulenkarhWords": "assets/SUONI/Dulenkarh",
  "LavaaWords": "assets/SUONI/Lavaa",
  "DulaavaWords": "assets/SUONI/Dulaava",
  "HorhaWords": "assets/SUONI/Horha",
  "KnaurhaWords": "assets/SUONI/Knaurha",
};
final Map<List<String>, String> wordCategories = {
  AdhakWords: "AdhakWords",
  BindiWords: "BindiWords",
  TippiWords: "TippiWords",
  MuktaWords: "MuktaWords",
  KannaWords: "KannaWords",
  SihariWords: "SihariWords",
  BihariWords: "BihariWords",
  OnkarhWords: "OnkarhWords",
  DulenkarhWords: "DulenkarhWords",
  LavaaWords: "LavaaWords",
  DulaavaWords: "DulaavaWords",
  HorhaWords: "HorhaWords",
  KnaurhaWords: "KnaurhaWords",
};

// !!! SOSTITUISCI I PLACEHOLDER CON LE COORDINATE CORRETTE !!!
final Map<String, List<Rect>> letterCheckpoints = {
  "ੳ": [
    Rect.fromLTWH(70, 228, 80, 80), // Centro (110, 268)
    Rect.fromLTWH(660, 231, 80, 80), // Centro (700, 271)
    Rect.fromLTWH(581, 421, 80, 80), // Centro (621, 461)
    Rect.fromLTWH(355, 502, 80, 80), // Centro (395, 542)
    Rect.fromLTWH(424, 805, 80, 80), // Centro (464, 845)
    Rect.fromLTWH(161, 462, 80, 80), // Centro (201, 502)
    Rect.fromLTWH(367, -1, 80, 80), // Centro (407, 39)
    Rect.fromLTWH(597, 182, 80, 80), // Centro (637, 222)
  ],
  "ਅ": [
    // Lato 140
    Rect.fromLTWH(63, 229, 140, 140), // Centro (133, 299)
    Rect.fromLTWH(338, 565, 140, 140), // Centro (408, 635)
    Rect.fromLTWH(240, 799, 140, 140), // Centro (310, 869)
    Rect.fromLTWH(590, 328, 140, 140), // Centro (660, 398)
    Rect.fromLTWH(651, 521, 140, 140), // Centro (721, 591)
    Rect.fromLTWH(624, 892, 140, 140), // Centro (694, 962)
    Rect.fromLTWH(551, 766, 140, 140), // Centro (621, 836)
    Rect.fromLTWH(942, 547, 140, 140), // Centro (1012, 617)
    Rect.fromLTWH(944, 1005, 140, 140), // Centro (1014, 1075)
    Rect.fromLTWH(
        930, 216, 140, 140), // Centro (1000, 286) // Verificato centro
    Rect.fromLTWH(1066, 213, 140, 140), // Centro (1136, 283)
  ],
  "ੲ": [
    // Lato 140
    Rect.fromLTWH(133, 306, 140, 140), // Centro (203, 376) // Verificato centro
    Rect.fromLTWH(916, 311, 140, 140), // Centro (986, 381)
    Rect.fromLTWH(918, 649, 140, 140), // Centro (988, 719)
    Rect.fromLTWH(672, 819, 140, 140), // Centro (742, 889)
    Rect.fromLTWH(299, 1078, 140, 140), // Centro (369, 1148)
    Rect.fromLTWH(
        880, 1380, 140, 140), // Centro (950, 1450) // Verificato centro
    Rect.fromLTWH(310, 427, 140, 140), // Centro (380, 497)
    Rect.fromLTWH(449, 707, 140, 140), // Centro (519, 807)
  ],
  "ਸ": [
    // Lato 140
    Rect.fromLTWH(77, 285, 140, 140), // Centro (147, 355)
    Rect.fromLTWH(1047, 273, 140, 140), // Centro (1117, 343)
    Rect.fromLTWH(347, 446, 140, 140), // Centro (417, 516)
    Rect.fromLTWH(361, 1124, 140, 140), // Centro (431, 1194)
    Rect.fromLTWH(286, 923, 140, 140), // Centro (356, 993)
    Rect.fromLTWH(672, 748, 140, 140), // Centro (742, 818)
    Rect.fromLTWH(924, 748, 140, 140), // Centro (994, 818)
    Rect.fromLTWH(919, 388, 140, 140), // Centro (989, 458)
    Rect.fromLTWH(927, 1298, 140, 140), // Centro (997, 1368)
  ],
  "ਹ": [
    // Lato 140
    Rect.fromLTWH(111, 299, 140, 140), // Centro (181, 369)
    Rect.fromLTWH(1035, 300, 140, 140), // Centro (1105, 370)
    Rect.fromLTWH(912, 690, 140, 140), // Centro (982, 760)
    Rect.fromLTWH(545, 1293, 140, 140), // Centro (615, 1363)
    Rect.fromLTWH(532, 746, 140, 140), // Centro (602, 816)
  ],
  "ਕ": [
    // Lato 140
    Rect.fromLTWH(85, 256, 140, 140), // Centro (155, 326)
    Rect.fromLTWH(1039, 256, 140, 140), // Centro (1109, 326)
    Rect.fromLTWH(848, 696, 140, 140), // Centro (918, 766)
    Rect.fromLTWH(253, 818, 140, 140), // Centro (323, 888)
    Rect.fromLTWH(780, 841, 140, 140), // Centro (850, 911)
    Rect.fromLTWH(880, 1209, 140, 140), // Centro (950, 1279)
  ],
  "ਖ": [
    // Lato 140
    Rect.fromLTWH(81, 299, 140, 140), // Centro (151, 369)
    Rect.fromLTWH(390, 491, 140, 140), // Centro (460, 561) // Verificato
    Rect.fromLTWH(316, 893, 140, 140), // Centro (386, 963)
    Rect.fromLTWH(614, 1121, 140, 140), // Centro (684, 1191) // Verificato
    Rect.fromLTWH(885, 962, 140, 140), // Centro (955, 1032) // Corretto centro
    Rect.fromLTWH(909, 408, 140, 140), // Centro (979, 478) // Corretto centro
    Rect.fromLTWH(882, 1322, 140, 140), // Centro (952, 1392) // Corretto centro
    Rect.fromLTWH(424, 662, 140, 140), // Centro (494, 732)
    Rect.fromLTWH(805, 664, 140, 140), // Centro (875, 734)
  ],
  "ਗ": [
    // Lato 140
    Rect.fromLTWH(128, 213, 140, 140), // Centro (198, 283)
    Rect.fromLTWH(947, 214, 140, 140), // Centro (1017, 284)
    Rect.fromLTWH(945, 541, 140, 140), // Centro (1015, 611)
    Rect.fromLTWH(959, 1023, 140, 140), // Centro (1029, 1093)
    Rect.fromLTWH(660, 265, 140, 140), // Centro (730, 335)
    Rect.fromLTWH(645, 958, 140, 140), // Centro (715, 1028)
    Rect.fromLTWH(274, 918, 140, 140), // Centro (344, 988)
    Rect.fromLTWH(256, 604, 140, 140), // Centro (326, 674)
    Rect.fromLTWH(662, 561, 140, 140), // Centro (732, 631)
  ],
  "ਘ": [
    // Lato 140
    Rect.fromLTWH(93, 243, 140, 140), // Centro (163, 313)
    Rect.fromLTWH(304, 241, 140, 140), // Centro (374, 311)
    Rect.fromLTWH(255, 727, 140, 140), // Centro (325, 797)
    Rect.fromLTWH(437, 925, 140, 140), // Centro (507, 995)
    Rect.fromLTWH(684, 506, 140, 140), // Centro (754, 576)
    Rect.fromLTWH(629, 288, 140, 140), // Centro (699, 358)
    Rect.fromLTWH(585, 579, 140, 140), // Centro (655, 649)
    Rect.fromLTWH(788, 914, 140, 140), // Centro (858, 984)
    Rect.fromLTWH(944, 796, 140, 140), // Centro (1014, 866)
    Rect.fromLTWH(945, 384, 140, 140), // Centro (1015, 454)
    Rect.fromLTWH(941, 235, 140, 140), // Centro (1011, 305)
    Rect.fromLTWH(943, 1066, 140, 140), // Centro (1013, 1136)
  ],
  "ਙ": [
    // Lato 140
    Rect.fromLTWH(101, 304, 140, 140), // Centro (171, 374)
    Rect.fromLTWH(1055, 295, 140, 140), // Centro (1125, 365)
    Rect.fromLTWH(259, 342, 140, 140), // Centro (329, 412)
    Rect.fromLTWH(250, 648, 140, 140), // Centro (320, 718) // Corretto centro Y
    Rect.fromLTWH(886, 801, 140, 140), // Centro (956, 871)
    Rect.fromLTWH(708, 1231, 140, 140), // Centro (778, 1301)
    Rect.fromLTWH(256, 1163, 140, 140), // Centro (326, 1233)
    Rect.fromLTWH(555, 966, 140, 140), // Centro (625, 1036)
    Rect.fromLTWH(821, 1118, 140, 140), // Centro (891, 1188)
    Rect.fromLTWH(970, 1347, 140, 140), // Centro (1040, 1417)
  ],
  "ਚ": [
    Rect.fromLTWH(116, 276, 140, 140), // Centro (186, 346)
    Rect.fromLTWH(921, 264, 140, 140), // Centro (991, 334)
    Rect.fromLTWH(921, 544, 140, 140), // Centro (991, 614)
    Rect.fromLTWH(922, 771, 140, 140), // Centro (992, 841)
    Rect.fromLTWH(682, 763, 140, 140), // Centro (752, 833)
    Rect.fromLTWH(231, 773, 140, 140), // Centro (301, 843)
    Rect.fromLTWH(371, 596, 140, 140), // Centro (441, 666)
    Rect.fromLTWH(392, 966, 140, 140), // Centro (462, 1036)
    Rect.fromLTWH(738, 1280, 140, 140), // Centro (808, 1350)
    Rect.fromLTWH(917, 811, 140, 140), // Centro (987, 881)
  ],
  "ਛ": [
    Rect.fromLTWH(135, 282, 140, 140), // Centro (205, 352)
    Rect.fromLTWH(890, 281, 140, 140), // Centro (960, 351)
    Rect.fromLTWH(872, 544, 140, 140), // Centro (942, 614)
    Rect.fromLTWH(641, 556, 140, 140), // Centro (711, 626)
    Rect.fromLTWH(337, 592, 140, 140), // Centro (407, 662)
    Rect.fromLTWH(349, 773, 140, 140), // Centro (419, 913)
    Rect.fromLTWH(602, 871, 140, 140), // Centro (672, 941)
    Rect.fromLTWH(672, 871, 140, 140), // Centro (979, 989)
    Rect.fromLTWH(591, 1212, 140, 140), // Centro (961, 1282)
    Rect.fromLTWH(459, 1194, 140, 140), // Centro (529, 1334)
    Rect.fromLTWH(266, 1048, 140, 140), // Centro (336, 1118)
    Rect.fromLTWH(611, 965, 140, 140), // Centro (681, 1035)
    Rect.fromLTWH(601, 1236, 140, 140), // Centro (671, 1306)
  ],
  "ਜ": [
    Rect.fromLTWH(113, 264, 140, 140), // Centro (173, 354)
    Rect.fromLTWH(848, 264, 140, 140), // Centro (988, 351)
    Rect.fromLTWH(869, 716, 140, 140), // Centro (986, 846)
    Rect.fromLTWH(879, 1200, 140, 140), // Centro (998, 1346)
    Rect.fromLTWH(770, 842, 140, 140), // Centro (910, 882)
    Rect.fromLTWH(152, 813, 140, 140), // Centro (292, 893)
    Rect.fromLTWH(308, 632, 140, 140), // Centro (448, 702)
    Rect.fromLTWH(317, 1200, 140, 140), // Centro (461, 1350)
  ],
  "ਝ": [
    Rect.fromLTWH(267, 264, 180, 180), // Centro (337, 404)
    Rect.fromLTWH(943, 262, 180, 180), // Centro (1013, 392)
    Rect.fromLTWH(259, 727, 180, 180), // Centro (399, 867)
    Rect.fromLTWH(247, 555, 180, 180), // Centro (388, 595)
    Rect.fromLTWH(807, 897, 180, 180), // Centro (947, 1037)
    Rect.fromLTWH(400, 1281, 180, 180), // Centro (520, 1321)
    Rect.fromLTWH(304, 1063, 180, 180), // Centro (494, 1183)
    Rect.fromLTWH(803, 1340, 180, 180), // Centro (803, 1480)
  ],
  "ਞ": [
    Rect.fromLTWH(111, 309, 140, 140), // Centro (181, 379)
    Rect.fromLTWH(945, 307, 140, 140), // Centro (1015, 377)
    Rect.fromLTWH(913, 657, 140, 140), // Centro (983, 727)
    Rect.fromLTWH(285, 855, 140, 140), // Centro (355, 925)
    Rect.fromLTWH(934, 993, 140, 140), // Centro (1004, 1063)
    Rect.fromLTWH(524, 1174, 140, 140), // Centro (594, 1244)
    Rect.fromLTWH(944, 1317, 140, 140), // Centro (1014, 1387)
    Rect.fromLTWH(304, 420, 140, 140), // Centro (374, 490)
    Rect.fromLTWH(389, 604, 140, 140), // Centro (459, 674)
  ],
  "ਟ": [
    Rect.fromLTWH(83, 296, 140, 140), // Centro (153, 366)
    Rect.fromLTWH(906, 301, 140, 140), // Centro (976, 371)
    Rect.fromLTWH(918, 657, 140, 140), // Centro (988, 727)
    Rect.fromLTWH(284, 979, 140, 140), // Centro (354, 1049)
    Rect.fromLTWH(922, 1307, 140, 140), // Centro (992, 1377)
  ],
  "ਠ": [
    Rect.fromLTWH(92, 276, 140, 140), // Centro (162, 346)
    Rect.fromLTWH(1021, 268, 140, 140), // Centro (1091, 338)
    Rect.fromLTWH(589, 590, 140, 140), // Centro (659, 660)
    Rect.fromLTWH(273, 1058, 140, 140), // Centro (343, 1128)
    Rect.fromLTWH(563, 1226, 140, 140), // Centro (633, 1296)
    Rect.fromLTWH(634, 610, 140, 140), // Centro (704, 680)
  ],
  "ਡ": [
    Rect.fromLTWH(107, 281, 140, 140), // Centro (177, 351)
    Rect.fromLTWH(1004, 272, 140, 140), // Centro (1074, 342)
    Rect.fromLTWH(823, 561, 140, 140), // Centro (893, 631)
    Rect.fromLTWH(496, 707, 140, 140), // Centro (566, 777)
    Rect.fromLTWH(323, 646, 140, 140), // Centro (393, 716)
    Rect.fromLTWH(705, 670, 140, 140), // Centro (775, 740)
    Rect.fromLTWH(927, 1019, 140, 140), // Centro (997, 1089)
    Rect.fromLTWH(314, 1203, 140, 140), // Centro (384, 1273)
    Rect.fromLTWH(432, 945, 140, 140), // Centro (502, 1015)
    Rect.fromLTWH(776, 1147, 140, 140), // Centro (846, 1217)
  ],
  "ਢ": [
    Rect.fromLTWH(162, 274, 140, 140), // Centro (232, 344)
    Rect.fromLTWH(910, 267, 140, 140), // Centro (980, 337)
    Rect.fromLTWH(910, 503, 140, 140), // Centro (980, 573)
    Rect.fromLTWH(912, 712, 140, 140), // Centro (982, 782)
    Rect.fromLTWH(484, 722, 140, 140), // Centro (554, 792)
    Rect.fromLTWH(251, 705, 140, 140), // Centro (321, 775)
    Rect.fromLTWH(346, 572, 140, 140), // Centro (416, 642)
    Rect.fromLTWH(403, 1003, 140, 140), // Centro (463, 1073)
    Rect.fromLTWH(763, 1265, 140, 140), // Centro (833, 1335)
    Rect.fromLTWH(956, 1070, 140, 140), // Centro (1026, 1140)
    Rect.fromLTWH(536, 1133, 140, 140), // Centro (606, 1203)
  ],
  "ਣ": [
    Rect.fromLTWH(108, 247, 140, 140), // Centro (178, 317)
    Rect.fromLTWH(1040, 235, 140, 140), // Centro (1110, 305)
    Rect.fromLTWH(550, 266, 140, 140), // Centro (620, 336)
    Rect.fromLTWH(961, 542, 140, 140), // Centro (1031, 612)
    Rect.fromLTWH(722, 438, 140, 140), // Centro (792, 508)
    Rect.fromLTWH(679, 590, 140, 140), // Centro (749, 660)
    Rect.fromLTWH(248, 818, 140, 140), // Centro (318, 888)
    Rect.fromLTWH(912, 1105, 140, 140), // Centro (982, 1175)
  ],
  "ਤ": [
    Rect.fromLTWH(119, 298, 140, 140), // Centro (189, 368)
    Rect.fromLTWH(922, 277, 140, 140), // Centro (992, 347)
    Rect.fromLTWH(863, 659, 140, 140), // Centro (933, 729)
    Rect.fromLTWH(484, 875, 140, 140), // Centro (554, 945)
    Rect.fromLTWH(457, 745, 140, 140), // Centro (527, 815)
    Rect.fromLTWH(908, 1099, 140, 140), // Centro (978, 1169)
    Rect.fromLTWH(234, 1279, 140, 140), // Centro (304, 1349)
  ],
  "ਥ": [
    Rect.fromLTWH(110, 287, 140, 140), // Centro (180, 357)
    Rect.fromLTWH(902, 297, 140, 140), // Centro (972, 367)
    Rect.fromLTWH(936, 528, 140, 140), // Centro (1006, 598)
    Rect.fromLTWH(916, 1319, 140, 140), // Centro (986, 1389)
    Rect.fromLTWH(344, 353, 140, 140), // Centro (414, 423)
    Rect.fromLTWH(322, 906, 140, 140), // Centro (382, 976)
    Rect.fromLTWH(591, 1106, 140, 140), // Centro (661, 1176)
    Rect.fromLTWH(852, 1019, 140, 140), // Centro (922, 1089)
    Rect.fromLTWH(457, 686, 140, 140), // Centro (527, 756)
    Rect.fromLTWH(849, 679, 140, 140), // Centro (919, 749)
  ],
  "ਦ": [
    Rect.fromLTWH(101, 270, 140, 140), // Centro (171, 340)
    Rect.fromLTWH(914, 286, 140, 140), // Centro (984, 356)
    Rect.fromLTWH(925, 726, 140, 140), // Centro (995, 796)
    Rect.fromLTWH(500, 753, 140, 140), // Centro (570, 823)
    Rect.fromLTWH(199, 741, 140, 140), // Centro (269, 811)
    Rect.fromLTWH(363, 593, 140, 140), // Centro (433, 663)
    Rect.fromLTWH(432, 1101, 140, 140), // Centro (502, 1171)
    Rect.fromLTWH(914, 1245, 140, 140), // Centro (984, 1315)
  ],
  "ਧ": [
    Rect.fromLTWH(135, 299, 140, 140), // Centro (205, 369)
    Rect.fromLTWH(921, 308, 140, 140), // Centro (991, 378)
    Rect.fromLTWH(912, 765, 140, 140), // Centro (982, 835)
    Rect.fromLTWH(921, 1329, 140, 140), // Centro (991, 1399)
    Rect.fromLTWH(352, 370, 140, 140), // Centro (422, 440)
    Rect.fromLTWH(326, 919, 140, 140), // Centro (396, 989)
    Rect.fromLTWH(603, 1106, 140, 140), // Centro (673, 1176)
    Rect.fromLTWH(856, 1029, 140, 140), // Centro (926, 1099)
  ],
  "ਨ": [
    Rect.fromLTWH(90, 270, 140, 140), // Centro (160, 340)
    Rect.fromLTWH(1021, 273, 140, 140), // Centro (1091, 343)
    Rect.fromLTWH(601, 322, 140, 140), // Centro (671, 392)
    Rect.fromLTWH(592, 618, 140, 140), // Centro (662, 688)
    Rect.fromLTWH(262, 906, 140, 140), // Centro (332, 976)
    Rect.fromLTWH(379, 1206, 140, 140), // Centro (439, 1276)
    Rect.fromLTWH(909, 883, 140, 140), // Centro (979, 953)
    Rect.fromLTWH(819, 1196, 140, 140), // Centro (889, 1266)
  ],
  "ਪ": [
    Rect.fromLTWH(101, 278, 140, 140), // Centro (171, 348)
    Rect.fromLTWH(379, 432, 140, 140), // Centro (449, 502)
    Rect.fromLTWH(304, 860, 140, 140), // Centro (374, 930)
    Rect.fromLTWH(570, 1052, 140, 140), // Centro (640, 1122)
    Rect.fromLTWH(898, 959, 140, 140), // Centro (968, 1029)
    Rect.fromLTWH(921, 314, 140, 140), // Centro (991, 384)
    Rect.fromLTWH(906, 1316, 140, 140), // Centro (976, 1386)
  ],
  "ਫ": [
    Rect.fromLTWH(134, 293, 140, 140), // Centro (204, 363)
    Rect.fromLTWH(910, 291, 140, 140), // Centro (980, 361)
    Rect.fromLTWH(912, 658, 140, 140), // Centro (982, 728)
    Rect.fromLTWH(259, 796, 140, 140), // Centro (329, 866)
    Rect.fromLTWH(707, 1348, 140, 140), // Centro (777, 1418)
    Rect.fromLTWH(928, 1130, 140, 140), // Centro (998, 1200)
    Rect.fromLTWH(424, 1134, 140, 140), // Centro (494, 1194)
  ],
  "ਬ": [
    Rect.fromLTWH(169, 300, 140, 140), // Centro (239, 370)
    Rect.fromLTWH(931, 289, 140, 140), // Centro (1001, 359)
    Rect.fromLTWH(918, 715, 140, 140), // Centro (988, 785)
    Rect.fromLTWH(922, 1314, 140, 140), // Centro (992, 1384)
    Rect.fromLTWH(264, 351, 140, 140), // Centro (334, 421)
    Rect.fromLTWH(497, 669, 140, 140), // Centro (557, 739)
    Rect.fromLTWH(839, 723, 140, 140), // Centro (909, 793)
    Rect.fromLTWH(301, 924, 140, 140), // Centro (371, 994)
    Rect.fromLTWH(851, 1126, 140, 140), // Centro (921, 1186)
  ],
  "ਭ": [
    Rect.fromLTWH(118, 311, 140, 140), // Centro (188, 381)
    Rect.fromLTWH(897, 314, 140, 140), // Centro (967, 384)
    Rect.fromLTWH(875, 706, 140, 140), // Centro (945, 776)
    Rect.fromLTWH(489, 1024, 140, 140), // Centro (559, 1094)
    Rect.fromLTWH(276, 823, 140, 140), // Centro (346, 893)
    Rect.fromLTWH(492, 656, 140, 140), // Centro (562, 726)
    Rect.fromLTWH(804, 841, 140, 140), // Centro (874, 911)
    Rect.fromLTWH(872, 1270, 140, 140), // Centro (932, 1340)
    Rect.fromLTWH(190, 1336, 140, 140), // Centro (260, 1406)
  ],
  "ਮ": [
    Rect.fromLTWH(90, 287, 140, 140), // Centro (160, 357)
    Rect.fromLTWH(389, 518, 140, 140), // Centro (459, 588)
    Rect.fromLTWH(381, 1094, 140, 140), // Centro (451, 1164)
    Rect.fromLTWH(265, 971, 140, 140), // Centro (335, 1041)
    Rect.fromLTWH(479, 733, 140, 140), // Centro (549, 803)
    Rect.fromLTWH(720, 753, 140, 140), // Centro (790, 823)
    Rect.fromLTWH(924, 751, 140, 140), // Centro (994, 821)
    Rect.fromLTWH(909, 315, 140, 140), // Centro (979, 385)
    Rect.fromLTWH(914, 1254, 140, 140), // Centro (984, 1324)
  ],
  "ਯ": [
    Rect.fromLTWH(86, 247, 140, 140), // Centro (156, 317)
    Rect.fromLTWH(943, 234, 140, 140), // Centro (1013, 304)
    Rect.fromLTWH(939, 649, 140, 140), // Centro (1009, 719)
    Rect.fromLTWH(933, 1108, 140, 140), // Centro (1003, 1178)
    Rect.fromLTWH(286, 286, 140, 140), // Centro (356, 356)
    Rect.fromLTWH(269, 794, 140, 140), // Centro (339, 864)
    Rect.fromLTWH(617, 940, 140, 140), // Centro (687, 1010)
    Rect.fromLTWH(637, 652, 140, 140), // Centro (707, 722)
    Rect.fromLTWH(883, 651, 140, 140), // Centro (953, 721)
  ],
  "ਰ": [
    Rect.fromLTWH(95, 299, 140, 140), // Centro (165, 369)
    Rect.fromLTWH(916, 312, 140, 140), // Centro (986, 382)
    Rect.fromLTWH(908, 787, 140, 140), // Centro (978, 857)
    Rect.fromLTWH(753, 1375, 140, 140), // Centro (823, 1485)
    Rect.fromLTWH(274, 872, 140, 140), // Centro (344, 942)
    Rect.fromLTWH(846, 783, 140, 140), // Centro (916, 853)
  ],
  "ਲ": [
    Rect.fromLTWH(98, 213, 140, 140), // Centro (168, 283)
    Rect.fromLTWH(1007, 219, 140, 140), // Centro (1077, 289)
    Rect.fromLTWH(400, 468, 140, 140), // Centro (470, 538)
    Rect.fromLTWH(583, 704, 140, 140), // Centro (653, 774)
    Rect.fromLTWH(796, 293, 140, 140), // Centro (866, 363)
    Rect.fromLTWH(742, 599, 140, 140), // Centro (812, 669)
    Rect.fromLTWH(934, 823, 140, 140), // Centro (1004, 883)
    Rect.fromLTWH(756, 1019, 140, 140), // Centro (826, 1089)
    Rect.fromLTWH(423, 598, 140, 140), // Centro (493, 668)
    Rect.fromLTWH(220, 816, 140, 140), // Centro (290, 886)
    Rect.fromLTWH(428, 1035, 140, 140), // Centro (498, 1105)
  ],
  "ਵ": [
    Rect.fromLTWH(101, 287, 140, 140), // Centro (171, 357)
    Rect.fromLTWH(927, 300, 140, 140), // Centro (997, 370)
    Rect.fromLTWH(908, 581, 140, 140), // Centro (978, 651)
    Rect.fromLTWH(276, 750, 140, 140), // Centro (346, 820)
    Rect.fromLTWH(479, 971, 140, 140), // Centro (549, 1041)
    Rect.fromLTWH(925, 963, 140, 140), // Centro (995, 1033)
    Rect.fromLTWH(481, 1040, 140, 140), // Centro (541, 1110)
    Rect.fromLTWH(917, 1327, 140, 140), // Centro (987, 1397)
  ],
  "ੜ": [
    Rect.fromLTWH(119, 287, 140, 140), // Centro (189, 357)
    Rect.fromLTWH(927, 284, 140, 140), // Centro (997, 354)
    Rect.fromLTWH(888, 530, 140, 140), // Centro (958, 600)
    Rect.fromLTWH(539, 718, 140, 140), // Centro (609, 788)
    Rect.fromLTWH(382, 658, 140, 140), // Centro (452, 728)
    Rect.fromLTWH(632, 640, 140, 140), // Centro (702, 710)
    Rect.fromLTWH(831, 727, 140, 140), // Centro (901, 797)
    Rect.fromLTWH(874, 1002, 140, 140), // Centro (934, 1072)
    Rect.fromLTWH(581, 1086, 140, 140), // Centro (651, 1156)
    Rect.fromLTWH(293, 1034, 140, 140), // Centro (363, 1104)
    Rect.fromLTWH(423, 1273, 140, 140), // Centro (493, 1343)
    Rect.fromLTWH(740, 1107, 140, 140), // Centro (810, 1177)
    Rect.fromLTWH(884, 1273, 140, 140), // Centro (954, 1343)
  ],
  "ਸ਼": [
    // Lato 140
    Rect.fromLTWH(154, 291, 140, 140), // Centro (224, 361)
    Rect.fromLTWH(1033, 272, 140, 140), // Centro (1103, 342)
    Rect.fromLTWH(332, 367, 140, 140), // Centro (402, 437)
    Rect.fromLTWH(376, 1124, 140, 140), // Centro (446, 1194)
    Rect.fromLTWH(422, 750, 140, 140), // Centro (492, 820)
    Rect.fromLTWH(914, 745, 140, 140), // Centro (984, 815)
    Rect.fromLTWH(916, 346, 140, 140), // Centro (986, 416)
    Rect.fromLTWH(908, 1264, 140, 140), // Centro (978, 1334)
    Rect.fromLTWH(
        551, 1294, 140, 140), // Centro (671, 1364) // Verificato centro
  ],
  "ਜ਼": [
    Rect.fromLTWH(109, 271, 140, 140), // Centro (179, 341)
    Rect.fromLTWH(919, 269, 140, 140), // Centro (989, 339)
    Rect.fromLTWH(922, 764, 140, 140), // Centro (992, 834)
    Rect.fromLTWH(918, 1237, 140, 140), // Centro (988, 1297)
    Rect.fromLTWH(860, 786, 140, 140), // Centro (930, 846)
    Rect.fromLTWH(217, 793, 140, 140), // Centro (297, 853)
    Rect.fromLTWH(361, 614, 140, 140), // Centro (431, 684)
    Rect.fromLTWH(370, 821, 140, 140), // Centro (440, 891)
    Rect.fromLTWH(374, 1226, 140, 140), // Centro (444, 1286)
    Rect.fromLTWH(658, 1225, 140, 140), // Centro (728, 1295)
  ],
  "ਖ਼": [
    // Lato 140
    Rect.fromLTWH(139, 302, 140, 140), // Centro (209, 372)
    Rect.fromLTWH(389, 636, 140, 140), // Centro (459, 706)
    Rect.fromLTWH(318, 862, 140, 140), // Centro (388, 932)
    Rect.fromLTWH(577, 1113, 140, 140), // Centro (647, 1183)
    Rect.fromLTWH(913, 990, 140, 140), // Centro (983, 1060)
    Rect.fromLTWH(917, 331, 140, 140), // Centro (987, 401)
    Rect.fromLTWH(928, 1324, 140, 140), // Centro (998, 1394)
    Rect.fromLTWH(428, 674, 140, 140), // Centro (498, 744)
    Rect.fromLTWH(916, 675, 140, 140), // Centro (986, 745)
    Rect.fromLTWH(270, 1346, 140, 140), // Centro (340, 1416)
  ],
  "ਗ਼": [
    Rect.fromLTWH(103, 221, 140, 140), // Centro (173, 291)
    Rect.fromLTWH(935, 219, 140, 140), // Centro (1005, 289)
    Rect.fromLTWH(954, 1024, 140, 140), // Centro (1024, 1084)
    Rect.fromLTWH(656, 260, 140, 140), // Centro (726, 330)
    Rect.fromLTWH(659, 573, 140, 140), // Centro (729, 643)
    Rect.fromLTWH(532, 1046, 140, 140), // Centro (602, 1106)
    Rect.fromLTWH(252, 598, 140, 140), // Centro (322, 668)
    Rect.fromLTWH(608, 572, 140, 140), // Centro (678, 642)
    Rect.fromLTWH(209, 1095, 140, 140), // Centro (279, 1165)
  ],
  "ਫ਼": [
    Rect.fromLTWH(83, 301, 140, 140), // Centro (153, 371)
    Rect.fromLTWH(918, 303, 140, 140), // Centro (988, 373)
    Rect.fromLTWH(914, 653, 140, 140), // Centro (984, 723)
    Rect.fromLTWH(320, 714, 140, 140), // Centro (390, 784)
    Rect.fromLTWH(375, 1178, 140, 140), // Centro (445, 1258)
    Rect.fromLTWH(934, 1138, 140, 140), // Centro (1004, 1208)
    Rect.fromLTWH(426, 1125, 140, 140), // Centro (486, 1195)
    Rect.fromLTWH(242, 1417, 140, 140), // Centro (312, 1487)
  ],
  "ਲ਼": [
    Rect.fromLTWH(69, 224, 140, 140), // Centro (139, 294)
    Rect.fromLTWH(1033, 206, 140, 140), // Centro (1103, 276)
    Rect.fromLTWH(366, 262, 140, 140), // Centro (436, 332)
    Rect.fromLTWH(442, 545, 140, 140), // Centro (512, 615)
    Rect.fromLTWH(595, 712, 140, 140), // Centro (665, 782)
    Rect.fromLTWH(826, 274, 140, 140), // Centro (866, 344)
    Rect.fromLTWH(740, 591, 140, 140), // Centro (810, 661)
    Rect.fromLTWH(971, 814, 140, 140), // Centro (1011, 874)
    Rect.fromLTWH(749, 1042, 140, 140), // Centro (809, 1102)
    Rect.fromLTWH(419, 602, 140, 140), // Centro (489, 672)
    Rect.fromLTWH(223, 818, 140, 140), // Centro (293, 878)
    Rect.fromLTWH(471, 1035, 140, 140), // Centro (521, 1105)
    Rect.fromLTWH(998, 1111, 140, 140), // Centro (1068, 1181)
  ],
};
