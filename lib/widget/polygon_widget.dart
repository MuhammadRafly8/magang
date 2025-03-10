import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

List<Polygon> getPolygons() {
  return [
    // Polygon ke 1
                Polygon(
                  points: [
                    const LatLng(-6.828415, 112.982696),
                    const LatLng(-6.877396, 112.982696),
                    const LatLng(-6.877526, 112.931058),
                    const LatLng(-6.828415, 112.931058),
                    const LatLng(-6.828415, 112.982696),
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                // Polygon ke 2
                Polygon(
                  points: [
                    const LatLng(-6.412635, 112.916869),
                    const LatLng(-6.444161, 112.919647),
                    const LatLng(-6.444192, 112.911409),
                    const LatLng(-6.455784, 112.9137),
                    const LatLng(-6.455732, 112.927599),
                    const LatLng(-6.487478, 112.927599),
                    const LatLng(-6.487478, 112.900571),
                    const LatLng(-6.488425, 112.898826),
                    const LatLng(-6.489918, 112.894022),
                    const LatLng(-6.492847, 112.876109),
                    const LatLng(-6.50522, 112.876109),
                    const LatLng(-6.50522, 112.894403),
                    const LatLng(-6.536795, 112.894403),
                    const LatLng(-6.536839, 112.882658),
                    const LatLng(-6.536878, 112.872351),
                    const LatLng(-6.536913, 112.862655),
                    const LatLng(-6.50784, 112.862655),
                    const LatLng(-6.500419, 112.860917),
                    const LatLng(-6.500419, 112.84431),
                    const LatLng(-6.468415, 112.84431),
                    const LatLng(-6.468415, 112.875992),
                    const LatLng(-6.483692, 112.875992),
                    const LatLng(-6.481075, 112.892091),
                    const LatLng(-6.479647, 112.896053),
                    const LatLng(-6.455851, 112.895964),
                    const LatLng(-6.455819, 112.904494),
                    const LatLng(-6.444227, 112.902203),
                    const LatLng(-6.444279, 112.888014),
                    const LatLng(-6.412635, 112.888014),
                    const LatLng(-6.412635, 112.916869),
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
          Polygon(
                  points: [
                    const LatLng(-6.536839,112.882658), //13
                    const LatLng(-6.625594,112.914924), //14
                    const LatLng(-6.642428, 112.907465) ,//144
                    const LatLng(-6.567989, 112.882739) , //145
                    const LatLng(-6.55938, 112.879866) , //81
                    const LatLng(-6.536878,112.872351), //82
                    const LatLng(-6.536839,112.882658), //13
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.625594,112.914924),//14
                    const LatLng(-6.607979,112.914856),
                    const LatLng(-6.607979,112.946501),
                    const LatLng(-6.639499,112.946501),
                    const LatLng(-6.645262,112.951293),
                    const LatLng(-6.676905,112.951293),
                    const LatLng(-6.676905,112.936018),
                    const LatLng(-6.678438,112.926019), //26
                    const LatLng(-6.701719,112.911401), //27
                    const LatLng(-6.721404,112.911401), //28
                    const LatLng(-6.721494,112.888267), //29
                    const LatLng(-6.713304,112.882671), //116
                    const LatLng(-6.713304,112.869402),
                    const LatLng(-6.681659,112.869402), //118
                    const LatLng(-6.681659,112.894337),
                    const LatLng(-6.670141,112.894337),
                    const LatLng(-6.670108,112.90281),
                    const LatLng(-6.664518,112.902788), //122
                    const LatLng(-6.655219, 112.902753), //142
                    const LatLng(-6.642446, 112.902703), // 143
                    const LatLng(-6.642428, 112.907465), // 144
                    const LatLng(-6.625594,112.914924),//14
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.826906,113.040529),
                    const LatLng(-6.826906,113.061993),
                    const LatLng(-6.85859,113.061993),
                    const LatLng(-6.85859,113.030341),
                    const LatLng(-6.828114,113.030341),
                    const LatLng(-6.826906,113.040529),
                  ],
                  color: Colors.blue,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue.withOpacity(0.2),
                ),
                Polygon(
                  points: [
                    const LatLng(-6.676905,112.936018), //20
                    const LatLng(-6.826906,113.040529), //21
                    const LatLng(-6.828114, 113.030341),
                    const LatLng(-6.678438,112.926019), //26
                    const LatLng(-6.676905,112.936018), //20
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.721494,112.888267), //29
                    const LatLng(-6.867736,112.801153),//part 6
                    const LatLng(-6.874153,112.793874),
                    const LatLng(-6.885337,112.776754),
                    const LatLng(-6.915723,112.7371),
                    const LatLng(-6.921693,112.73204),
                    const LatLng(-6.932077,112.728345),
                    const LatLng(-6.949531,112.726349),
                    const LatLng(-6.980208,112.71351),
                    const LatLng(-6.999522,112.698295),
                    const LatLng(-7.006999,112.690313),
                    const LatLng(-7.011753,112.687268),
                    const LatLng(-7.044181,112.673664),
                    const LatLng(-7.059346,112.670243),
                    const LatLng(-7.071968,112.670263), //43
                    const LatLng(-7.092007,112.667616),
                    const LatLng(-7.10881,112.670841),
                    const LatLng(-7.121279,112.679911),
                    const LatLng(-7.128217,112.681537),
                    const LatLng(-7.140631,112.681277),
                    const LatLng(-7.147863,112.679012),
                    const LatLng(-7.155881,112.679269), 
                    const LatLng(-7.173373,112.669881),
                    const LatLng(-7.16801,112.662592), // 52 
                    const LatLng(-7.16151,112.667385),//97
                    const LatLng(-7.139145,112.672478),//98  
                    const LatLng(-7.129072,112.672492),
                    const LatLng(-7.125015,112.671562),
                    const LatLng(-7.112481,112.662443),
                    const LatLng(-7.092189,112.658507),
                    const LatLng(-7.071383,112.661221),
                    const LatLng(-7.067351,112.66122),
                    const LatLng(-7.034241,112.667055),
                    const LatLng(-7.015417,112.675933),
                    const LatLng(-6.993393,112.691624),
                    const LatLng(-6.975586,112.705691),
                    const LatLng(-6.947251,112.717545),
                    const LatLng(-6.940674,112.718291),
                    const LatLng(-6.911774,112.728659),
                    const LatLng(-6.909069,112.730938),
                    const LatLng(-6.877956,112.771523),
                    const LatLng(-6.866937,112.788404),
                    const LatLng(-6.861911,112.794159),
                    const LatLng(-6.713304,112.882671), //116
                    const LatLng(-6.721494,112.888267), //29
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),

                // Polygon kedua
                Polygon(
                  points: [
                    const LatLng(-7.16801, 112.662592), //part 6.5
                    const LatLng(-7.131421, 112.648949),
                    const LatLng(-7.106253, 112.64744),
                    const LatLng(-7.086429, 112.646869),
                    const LatLng(-7.039473, 112.655268),
                    const LatLng(-7.012645, 112.663982),
                    const LatLng(-6.887931, 112.714591),
                    const LatLng(-6.876458, 112.714879),
                    const LatLng(-6.837363, 112.715086),
                    const LatLng(-6.76502, 112.715295),
                    const LatLng(-6.760491, 112.715777),
                    const LatLng(-6.755682, 112.717644),
                    const LatLng(-6.750766, 112.721094),
                    const LatLng(-6.661401, 112.80822),     
                    const LatLng(-6.666542, 112.815833),     
                    const LatLng(-6.756611, 112.728013),    
                    const LatLng(-6.759986, 112.725636),    
                    const LatLng(-6.762547, 112.724629),    
                    const LatLng(-6.765417, 112.724337),     
                    const LatLng(-6.837395, 112.724132),     
                    const LatLng(-6.837406, 112.724132),     
                    const LatLng(-6.87655, 112.723927),     
                    const LatLng(-6.889789, 112.723521),    
                    const LatLng(-7.015744, 112.672487),
                    const LatLng(-7.033741, 112.665508),   
                    const LatLng(-7.041674, 112.664058),     
                    const LatLng(-7.087095, 112.65592),     
                    const LatLng(-7.133585, 112.658148),    
                    const LatLng(-7.14675, 112.662503),
                    const LatLng(-7.16151,112.667385),    
                    const LatLng(-7.16801, 112.662592),
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                Polygon(
                  points: [
                   const LatLng(-6.661401,112.80822), // part 7
                    const LatLng(-6.644327,112.808157),// 66
                    const LatLng(-6.608956,112.756866),
                    const LatLng(-6.608956,112.726),
                    const LatLng(-6.574517,112.726),
                    const LatLng(-6.574517,112.764775),
                    const LatLng(-6.603427,112.764775),
                    const LatLng(-6.626139,112.797711),
                    const LatLng(-6.607776,112.797644),
                    const LatLng(-6.569115,112.807314),
                    const LatLng(-6.542615,112.814755),
                    const LatLng(-6.542615,112.846397),
                    const LatLng(-6.555991,112.846447),
                    const LatLng(-6.559076,112.862333),
                    const LatLng(-6.560042,112.867584),
                    const LatLng(-6.560286,112.873725),//80
                    const LatLng(-6.55938,112.879866), //81  
                    const LatLng(-6.567989, 112.882739) , //145  
                    const LatLng(-6.569085,112.876862),
                    const LatLng(-6.569375,112.871655),
                    const LatLng(-6.569049,112.866734),
                    const LatLng(-6.567953,112.860616),
                    const LatLng(-6.565208,112.846481),
                    const LatLng(-6.626459,112.831455), //151
                    const LatLng(-6.626459,112.875547),//140
                    const LatLng(-6.653259,112.875649),
                    const LatLng(-6.655219,112.902753),
                    const LatLng(-6.664518,112.902788), //122
                    const LatLng(-6.660094,112.840824),
                    const LatLng(-6.666449,112.840848),
                    const LatLng(-6.666542,112.815833), //125
                    const LatLng(-6.661401,112.80822), //65
                  ],
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.blue,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.653704,112.923557), //area terlarang 1
                    const LatLng(-6.665721,112.923557),
                    const LatLng(-6.665721,112.914049),
                    const LatLng(-6.653704,112.914049),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.69044,112.905684), //area terlarang 2
                    const LatLng(-6.681364,112.905684),
                    const LatLng(-6.681364,112.914762),
                    const LatLng(-6.69044,112.914762),
                                      ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.701959,112.880748), //area terlarang 3
                      const LatLng(-6.710181,112.880748),
                      const LatLng(-6.710181,112.889826),
                      const LatLng(-6.701959,112.889826),
                      const LatLng(-6.692883,112.880748),
                      const LatLng(-6.692883,112.889826),
                      const LatLng(-6.701959,112.889826),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.710181,112.891051), //area terlarang 4
                      const LatLng(-6.701105,112.891051),
                      const LatLng(-6.701105,112.900129),
                      const LatLng(-6.710181,112.900129),
                      const LatLng(-6.701105,112.891051),
                      const LatLng(-6.701105,112.900129),
                      const LatLng(-6.710181,112.900129),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.839671,112.951455), //area terlarang 5
                      const LatLng(-6.839671,112.960184),
                      const LatLng(-6.847851,112.951455),
                      const LatLng(-6.847851,112.960184),
                      const LatLng(-6.853617,112.960184),
                      const LatLng(-6.853617,112.969002),
                      const LatLng(-6.857111,112.969017),
                      const LatLng(-6.857101,112.971473),
                      const LatLng(-6.866179,112.971473),
                      const LatLng(-6.866179,112.962413),
                      const LatLng(-6.860767,112.962413),
                      const LatLng(-6.860767,112.952383),
                      const LatLng(-6.864447,112.952398),
                      const LatLng(-6.864447,112.943231),
                      const LatLng(-6.853645,112.943231),
                      const LatLng(-6.853645,112.949198),
                      const LatLng(-6.848712,112.949198),
                      const LatLng(-6.848712,112.94241),
                      const LatLng(-6.839671,112.94241),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.847242,113.041691), //area terlarang 6
                    const LatLng(-6.847242,113.050774),
                    const LatLng(-6.856319,113.050774),
                    const LatLng(-6.856319,113.041691),
                    const LatLng(-6.838163,113.041691),
                    const LatLng(-6.838163,113.050774),
                    const LatLng(-6.847242,113.050774),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.619201,112.926202), //area terlarang 7
                    const LatLng(-6.619201,112.935278),
                    const LatLng(-6.628277,112.935278),
                    const LatLng(-6.628277,112.926202),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.637687,112.855245), //area terlarang 8
                      const LatLng(-6.637687,112.864321),
                      const LatLng(-6.646762,112.864321),
                      const LatLng(-6.646762,112.855245),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.655223,112.829502), //area terlarang 9
                      const LatLng(-6.655223,112.819467),
                      const LatLng(-6.646031,112.819467),
                      const LatLng(-6.646031,112.829502),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.628079,112.808988), //area terlarang 10
                      const LatLng(-6.619004,112.808988),
                      const LatLng(-6.619004,112.818063),
                      const LatLng(-6.628079,112.818063),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                      const LatLng(-6.603411,112.8104), //area terlarang 11
                      const LatLng(-6.603411,112.819475),
                      const LatLng(-6.612485,112.819475),
                      const LatLng(-6.612485,112.8104),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.589418,112.818656), //area terlarang 13
                    const LatLng(-6.580343,112.818656),
                    const LatLng(-6.580343,112.827731),
                    const LatLng(-6.589418,112.827731),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.553876,112.82613), //area terlarang 14
                    const LatLng(-6.553876,112.835138),
                    const LatLng(-6.562884,112.835138),
                    const LatLng(-6.562884,112.82613),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.52557,112.873987), //area terlarang 15
                    const LatLng(-6.516495,112.873987),
                    const LatLng(-6.516495,112.88306),
                    const LatLng(-6.52557,112.88306),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.489076,112.864768), //area terlarang 16
                    const LatLng(-6.489076,112.85565),
                    const LatLng(-6.479642,112.85565),
                    const LatLng(-6.479642,112.864768),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.476151,112.907305), //area terlarang 17
                    const LatLng(-6.46711	,112.907305),
                    const LatLng(-6.46711,112.916378),
                    const LatLng(-6.476151,112.916378),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.423861,112.899354), //area terlarang 18
                    const LatLng(-6.423861,112.908425),
                    const LatLng(-6.432936,112.908425),
                    const LatLng(-6.432936,112.899354),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
                Polygon(
                  points: [
                    const LatLng(-6.656607,112.930993), //area terlarang 19
                    const LatLng(-6.656607,112.94007),
                    const LatLng(-6.665683,112.940070),
                    const LatLng(-6.665683,112.930993),
                    const LatLng(-6.656607,112.94007),
                    const LatLng(-6.665683,112.940070),
                    const LatLng(-6.665683,112.930993),
                  ],
                  color: Colors.red,
                  borderStrokeWidth: 3.0,
                  borderColor: Colors.red,
                ),
  ];
}