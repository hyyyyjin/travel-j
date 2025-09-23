# TripFlow 에이전트 운영 매뉴얼 (AGENTS)

본 문서는 TripFlow 레포지토리의 현재 코드 상태를 기준으로, 역할 기반(멀티-에이전트) 협업 방식을 정의합니다. 각 에이전트의 목표, 입력/출력, 작업 범위, 가드레일, 산출물 위치를 명확히 하여 병렬 개발을 가속화합니다.

## 코드베이스 스냅샷 (2025-09-21)
- 런타임/프레임워크: Flutter + Riverpod
- 주요 디렉토리
  - `tripflow/lib/main.dart`: 앱 엔트리 및 라우팅
  - `tripflow/lib/models/`: 도메인 모델 (`plan.dart`, `day_plan.dart`, `schedule_item.dart`)
  - `tripflow/lib/providers/`: 상태관리 (`plan_list_provider.dart`, `repository_providers.dart`)
  - `tripflow/lib/repositories/`: 저장소 인터페이스/구현 (`plan_repository.dart`, `memory_plan_repository.dart`)
  - `tripflow/lib/screens/`: 화면(UI) (`home_screen.dart`, `plan_detail_screen.dart`, `day_schedule_screen.dart`, `edit_place_screen.dart`)
  - `tripflow/lib/services/directions_service.dart`: 길찾기(딥링크) 서비스
- 현재 상태(요약)
  - 홈 → 플랜 상세 → 일일 일정 → 일정 편집 네비게이션 구성 완료
  - 일정 추가/정렬, 예산 표시, 원클릭 길찾기(Naver → Google 앱 → 웹) 동작
  - 상태관리: Riverpod Notifier + 메모리 저장소(추후 Firestore로 대체 예정)

## 현재 구현 상태 (2025-01-21)

### 화면 구조 및 네비게이션
- **HomeScreen** → **PlanDetailScreen** → **DayScheduleScreen** → **EditPlaceScreen**
- 상태관리: Riverpod Notifier + 메모리 저장소
- 주요 위젯: `_ScheduleCard`, `_TravelTimeCard`, `_EditPlaceScreenState`
- 네비게이션: `Navigator.pushNamed` 기반

### 파일별 역할
- `home_screen.dart`: 플랜 목록 표시, 새 플랜 생성, 플랜 수정/삭제 (PopupMenu)
- `plan_detail_screen.dart`: 확장 가능한 날짜별 카드, 일정 목록 표시, 일정 추가/편집/삭제
- `create_plan_screen.dart`: 새 플랜 생성 폼 (제목, 날짜 선택)
- `edit_plan_screen.dart`: 플랜 수정/삭제 폼
- `edit_place_screen.dart`: 일정 추가/편집 폼 (수정 모드 지원)
- `day_schedule_screen.dart`: 선택적 사용 (상세 타임라인 뷰가 필요한 경우)
- `directions_service.dart`: 길찾기 딥링크 (Naver → Google → 웹)

### 주요 위젯 구조 (plan_detail_screen.dart)
- `_PlanDetailScreenState`: `expandedDays` Map으로 펼침/접힘 상태 관리
- `_ExpandableDayCard`: 펼침/접힘 가능한 날짜 카드
- `_DayScheduleList`: 펼쳐진 상태의 일정 목록 (일정 + 이동시간 카드)
- `_ScheduleItemCard`: 개별 일정 카드 (길찾기/편집/삭제 버튼)
- `_TravelTimeCard`: 이동 시간 표시 카드

### 상태관리 기능 (PlanListNotifier)
- `addPlan()`: 새 플랜 생성
- `removePlan()`: 플랜 삭제
- `updatePlan()`: 플랜 수정
- `addScheduleItem()`: 일정 추가
- `updateScheduleItem()`: 일정 수정
- `removeScheduleItem()`: 일정 삭제 (새로 추가)
- `toggleVisited()`: 방문 여부 토글


## 공통 운영 원칙
- 커밋 규칙: Conventional Commits 사용 (예: `feat(app): ...`, `fix(state): ...`, `docs(agents): ...`)
- 브랜치 전략: `main` 보호, 기능별 `feat/*`, 버그픽스 `fix/*`, 문서 `docs/*`
- 코드스타일: `flutter_lints`, `analysis_options.yaml` 준수, 단일 인용부호 선호
- 플랫폼 폴더: VCS 제외. 최초 셋업 시 `cd tripflow && flutter create .`
- 비밀정보: 키/토큰은 커밋 금지. `.env`/런처 스킴 등은 런타임 주입

## 에이전트 정의

### 1) PM 에이전트 (Product Manager)
- 목표: Roadmap/Backlog를 명세와 사용자 가치에 정렬
- 입력: 기획 명세(`README.md`), 사용자 피드백, 데이터
- 출력: 이슈/스토리(수락 기준 포함), 마일스톤, 우선순위
- 가드레일: MVP 범위 엄수, 핵심 가치(원클릭 실행) 우선

### 2) UX 에이전트 (UX/UI Designer)
- 목표: 화면 플로우/컴포넌트 체계화 및 사용성 개선
- 입력: `screens/*` 구조, 기획 명세
- 출력: Figma/프로토타입, UI 스펙(컴포넌트 속성/레이아웃), 접근성 가이드
- 산출물 반영 위치: `tripflow/lib/screens/*`, 테마/컴포넌트 추상화 제안
- 가드레일: 타임라인 가독성, FAB 행동 일관성, 오프라인 대비

### 3) Flutter 앱 에이전트 (App/UI)
- 목표: 화면/네비게이션/위젯 구현과 다듬기
- 입력: UX 스펙, 상태/리포지토리 계약
- 출력: 화면/위젯 구현, 라우팅, 폼 검증, 애니메이션(필요 시)
- 주요 경로: `tripflow/lib/screens/*`, `tripflow/lib/main.dart`
- 가드레일: 불필요한 상태 보관 금지, 위젯 트리 단순화, 긴 라인 분리

### 4) 상태관리 에이전트 (State/Riverpod)
- 목표: 도메인 로직, 불변 업데이트, 파생 상태 구성
- 입력: 도메인 모델, UI 요구사항
- 출력: Provider/Notifier, 업데이트 함수(정렬/검증 포함)
- 주요 경로: `tripflow/lib/providers/*`
- 현 구현
  - `PlanListNotifier`: 플랜 CRUD, 일정 추가/정렬, 방문여부 토글 API 준비
- 가드레일: 사이드이펙트 격리, 예외/에러 전파 정책 정의, 메모리 저장소와 계약 일치

### 5) 데이터 에이전트 (Repository/Firestore)
- 목표: 메모리 저장소를 Firestore로 대체, 오프라인/동기화 지원
- 입력: `PlanRepository` 인터페이스, 모델
- 출력: `FirestorePlanRepository`, DTO/Converter, 에러/리트라이 정책
- 주요 경로: `tripflow/lib/repositories/*`
- 가드레일: 스키마 버저닝, 보안 규칙, 인덱스 설계, 네트워크 비용 최소화

### 6) 지도/딥링크 에이전트 (Maps/Deep Link)
- 목표: 목적지 탐색 UX 최적화 및 이동시간 산출
- 입력: 장소(lat/lng), 사용국가/플랫폼 컨텍스트(가능 시)
- 출력: 네이티브 스킴 우선(Naver → Google) + 웹 폴백, 이동시간 계산 API 통합
- 주요 경로: `tripflow/lib/services/directions_service.dart`, `day_schedule_screen.dart`
- 가드레일: 설치 앱 감지, 실패 폴백 보장, URL 인코딩/국가별 스킴 차이 대응

### 7) 알림 에이전트 (Push/Local Notifications)
- 목표: 일정 시작 전 알림(예: 15분 전)
- 입력: 일정 타임스탬프, 사용자 설정
- 출력: 로컬/푸시 알림 스케줄링, 클릭 시 해당 일정으로 딥링크
- 제안: `flutter_local_notifications`(로컬) → `Firebase Messaging`(원격) 단계적 적용
- 가드레일: Doze/배터리 최적화, 타임존, 재부팅 후 복원

### 8) 웹 뷰어 에이전트 (Read-only 공유)
- 목표: 로그인 없이 플랜을 읽기 전용으로 공유
- 입력: 플랜 스냅샷/토큰
- 출력: 공유 URL, SSR/SEO(선택), 인쇄/PDF 최적화
- 구현 옵션: Flutter Web 또는 별도 웹(Next.js) + Firestore 읽기 권한 토큰화

### 9) QA 에이전트 (Quality)
- 목표: 회귀 방지, 핵심 흐름 보증
- 입력: 수락 기준, 테스트 대상 목록
- 출력: 체크리스트, 통합/위젯/골든 테스트, 수동 테스트 매트릭스(디바이스/OS)
- 가드레일: 핵심 플로우(추가→길찾기) 스모크 테스트 상시 녹색 유지

### 10) DevOps 에이전트 (CI/CD/릴리즈)
- 목표: 일관된 빌드/테스트/배포 파이프라인
- 입력: 프로젝트 스크립트, 스토어 자격증명
- 출력: GitHub Actions 워크플로, 스토어 업로드, 크래시/로그 수집
- 가드레일: 시크릿 분리, 캐시/빌드 시간 최적화, 아티팩트 보존

## 백로그 맵 (Spec ↔ Agent)
1. 이동시간 자동 계산 (Spec 2-2)
   - Maps/딥링크: API 선택/통합
   - 상태관리: 이동구간 모델링, 에러/로딩 상태
   - UI: 타임라인의 이동 위젯에 값 표시/스켈레톤
   - 수락 기준: 동일 도시 내 직전-다음 일정 간 도보/대중교통 시간 표시
2. 방문여부 기록/여행 타임라인 생성 (Spec 3-3)
   - 상태관리: `visited` 토글 반영 및 여행 기록 생성 로직
   - UI: 체크박스/필터, 완료 후 기록 화면/공유
3. 푸시 알림 (Spec 3-1)
   - 알림: 로컬 → FCM 전환, 알림 탭/권한/딥링크
4. 읽기 전용 공유 웹 (Spec 1-2, 로드맵 2단계)
   - 웹 뷰어: 토큰 기반 공개 링크, 프린팅 최적화
5. 장소 입력 개선 (Spec 2-1)
   - Places 자동완성, 지오코딩으로 lat/lng 저장
6. 예산 관리 (Spec 2-3)
   - 합계/일별 통계, 통화/서식, 내보내기
7. 템플릿 (Spec 1-3)
   - 관리자 템플릿 CRUD, 복제로 플랜 시작

## 수락 기준 템플릿 (예시)
- 사용자 스토리: “사용자로서 일정 사이 이동 시간을 보고 싶다.”
- 완료 조건
  - 이전/다음 일정 간 이동 시간/모드 표시
  - 네트워크 실패 시 재시도/폴백 문구 표시
  - 단위 테스트(계산/정렬), 위젯 테스트(렌더)

## 작업 위치/계약 요약
- 모델: `tripflow/lib/models/*`
- 상태: `tripflow/lib/providers/*`
- 데이터: `tripflow/lib/repositories/*`
- UI: `tripflow/lib/screens/*`
- 서비스: `tripflow/lib/services/*`

## 개발/실행 명령 (요약)
- 최초 셋업: `cd tripflow && flutter create . && flutter pub get`
- 실행: `flutter run -d <device>`
- 분석/포맷/테스트: `flutter analyze`, `flutter format .`, `flutter test`

## 가드레일 요약
- 실패 폴백 보장(딥링크/네트워크)
- PII/키 비노출, 플랫폼 폴더 비커밋
- 긴 함수/위젯 분리, 의미 있는 네이밍
- Conventional Commits + 작은 PR, 테스트 동반
