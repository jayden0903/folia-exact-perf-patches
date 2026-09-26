# folia-exact-perf-patches

Folia 26.2에 얹어 쓰는 성능 패치 세 개입니다.

몹 AI나 농장, 전투가 싱글플레이와 똑같이 돌아야 하는 서버라서, 활성 범위를 줄이거나 AI를 건너뛰는 식의 최적화는 쓸 수 없었습니다.
그래서 결과는 그대로 두고 같은 계산을 덜 하는 것만 골랐습니다.

- `0001-exact-default-block-predicates`: 블록 상태의 기본 판정(충돌, 빛 가림 같은 것) 중 계산이 순수한 것만 한 번 계산해서 캐시합니다.
- `0002-bounded-parallel-nearest-entities`: 몹 주변 "가까운 엔티티" 목록이 클 때만 제한된 스레드 풀로 거리순 정렬을 나눠 합니다.
  거리가 같을 때 순서까지 원래와 똑같이 맞췄습니다. 기본은 꺼져 있고 `-Dexactperf.parallel-sensors=true`로 켭니다.
- `0003-exact-player-query-and-empty-effects`: "가장 가까운 플레이어"를 찾을 때 조건을 만족할 수 없는 후보를 원래 비교 순서를 지키며
  먼저 거릅니다. 블록 안에 들어간 엔티티에 쌓을 효과가 없으면 빈 배열 처리를 건너뜁니다. `-Dexactperf.nearest-player-pruning=false`로 끌 수 있습니다.

## 빌드

```bash
./build.sh /absolute/path/to/new-dir
```

Folia `68b2af1`(바꾸려면 `FOLIA_COMMIT`)을 받아 Paper 패치를 적용하고, 이 패치들을 `folia-server/src/minecraft/java`에 적용한 뒤
paperclip JAR를 만듭니다. JDK 25와 네트워크가 필요합니다.

패치 전후로 같은 조건의 테스트 서버에서 몹 AI, 레드스톤·호퍼·주민·철 농장, 발사체와 PvP가 똑같이 동작하는지 비교했습니다.
함수 단위로 빨라진 건 확인했지만 그게 곧 서버 전체 TPS 향상은 아니라서 숫자는 따로 적지 않았습니다.
다른 버전에서 `git apply --check`가 실패하면 억지로 넣지 말고, 원본 코드 의미가 같은지부터 다시 봐 주세요.

## English

Three Folia 26.2 patches that keep game results identical while doing less work: cached pure default block predicates,
an opt-in bounded parallel sort for large nearest-entity lists (tie order preserved), and exact pruning for nearest-player
queries plus skipping empty inside-block effect flushes. GPL-3.0, like Folia and Paper.
