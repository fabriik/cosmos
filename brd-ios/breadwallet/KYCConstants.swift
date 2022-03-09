// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

// swiftlint:disable line_length
enum Constants {
    struct Countries {
        static let names: [String] = ["Ascension Island", "Andorra", "United Arab Emirates", "Afghanistan", "Antigua & Barbuda", "Anguilla", "Albania", "Armenia", "Angola", "Antarctica", "Argentina", "American Samoa", "Austria", "Australia", "Aruba", "Åland Islands", "Azerbaijan", "Bosnia & Herzegovina", "Barbados", "Bangladesh", "Belgium", "Burkina Faso", "Bulgaria", "Bahrain", "Burundi", "Benin", "St. Barthélemy", "Bermuda", "Brunei", "Bolivia", "Caribbean Netherlands", "Brazil", "Bahamas", "Bhutan", "Bouvet Island", "Botswana", "Belarus", "Belize", "Canada", "Cocos (Keeling) Islands", "Congo - Kinshasa", "Central African Republic", "Congo - Brazzaville", "Switzerland", "Côte d’Ivoire", "Cook Islands", "Chile", "Cameroon", "China mainland", "Colombia", "Clipperton Island", "Costa Rica", "Cuba", "Cape Verde", "Curaçao", "Christmas Island", "Cyprus", "Czechia", "Germany", "Diego Garcia", "Djibouti", "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ceuta & Melilla", "Ecuador", "Estonia", "Egypt", "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji", "Falkland Islands", "Micronesia", "Faroe Islands", "France", "Gabon", "United Kingdom", "Grenada", "Georgia", "French Guiana", "Guernsey", "Ghana", "Gibraltar", "Greenland", "Gambia", "Guinea", "Guadeloupe", "Equatorial Guinea", "Greece", "So. Georgia & So. Sandwich Isl.", "Guatemala", "Guam", "Guinea-Bissau", "Guyana", "Hong Kong", "Heard & McDonald Islands", "Honduras", "Croatia", "Haiti", "Hungary", "Canary Islands", "Indonesia", "Ireland", "Israel", "Isle of Man", "India", "Chagos Archipelago", "Iraq", "Iran", "Iceland", "Italy", "Jersey", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "Kiribati", "Comoros", "St. Kitts & Nevis", "North Korea", "South Korea", "Kuwait", "Cayman Islands", "Kazakhstan", "Laos", "Lebanon", "St. Lucia", "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania", "Luxembourg", "Latvia", "Libya", "Morocco", "Monaco", "Moldova", "Montenegro", "St. Martin", "Madagascar", "Marshall Islands", "North Macedonia", "Mali", "Myanmar (Burma)", "Mongolia", "Macao", "Northern Mariana Islands", "Martinique", "Mauritania", "Montserrat", "Malta", "Mauritius", "Maldives", "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "New Caledonia", "Niger", "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal", "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru", "French Polynesia", "Papua New Guinea", "Philippines", "Pakistan", "Poland", "St. Pierre & Miquelon", "Pitcairn Islands", "Puerto Rico", "Palestinian Territories", "Portugal", "Palau", "Paraguay", "Qatar", "Réunion", "Romania", "Serbia", "Russia", "Rwanda", "Saudi Arabia", "Solomon Islands", "Seychelles", "Sudan", "Sweden", "Singapore", "St. Helena", "Slovenia", "Svalbard & Jan Mayen", "Slovakia", "Sierra Leone", "San Marino", "Senegal", "Somalia", "Suriname", "South Sudan", "São Tomé & Príncipe", "El Salvador", "Sint Maarten", "Syria", "Eswatini", "Tristan da Cunha", "Turks & Caicos Islands", "Chad", "French Southern Territories", "Togo", "Thailand", "Tajikistan", "Tokelau", "Timor-Leste", "Turkmenistan", "Tunisia", "Tonga", "Turkey", "Trinidad & Tobago", "Tuvalu", "Taiwan", "Tanzania", "Ukraine", "Uganda", "U.S. Outlying Islands", "United States", "Uruguay", "Uzbekistan", "Vatican City", "St. Vincent & Grenadines", "Venezuela", "British Virgin Islands", "U.S. Virgin Islands", "Vietnam", "Vanuatu", "Wallis & Futuna", "Samoa", "Kosovo", "Yemen", "Mayotte", "South Africa", "Zambia", "Zimbabwe"]
        
        static let codes: [String] = ["AC", "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR", "AS", "AT", "AU", "AW", "AX", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BL", "BM", "BN", "BO", "BQ", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN", "CO", "CP", "CR", "CU", "CV", "CW", "CX", "CY", "CZ", "DE", "DG", "DJ", "DK", "DM", "DO", "DZ", "EA", "EC", "EE", "EG", "EH", "ER", "ES", "ET", "FI", "FJ", "FK", "FM", "FO", "FR", "GA", "GB", "GD", "GE", "GF", "GG", "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN", "HR", "HT", "HU", "IC", "ID", "IE", "IL", "IM", "IN", "IO", "IQ", "IR", "IS", "IT", "JE", "JM", "JO", "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI", "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD", "ME", "MF", "MG", "MH", "MK", "ML", "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ", "NA", "NC", "NE", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "PA", "PE", "PF", "PG", "PH", "PK", "PL", "PM", "PN", "PR", "PS", "PT", "PW", "PY", "QA", "RE", "RO", "RS", "RU", "RW", "SA", "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "SS", "ST", "SV", "SX", "SY", "SZ", "TA", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TL", "TM", "TN", "TO", "TR", "TT", "TV", "TW", "TZ", "UA", "UG", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU", "WF", "WS", "XK", "YE", "YT", "ZA", "ZM", "ZW"]
    }
    
    struct USAStates {
        static let names: [String] = ["Alaska", "Alabama", "Arkansas", "American Samoa", "Arizona", "California", "Colorado", "Connecticut", "District of Columbia", "Delaware", "Florida", "Georgia", "Guam", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "North Carolina", "North Dakota", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "Nevada", "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Virginia", "Virgin Islands", "Vermont", "Washington", "Wisconsin", "West Virginia", "Wyoming"]
        
        static let codes: [String] = ["AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "GU", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY"]
    }
    
    struct CountryCodes {
        static let names: [String] = ["+1 (American Samoa)", "+1 (Anguilla)", "+1 (Antigua & Barbuda)", "+1 (Bahamas)", "+1 (Barbados)", "+1 (Bermuda)", "+1 (British Virgin Islands)", "+1 (Canada)", "+1 (Cayman Islands)", "+1 (Dominica)", "+1 (Dominican Republic)", "+1 (Grenada)", "+1 (Guam)", "+1 (Jamaica)", "+1 (Montserrat)", "+1 (Northern Mariana Islands)", "+1 (Puerto Rico)", "+1 (Sint Maarten)", "+1 (St. Kitts & Nevis)", "+1 (St. Lucia)", "+1 (St. Vincent & Grenadines)", "+1 (Trinidad & Tobago)", "+1 (Turks & Caicos Islands)", "+1 (U.S. Virgin Islands)", "+1 (United States)", "+20 (Egypt)", "+211 (South Sudan)", "+212 (Morocco)", "+212 (Western Sahara)", "+213 (Algeria)", "+216 (Tunisia)", "+218 (Libya)", "+220 (Gambia)", "+221 (Senegal)", "+222 (Mauritania)", "+223 (Mali)", "+224 (Guinea)", "+225 (Côte d’Ivoire)", "+226 (Burkina Faso)", "+227 (Niger)", "+228 (Togo)", "+229 (Benin)", "+230 (Mauritius)", "+231 (Liberia)", "+232 (Sierra Leone)", "+233 (Ghana)", "+234 (Nigeria)", "+235 (Chad)", "+236 (Central African Republic)", "+237 (Cameroon)", "+238 (Cape Verde)", "+239 (São Tomé & Príncipe)", "+240 (Equatorial Guinea)", "+241 (Gabon)", "+242 (Congo - Brazzaville)", "+243 (Congo - Kinshasa)", "+244 (Angola)", "+245 (Guinea-Bissau)", "+246 (Chagos Archipelago)", "+247 (Ascension Island)", "+248 (Seychelles)", "+249 (Sudan)", "+250 (Rwanda)", "+251 (Ethiopia)", "+252 (Somalia)", "+253 (Djibouti)", "+254 (Kenya)", "+255 (Tanzania)", "+256 (Uganda)", "+257 (Burundi)", "+258 (Mozambique)", "+260 (Zambia)", "+261 (Madagascar)", "+262 (Mayotte)", "+262 (Réunion)", "+263 (Zimbabwe)", "+264 (Namibia)", "+265 (Malawi)", "+266 (Lesotho)", "+267 (Botswana)", "+268 (Eswatini)", "+269 (Comoros)", "+27 (South Africa)", "+290 (St. Helena)", "+290 (Tristan da Cunha)", "+291 (Eritrea)", "+297 (Aruba)", "+298 (Faroe Islands)", "+299 (Greenland)", "+30 (Greece)", "+31 (Netherlands)", "+32 (Belgium)", "+33 (France)", "+34 (Spain)", "+350 (Gibraltar)", "+351 (Portugal)", "+352 (Luxembourg)", "+353 (Ireland)", "+354 (Iceland)", "+355 (Albania)", "+356 (Malta)", "+357 (Cyprus)", "+358 (Åland Islands)", "+358 (Finland)", "+359 (Bulgaria)", "+36 (Hungary)", "+370 (Lithuania)", "+371 (Latvia)", "+372 (Estonia)", "+373 (Moldova)", "+374 (Armenia)", "+375 (Belarus)", "+376 (Andorra)", "+377 (Monaco)", "+378 (San Marino)", "+380 (Ukraine)", "+381 (Serbia)", "+382 (Montenegro)", "+383 (Kosovo)", "+385 (Croatia)", "+386 (Slovenia)", "+387 (Bosnia & Herzegovina)", "+389 (North Macedonia)", "+39 (Italy)", "+39 (Vatican City)", "+40 (Romania)", "+41 (Switzerland)", "+420 (Czechia)", "+421 (Slovakia)", "+423 (Liechtenstein)", "+43 (Austria)", "+44 (Guernsey)", "+44 (Isle of Man)", "+44 (Jersey)", "+44 (United Kingdom)", "+45 (Denmark)", "+46 (Sweden)", "+47 (Norway)", "+47 (Svalbard & Jan Mayen)", "+48 (Poland)", "+49 (Germany)", "+500 (Falkland Islands)", "+501 (Belize)", "+502 (Guatemala)", "+503 (El Salvador)", "+504 (Honduras)", "+505 (Nicaragua)", "+506 (Costa Rica)", "+507 (Panama)", "+508 (St. Pierre & Miquelon)", "+509 (Haiti)", "+51 (Peru)", "+52 (Mexico)", "+53 (Cuba)", "+54 (Argentina)", "+55 (Brazil)", "+56 (Chile)", "+57 (Colombia)", "+58 (Venezuela)", "+590 (Guadeloupe)", "+590 (St. Barthélemy)", "+590 (St. Martin)", "+591 (Bolivia)", "+592 (Guyana)", "+593 (Ecuador)", "+594 (French Guiana)", "+595 (Paraguay)", "+596 (Martinique)", "+597 (Suriname)", "+598 (Uruguay)", "+599 (Caribbean Netherlands)", "+599 (Curaçao)", "+60 (Malaysia)", "+61 (Australia)", "+61 (Christmas Island)", "+61 (Cocos (Keeling) Islands)", "+62 (Indonesia)", "+63 (Philippines)", "+64 (New Zealand)", "+65 (Singapore)", "+66 (Thailand)", "+670 (Timor-Leste)", "+672 (Norfolk Island)", "+673 (Brunei)", "+674 (Nauru)", "+675 (Papua New Guinea)", "+676 (Tonga)", "+677 (Solomon Islands)", "+678 (Vanuatu)", "+679 (Fiji)", "+680 (Palau)", "+681 (Wallis & Futuna)", "+682 (Cook Islands)", "+683 (Niue)", "+685 (Samoa)", "+686 (Kiribati)", "+687 (New Caledonia)", "+688 (Tuvalu)", "+689 (French Polynesia)", "+690 (Tokelau)", "+691 (Micronesia)", "+692 (Marshall Islands)", "+7 (Kazakhstan)", "+7 (Russia)", "+81 (Japan)", "+82 (South Korea)", "+84 (Vietnam)", "+850 (North Korea)", "+852 (Hong Kong)", "+853 (Macao)", "+855 (Cambodia)", "+856 (Laos)", "+86 (China mainland)", "+880 (Bangladesh)", "+886 (Taiwan)", "+90 (Turkey)", "+91 (India)", "+92 (Pakistan)", "+93 (Afghanistan)", "+94 (Sri Lanka)", "+95 (Myanmar (Burma))", "+960 (Maldives)", "+961 (Lebanon)", "+962 (Jordan)", "+963 (Syria)", "+964 (Iraq)", "+965 (Kuwait)", "+966 (Saudi Arabia)", "+967 (Yemen)", "+968 (Oman)", "+970 (Palestinian Territories)", "+971 (United Arab Emirates)", "+972 (Israel)", "+973 (Bahrain)", "+974 (Qatar)", "+975 (Bhutan)", "+976 (Mongolia)", "+977 (Nepal)", "+98 (Iran)", "+992 (Tajikistan)", "+993 (Turkmenistan)", "+994 (Azerbaijan)", "+995 (Georgia)", "+996 (Kyrgyzstan)", "+998 (Uzbekistan)"]
        
        static let codes: [String] = ["+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+1", "+20", "+211", "+212", "+212", "+213", "+216", "+218", "+220", "+221", "+222", "+223", "+224", "+225", "+226", "+227", "+228", "+229", "+230", "+231", "+232", "+233", "+234", "+235", "+236", "+237", "+238", "+239", "+240", "+241", "+242", "+243", "+244", "+245", "+246", "+247", "+248", "+249", "+250", "+251", "+252", "+253", "+254", "+255", "+256", "+257", "+258", "+260", "+261", "+262", "+262", "+263", "+264", "+265", "+266", "+267", "+268", "+269", "+27", "+290", "+290", "+291", "+297", "+298", "+299", "+30", "+31", "+32", "+33", "+34", "+350", "+351", "+352", "+353", "+354", "+355", "+356", "+357", "+358", "+358", "+359", "+36", "+370", "+371", "+372", "+373", "+374", "+375", "+376", "+377", "+378", "+380", "+381", "+382", "+383", "+385", "+386", "+387", "+389", "+39", "+39", "+40", "+41", "+420", "+421", "+423", "+43", "+44", "+44", "+44", "+44", "+45", "+46", "+47", "+47", "+48", "+49", "+500", "+501", "+502", "+503", "+504", "+505", "+506", "+507", "+508", "+509", "+51", "+52", "+53", "+54", "+55", "+56", "+57", "+58", "+590", "+590", "+590", "+591", "+592", "+593", "+594", "+595", "+596", "+597", "+598", "+599", "+599", "+60", "+61", "+61", "+61", "+62", "+63", "+64", "+65", "+66", "+670", "+672", "+673", "+674", "+675", "+676", "+677", "+678", "+679", "+680", "+681", "+682", "+683", "+685", "+686", "+687", "+688", "+689", "+690", "+691", "+692", "+7", "+7", "+81", "+82", "+84", "+850", "+852", "+853", "+855", "+856", "+86", "+880", "+886", "+90", "+91", "+92", "+93", "+94", "+95", "+960", "+961", "+962", "+963", "+964", "+965", "+966", "+967", "+968", "+970", "+971", "+972", "+973", "+974", "+975", "+976", "+977", "+98", "+992", "+993", "+994", "+995", "+996", "+998"]
    }
}
