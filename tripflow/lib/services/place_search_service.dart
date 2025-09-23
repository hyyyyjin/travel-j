import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSearchResult {
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String category;

  const PlaceSearchResult({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  @override
  String toString() {
    return 'PlaceSearchResult(title: $title, address: $address, lat: $latitude, lng: $longitude)';
  }
}

class PlaceSearchService {
  static const String _baseUrl =
      'https://openapi.naver.com/v1/search/local.json';

  // 실제 사용 시에는 환경변수나 설정 파일에서 관리해야 함
  static const String _clientId = 'YOUR_NAVER_CLIENT_ID';
  static const String _clientSecret = 'YOUR_NAVER_CLIENT_SECRET';

  static Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?query=${Uri.encodeComponent(query)}&display=10&sort=random'),
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;

        return items.map((item) {
          return PlaceSearchResult(
            title: _removeHtmlTags(item['title']),
            address: _removeHtmlTags(item['address']),
            latitude: double.tryParse(item['mapy']) ?? 0.0,
            longitude: double.tryParse(item['mapx']) ?? 0.0,
            category: _removeHtmlTags(item['category']),
          );
        }).toList();
      } else {
        print('네이버 API 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('장소 검색 오류: $e');
      return [];
    }
  }

  static String _removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // 개발/테스트용 더미 데이터
  static Future<List<PlaceSearchResult>> searchPlacesDummy(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // API 호출 시뮬레이션

    final lowerQuery = query.toLowerCase();

    // 도쿄 관련 검색
    if (lowerQuery.contains('스카이트리') || lowerQuery.contains('도쿄')) {
      return [
        const PlaceSearchResult(
          title: '도쿄 스카이트리',
          address: '일본 도쿄도 스미다구 오시아게 1-1-2',
          latitude: 35.7101,
          longitude: 139.8107,
          category: '관광명소',
        ),
        const PlaceSearchResult(
          title: '도쿄 타워',
          address: '일본 도쿄도 미나토구 시바공원 4-2-8',
          latitude: 35.6586,
          longitude: 139.7454,
          category: '관광명소',
        ),
      ];
    }

    // 음식점 관련 검색
    if (lowerQuery.contains('스시') || lowerQuery.contains('초밥')) {
      return [
        const PlaceSearchResult(
          title: '스시집',
          address: '일본 도쿄도 시부야구',
          latitude: 35.6762,
          longitude: 139.6503,
          category: '음식점',
        ),
        const PlaceSearchResult(
          title: '스시로',
          address: '일본 도쿄도 긴자',
          latitude: 35.6716,
          longitude: 139.7650,
          category: '음식점',
        ),
      ];
    }

    // 파리 관련 검색
    if (lowerQuery.contains('에펠탑') || lowerQuery.contains('파리')) {
      return [
        const PlaceSearchResult(
          title: '에펠탑',
          address: '프랑스 파리 7구 샹 드 마르스',
          latitude: 48.8584,
          longitude: 2.2945,
          category: '관광명소',
        ),
        const PlaceSearchResult(
          title: '루브르 박물관',
          address: '프랑스 파리 1구',
          latitude: 48.8606,
          longitude: 2.3376,
          category: '관광명소',
        ),
      ];
    }

    // 서울 관련 검색
    if (lowerQuery.contains('남산') || lowerQuery.contains('서울')) {
      return [
        const PlaceSearchResult(
          title: '남산타워',
          address: '서울특별시 용산구 남산공원길 105',
          latitude: 37.5512,
          longitude: 126.9882,
          category: '관광명소',
        ),
        const PlaceSearchResult(
          title: '경복궁',
          address: '서울특별시 종로구 사직로 161',
          latitude: 37.5796,
          longitude: 126.9770,
          category: '관광명소',
        ),
      ];
    }

    // 호텔 관련 검색
    if (lowerQuery.contains('호텔') || lowerQuery.contains('숙소')) {
      return [
        const PlaceSearchResult(
          title: '그랜드 하얏트 서울',
          address: '서울특별시 용산구 이태원로 322',
          latitude: 37.5347,
          longitude: 126.9947,
          category: '숙박',
        ),
        const PlaceSearchResult(
          title: '롯데호텔 서울',
          address: '서울특별시 중구 을지로 30',
          latitude: 37.5648,
          longitude: 127.0017,
          category: '숙박',
        ),
      ];
    }

    return [];
  }
}
